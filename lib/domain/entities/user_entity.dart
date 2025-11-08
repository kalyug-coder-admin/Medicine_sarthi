import 'package:equatable/equatable.dart';

enum UserRole { elderly, family }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final int age;
  final String gender;
  final String? bloodGroup;
  final UserRole role;
  final List<String>? linkedFamilyIds;
  final String? linkedElderlyId;
  final String? emergencyContact;
  final String? profileImageUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    this.bloodGroup,
    required this.role,
    this.linkedFamilyIds,
    this.linkedElderlyId,
    this.emergencyContact,
    this.profileImageUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    age,
    gender,
    bloodGroup,
    role,
    linkedFamilyIds,
    linkedElderlyId,
    emergencyContact,
    profileImageUrl,
    createdAt,
  ];
}