import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../../domain/usecases/appointment/add_appointment_usecase.dart';
import '../../../domain/usecases/appointment/get_appointments_usecase.dart';
import '../../../domain/usecases/appointment/delete_appointment_usecase.dart';
import '../../../core/services/notification_service.dart';

part 'appointment_event_state.dart';


class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final AddAppointmentUseCase addAppointmentUseCase;
  final GetAppointmentsUseCase getAppointmentsUseCase;
  final DeleteAppointmentUseCase deleteAppointmentUseCase;
  final NotificationService notificationService;

  AppointmentBloc({
    required this.addAppointmentUseCase,
    required this.getAppointmentsUseCase,
    required this.deleteAppointmentUseCase,
    required this.notificationService,
  }) : super(AppointmentInitial()) {
    on<LoadAppointmentsEvent>(_onLoadAppointments);
    on<AddAppointmentEvent>(_onAddAppointment);
    on<DeleteAppointmentEvent>(_onDeleteAppointment);
  }

  Future<void> _onLoadAppointments(
      LoadAppointmentsEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(AppointmentLoading());

    final result = await getAppointmentsUseCase(event.userId);

    result.fold(
          (failure) => emit(AppointmentError(message: failure.message)),
          (appointments) => emit(AppointmentsLoaded(appointments: appointments)),
    );
  }

  Future<void> _onAddAppointment(
      AddAppointmentEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    emit(AppointmentLoading());

    final result = await addAppointmentUseCase(event.appointment);

    await result.fold(
          (failure) async {
        emit(AppointmentError(message: failure.message));
      },
          (success) async {
        // Schedule appointment notification
        if (event.appointment.reminderSet) {
          await _scheduleAppointmentNotification(event.appointment);
        }
        emit(AppointmentActionSuccess(message: 'Appointment added successfully'));
        add(LoadAppointmentsEvent(userId: event.appointment.userId));
      },
    );
  }

  Future<void> _onDeleteAppointment(
      DeleteAppointmentEvent event,
      Emitter<AppointmentState> emit,
      ) async {
    final result = await deleteAppointmentUseCase(event.appointmentId);

    result.fold(
          (failure) => emit(AppointmentError(message: failure.message)),
          (_) {
        // Cancel notification
        notificationService.cancelNotification(event.appointmentId.hashCode);
        emit(AppointmentActionSuccess(message: 'Appointment deleted'));
        if (state is AppointmentsLoaded) {
          final currentState = state as AppointmentsLoaded;
          add(LoadAppointmentsEvent(
            userId: currentState.appointments.first.userId,
          ));
        }
      },
    );
  }

  Future<void> _scheduleAppointmentNotification(
      AppointmentEntity appointment,
      ) async {
    await notificationService.scheduleAppointmentReminder(
      id: appointment.id.hashCode,
      doctorName: appointment.doctorName,
      hospital: appointment.hospital,
      scheduledTime: appointment.appointmentDate,
    );
  }
}