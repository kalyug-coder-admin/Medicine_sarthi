import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/repositories/medicine_repository.dart';
import '../datasources/remote/medicine_remote_datasource.dart';
import '../models/medicine_model.dart';

class MedicineRepositoryImpl implements MedicineRepository {
  final MedicineRemoteDataSource remoteDataSource;

  MedicineRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addMedicine(MedicineEntity medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      await remoteDataSource.addMedicine(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to add medicine'));
    }
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> getMedicines(
      String userId,
      ) async {
    try {
      final medicines = await remoteDataSource.getMedicines(userId);
      return Right(medicines);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get medicines'));
    }
  }

  @override
  Future<Either<Failure, MedicineEntity>> getMedicineById(
      String medicineId,
      ) async {
    try {
      final medicine = await remoteDataSource.getMedicineById(medicineId);
      return Right(medicine);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get medicine'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicine(MedicineEntity medicine) async {
    try {
      final model = MedicineModel.fromEntity(medicine);
      await remoteDataSource.updateMedicine(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update medicine'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedicine(String medicineId) async {
    try {
      await remoteDataSource.deleteMedicine(medicineId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete medicine'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMedicineStatus({
    required String medicineId,
    required String date,
    required MedicineStatus status,
  }) async {
    try {
      await remoteDataSource.updateMedicineStatus(
        medicineId: medicineId,
        date: date,
        status: status,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update medicine status'));
    }
  }

  @override
  Stream<List<MedicineEntity>> watchMedicines(String userId) {
    return remoteDataSource.watchMedicines(userId);
  }

  @override
  Future<Either<Failure, List<MedicineEntity>>> getTodaysMedicines(
      String userId,
      ) async {
    try {
      final medicines = await remoteDataSource.getMedicines(userId);
      final today = DateTime.now();

      final todaysMedicines = medicines.where((medicine) {
        return medicine.startDate.isBefore(today) &&
            (medicine.endDate == null || medicine.endDate!.isAfter(today));
      }).toList();

      return Right(todaysMedicines);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get today\'s medicines'));
    }
  }
}