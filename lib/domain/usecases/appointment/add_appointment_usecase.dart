import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/appointment_entity.dart';
import '../../repositories/appointment_repository.dart';

class AddAppointmentUseCase implements UseCase<void, AppointmentEntity> {
  final AppointmentRepository repository;

  AddAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AppointmentEntity appointment) async {
    return await repository.addAppointment(appointment);
  }
}
