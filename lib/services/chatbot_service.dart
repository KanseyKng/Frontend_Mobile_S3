// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/api_headers.dart';

class ChatbotService {
  Future<String> sendMessage(
    String message,
    List<Map<String, dynamic>> history,
  ) async {
    try {
      final headers = await ApiHeaders.get(withAuth: false);
      final url = Uri.parse('${AppConfig.apiUrl}/chat');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'message': message,
          'history': history
              .map((h) => {
                    'role': h['isFromUser'] ? 'user' : 'model',
                    'parts': [
                      {'text': h['text']}
                    ],
                  })
              .toList(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data']['reply'];
      } else {
        return "Maaf, asisten sedang sibuk. Coba lagi nanti ya.";
      }
    } catch (e) {
      return "Koneksi gagal. Pastikan internetmu lancar dan server menyala.";
    }
  }
}