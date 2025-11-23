import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/medicine_entity.dart';
import '../../../domain/usecases/medicine/add_medicine_usecase.dart';
import '../../../domain/usecases/medicine/get_medicines_usecase.dart';
import '../../../domain/usecases/medicine/update_medicine_status_usecase.dart';
import '../../../domain/usecases/medicine/delete_medicine_usecase.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/tts_service.dart';

part 'medicine_event.dart';
part 'medicine_state.dart';

class MedicineBloc extends Bloc<MedicineEvent, MedicineState> {
  final AddMedicineUseCase addMedicineUseCase;
  final GetMedicinesUseCase getMedicinesUseCase;
  final UpdateMedicineStatusUseCase updateMedicineStatusUseCase;
  final DeleteMedicineUseCase deleteMedicineUseCase;
  final NotificationService notificationService;
  final TtsService ttsService;

  MedicineBloc({
    required this.addMedicineUseCase,
    required this.getMedicinesUseCase,
    required this.updateMedicineStatusUseCase,
    required this.deleteMedicineUseCase,
    required this.notificationService,
    required this.ttsService,
  }) : super(MedicineInitial()) {
    on<LoadMedicinesEvent>(_onLoadMedicines);
    on<AddMedicineEvent>(_onAddMedicine);
    on<UpdateMedicineStatusEvent>(_onUpdateMedicineStatus);
    on<DeleteMedicineEvent>(_onDeleteMedicine);
    on<MarkMedicineTakenEvent>(_onMarkMedicineTaken);
  }

  Future<void> _onLoadMedicines(
      LoadMedicinesEvent event,
      Emitter<MedicineState> emit,
      ) async {
    emit(MedicineLoading());
    final result = await getMedicinesUseCase(event.userId);
    result.fold(
          (failure) => emit(MedicineError(message: failure.message)),
          (medicines) => emit(MedicinesLoaded(medicines: medicines)),
    );
  }

  Future<void> _onAddMedicine(
      AddMedicineEvent event,
      Emitter<MedicineState> emit,
      ) async {
    emit(MedicineLoading());
    final result = await addMedicineUseCase(event.medicine);

    await result.fold(
          (failure) async {
        emit(MedicineError(message: failure.message));
      },
          (success) async {
        // Schedule notifications for all time slots
        await _scheduleMedicineNotifications(event.medicine);

        emit(MedicineActionSuccess(message: 'Medicine added successfully'));
        add(LoadMedicinesEvent(userId: event.medicine.userId));
      },
    );
  }

  Future<void> _onUpdateMedicineStatus(
      UpdateMedicineStatusEvent event,
      Emitter<MedicineState> emit,
      ) async {
    final result = await updateMedicineStatusUseCase(
      UpdateMedicineStatusParams(
        medicineId: event.medicineId,
        date: event.date,
        status: event.status,
      ),
    );

    result.fold(
          (failure) => emit(MedicineError(message: failure.message)),
          (_) {
        emit(MedicineActionSuccess(message: 'Status updated'));
        if (state is MedicinesLoaded) {
          final currentState = state as MedicinesLoaded;
          add(LoadMedicinesEvent(
            userId: currentState.medicines.first.userId,
          ));
        }
      },
    );
  }

  Future<void> _onDeleteMedicine(
      DeleteMedicineEvent event,
      Emitter<MedicineState> emit,
      ) async {
    final result = await deleteMedicineUseCase(event.medicineId);

    result.fold(
          (failure) => emit(MedicineError(message: failure.message)),
          (_) async {
        // Cancel ALL notifications for this medicine (all time slots)
        await _cancelMedicineNotifications(event.medicineId);

        emit(MedicineActionSuccess(message: 'Medicine deleted'));
        if (state is MedicinesLoaded) {
          final currentState = state as MedicinesLoaded;
          add(LoadMedicinesEvent(
            userId: currentState.medicines.first.userId,
          ));
        }
      },
    );
  }

  Future<void> _onMarkMedicineTaken(
      MarkMedicineTakenEvent event,
      Emitter<MedicineState> emit,
      ) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    add(UpdateMedicineStatusEvent(
      medicineId: event.medicineId,
      date: today,
      status: MedicineStatus.taken,
    ));

    if (event.voiceEnabled) {
      await ttsService.speak('Medicine marked as taken. Great job!');
    }
  }

  // ===========================================================================
  // SCHEDULE NOTIFICATIONS (Correct signature - no repeatDaily param)
  // ===========================================================================
  Future<void> _scheduleMedicineNotifications(MedicineEntity medicine) async {
    try {
      await notificationService.scheduleMedicineReminder(
        medicineId: medicine.id,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        timesOfDay: medicine.timesOfDay,
        startDate: medicine.startDate,
        // repeatDaily removed — daily repeat is automatic via matchDateTimeComponents
      );
      print('Notifications scheduled for medicine: ${medicine.name}');
    } catch (e) {
      print('Failed to schedule notifications: $e');
    }
  }

  // ===========================================================================
  // CANCEL ALL NOTIFICATIONS FOR A MEDICINE (All time slots)
  // ===========================================================================
  Future<void> _cancelMedicineNotifications(String medicineId) async {
    try {
      final pending = await notificationService.getPendingNotifications();
      final idsToCancel = pending
          .where((n) => n.payload?.contains(medicineId) == true)
          .map((n) => n.id)
          .toList();

      for (int id in idsToCancel) {
        await notificationService.cancelNotification(id);
      }

      // Also cancel any old-style ones using hashCode (fallback)
      await notificationService.cancelNotification(medicineId.hashCode);
      await notificationService.cancelNotification((medicineId + '08:00').hashCode);
      await notificationService.cancelNotification((medicineId + '20:00').hashCode);
      // Add more if you have fixed times

      print('Cancelled ${idsToCancel.length} notifications for medicine: $medicineId');
    } catch (e) {
      print('Error cancelling notifications: $e');
    }
  }
}