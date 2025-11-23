// lib/data/datasources/remote/auth_remote_datasource.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/user_entity.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required UserRole role,
    String? linkedElderlyId,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel> getCurrentUser();
  Future<String> generateFamilyLinkCode(String userId);
  Future<void> linkFamilyMember(String elderlyUserId, String familyUserId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('Sign in failed');
      }

      final uid = credential.user!.uid;
      return await _getOrCreateUser(uid, email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw ServerException('Sign in failed: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required UserRole role,
    String? linkedElderlyId,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw ServerException('Sign up failed');
      }

      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        age: age,
        gender: gender,
        role: role,
        linkedElderlyId: linkedElderlyId,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.id).set(user.toJson());

      if (role == UserRole.family && linkedElderlyId != null) {
        await linkFamilyMember(linkedElderlyId, user.id);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw ServerException('Google sign in cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) throw ServerException('Google sign in failed');

      return await _getOrCreateUser(
        userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
      );
    } catch (e) {
      throw ServerException('Google sign in failed: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw ServerException('Sign out failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) throw ServerException('No user logged in');
    return await _getOrCreateUser(currentUser.uid, email: currentUser.email);
  }

  @override
  Future<String> generateFamilyLinkCode(String userId) async {
    try {
      final code = DateTime.now().millisecondsSinceEpoch.toString();
      await firestore.collection('link_codes').doc(code).set({
        'elderlyUserId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 24))),
      });
      return code;
    } catch (e) {
      throw ServerException('Failed to generate link code');
    }
  }

  @override
  Future<void> linkFamilyMember(String elderlyUserId, String familyUserId) async {
    try {
      final batch = firestore.batch();

      final elderlyRef = firestore.collection('users').doc(elderlyUserId);
      batch.update(elderlyRef, {
        'linkedFamilyIds': FieldValue.arrayUnion([familyUserId])
      });

      final familyRef = firestore.collection('users').doc(familyUserId);
      batch.update(familyRef, {'linkedElderlyId': elderlyUserId});

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to link family member');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helper: Get user or create default if missing
  // ─────────────────────────────────────────────────────────────────────
  Future<UserModel> _getOrCreateUser(
      String uid, {
        String? email,
        String? name,
        String? photoUrl,
      }) async {
    final docRef = firestore.collection('users').doc(uid);
    final doc = await docRef.get();

    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }

    // Create default user
    final defaultUser = UserModel(
      id: uid,
      email: email ?? '$uid@unknown.com',
      name: name ?? 'User',
      age: 0,
      gender: 'Other',
      bloodGroup: null,
      role: UserRole.elderly,
      linkedFamilyIds: null,
      linkedElderlyId: null,
      emergencyContact: null,
      profileImageUrl: photoUrl,
      createdAt: DateTime.now(),
    );

    try {
      await docRef.set(defaultUser.toJson());
    } catch (e) {
      print('Failed to create default user: $e'); // Debug
      throw ServerException('Permission denied: Could not create profile');
    }

    final newDoc = await docRef.get();
    if (!newDoc.exists) {
      throw ServerException('Failed to create user profile');
    }

    return UserModel.fromJson(newDoc.data()!);
  }
}