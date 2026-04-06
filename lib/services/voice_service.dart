import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<void> init() async {
    _isAvailable = await _speech.initialize(
      onStatus: (status) => debugPrint('STT Status: $status'),
      onError: (error) => debugPrint('STT Error: $error'),
    );
  }

  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListening,
  }) async {
    if (!_isAvailable) {
      await init();
    }

    if (_isAvailable) {
      onListening(true);
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            onListening(false);
          }
        },
        localeId: 'id_ID', // Default to Indonesian
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  bool get isListening => _speech.isListening;
}
