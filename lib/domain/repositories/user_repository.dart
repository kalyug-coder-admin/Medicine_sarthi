import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../entities/medical_history_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById(String userId);
  Future<Either<Failure, void>> updateUser(UserEntity user);
  Future<Either<Failure, void>> updateProfileImage(String userId, String imagePath);
  Future<Either<Failure, MedicalHistoryEntity>> getMedicalHistory(String userId);
  Future<Either<Failure, void>> updateMedicalHistory(MedicalHistoryEntity history);
  Future<Either<Failure, List<UserEntity>>> getLinkedFamilyMembers(String elderlyUserId);
  Future<Either<Failure, String>> uploadPrescription(String userId, String filePath);
}