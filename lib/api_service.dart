import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ApiService {
  final String apiUrl = 'https://test.com/api';

  Future<String> sendPhoto(File photo) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..files.add(await http.MultipartFile.fromPath('photo', photo.path));
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = jsonDecode(responseData);
        return data['text'] ?? 'No text returned';
      } else {
        return 'Failed to load';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
