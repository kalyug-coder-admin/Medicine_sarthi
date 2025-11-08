class AppConstants {
  // App info
  static const String appName = 'Health Companion';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Medicine Reminder';

  // Notification channels
  static const String medicineReminderChannelId = 'medicine_reminder_channel';
  static const String medicineReminderChannelName = 'Medicine Reminders';
  static const String appointmentReminderChannelId = 'appointment_reminder_channel';
  static const String appointmentReminderChannelName = 'Appointment Reminders';
  static const String dailySummaryChannelId = 'daily_summary_channel';
  static const String dailySummaryChannelName = 'Daily Summary';

  // Notification IDs
  static const int dailySummaryNotificationId = 999;

  // Time settings
  static const int medicineReminderAdvanceMinutes = 5;
  static const int appointmentReminderAdvanceHours = 1;
  static const int dailySummaryHour = 8;
  static const int dailySummaryMinute = 0;

  // Pagination
  static const int medicinesPerPage = 20;
  static const int appointmentsPerPage = 20;

  // File upload limits
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocTypes = ['pdf'];

  // Voice settings
  static const double defaultSpeechRate = 0.4; // Slower for elderly
  static const double defaultVolume = 1.0;
  static const double defaultPitch = 1.0;
  static const int voiceListenDuration = 10; // seconds

  // AI settings
  static const int maxAITokens = 200;
  static const double aiTemperature = 0.7;
  static const String aiModel = 'gpt-3.5-turbo';

  // UI settings
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 16.0;
  static const double inputBorderRadius = 16.0;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(minutes: 5);

  // Regex patterns
  static const String emailPattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
  static const String phonePattern = r'^\+?[0-9]{10,15}$';

  // Links
  static const String privacyPolicyUrl = 'https://yourapp.com/privacy';
  static const String termsOfServiceUrl = 'https://yourapp.com/terms';
  static const String supportEmail = 'support@yourapp.com';

  // Feature flags
  static const bool enableVoiceAssistant = true;
  static const bool enableAIChat = true;
  static const bool enableFamilyDashboard = false; // Coming soon
  static const bool enableOfflineMode = false; // Coming soon

  // Error messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternetError = 'No internet connection. Please check your network.';
  static const String timeoutError = 'Request timed out. Please try again.';

  // Success messages
  static const String medicineSavedSuccess = 'Medicine saved successfully';
  static const String appointmentSavedSuccess = 'Appointment scheduled successfully';
  static const String profileUpdatedSuccess = 'Profile updated successfully';
}