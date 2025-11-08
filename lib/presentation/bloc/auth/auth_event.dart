part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final int age;
  final String gender;
  final UserRole role;
  final String? linkedElderlyId;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    required this.name,
    required this.age,
    required this.gender,
    required this.role,
    this.linkedElderlyId,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    name,
    age,
    gender,
    role,
    linkedElderlyId,
  ];
}

class SignInWithGoogleEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}