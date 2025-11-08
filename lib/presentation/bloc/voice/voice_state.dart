part of 'voice_bloc.dart';

abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object?> get props => [];
}

class VoiceInitial extends VoiceState {}

class VoiceListening extends VoiceState {}

class VoiceProcessing extends VoiceState {}

class VoiceResponseReady extends VoiceState {
  final String response;

  const VoiceResponseReady({required this.response});

  @override
  List<Object> get props => [response];
}

class VoiceError extends VoiceState {
  final String message;

  const VoiceError({required this.message});

  @override
  List<Object> get props => [message];
}