abstract class PatientRemoteDataSource {
  Future<List<dynamic>> getPatients(String userId);

  Future<Map<String, dynamic>> createPatient(String name, String userId);

  Future<Map<String, dynamic>> getPatientDetails(String patientId);

  Future<List<dynamic>> getPatientSessions(String patientId);
}
