import 'package:equatable/equatable.dart';

enum MedicineStatus { taken, missed, pending, skipped }
enum Frequency { daily, twiceDaily, threeTimesDaily, weekly, asNeeded }

class MedicineEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final Frequency frequency;
  final List<String> timesOfDay; // e.g., ["08:00", "14:00", "20:00"]
  final DateTime startDate;
  final DateTime? endDate;
  final String? instructions;
  final bool voiceReminder;
  final bool notificationEnabled;
  final Map<String, MedicineStatus>? statusHistory; // date -> status
  final DateTime createdAt;

  const MedicineEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.timesOfDay,
    required this.startDate,
    this.endDate,
    this.instructions,
    this.voiceReminder = true,
    this.notificationEnabled = true,
    this.statusHistory,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    dosage,
    frequency,
    timesOfDay,
    startDate,
    endDate,
    instructions,
    voiceReminder,
    notificationEnabled,
    statusHistory,
    createdAt,
  ];
}