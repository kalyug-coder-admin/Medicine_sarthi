import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/medicine_entity.dart';

abstract class MedicineRepository {
  Future<Either<Failure, void>> addMedicine(MedicineEntity medicine);

  Future<Either<Failure, List<MedicineEntity>>> getMedicines(String userId);

  Future<Either<Failure, MedicineEntity>> getMedicineById(String medicineId);

  Future<Either<Failure, void>> updateMedicine(MedicineEntity medicine);

  Future<Either<Failure, void>> deleteMedicine(String medicineId);

  Future<Either<Failure, void>> updateMedicineStatus({
    required String medicineId,
    required String date,
    required MedicineStatus status,
  });

  Stream<List<MedicineEntity>> watchMedicines(String userId);

  Future<Either<Failure, List<MedicineEntity>>> getTodaysMedicines(
      String userId,
      );
}