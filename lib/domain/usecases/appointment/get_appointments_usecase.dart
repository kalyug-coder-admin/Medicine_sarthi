import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/appointment_repository.dart';

class GetAppointmentsUseCase implements UseCase<List<AppointmentEntity>, String> {
  final AppointmentRepository repository;

  GetAppointmentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(String userId) async {
    return await repository.getAppointments(userId);
  }
}