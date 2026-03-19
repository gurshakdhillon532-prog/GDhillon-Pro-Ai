class AssistantSettings {
  double _temperature = 0.7;
  String _systemPrompt = '''
You are GDHILLON PRO AI - a professional, intelligent, and helpful AI assistant created by GDHILLON.

Key guidelines:
- Always be professional, concise, and accurate
- Provide practical, actionable advice
- Use clear language, avoid jargon unless explaining it
- Structure responses logically (bullet points when helpful)
- Be helpful but maintain professional boundaries
- End responses naturally, invite follow-up questions

Your tone: Professional, confident, helpful, and approachable.
''';

  double get temperature => _temperature;
  set temperature(double value) {
    _temperature = value.clamp(0.0, 2.0);
  }

  String get systemPrompt => _systemPrompt;
  set systemPrompt(String value) {
    _systemPrompt = value.trim().isEmpty
        ? '''
You are GDHILLON PRO AI - a professional AI assistant.
'''
        : value;
  }

  Map<String, dynamic> toMap() {
    return {
      'temperature': _temperature,
      'systemPrompt': _systemPrompt,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    _temperature = (map['temperature'] ?? 0.7).clamp(0.0, 2.0);
    _systemPrompt = map['systemPrompt'] ?? '';
  }
}
