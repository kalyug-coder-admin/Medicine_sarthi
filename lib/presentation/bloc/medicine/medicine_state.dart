part of 'medicine_bloc.dart';

abstract class MedicineState extends Equatable {
  const MedicineState();

  @override
  List<Object?> get props => [];
}

class MedicineInitial extends MedicineState {}

class MedicineLoading extends MedicineState {}

class MedicinesLoaded extends MedicineState {
  final List<MedicineEntity> medicines;

  const MedicinesLoaded({required this.medicines});

  @override
  List<Object> get props => [medicines];
}

class MedicineActionSuccess extends MedicineState {
  final String message;

  const MedicineActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class MedicineError extends MedicineState {
  final String message;

  const MedicineError({required this.message});

  @override
  List<Object> get props => [message];
}