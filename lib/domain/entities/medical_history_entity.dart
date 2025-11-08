import 'package:equatable/equatable.dart';

class MedicalHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<String> pastSurgeries;
  final String? bloodPressure;
  final String? sugarLevel;
  final String? weight;
  final String? height;
  final List<String> prescriptionUrls;
  final DateTime lastUpdated;

  const MedicalHistoryEntity({
    required this.id,
    required this.userId,
    this.chronicConditions = const [],
    this.allergies = const [],
    this.pastSurgeries = const [],
    this.bloodPressure,
    this.sugarLevel,
    this.weight,
    this.height,
    this.prescriptionUrls = const [],
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    chronicConditions,
    allergies,
    pastSurgeries,
    bloodPressure,
    sugarLevel,
    weight,
    height,
    prescriptionUrls,
    lastUpdated,
  ];
}