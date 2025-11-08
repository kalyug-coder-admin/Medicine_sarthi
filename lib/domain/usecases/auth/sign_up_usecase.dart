import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      name: params.name,
      age: params.age,
      gender: params.gender,
      role: params.role,
      linkedElderlyId: params.linkedElderlyId,
    );
  }
}

class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final int age;
  final String gender;
  final UserRole role;
  final String? linkedElderlyId;

  const SignUpParams({
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