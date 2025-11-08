import 'package:flutter_tts/flutter_tts.dart';

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
  }

  Future<void> speak(String text) async {
    await initialize();
    await _flutterTts.speak(text);
  }

  Future<void> speakMedicineReminder({
    required String medicineName,
    required String dosage,
  }) async {
    await initialize();
    final message = "It's time to take your medicine. $medicineName, $dosage. "
        "Please take it now.";
    await _flutterTts.speak(message);
  }

  Future<void> speakAppointmentReminder({
    required String doctorName,
    required String time,
  }) async {
    await initialize();
    final message = "Reminder: You have an appointment with Doctor $doctorName "
        "at $time. Please get ready.";
    await _flutterTts.speak(message);
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
    return await _flutterTts.getLanguages;
  }

  Future<bool> get isLanguageAvailable async {
    var result = await _flutterTts.isLanguageAvailable("en-US");
    return result;
  }
}