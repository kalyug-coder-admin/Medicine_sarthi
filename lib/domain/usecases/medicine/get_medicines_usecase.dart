import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/medicine_entity.dart';
import '../../repositories/medicine_repository.dart';

class GetMedicinesUseCase implements UseCase<List<MedicineEntity>, String> {
  final MedicineRepository repository;

  GetMedicinesUseCase(this.repository);

  @override
  Future<Either<Failure, List<MedicineEntity>>> call(String userId) async {
    return await repository.getMedicines(userId);
  }
}