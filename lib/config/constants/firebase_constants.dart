class FirebaseConstants {
  // Collection names
  static const String usersCollection = 'users';
  static const String medicinesCollection = 'medicines';
  static const String appointmentsCollection = 'appointments';
  static const String medicalHistoryCollection = 'medical_history';
  static const String linkCodesCollection = 'link_codes';

  // Storage paths
  static const String profileImagesPath = 'users/{userId}/profile';
  static const String prescriptionsPath = 'prescriptions/{userId}';

  // Field names - Users
  static const String userIdField = 'id';
  static const String userEmailField = 'email';
  static const String userNameField = 'name';
  static const String userAgeField = 'age';
  static const String userGenderField = 'gender';
  static const String userRoleField = 'role';
  static const String linkedFamilyIdsField = 'linkedFamilyIds';
  static const String linkedElderlyIdField = 'linkedElderlyId';

  // Field names - Medicines
  static const String medicineUserIdField = 'userId';
  static const String medicineNameField = 'name';
  static const String medicineCreatedAtField = 'createdAt';

  // Field names - Appointments
  static const String appointmentUserIdField = 'userId';
  static const String appointmentDateField = 'appointmentDate';

  // Error messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authError = 'Authentication error. Please sign in again.';
  static const String permissionError = 'You don\'t have permission to perform this action.';

  // Cache durations
  static const Duration cacheValidDuration = Duration(minutes: 5);
  static const Duration tokenRefreshDuration = Duration(minutes: 50);
}