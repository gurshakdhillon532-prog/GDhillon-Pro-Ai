import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../constants.dart';

class ApiService {
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: AppConstants.apiKey,
    generationConfig: const GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 2048,
    ),
  );

  static Future<String> generateResponse({
    required String prompt,
    String systemPrompt = '',
    double temperature = 0.7,
  }) async {
    try {
      final content = [
        if (systemPrompt.isNotEmpty) Content.text(systemPrompt),
        Content.text(prompt),
      ];

      final response = await _model.generateContent(content);
      
      if (response.text != null) {
        return response.text!.trim();
      }
      
      return 'Sorry, I could not generate a response at this time.';
    } catch (e) {
      print('API Error: $e');
      return 'Error: Unable to connect to AI service. Please check your API key.';
    }
  }

  static Future<String> generateResponseWithSettings({
    required String prompt,
    required String systemPrompt,
    required double temperature,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: AppConstants.apiKey,
        generationConfig: GenerationConfig(
          temperature: temperature,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );

      final content = [
        Content.text(systemPrompt),
        Content.text(prompt),
      ];

      final response = await model.generateContent(content);
      
      return response.text?.trim() ?? 'No response received.';
    } catch (e) {
      print('API Error with settings: $e');
      return 'Error: Unable to generate response with current settings.';
    }
  }
}
