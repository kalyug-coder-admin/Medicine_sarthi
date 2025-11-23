import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/medicine/medicine_bloc.dart';
import 'presentation/bloc/appointment/appointment_bloc.dart';
import 'presentation/bloc/voice/voice_bloc.dart';
import 'injection_container.dart' as di;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<MedicineBloc>(
          create: (_) => di.sl<MedicineBloc>(),
        ),
        BlocProvider<AppointmentBloc>(
          create: (_) => di.sl<AppointmentBloc>(),
        ),
        BlocProvider<VoiceBloc>(
          create: (_) => di.sl<VoiceBloc>(),
        ),
      ],

      child: MaterialApp.router(
        title: 'Health Companion',
        debugShowCheckedModeBanner: false,

        // ------------------------------------------------
        // 🌈 FINAL FIX — NEUMORPHIC + PURPLE UI ENABLED
        // ------------------------------------------------
        theme: AppTheme.lightTheme.copyWith(

          // 🌤 Lavender background (visible purple contrast)
          scaffoldBackgroundColor: const Color(0xFFEDECF3),

          // 🎨 Force purple for icons & text (override M3 tint)
          iconTheme: IconThemeData(
            color: Colors.deepPurple.shade500,
          ),

          // Override color scheme so Material 3 doesn't grey-out icons
          colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
            primary: Colors.deepPurple.shade500,
            secondary: Colors.indigo.shade400,
            onSurface: Colors.black87,
            onSurfaceVariant: Colors.black54,
          ),

          // 🟣 AppBar — clean lavender UI
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFFEDECF3),
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.deepPurple.shade600,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.deepPurple.shade600,
            ),
          ),

          // 🟣 Cards (used later)
          cardTheme: CardThemeData(
            color: const Color(0xFFEDECF3),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          dividerColor: Colors.grey.shade300,
        ),

        // Dark theme (unchanged)
        darkTheme: AppTheme.darkTheme,

        // Force light theme
        themeMode: ThemeMode.light,

        routerConfig: AppRouter.router,
      ),
    );
  }
}
