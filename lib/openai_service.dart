import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static String? _apiKey;
  
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    _apiKey = dotenv.env['OPENAI_API_KEY'];
  }
  
  static const String _systemPrompt = """
You are a helpful and friendly language learning assistant for the Multicult app. Your role is to:

1. Help users learn multiple languages (English, Vietnamese, Spanish, French, Japanese, Korean)
2. Provide translation assistance and language explanations
3. Answer questions about cultural differences and multicultural topics
4. Help with medical terminology and healthcare communication in different languages
5. Be encouraging and supportive in the learning process
6. Keep responses concise but informative
7. Use simple language when explaining complex concepts
8. Provide examples when helpful

Always be patient, friendly, and culturally sensitive. Focus on practical language learning that can help multicultural populations with better medical access and daily communication.
""";

  static Future<String> sendMessage(String userMessage) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return "Sorry, the AI service is not configured properly. Please check the API key.";
    }

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': _systemPrompt,
            },
            {
              'role': 'user',
              'content': userMessage,
            },
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        print('OpenAI API Error: ${response.statusCode} - ${response.body}');
        return "Sorry, I'm having trouble connecting to the AI service right now. Please try again later.";
      }
    } catch (e) {
      print('OpenAI Service Error: $e');
      return "Sorry, there was an error processing your message. Please try again.";
    }
  }
}
