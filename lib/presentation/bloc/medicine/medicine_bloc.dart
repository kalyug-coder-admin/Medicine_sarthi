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
        // Schedule notifications for this medicine
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
          (_) {
        // Cancel notifications for this medicine
        notificationService.cancelNotification(event.medicineId.hashCode);
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

    // Speak confirmation if voice is enabled
    if (event.voiceEnabled) {
      await ttsService.speak('Medicine marked as taken. Great job!');
    }
  }

  Future<void> _scheduleMedicineNotifications(MedicineEntity medicine) async {
    for (final time in medicine.timesOfDay) {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final scheduledTime = DateTime.now().copyWith(
        hour: hour,
        minute: minute,
        second: 0,
      );

      await notificationService.scheduleMedicineReminder(
        id: '${medicine.id}_$time'.hashCode,
        medicineName: medicine.name,
        dosage: medicine.dosage,
        scheduledTime: scheduledTime,
      );
    }
  }
}