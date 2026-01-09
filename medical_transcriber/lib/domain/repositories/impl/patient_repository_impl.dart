import 'package:flutter/foundation.dart';
import 'package:medical_transcriber/domain/repositories/patient_repository.dart';
import '../../../data/datasources/patient_remote_data_source.dart';
import '../../models/patient.dart';
import '../../models/session_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remote;

  PatientRepositoryImpl(this.remote);

  @override
  Future<List<Patient>> getPatients(String userId) async {
    final patients = await remote.getPatients(userId);
    return patients.map((e) => Patient.fromJson(e)).toList();
  }

  @override
  Future<Patient> createPatient(String name, String userId) async {
    final patient = await remote.createPatient(name, userId);
    return Patient.fromJson(patient);
  }

  @override
  Future<Patient> getPatientsDetails(String patientId) async {
    final patient = await remote.getPatientDetails(patientId);
    return Patient.fromJson(patient);
  }

  @override
  Future<List<SessionModel>> getPatientSessions(String patientId) async {
    final sessions = await remote.getPatientSessions(patientId);
    try {
      return sessions.map((e) => SessionModel.fromJson(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PatientRepositoryImpl: error parsing sessions: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String> getPatientTranscription(String sessionId) {
    try {
      return remote.getPatientTranscription(sessionId);
    } catch (e) {
      throw Exception('Failed to get patient transcription: $e');
    }
  }
}