import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String userId);
  Future<void> updateUser(UserModel user);
  Future<String> uploadProfileImage(String userId, String imagePath);
  Future<String> uploadPrescription(String userId, String filePath);
  Future<List<UserModel>> getLinkedFamilyMembers(String elderlyUserId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  UserRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw ServerException('User not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get user: $e');
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw ServerException('Failed to update user: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('users/$userId/profile/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      // Update user document with new image URL
      await firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      throw ServerException('Failed to upload profile image: $e');
    }
  }

  @override
  Future<String> uploadPrescription(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = 'prescription_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final ref = storage.ref().child('prescriptions/$userId/$fileName');

      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw ServerException('Failed to upload prescription: $e');
    }
  }

  @override
  Future<List<UserModel>> getLinkedFamilyMembers(String elderlyUserId) async {
    try {
      final querySnapshot = await firestore
          .collection('users')
          .where('linkedElderlyId', isEqualTo: elderlyUserId)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get linked family members: $e');
    }
  }
}