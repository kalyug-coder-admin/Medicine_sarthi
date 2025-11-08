import 'package:dio/dio.dart';

class AiService {
  final Dio _dio = Dio();

  // Replace with your OpenAI API key
  static const String _apiKey = 'YOUR_OPENAI_API_KEY';
  static const String _baseUrl = 'https://api.openai.com/v1';

  AiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };
  }

  Future<String> getChatResponse(String message) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful health assistant. Provide general '
                  'health information only. Always remind users to consult '
                  'healthcare professionals for medical advice. Keep responses '
                  'concise and easy to understand for elderly users.',
            },
            {
              'role': 'user',
              'content': message,
            },
          ],
          'max_tokens': 200,
          'temperature': 0.7,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return 'Sorry, I could not process your request. Please try again.';
      }
    } catch (e) {
      print('AI Service Error: $e');
      return 'I apologize, but I am having trouble connecting. '
          'Please try again later.';
    }
  }

  Future<String> getMedicineInfo(String medicineName) async {
    final prompt = 'Provide brief information about the medicine "$medicineName" '
        'including its common uses and important side effects. '
        'Keep it simple for elderly users.';

    return await getChatResponse(prompt);
  }

  Future<String> processVoiceCommand(String command) async {
    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a voice assistant for a medicine reminder app. '
                  'Extract the intent from user commands. Respond with JSON format: '
                  '{"intent": "check_medicine|next_appointment|medicine_info", '
                  '"entity": "extracted entity"}',
            },
            {
              'role': 'user',
              'content': command,
            },
          ],
          'max_tokens': 50,
          'temperature': 0.3,
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content.trim();
      } else {
        return '{"intent": "unknown", "entity": ""}';
      }
    } catch (e) {
      print('Voice Command Processing Error: $e');
      return '{"intent": "error", "entity": ""}';
    }
  }

  Future<String> getHealthAdvice(String query) async {
    final prompt = 'Provide brief, simple health advice about: $query. '
        'Keep it concise and elderly-friendly. '
        'Add disclaimer that this is general information only.';

    return await getChatResponse(prompt);
  }

  Future<List<String>> getSuggestedQuestions() async {
    return [
      'What medicine do I need to take now?',
      'When is my next appointment?',
      'Tell me about my medicines',
      'What are the side effects of my medicine?',
      'How should I take my medicine?',
    ];
  }
}