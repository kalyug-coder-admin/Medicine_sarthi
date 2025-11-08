import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/exceptions.dart';
import '../../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<void> addAppointment(AppointmentModel appointment);
  Future<List<AppointmentModel>> getAppointments(String userId);
  Future<AppointmentModel> getAppointmentById(String appointmentId);
  Future<void> updateAppointment(AppointmentModel appointment);
  Future<void> deleteAppointment(String appointmentId);
  Stream<List<AppointmentModel>> watchAppointments(String userId);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore firestore;

  AppointmentRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      await firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toJson());
    } catch (e) {
      throw ServerException('Failed to add appointment: $e');
    }
  }

  @override
  Future<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get appointments: $e');
    }
  }

  @override
  Future<AppointmentModel> getAppointmentById(String appointmentId) async {
    try {
      final doc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        throw ServerException('Appointment not found');
      }

      return AppointmentModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException('Failed to get appointment: $e');
    }
  }

  @override
  Future<void> updateAppointment(AppointmentModel appointment) async {
    try {
      await firestore
          .collection('appointments')
          .doc(appointment.id)
          .update(appointment.toJson());
    } catch (e) {
      throw ServerException('Failed to update appointment: $e');
    }
  }

  @override
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await firestore
          .collection('appointments')
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete appointment: $e');
    }
  }

  @override
  Stream<List<AppointmentModel>> watchAppointments(String userId) {
    return firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .orderBy('appointmentDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromJson(doc.data()))
            .toList());
  }
}
