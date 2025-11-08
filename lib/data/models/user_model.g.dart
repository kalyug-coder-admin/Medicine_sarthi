// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      gender: json['gender'] as String,
      bloodGroup: json['bloodGroup'] as String?,
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      linkedFamilyIds: (json['linkedFamilyIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      linkedElderlyId: json['linkedElderlyId'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'gender': instance.gender,
      'bloodGroup': instance.bloodGroup,
      'role': _$UserRoleEnumMap[instance.role]!,
      'linkedFamilyIds': instance.linkedFamilyIds,
      'linkedElderlyId': instance.linkedElderlyId,
      'emergencyContact': instance.emergencyContact,
      'profileImageUrl': instance.profileImageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$UserRoleEnumMap = {
  UserRole.elderly: 'elderly',
  UserRole.family: 'family',
};
