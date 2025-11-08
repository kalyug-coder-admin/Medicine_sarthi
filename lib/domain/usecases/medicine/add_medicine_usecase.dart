import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/medicine_entity.dart';
import '../../repositories/medicine_repository.dart';

class AddMedicineUseCase implements UseCase<void, MedicineEntity> {
  final MedicineRepository repository;

  AddMedicineUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MedicineEntity medicine) async {
    return await repository.addMedicine(medicine);
  }
}