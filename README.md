# Medicine Reminder & Health Companion App 💊

A comprehensive Flutter application designed for elderly users with medicine reminders, appointment tracking, voice assistant, and family monitoring capabilities.

## 🏗️ Architecture

This project follows **Clean Architecture** with **BLoC Pattern** for state management:

```
lib/
├── core/              # Core utilities, services, and base classes
├── data/              # Data layer (models, datasources, repositories)
├── domain/            # Domain layer (entities, repositories, use cases)
├── presentation/      # Presentation layer (BLoC, screens, widgets)
└── config/            # App configuration (routes, themes, constants)
```

## 🚀 Features

### ✅ Implemented Core Features

1. **User Authentication**
    - Email/Password authentication
    - Google Sign-In
    - Role-based access (Elderly User / Family Member)
    - Family linking system

2. **Medicine Management**
    - CRUD operations for medicines
    - Dosage and frequency tracking
    - Medicine status tracking (Taken/Missed/Pending)
    - Real-time Firestore synchronization

3. **Notification System**
    - Local notifications for medicine reminders
    - Appointment reminders
    - Daily health summary
    - Voice reminders (TTS integration)

4. **Voice Assistant**
    - Speech-to-Text (STT) integration
    - Text-to-Speech (TTS) responses
    - AI-powered command processing
    - Natural language understanding

5. **Elderly-Friendly UI**
    - Large fonts and high contrast
    - Simple navigation
    - Voice interaction support
    - Material 3 design

## 📦 Dependencies

### Core Dependencies
```yaml
# State Management
flutter_bloc: ^8.1.3

# Firebase
firebase_core: ^2.24.2
firebase_auth: ^4.15.3
cloud_firestore: ^4.13.6
firebase_storage: ^11.5.6

# Voice Features
speech_to_text: ^6.5.1
flutter_tts: ^3.8.5

# Notifications
flutter_local_notifications: ^16.3.0

# Storage
flutter_secure_storage: ^9.0.0
```

## 🔧 Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.0.0+)
- Firebase account
- Android Studio / VS Code
- OpenAI API key (for AI assistant)

### 2. Firebase Setup

