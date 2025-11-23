import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/remote/appointment_remote_datasource.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> addAppointment(
      AppointmentEntity appointment,
      ) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      await remoteDataSource.addAppointment(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to add appointment'));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getAppointments(
      String userId,
      ) async {
    try {
      final appointments = await remoteDataSource.getAppointments(userId);
      return Right(appointments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get appointments'));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(
      String appointmentId,
      ) async {
    try {
      final appointment = await remoteDataSource.getAppointmentById(appointmentId);
      return Right(appointment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get appointment'));
    }
  }

  @override
  Future<Either<Failure, void>> updateAppointment(
      AppointmentEntity appointment,
      ) async {
    try {
      final model = AppointmentModel.fromEntity(appointment);
      await remoteDataSource.updateAppointment(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to update appointment'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(String appointmentId) async {
    try {
      await remoteDataSource.deleteAppointment(appointmentId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to delete appointment'));
    }
  }

  @override
  Stream<List<AppointmentEntity>> watchAppointments(String userId) {
    return remoteDataSource.watchAppointments(userId);
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUpcomingAppointments(
      String userId,
      ) async {
    try {
      final appointments = await remoteDataSource.getAppointments(userId);
      final now = DateTime.now();

      final upcoming = appointments.where((appointment) {
        return appointment.appointmentDate.isAfter(now);
      }).toList();

      return Right(upcoming);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get upcoming appointments'));
    }
  }
}