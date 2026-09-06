import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiService {
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent';

  Future<String> sendMessage(String message) async {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY was not provided at build time');
    }

    final response = await http
        .post(
          Uri.parse('$_endpoint?key=$_apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {
                    'text':
                        'You are DermaLens skin health assistant. Give concise, safe educational information. Do not diagnose; recommend a healthcare professional for concerning symptoms. User message: $message',
                  },
                ],
              },
            ],
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gemini request failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw Exception('Gemini returned no candidates: ${response.body}');
    }
    final parts = candidates.first['content']['parts'] as List<dynamic>?;
    final text = parts?.first['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw Exception('Gemini returned an empty response');
    }
    return text.trim();
  }
}
