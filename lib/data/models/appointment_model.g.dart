// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) =>
    AppointmentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      doctorName: json['doctorName'] as String,
      specialization: json['specialization'] as String?,
      hospital: json['hospital'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      appointmentTime: json['appointmentTime'] as String,
      notes: json['notes'] as String?,
      prescriptionUrl: json['prescriptionUrl'] as String?,
      reminderSet: json['reminderSet'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AppointmentModelToJson(AppointmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'doctorName': instance.doctorName,
      'specialization': instance.specialization,
      'hospital': instance.hospital,
      'appointmentDate': instance.appointmentDate.toIso8601String(),
      'appointmentTime': instance.appointmentTime,
      'notes': instance.notes,
      'prescriptionUrl': instance.prescriptionUrl,
      'reminderSet': instance.reminderSet,
      'createdAt': instance.createdAt.toIso8601String(),
    };
