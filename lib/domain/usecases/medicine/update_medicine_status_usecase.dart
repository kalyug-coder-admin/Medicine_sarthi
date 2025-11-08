import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/medicine_entity.dart';
import '../../repositories/medicine_repository.dart';

class UpdateMedicineStatusUseCase
    implements UseCase<void, UpdateMedicineStatusParams> {
  final MedicineRepository repository;

  UpdateMedicineStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateMedicineStatusParams params) async {
    return await repository.updateMedicineStatus(
      medicineId: params.medicineId,
      date: params.date,
      status: params.status,
    );
  }
}

class UpdateMedicineStatusParams extends Equatable {
  final String medicineId;
  final String date;
  final MedicineStatus status;

  const UpdateMedicineStatusParams({
    required this.medicineId,
    required this.date,
    required this.status,
  });

  @override
  List<Object> get props => [medicineId, date, status];
}