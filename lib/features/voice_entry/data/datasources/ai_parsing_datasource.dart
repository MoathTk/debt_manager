/// VOICE ENTRY FEATURE — DATA LAYER: AI PARSING DATASOURCE
///
/// Handles communication with OpenAI API to parse
/// voice transcripts into structured debt data.
///
/// WHY THIS EXISTS:
/// - The domain layer defines WHAT to parse (repository interface)
/// - This datasource defines HOW to parse (OpenAI API)
/// - Separation allows swapping AI providers without touching domain code
/// ---------------------------------------------------------------------------
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/voice_parsed_debt.dart';
import '../../domain/exceptions/voice_entry_exception.dart';
import '../../../voice_command/domain/entities/voice_command.dart';

class AiParsingDatasource {
  final String apiKey;
  final http.Client _client;

  static const _parseModel = 'gpt-4o-mini';
  static const _transcribeModel = 'gpt-transcribe';

  AiParsingDatasource({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  Future<String> transcribeAudio(String filePath) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/audio/transcriptions');
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['model'] = _transcribeModel
        ..fields['language'] = 'ar'
        ..fields['prompt'] =
            'Arabic speech, Iraqi dialect. Retail shop items and amounts in IQD.';
      request.files.add(
        await http.MultipartFile.fromPath('file', filePath),
      );

      final streamed = await _client.send(request).timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw AiParsingException(
          'Transcription failed (${response.statusCode}): ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final text = data['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw const AiParsingException('Empty transcription result');
      }
      return text.trim();
    } on AiParsingException {
      rethrow;
    } catch (e) {
      throw AiParsingException('Failed to transcribe audio', e);
    }
  }

  Future<VoiceParsedDebt> parse(String transcript) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final prompt = _buildPrompt(today, transcript);
    final body = _buildBody(prompt);

