// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineModel _$MedicineModelFromJson(Map<String, dynamic> json) =>
    MedicineModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: $enumDecode(_$FrequencyEnumMap, json['frequency']),
      timesOfDay: (json['timesOfDay'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      instructions: json['instructions'] as String?,
      voiceReminder: json['voiceReminder'] as bool? ?? true,
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      statusHistory: (json['statusHistory'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$MedicineStatusEnumMap, e)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MedicineModelToJson(MedicineModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'dosage': instance.dosage,
      'frequency': _$FrequencyEnumMap[instance.frequency]!,
      'timesOfDay': instance.timesOfDay,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'instructions': instance.instructions,
      'voiceReminder': instance.voiceReminder,
      'notificationEnabled': instance.notificationEnabled,
      'statusHistory': instance.statusHistory
          ?.map((k, e) => MapEntry(k, _$MedicineStatusEnumMap[e]!)),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$FrequencyEnumMap = {
  Frequency.daily: 'daily',
  Frequency.twiceDaily: 'twiceDaily',
  Frequency.threeTimesDaily: 'threeTimesDaily',
  Frequency.weekly: 'weekly',
  Frequency.asNeeded: 'asNeeded',
};

const _$MedicineStatusEnumMap = {
  MedicineStatus.taken: 'taken',
  MedicineStatus.missed: 'missed',
  MedicineStatus.pending: 'pending',
  MedicineStatus.skipped: 'skipped',
};
