import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vision_echo/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiProvider extends ChangeNotifier {
  static GenerativeModel _initModel() {
    //const key = String.fromEnvironment('GEMINI_API_KEY');
    final key = dotenv.env['GEMINI_API_KEY'];

    if (key!.isEmpty) {
      throw Exception('GEMINI_API_KEY not found');
    }
    return GenerativeModel(model: 'gemini-1.5-flash', apiKey: key);
  }

  static final _geminiService = GeminiService(model: _initModel());

  String? response;
  bool isLoading = false;

  Future<void> generateContentFromImage({
    required Uint8List bytes,
  }) async {
    isLoading = true;
    notifyListeners();
    response = null;
    try {
    final dataPart = DataPart(
      'image/jpeg',
      bytes,
    );

    const prompt = '''Analyze the provided image and generate a detailed description that includes the following:

Object Identification: Identify and list the main objects or elements visible in the image (e.g., people, animals, vehicles, buildings).

Spatial Relationships: Describe the relative positions of these objects (e.g., 'A person is standing to the right of a car').

Distance Information: Provide estimated distances of key objects from the viewer if possible (e.g., 'The object is approximately 5 meters away').

Contextual Information: Include any relevant contextual information that might help understand the environment (e.g., 'The setting is a park with a walking path and trees').

Accessibility Considerations: Ensure the description is detailed enough to give a clear sense of the scene and help the user navigate or understand their surroundings.

my request is ''';

    response = await _geminiService.generateContentFromImage(
      prompt: prompt,
      dataPart: dataPart,
    );}catch (e) {
      response = 'Error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }

    isLoading = false;
    notifyListeners();
  }

  void reset() {
    response = null;
    isLoading = false;
    notifyListeners();
  }
}
