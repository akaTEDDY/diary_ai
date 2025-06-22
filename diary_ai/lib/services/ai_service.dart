import 'package:http/http.dart' as http;
import 'dart:convert';

class AiService {
  final String apiUrl;
  AiService({required this.apiUrl});

  Future<String?> requestDiaryExample({required String prompt}) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result'] as String?;
      }
    } catch (e) {
      // 에러 처리
    }
    return null;
  }
}
