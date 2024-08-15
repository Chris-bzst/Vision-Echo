import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vision_echo/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:vision_echo/constants/prompts.dart';

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

    const prompt = PromptConstants.shortPrompt;

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
