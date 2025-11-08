import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/appointment_entity.dart';

part 'appointment_model.g.dart';

@JsonSerializable()
class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.userId,
    required super.doctorName,
    super.specialization,
    required super.hospital,
    required super.appointmentDate,
    required super.appointmentTime,
    super.notes,
    super.prescriptionUrl,
    super.reminderSet,
    required super.createdAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentModelToJson(this);

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      userId: entity.userId,
      doctorName: entity.doctorName,
      specialization: entity.specialization,
      hospital: entity.hospital,
      appointmentDate: entity.appointmentDate,
      appointmentTime: entity.appointmentTime,
      notes: entity.notes,
      prescriptionUrl: entity.prescriptionUrl,
      reminderSet: entity.reminderSet,
      createdAt: entity.createdAt,
    );
  }

  AppointmentEntity toEntity() => this;
}