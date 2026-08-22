/// VOICE ENTRY FEATURE — DATA LAYER: AI PARSING DATASOURCE
///
/// Handles communication with Google Gemini API to parse
/// voice transcripts into structured debt data.
///
/// WHY THIS EXISTS:
/// - The domain layer defines WHAT to parse (repository interface)
/// - This datasource defines HOW to parse (Gemini API)
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

  static const _primaryModel = 'gemini-3.5-flash-lite';
  static const _fallbackModel = 'gemini-3.6-flash';

  AiParsingDatasource({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  Future<VoiceParsedDebt> parse(String transcript) async {
    final today = DateTime.now().toIso8601String().substring(
      0,
      10,
    ); //ntp or firebase timestap might perform better.
    final prompt = _buildPrompt(today, transcript);
    final body = _buildBody(prompt);

    // Try primary model first
    try {
      final result = await _callModel(_primaryModel, body);
      return result;
    } on AiParsingException catch (e) {
      final msg = e.message;
      // Retry with fallback model on rate limit or server overload
      if (msg.contains('429') || msg.contains('503')) {
        return await _callModel(_fallbackModel, body);
      }
      rethrow;
    }
  }

  Future<VoiceParsedDebt> _callModel(
    String model,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
      );

      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw AiParsingException(
          'API returned status ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body);
      final content = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (content == null || content is! String) {
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
    'contents': [
      {
        'parts': [
          {'text': prompt},
        ],
      },
    ],
    'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 500},
  };

  /// Parse the Gemini response text into a [VoiceParsedDebt].
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
        dueDate = DateTime.tryParse(data['due_date']); //not safe.
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
You are a debt parser for a shopkeeper application.
The shopkeeper speaks in a casual mix of Arabic and English (often "Arabish").
They list items with prices, optionally mention a customer name and payment due date.

Given their voice transcript, extract ALL items mentioned, their amounts, and optional due date.

RULES:
- Extract EVERY item separately — if the speaker lists 2 items, return 2 items in the array
- Amounts are numbers (no currency symbols, no commas in output)
- If the speaker says "after X days", calculate the due date from TODAY ($today)
- If no due date is mentioned, set due_date to null
- Item names should be clean, short, and in the language the speaker used
- total_amount MUST equal the sum of ALL individual item amounts
- Customer names should NOT be included in items — they go elsewhere in the app
- If the transcript is unclear, make your best interpretation

EXAMPLES:
Speaker: "رسيفر ب 300 و سبورة ب 200" → {"items": [{"name": "رسيفر", "amount": 300}, {"name": "سبورة", "amount": 200}], "total_amount": 500, "due_date": null}
Speaker: "مكواه 200 بعد أسبوع" → {"items": [{"name": "مكواه", "amount": 200}], "total_amount": 200, "due_date": "2026-08-27"}
Speaker: "شاحن 50 و كفر جوال 30 و سماعة 70" → {"items": [{"name": "شاحن", "amount": 50}, {"name": "كفر جوال", "amount": 30}, {"name": "سماعة", "amount": 70}], "total_amount": 150, "due_date": null}

Return ONLY valid JSON (no explanation, no markdown):
{
  "items": [{"name": "item name", "amount": 123}],
  "total_amount": 123,
  "due_date": "YYYY-MM-DD" or null
}

Transcript: $transcript
''';
}
