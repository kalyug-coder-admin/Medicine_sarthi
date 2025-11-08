import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/stt_service.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/services/ai_service.dart';
import '../../../domain/repositories/medicine_repository.dart';
import '../../../domain/repositories/appointment_repository.dart';

part 'voice_event.dart';
part 'voice_state.dart';

class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final SttService sttService;
  final TtsService ttsService;
  final AiService aiService;
  final MedicineRepository medicineRepository;
  final AppointmentRepository appointmentRepository;

  VoiceBloc({
    required this.sttService,
    required this.ttsService,
    required this.aiService,
    required this.medicineRepository,
    required this.appointmentRepository,
  }) : super(VoiceInitial()) {
    on<StartListeningEvent>(_onStartListening);
    on<StopListeningEvent>(_onStopListening);
    on<ProcessVoiceCommandEvent>(_onProcessVoiceCommand);
  }

  Future<void> _onStartListening(
      StartListeningEvent event,
      Emitter<VoiceState> emit,
      ) async {
    emit(VoiceListening());

    try {
      await sttService.startListening(
        onResult: (text) {
          add(ProcessVoiceCommandEvent(command: text));
        },
      );
    } catch (e) {
      emit(VoiceError(message: 'Failed to start listening: $e'));
    }
  }

  Future<void> _onStopListening(
      StopListeningEvent event,
      Emitter<VoiceState> emit,
      ) async {
    await sttService.stopListening();
    emit(VoiceInitial());
  }

  Future<void> _onProcessVoiceCommand(
      ProcessVoiceCommandEvent event,
      Emitter<VoiceState> emit,
      ) async {
    emit(VoiceProcessing());

    try {
      // Stop listening if active
      if (sttService.isListening) {
        await sttService.stopListening();
      }

      // Process the command with AI
      final response = await aiService.getChatResponse(event.command);

      // Speak the response
      await ttsService.speak(response);

      emit(VoiceResponseReady(response: response));
    } catch (e) {
      emit(VoiceError(message: 'Failed to process command: $e'));
    }
  }
}