part of 'voice_bloc.dart';

abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class StartListeningEvent extends VoiceEvent {}

class StopListeningEvent extends VoiceEvent {}

class ProcessVoiceCommandEvent extends VoiceEvent {
  final String command;

  const ProcessVoiceCommandEvent({required this.command});

  @override
  List<Object> get props => [command];
}