// lib/config/routes/app_router.dart
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

    // NEW: modern GoRouter error handler
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text(
          'Page not found.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    ),

    routes: [
      _animatedRoute(
        path: RouteNames.splash,
        name: 'splash',
        child: const SplashScreen(),
      ),
      _animatedRoute(
        path: RouteNames.login,
        name: 'login',
        child: const LoginScreen(),
      ),
      _animatedRoute(
        path: RouteNames.register,
        name: 'register',
        child: const RegisterScreen(),
      ),
      _animatedRoute(
        path: RouteNames.home,
        name: 'home',
        child: const HomeScreen(),
      ),
      _animatedRoute(
        path: RouteNames.medicines,
        name: 'medicines',
        child: const MedicineListScreen(),
      ),
      _animatedRoute(
        path: RouteNames.addMedicine,
        name: 'addMedicine',
        child: const AddMedicineScreen(),
      ),
      _animatedRoute(
        path: RouteNames.appointments,
        name: 'appointments',
        child: const AppointmentListScreen(),
      ),
      _animatedRoute(
        path: RouteNames.addAppointment,
        name: 'addAppointment',
        child: const AddAppointmentScreen(),
      ),
      _animatedRoute(
        path: RouteNames.voiceAssistant,
        name: 'voiceAssistant',
        child: const VoiceAssistantScreen(),
      ),
      _animatedRoute(
        path: RouteNames.profile,
        name: 'profile',
        child: const ProfileScreen(),
      ),
    ],
  );

  // ------------------------------
  // Smooth Slide + Fade Transition
  // ------------------------------
  static GoRoute _animatedRoute({
    required String path,
    required String name,
    required Widget child,
  }) {
    return GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: child,
          transitionDuration: const Duration(milliseconds: 320),
          transitionsBuilder: (context, animation, secondaryAnimation, widgetChild) {
            final slideTween = Tween<Offset>(
              begin: const Offset(0.12, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(slideTween),
                child: widgetChild,
              ),
            );
          },
        );
      },
    );
  }
}
