import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/medicine/medicine_list_screen.dart';
import '../../presentation/screens/medicine/add_medicine_screen.dart';
import '../../presentation/screens/appointment/appointment_list_screen.dart';
import '../../presentation/screens/appointment/add_appointment_screen.dart';
import '../../presentation/screens/voice/voice_assistant_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.medicines,
        name: 'medicines',
        builder: (context, state) => const MedicineListScreen(),
      ),
      GoRoute(
        path: RouteNames.addMedicine,
        name: 'addMedicine',
        builder: (context, state) => const AddMedicineScreen(),
      ),
      GoRoute(
        path: RouteNames.appointments,
        name: 'appointments',
        builder: (context, state) => const AppointmentListScreen(),
      ),
      GoRoute(
        path: RouteNames.addAppointment,
        name: 'addAppointment',
        builder: (context, state) => const AddAppointmentScreen(),
      ),
      GoRoute(
        path: RouteNames.voiceAssistant,
        name: 'voiceAssistant',
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}