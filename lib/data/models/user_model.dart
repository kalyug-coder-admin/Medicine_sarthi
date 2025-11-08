import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.age,
    required super.gender,
    super.bloodGroup,
    required super.role,
    super.linkedFamilyIds,
    super.linkedElderlyId,
    super.emergencyContact,
    super.profileImageUrl,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      age: entity.age,
      gender: entity.gender,
      bloodGroup: entity.bloodGroup,
      role: entity.role,
      linkedFamilyIds: entity.linkedFamilyIds,
      linkedElderlyId: entity.linkedElderlyId,
      emergencyContact: entity.emergencyContact,
      profileImageUrl: entity.profileImageUrl,
      createdAt: entity.createdAt,
    );
  }

  UserEntity toEntity() => this;
}