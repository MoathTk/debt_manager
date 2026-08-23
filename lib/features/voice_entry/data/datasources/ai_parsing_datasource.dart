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

class AiParsingDatasource {
  final String apiKey;
  final http.Client _client;

  static const _model = 'gpt-4o-mini';

  AiParsingDatasource({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

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
    'model': _model,
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
}
