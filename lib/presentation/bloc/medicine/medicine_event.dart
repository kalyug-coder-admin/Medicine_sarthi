part of 'medicine_bloc.dart';

abstract class MedicineEvent extends Equatable {
  const MedicineEvent();

  @override
  List<Object?> get props => [];
}

class LoadMedicinesEvent extends MedicineEvent {
  final String userId;

  const LoadMedicinesEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class AddMedicineEvent extends MedicineEvent {
  final MedicineEntity medicine;

  const AddMedicineEvent({required this.medicine});

  @override
  List<Object> get props => [medicine];
}

class UpdateMedicineStatusEvent extends MedicineEvent {
  final String medicineId;
  final String date;
  final MedicineStatus status;

  const UpdateMedicineStatusEvent({
    required this.medicineId,
    required this.date,
    required this.status,
  });

  @override
  List<Object> get props => [medicineId, date, status];
}

class DeleteMedicineEvent extends MedicineEvent {
  final String medicineId;

  const DeleteMedicineEvent({required this.medicineId});

  @override
  List<Object> get props => [medicineId];
}

class MarkMedicineTakenEvent extends MedicineEvent {
  final String medicineId;
  final bool voiceEnabled;

  const MarkMedicineTakenEvent({
    required this.medicineId,
    this.voiceEnabled = false,
  });

  @override
  List<Object> get props => [medicineId, voiceEnabled];
}