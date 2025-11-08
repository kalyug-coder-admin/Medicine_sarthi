import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/medicine_entity.dart';

part 'medicine_model.g.dart';

@JsonSerializable()
class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.dosage,
    required super.frequency,
    required super.timesOfDay,
    required super.startDate,
    super.endDate,
    super.instructions,
    super.voiceReminder,
    super.notificationEnabled,
    super.statusHistory,
    required super.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) =>
      _$MedicineModelFromJson(json);

  Map<String, dynamic> toJson() => _$MedicineModelToJson(this);

  factory MedicineModel.fromEntity(MedicineEntity entity) {
    return MedicineModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      dosage: entity.dosage,
      frequency: entity.frequency,
      timesOfDay: entity.timesOfDay,
      startDate: entity.startDate,
      endDate: entity.endDate,
      instructions: entity.instructions,
      voiceReminder: entity.voiceReminder,
      notificationEnabled: entity.notificationEnabled,
      statusHistory: entity.statusHistory,
      createdAt: entity.createdAt,
    );
  }

  MedicineEntity toEntity() => this;
}