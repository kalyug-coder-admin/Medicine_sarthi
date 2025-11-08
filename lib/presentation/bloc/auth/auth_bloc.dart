import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;

  AuthBloc({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignOutEvent>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signInUseCase.getCurrentUser();

    result.fold(
          (failure) => emit(AuthUnauthenticated()),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignInWithEmail(
      SignInWithEmailEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signInUseCase(
      SignInParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignUpWithEmail(
      SignUpWithEmailEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signUpUseCase(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        age: event.age,
        gender: event.gender,
        role: event.role,
        linkedElderlyId: event.linkedElderlyId,
      ),
    );

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signInUseCase.signInWithGoogle();

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthAuthenticated(user: user)),
    );
  }

  Future<void> _onSignOut(
      SignOutEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final result = await signOutUseCase(NoParams());

    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (_) => emit(AuthUnauthenticated()),
    );
  }
}