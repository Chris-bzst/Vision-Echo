import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  GeminiService({
    required this.model,
  });

  final GenerativeModel model;

  Future<String?> generateContentFromImage(
      {required String prompt, required DataPart dataPart}) async {

    final text = TextPart(prompt);
    final response = await model.generateContent([
      Content.multi([text, dataPart])
    ]);

    return response.text;
  }
}
