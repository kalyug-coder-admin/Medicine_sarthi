import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../../domain/entities/medicine_entity.dart';
import '../../models/medicine_model.dart';

abstract class MedicineRemoteDataSource {
  Future<void> addMedicine(MedicineModel medicine);
  Future<List<MedicineModel>> getMedicines(String userId);
  Future<MedicineModel> getMedicineById(String medicineId);
  Future<void> updateMedicine(MedicineModel medicine);
  Future<void> deleteMedicine(String medicineId);
  Future<void> updateMedicineStatus({
    required String medicineId,
    required String date,
    required MedicineStatus status,
  });
  Stream<List<MedicineModel>> watchMedicines(String userId);
}

class MedicineRemoteDataSourceImpl implements MedicineRemoteDataSource {
  final FirebaseFirestore firestore;

  MedicineRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addMedicine(MedicineModel medicine) async {
    try {
      await firestore
          .collection('medicines')
          .doc(medicine.id)
          .set(medicine.toJson());
    } catch (e) {
      throw ServerException('Failed to add medicine: $e');
    }
  }

  @override
  Future<List<MedicineModel>> getMedicines(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('medicines')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicineModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get medicines: $e');
    }
  }

  @override
  Future<MedicineModel> getMedicineById(String medicineId) async {
    try {
      final doc = await firestore
          .collection('medicines')
          .doc(medicineId)
          .get();

      if (!doc.exists) {
        throw ServerException('Medicine not found');
      }

      return MedicineModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get medicine: $e');
    }
  }

  @override
  Future<void> updateMedicine(MedicineModel medicine) async {
    try {
      await firestore
          .collection('medicines')
          .doc(medicine.id)
          .update(medicine.toJson());
    } catch (e) {
      throw ServerException('Failed to update medicine: $e');
    }
  }

  @override
  Future<void> deleteMedicine(String medicineId) async {
    try {
      await firestore
          .collection('medicines')
          .doc(medicineId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete medicine: $e');
    }
  }

  @override
  Future<void> updateMedicineStatus({
    required String medicineId,
    required String date,
    required MedicineStatus status,
  }) async {
    try {
      await firestore
          .collection('medicines')
          .doc(medicineId)
          .update({
        'statusHistory.$date': status.toString().split('.').last,
      });
    } catch (e) {
      throw ServerException('Failed to update medicine status: $e');
    }
  }

  @override
  Stream<List<MedicineModel>> watchMedicines(String userId) {
    return firestore
        .collection('medicines')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => MedicineModel.fromJson(doc.data()))
        .toList());
  }
}