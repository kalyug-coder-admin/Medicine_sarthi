import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, void>> addAppointment(AppointmentEntity appointment);
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(String userId);
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String appointmentId);
  Future<Either<Failure, void>> updateAppointment(AppointmentEntity appointment);
  Future<Either<Failure, void>> deleteAppointment(String appointmentId);
  Stream<List<AppointmentEntity>> watchAppointments(String userId);
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments(String userId);
}
