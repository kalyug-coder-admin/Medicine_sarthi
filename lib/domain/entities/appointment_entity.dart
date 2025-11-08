import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String userId;
  final String doctorName;
  final String? specialization;
  final String hospital;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String? notes;
  final String? prescriptionUrl;
  final bool reminderSet;
  final DateTime createdAt;

  const AppointmentEntity({
    required this.id,
    required this.userId,
    required this.doctorName,
    this.specialization,
    required this.hospital,
    required this.appointmentDate,
    required this.appointmentTime,
    this.notes,
    this.prescriptionUrl,
    this.reminderSet = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    doctorName,
    specialization,
    hospital,
    appointmentDate,
    appointmentTime,
    notes,
    prescriptionUrl,
    reminderSet,
    createdAt,
  ];
}