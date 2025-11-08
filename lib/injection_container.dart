import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import 'core/services/notification_service.dart';
import 'core/services/tts_service.dart';
import 'core/services/stt_service.dart';
import 'core/services/ai_service.dart';

// Data Sources
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/medicine_remote_datasource.dart';
import 'data/datasources/remote/appointment_remote_datasource.dart';
import 'data/datasources/remote/user_remote_datasource.dart';
import 'data/datasources/local/secure_storage_datasource.dart';

// Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/medicine_repository_impl.dart';
import 'data/repositories/appointment_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/medicine_repository.dart';
import 'domain/repositories/appointment_repository.dart';
import 'domain/repositories/user_repository.dart';

// Use Cases - Auth
import 'domain/usecases/auth/sign_in_usecase.dart';
import 'domain/usecases/auth/sign_up_usecase.dart';
import 'domain/usecases/auth/sign_out_usecase.dart';

// Use Cases - Medicine
import 'domain/usecases/medicine/add_medicine_usecase.dart';
import 'domain/usecases/medicine/get_medicines_usecase.dart';
import 'domain/usecases/medicine/update_medicine_status_usecase.dart';
import 'domain/usecases/medicine/delete_medicine_usecase.dart';

// Use Cases - Appointment
import 'domain/usecases/appointment/add_appointment_usecase.dart';
import 'domain/usecases/appointment/get_appointments_usecase.dart';
import 'domain/usecases/appointment/delete_appointment_usecase.dart';

// BLoCs
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/medicine/medicine_bloc.dart';
import 'presentation/bloc/appointment/appointment_bloc.dart';
import 'presentation/bloc/voice/voice_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== BLoCs ==========
  sl.registerFactory(() => AuthBloc(
    signInUseCase: sl(),
    signUpUseCase: sl(),
    signOutUseCase: sl(),
  ));

  sl.registerFactory(() => MedicineBloc(
    addMedicineUseCase: sl(),
    getMedicinesUseCase: sl(),
    updateMedicineStatusUseCase: sl(),
    deleteMedicineUseCase: sl(),
    notificationService: sl(),
    ttsService: sl(),
  ));

  sl.registerFactory(() => AppointmentBloc(
    addAppointmentUseCase: sl(),
    getAppointmentsUseCase: sl(),
    deleteAppointmentUseCase: sl(),
    notificationService: sl(),
  ));

  sl.registerFactory(() => VoiceBloc(
    sttService: sl(),
    ttsService: sl(),
    aiService: sl(),
    medicineRepository: sl(),
    appointmentRepository: sl(),
  ));

  // ========== Use Cases - Auth ==========
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));

  // ========== Use Cases - Medicine ==========
  sl.registerLazySingleton(() => AddMedicineUseCase(sl()));
  sl.registerLazySingleton(() => GetMedicinesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMedicineStatusUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMedicineUseCase(sl()));

  // ========== Use Cases - Appointment ==========
  sl.registerLazySingleton(() => AddAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetAppointmentsUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAppointmentUseCase(sl()));

  // ========== Repositories ==========
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorageDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<MedicineRepository>(
        () => MedicineRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AppointmentRepository>(
        () => AppointmentRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(remoteDataSource: sl()),
  );

  // ========== Data Sources ==========
  sl.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<MedicineRemoteDataSource>(
        () => MedicineRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<AppointmentRemoteDataSource>(
        () => AppointmentRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  sl.registerLazySingleton<SecureStorageDataSource>(
        () => SecureStorageDataSourceImpl(secureStorage: sl()),
  );

  // ========== Core Services ==========
  sl.registerLazySingleton<NotificationService>(
        () => NotificationService(),
  );

  sl.registerLazySingleton<TtsService>(
        () => TtsService(),
  );

  sl.registerLazySingleton<SttService>(
        () => SttService(),
  );

  sl.registerLazySingleton<AiService>(
        () => AiService(),
  );

  // ========== External Dependencies ==========
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
}