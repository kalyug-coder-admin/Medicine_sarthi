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

      return await _getUserData(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'Authentication failed');
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

      // If family member, link to elderly user
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw ServerException('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
      await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw ServerException('Google sign in failed');
      }

      // Check if user exists
      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!);
      }

      // Create new user
      final user = UserModel(
        id: userCredential.user!.uid,
        email: userCredential.user!.email!,
        name: userCredential.user!.displayName ?? 'User',
        age: 0,
        gender: '',
        role: UserRole.elderly,
        profileImageUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
      );

      await firestore.collection('users').doc(user.id).set(user.toJson());

      return user;
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
    try {
      final currentUser = firebaseAuth.currentUser;

      if (currentUser == null) {
        throw ServerException('No user logged in');
      }

      return await _getUserData(currentUser.uid);
    } catch (e) {
      throw ServerException('Failed to get current user');
    }
  }

  @override
  Future<String> generateFamilyLinkCode(String userId) async {
    try {
      final code = DateTime.now().millisecondsSinceEpoch.toString();

      await firestore.collection('link_codes').doc(code).set({
        'elderlyUserId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': DateTime.now().add(const Duration(hours: 24)),
      });

      return code;
    } catch (e) {
      throw ServerException('Failed to generate link code');
    }
  }

  @override
  Future<void> linkFamilyMember(
      String elderlyUserId,
      String familyUserId,
      ) async {
    try {
      await firestore.collection('users').doc(elderlyUserId).update({
        'linkedFamilyIds': FieldValue.arrayUnion([familyUserId]),
      });

      await firestore.collection('users').doc(familyUserId).update({
        'linkedElderlyId': elderlyUserId,
      });
    } catch (e) {
      throw ServerException('Failed to link family member');
    }
  }

  Future<UserModel> _getUserData(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw ServerException('User data not found');
    }

    return UserModel.fromJson(doc.data()!);
  }
}