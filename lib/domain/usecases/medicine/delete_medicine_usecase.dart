import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/medicine_repository.dart';

class DeleteMedicineUseCase implements UseCase<void, String> {
  final MedicineRepository repository;

  DeleteMedicineUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String medicineId) async {
    return await repository.deleteMedicine(medicineId);
  }
}