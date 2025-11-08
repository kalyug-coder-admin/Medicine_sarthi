part of 'appointment_bloc.dart';

abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

class LoadAppointmentsEvent extends AppointmentEvent {
  final String userId;

  const LoadAppointmentsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AddAppointmentEvent extends AppointmentEvent {
  final AppointmentEntity appointment;

  const AddAppointmentEvent({required this.appointment});

  @override
  List<Object> get props => [appointment];
}

class DeleteAppointmentEvent extends AppointmentEvent {
  final String appointmentId;

  const DeleteAppointmentEvent({required this.appointmentId});

  @override
  List<Object> get props => [appointmentId];
}

// appointment_state.dart

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentsLoaded extends AppointmentState {
  final List<AppointmentEntity> appointments;

  const AppointmentsLoaded({required this.appointments});

  @override
  List<Object> get props => [appointments];
}

class AppointmentActionSuccess extends AppointmentState {
  final String message;

  const AppointmentActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});

  @override
  List<Object> get props => [message];
}
