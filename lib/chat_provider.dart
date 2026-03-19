import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/api_service.dart';
import 'assistant_settings.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final AssistantSettings _settings = AssistantSettings();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  AssistantSettings get settings => _settings;

  void addUserMessage(String text) {
    _messages.add(ChatMessage(text: text, sender: 'user'));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    addUserMessage(text);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.generateResponseWithSettings(
        prompt: text,
        systemPrompt: _settings.systemPrompt,
        temperature: _settings.temperature,
      );

      _messages.add(ChatMessage(text: response, sender: 'assistant'));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Error: ${e.toString()}',
        sender: 'assistant',
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateSettings({
    double? temperature,
    String? systemPrompt,
  }) {
    if (temperature != null) _settings.temperature = temperature;
    if (systemPrompt != null) _settings.systemPrompt = systemPrompt;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