1. Create a new Firebase project at [console.firebase.google.com](https://console.firebase.google.com)

2. Add Android app:
   ```bash
   Package name: com.yourcompany.medicine_reminder_app
   ```

3. Add iOS app:
   ```bash
   Bundle ID: com.yourcompany.medicineReminderApp
   ```

4. Download and place configuration files:
    - `google-services.json` → `android/app/`
    - `GoogleService-Info.plist` → `ios/Runner/`

5. Enable Authentication methods:
    - Email/Password
    - Google Sign-In

6. Create Firestore database with rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && 
                  get(/databases/$(database)/documents/users/$(request.auth.uid)).data.linkedElderlyId == userId;
    }
    
    // Medicines collection
    match /medicines/{medicineId} {
      allow read, write: if request.auth != null;
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. OpenAI API Setup

1. Get API key from [platform.openai.com](https://platform.openai.com)
2. Update `lib/core/services/ai_service.dart`:

```dart
static const String _apiKey = 'YOUR_OPENAI_API_KEY';
```

### 4. Android Configuration

Update `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

Add permissions in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

```

### 5. iOS Configuration

Update `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access for voice assistant features</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>We need speech recognition to process your voice commands</string>
```

### 6. Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 7. Run the App

```bash
# Run on Android
flutter run

# Run on iOS
flutter run -d ios

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

## 📁 Project Structure Explained

### Domain Layer (Business Logic)

**Entities** (`lib/domain/entities/`)
- Pure Dart classes representing core business objects
- No dependencies on external packages
- Examples: `UserEntity`, `MedicineEntity`, `AppointmentEntity`

**Repositories** (`lib/domain/repositories/`)
- Abstract interfaces defining data operations
- Implemented by data layer
- Examples: `AuthRepository`, `MedicineRepository`

**Use Cases** (`lib/domain/usecases/`)
- Single responsibility business logic operations
- One use case per operation
- Examples: `SignInUseCase`, `AddMedicineUseCase`

### Data Layer (Implementation)

**Models** (`lib/data/models/`)
- Implementations of entities with JSON serialization
- Extend domain entities
- Include `fromJson()` and `toJson()` methods

**Data Sources** (`lib/data/datasources/`)
- Remote: Firebase interactions
- Local: Secure storage, SharedPreferences
- Examples: `AuthRemoteDataSource`, `MedicineRemoteDataSource`

**Repository Implementations** (`lib/data/repositories/`)
- Implement domain repository interfaces
- Handle data source coordination and error mapping

### Presentation Layer (UI)

**BLoC** (`lib/presentation/bloc/`)
- State management using flutter_bloc
- Each feature has: bloc, event, state files
- Examples: `AuthBloc`, `MedicineBloc`, `VoiceBloc`

**Screens** (`lib/presentation/screens/`)
- UI screens organized by feature
- Use BLoC for state management
- Examples: `HomeScreen`, `LoginScreen`, `VoiceAssistantScreen`

**Widgets** (`lib/presentation/widgets/`)
- Reusable UI components
- Common widgets: buttons, text fields, cards
- Feature-specific widgets: medicine cards, appointment cards

### Core Layer (Utilities)

**Services** (`lib/core/services/`)
- Cross-cutting concerns
- `NotificationService`: Local notifications
- `TtsService`: Text-to-speech
- `SttService`: Speech-to-text
- `AiService`: OpenAI integration

**Error Handling** (`lib/core/error/`)
- `Failures`: Domain-level errors
- `Exceptions`: Data-level errors

## 🔐 Security Best Practices

1. **Firestore Security Rules**: Restrict access based on authentication
2. **Secure Storage**: Use `flutter_secure_storage` for sensitive data
3. **API Keys**: Never commit API keys to version control
4. **User Validation**: Validate all user inputs
5. **HTTPS**: All network calls use secure connections

## 📱 Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test integration_test/
```

## 🎨 Customization

### Theme Colors

Update `lib/config/theme/app_colors.dart`:

```dart
static const Color primary = Color(0xFF6366F1); // Change primary color
static const Color accent = Color(0xFF10B981);  // Change accent color
```

### Text Sizes (for Elderly Users)

Adjust in `lib/config/theme/app_theme.dart`:

```dart
bodyLarge: GoogleFonts.poppins(
  fontSize: 18, // Increase for larger text
),
```

### Add New Language

1. Add translation files in `assets/translations/`
2. Update `pubspec.yaml`
3. Implement localization in app

## 🔄 Additional Features to Implement

### Phase 2 Features:
- [ ] Family Dashboard with real-time monitoring
- [ ] Health Chatbot integration
- [ ] Prescription PDF upload
- [ ] Medical history tracking
- [ ] Emergency SOS button
- [ ] Monthly PDF reports
- [ ] Offline mode support
- [ ] Biometric authentication
- [ ] Medicine interaction warnings
- [ ] Refill reminders

### Phase 3 Features:
- [ ] Wearable device integration
- [ ] Video call with doctors
- [ ] Medicine barcode scanner
- [ ] Pill identification using camera
- [ ] Health metrics tracking (BP, sugar levels)
- [ ] Geofencing for appointments
- [ ] Multiple language support (Hindi, regional)

## 📊 Database Schema

### Users Collection
```javascript
{
  id: string,
  email: string,
  name: string,
  age: number,
  gender: string,
  bloodGroup: string?,
  role: "elderly" | "family",
  linkedFamilyIds: string[]?,
  linkedElderlyId: string?,
  emergencyContact: string?,
  profileImageUrl: string?,
  createdAt: timestamp
}
```

### Medicines Collection
```javascript
{
  id: string,
  userId: string,
  name: string,
  dosage: string,
  frequency: "daily" | "twiceDaily" | "threeTimesDaily" | "weekly",
  timesOfDay: string[],
  startDate: timestamp,
  endDate: timestamp?,
  instructions: string?,
  voiceReminder: boolean,
  notificationEnabled: boolean,
  statusHistory: {
    "2025-01-15": "taken" | "missed" | "pending" | "skipped"
  },
  createdAt: timestamp
}
```

### Appointments Collection
```javascript
{
  id: string,
  userId: string,
  doctorName: string,
  specialization: string?,
  hospital: string,
  appointmentDate: timestamp,
  appointmentTime: string,
  notes: string?,
  prescriptionUrl: string?,
  reminderSet: boolean,
  createdAt: timestamp
}
```

## 🐛 Troubleshooting

### Common Issues

**1. Firebase initialization error**
```bash
Solution: Ensure google-services.json and GoogleService-Info.plist are properly placed
```

**2. Notification not working**
```bash
Solution: Check permissions in AndroidManifest.xml and Info.plist
```

**3. Voice assistant not responding**
```bash
Solution: 
- Check microphone permissions
- Verify OpenAI API key
- Test on physical device (not emulator)
```

**4. Build runner issues**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Email: support@healthcompanion.com

## 🙏 Acknowledgments

- Firebase for backend services
- OpenAI for AI capabilities
- Flutter community for amazing packages

---

**Built with ❤️ for elderly care**