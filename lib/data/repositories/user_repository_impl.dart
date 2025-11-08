import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/medical_history_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> getUserById(String userId) async {
    try {
      final user = await remoteDataSource.getUserById(userId);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(UserEntity user) async {
    try {
      final model = UserModel.fromEntity(user);
      await remoteDataSource.updateUser(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update user'));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfileImage(
      String userId,
      String imagePath,
      ) async {
    try {
      await remoteDataSource.uploadProfileImage(userId, imagePath);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update profile image'));
    }
  }

  @override
  Future<Either<Failure, MedicalHistoryEntity>> getMedicalHistory(
      String userId,
      ) async {
    try {
      // TODO: Implement medical history retrieval
      return Left(ServerFailure('Not implemented yet'));
    } catch (e) {
      return Left(ServerFailure('Failed to get medical history'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicalHistory(
      MedicalHistoryEntity history,
      ) async {
    try {
      // TODO: Implement medical history update
      return Left(ServerFailure('Not implemented yet'));
    } catch (e) {
      return Left(ServerFailure('Failed to update medical history'));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getLinkedFamilyMembers(
      String elderlyUserId,
      ) async {
    try {
      final users = await remoteDataSource.getLinkedFamilyMembers(elderlyUserId);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get linked family members'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadPrescription(
      String userId,
      String filePath,
      ) async {
    try {
      final url = await remoteDataSource.uploadPrescription(userId, filePath);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to upload prescription'));
    }
  }
}