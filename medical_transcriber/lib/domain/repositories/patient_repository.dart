import 'package:medical_transcriber/domain/models/patient.dart';
import 'package:medical_transcriber/domain/models/session_model.dart';

abstract class PatientRepository {
  Future<List<Patient>> getPatients(String userId);

  Future<Patient> createPatient(String name, String userId);

  Future<Patient> getPatientsDetails(String patientId);

  Future<List<SessionModel>> getPatientSessions(String patientId);

  Future<String> getPatientTranscription(String sessionId);
}