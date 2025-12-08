part of 'patient_bloc.dart';

@immutable
sealed class PatientEvent {}

class LoadPatientEvent extends PatientEvent {
  final String userId;
  LoadPatientEvent({required this.userId});
}

class AddPatientEvent extends PatientEvent {
  final String name;
  final String userId;
  AddPatientEvent({required this.userId, required this.name});
}

class LoadPatientDetailsEvent extends PatientEvent {
  final String patientId;
  LoadPatientDetailsEvent({required this.patientId});
}

class LoadPatientSessionsEvent extends PatientEvent {
  final String patientId;
  LoadPatientSessionsEvent({required this.patientId});
}

class LoadSessionRecordingsEvent extends PatientEvent {
  final String sessionId;
  LoadSessionRecordingsEvent({required this.sessionId});
}