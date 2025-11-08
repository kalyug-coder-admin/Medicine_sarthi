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
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}