    return await _callModel(body);
  }

  Future<VoiceParsedDebt> _callModel(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw AiParsingException(
          'API returned status ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content == null) {
        throw const AiParsingException('Invalid API response format');
      }

      return _parseResponse(content);
    } on AiParsingException {
      rethrow;
    } catch (e) {
      throw AiParsingException('Failed to communicate with AI service', e);
    }
  }

  Map<String, dynamic> _buildBody(String prompt) => {
    'model': _parseModel,
    'messages': [
      {
        'role': 'system',
        'content':
            'You are an expert Iraqi accounting AI for a retail shopkeeper app. '
            'You extract items, amounts in Iraqi Dinars (IQD), and due dates from voice transcripts. '
            'You ALWAYS respond with raw JSON only — no markdown, no codeblocks, no extra text.',
      },
      {'role': 'user', 'content': prompt},
    ],
    'response_format': {'type': 'json_object'},
    'temperature': 0.1,
    'max_tokens': 500,
  };

  /// Parse the OpenAI response text into a [VoiceParsedDebt].
  VoiceParsedDebt _parseResponse(String content) {
    try {
      final jsonStr = _extractJson(content);
      final data = jsonDecode(jsonStr);

      final items = (data['items'] as List?)?.map((item) {
        return VoiceParsedItem(
          name: (item['name'] as String?)?.trim() ?? 'Unknown',
          amount: _parseAmount(item['amount']),
        );
      }).toList();

      if (items == null || items.isEmpty) {
        throw const AiParsingException('No items found in transcript');
      }

      final totalAmount = items.fold(0.0, (sum, i) => sum + i.amount);

      DateTime? dueDate;
      if (data['due_date'] != null && data['due_date'] is String) {
        dueDate = DateTime.tryParse(data['due_date']);
      }

      return VoiceParsedDebt(
        items: items,
        totalAmount: totalAmount,
        dueDate: dueDate,
      );
    } catch (e) {
      if (e is AiParsingException) rethrow;
      throw AiParsingException('Failed to parse AI response', e);
    }
  }

  /// Extract JSON from content that may be wrapped in markdown code blocks.
  String _extractJson(String content) {
    final codeBlockRegex = RegExp(
      r'```(?:json)?\s*\n?(.*?)\n?\s*```',
      dotAll: true,
    );
    final match = codeBlockRegex.firstMatch(content);
    if (match != null) return match.group(1)!.trim();

    final jsonRegex = RegExp(r'\{.*\}', dotAll: true);
    final jsonMatch = jsonRegex.firstMatch(content);
    if (jsonMatch != null) return jsonMatch.group(0)!;

    throw const AiParsingException('No valid JSON found in AI response');
  }

  /// Safely parse a numeric amount from the AI response.
  double _parseAmount(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _buildPrompt(String today, String transcript) =>
      '''
Extract items, amounts in Iraqi Dinars (IQD), and due dates from the transcript below.

STRICT RULES:
1. OUTPUT FORMAT: Return ONLY raw JSON without markdown syntax, codeblocks, or extra text.

2. STUTTERING vs MERGING DUPLICATES (CRITICAL): 
   - STT GLITCHES: If exact words, items, or prices are repeated back-to-back (e.g., "طحين طحين", or "لحم ب 22 لحم ب 22"), treat it as a microphone stutter. KEEP ONLY ONE and DO NOT sum the amounts.
   - GENUINE MERGING: Only combine items and sum amounts if they are clearly mentioned as separate entries later in the sentence.

3. IRAQI DIALECT NUMBERS & SHORTHAND:
   - Convert spoken numbers to full IQD amounts:
     * "بعشرة" / "10" / "عشرة" -> 10000
     * "خمسة وثلاثين" -> 35000
     * "ألفين ونص" / "2.5" -> 2500
     * "ربع" -> 500 | "نص" -> 500 (if alone) | "ثلاث أرباع" -> 750
     * "شدة" (if used in electronic/big shops) -> 100 USD or equivalent, but default explicitly to IQD when context implies dinars.
   - If exact hundreds are mentioned ("500", "750", "1500"), keep as absolute IQD.

4. HANDLE QUANTITIES:
   - If speaker says "3 كواني طحين ب 45", set name as "طحين (3 كواني)" and amount as 45000.

5. PAYMENT vs DEBT (CRITICAL):
   - This prompt is strictly for RECORDING DEBT (إضافة دين).
   - Ignore payment terms like "وافي", "سدد", "رجعلي", "انطاني من الدين". 

6. CLEANING TEXT & GLITCHES:
   - Strip greetings and Iraqi fillers: "رحمة لأبيك", "والله", "عيني", "أغاتي", "حبيبي", "سجل يمعود".
   - Strip customer references: "على أبو شهاب", "حساب أحمد".
   - Ignore standalone stuttered numbers that don't make sense in context.

7. DUE DATE CALCULATION:
   - Relative to TODAY ($today).
   - "باجر" -> +1 day | "عقبه / عقب باجر" -> +2 days | "نهاية الشهر" -> last day of current month.

JSON FORMAT:
{
  "items": [{"name": "item_name", "amount": 10000}],
  "total_amount": 10000,
  "due_date": "YYYY-MM-DD" or null
}

EXAMPLES:

Transcript: "والله سجل على ابو جاسم 3 كواني طحين ب 45 و كارتين آسيا ب 20 عقب باجر ينطيها"
{"items": [{"name": "طحين (3 كواني)", "amount": 45000}, {"name": "كارت آسيا (2)", "amount": 20000}], "total_amount": 65000, "due_date": "2026-08-25"}

Transcript: "سجل سجل عيني كيلو لحم لحم ب 22 ب 22 وخمسة وثلاثين رصيد"
{"items": [{"name": "لحم (1 كيلو)", "amount": 22000}, {"name": "رصيد", "amount": 35000}], "total_amount": 57000, "due_date": null}

Transcript: "عيني كيلوين طماطة ب ألفين ونص وربع كيلو خيار ب 500"
{"items": [{"name": "طماطة (2 كيلو)", "amount": 2500}, {"name": "خيار (ربع كيلو)", "amount": 500}], "total_amount": 3000, "due_date": null}

Transcript: $transcript
''';

  // ---------------------------------------------------------------------------
  // VOICE COMMAND PARSING (used by Voice Command feature)
  // ---------------------------------------------------------------------------

  Future<VoiceCommand> parseVoiceCommand(String transcript) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final prompt = _buildCommandPrompt(today, transcript);
      final body = {
        'model': _parseModel,
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an Iraqi retail shopkeeper AI. '
                'You detect what ACTION the user wants to perform from a voice command, '
                'and extract relevant details (customer name, items, amounts). '
                'You ALWAYS respond with raw JSON only — no markdown, no codeblocks.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'response_format': {'type': 'json_object'},
        'temperature': 0.1,
        'max_tokens': 500,
      };

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw AiParsingException(
          'API returned status ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'] as String?;
      if (content == null) {
        throw const AiParsingException('Invalid API response format');
      }

      return _parseVoiceCommandResponse(content, transcript);
    } on AiParsingException {
      rethrow;
    } catch (e) {
      throw AiParsingException('Failed to parse voice command', e);
    }
  }

  VoiceCommand _parseVoiceCommandResponse(
    String content,
    String transcript,
  ) {
    try {
      final jsonStr = _extractJson(content);
      final data = jsonDecode(jsonStr);

      final actionStr = (data['action'] as String?)?.toLowerCase().trim();
      final action = _resolveAction(actionStr);

      final customerName =
          (data['customer_name'] as String?)?.trim() ?? '';

      final items = (data['items'] as List?)?.map((item) {
        return VoiceCommandItem(
          name: (item['name'] as String?)?.trim() ?? 'Unknown',
          amount: _parseAmount(item['amount']),
        );
      }).toList();

      final totalAmount = (data['total_amount'] != null)
          ? _parseAmount(data['total_amount'])
          : (items ?? []).fold(0.0, (sum, i) => sum + i.amount);

      DateTime? dueDate;
      if (data['due_date'] != null && data['due_date'] is String) {
        dueDate = DateTime.tryParse(data['due_date']);
      }

      final note = data['note']?.toString().trim();
      final phone = data['phone']?.toString().trim();

      return VoiceCommand(
        action: action,
        customerName: customerName,
        phone: phone,
        items: items ?? [],
        totalAmount: totalAmount,
        dueDate: dueDate,
        note: note,
        transcript: transcript,
      );
    } catch (e) {
      if (e is AiParsingException) rethrow;
      throw AiParsingException('Failed to parse AI command response', e);
    }
  }

  VoiceAction _resolveAction(String? actionStr) {
    switch (actionStr) {
      case 'add_debt':
      case 'add debt':
      case 'record_debt':
      case 'record debt':
        return VoiceAction.addDebt;
      case 'find_customer':
      case 'find customer':
      case 'search_customer':
      case 'search customer':
      case 'lookup_customer':
      case 'lookup customer':
      case 'show_customer':
      case 'show customer':
      case 'view_customer':
      case 'view customer':
      case 'view_balance':
      case 'view balance':
      case 'check_balance':
      case 'check balance':
        return VoiceAction.viewBalance;
      case 'record_payment':
      case 'record payment':
      case 'pay_debt':
      case 'pay debt':
      case 'make_payment':
      case 'make payment':
        return VoiceAction.recordPayment;
      case 'add_customer':
      case 'add customer':
      case 'create_customer':
      case 'create customer':
      case 'new_customer':
      case 'new customer':
      case 'register_customer':
      case 'register customer':
        return VoiceAction.addCustomer;
      case 'delete_debt':
      case 'delete debt':
      case 'cancel_debt':
      case 'cancel debt':
      case 'remove_debt':
      case 'remove debt':
      case 'erase_debt':
      case 'erase debt':
        return VoiceAction.deleteDebt;
      case 'view_history':
      case 'view history':
      case 'show_history':
      case 'show history':
      case 'transaction_history':
      case 'transaction history':
        return VoiceAction.viewHistory;
      default:
        return VoiceAction.unknown;
    }
  }

  String _buildCommandPrompt(String today, String transcript) =>
      '''
Analyze the voice command below and determine what action the user wants.

POSSIBLE ACTIONS:
1. "add_debt" — user wants to record a debt/sale for a customer
   Examples: "سجّل على أحمد 3 طحين ب 45", "أضف دين لابو حسين"

2. "view_balance" — user wants to look up or view a customer's balance/debts
   Examples: "وين أحمد", "拔ابو شهاب", "شكد علي أحمد", "كم عليّ أبو حسين", "give me Ahmed's debts", "أحمد وينه"

3. "record_payment" — user wants to record a payment from a customer (paying off debt)
   Examples: "سدد لأحمد 5000", "ادفع لابو حسين 10 آلاف", "دفع أحمد 20", "أحمد دفع 5000", "رجعلي 3000 من أبو حسين"

4. "add_customer" — user wants to add/register a new customer
   Examples: "أضف عميل اسمه محمد", "add customer Ahmed", "سجّل عميل جديد أبو حسين", "عميل جديد اسمه خالد"

5. "delete_debt" — user wants to delete/cancel an existing debt
   Examples: "احذف دين أحمد", "الغ آخر دين لأبو حسين", "امسح الدين اللي على أحمد", "delete Ahmed's debt", "cancel the debt"

6. "view_history" — user wants to see transaction history for a customer
   Examples: "شنو اشترى أحمد", "وين تاريخ علي", "what did Ahmed buy", "show Ahmed's transactions", "أحمد شنو اشترى"

7. "unknown" — cannot determine what the user wants

DETECT:
- action: one of "add_debt", "view_balance", "record_payment", "add_customer", "delete_debt", "view_history", "unknown"
- customer_name: the customer's name (extracted from speech, clean)
- phone: ONLY for add_customer — phone number if mentioned (digits only, e.g. "07701234567"), or null
- items: ONLY for add_debt — list of {name, amount} objects
- total_amount: for add_debt (sum of items) AND for record_payment (the payment amount)
- due_date: ONLY for add_debt — "YYYY-MM-DD" relative to TODAY ($today)
- note: ONLY for record_payment — optional note about the payment (e.g. " partial", " settles all")

IRAQI DIALECT NUMBERS:
- "بعشرة" / "10" -> 10000
- "خمسة وثلاثين" -> 35000
- "ألفين ونص" / "2.5" -> 2500

STUTTERING RULES:
- If exact words repeat back-to-back ("طحين طحين"), keep only ONE.

CLEANING:
- Strip fillers: "والله", "عيني", "أغاتي", "حبيبي", "سجل يمعود"
- Strip customer references: "على أبو شهاب" -> customer is "أبو شهاب"

JSON FORMAT:
{
  "action": "add_debt" | "view_balance" | "record_payment" | "add_customer" | "delete_debt" | "view_history" | "unknown",
  "customer_name": "extracted_name",
  "phone": "phone_number" or null,
  "items": [{"name": "item_name", "amount": 10000}],
  "total_amount": 10000,
  "due_date": "YYYY-MM-DD" or null,
  "note": "optional note" or null
}

EXAMPLES:

Command: "سجّل على ابو جاسم 3 طحين ب 45 وكارت آسيا ب 20"
{"action": "add_debt", "customer_name": "ابو جاسم", "items": [{"name": "طحين (3)", "amount": 45000}, {"name": "كارت آسيا", "amount": 20000}], "total_amount": 65000, "due_date": null, "note": null}

Command: "شكد علي أحمد"
{"action": "view_balance", "customer_name": "أحمد", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "كم عليّ أبو حسين"
{"action": "view_balance", "customer_name": "ابو حسين", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "give me Ahmed's debts"
{"action": "view_balance", "customer_name": "Ahmed", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "ابو حسين وينه"
{"action": "view_balance", "customer_name": "ابو حسين", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "سدد لأحمد 5000"
{"action": "record_payment", "customer_name": "أحمد", "items": [], "total_amount": 5000, "due_date": null, "note": null}

Command: "ادفع لابو حسين 10 آلاف"
{"action": "record_payment", "customer_name": "ابو حسين", "items": [], "total_amount": 10000, "due_date": null, "note": null}

Command: "أحمد دفع 20"
{"action": "record_payment", "customer_name": "أحمد", "items": [], "total_amount": 20000, "due_date": null, "note": null}

Command: "أضف عميل اسمه محمد"
{"action": "add_customer", "customer_name": "محمد", "phone": null, "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "add customer Ahmed 07701234567"
{"action": "add_customer", "customer_name": "Ahmed", "phone": "07701234567", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "سجّل عميل جديد أبو حسين 07809876543"
{"action": "add_customer", "customer_name": "ابو حسين", "phone": "07809876543", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "احذف دين أحمد"
{"action": "delete_debt", "customer_name": "أحمد", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "الغ آخر دين لأبو حسين"
{"action": "delete_debt", "customer_name": "ابو حسين", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "شنو اشترى أحمد"
{"action": "view_history", "customer_name": "أحمد", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: "what did Ahmed buy"
{"action": "view_history", "customer_name": "Ahmed", "items": [], "total_amount": 0, "due_date": null, "note": null}

Command: $transcript
''';
}
