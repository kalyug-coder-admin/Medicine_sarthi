import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.4); // Slower for elderly users
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
    print('✅ TtsService initialized');
  }

  /// Speak text and wait for it to complete
  /// Estimate speech duration based on text length
  Future<void> speak(String text) async {
    await initialize();

    try {
      print('🔊 Speaking: $text');

      // Speak the text
      await _flutterTts.speak(text);

      // Calculate estimated duration
      // Average speaking rate: ~150 words per minute = 2.5 words per second
      // Average word length: 5 characters
      final estimatedDuration = (text.length / 5 / 2.5 * 1000).toInt() + 500;

      print('⏱️ Waiting ${estimatedDuration}ms for speech to complete...');

      // Wait for estimated time
      await Future.delayed(Duration(milliseconds: estimatedDuration));

      print('✅ Speech completed: $text');
    } catch (e) {
      print('❌ Error speaking: $e');
    }
  }

  /// Speak text 3 times with interval
  Future<void> speakRepeatedly(String text, {int times = 3, int intervalSeconds = 5}) async {
    await initialize();

    for (int i = 0; i < times; i++) {
      print('🔊 Speaking (${i + 1}/$times): $text');
      await speak(text);

      if (i < times - 1) {
        print('⏱️ Waiting ${intervalSeconds}s before next repetition...');
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }

    print('✅ Completed speaking $times times');
  }

  Future<void> speakMedicineReminder({
    required String medicineName,
    required String dosage,
  }) async {
    await initialize();
    final message =
        "It's time to take your medicine. $medicineName, $dosage. Please take it now.";
    await speakRepeatedly(message);
  }

  Future<void> speakAppointmentReminder({
    required String doctorName,
    required String time,
  }) async {
    await initialize();
    final message =
        "Reminder: You have an appointment with Doctor $doctorName at $time. Please get ready.";
    await speakRepeatedly(message);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<List<dynamic>> getLanguages() async {
    return await _flutterTts.getLanguages ?? [];
  }

  Future<bool> get isLanguageAvailable async {
    var result = await _flutterTts.isLanguageAvailable("en-US");
    return result ?? false;
  }
}