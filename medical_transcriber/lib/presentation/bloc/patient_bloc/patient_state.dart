part of 'patient_bloc.dart';

@immutable
sealed class PatientState {}

final class PatientInitial extends PatientState {}

class PatientLoadingState extends PatientState {}

class PatientLoadedSuccessState extends PatientState {
  final List<Patient> patients;
  PatientLoadedSuccessState({required this.patients});
}

class PatientCreatedState extends PatientState {
  final Patient patient;
  PatientCreatedState({required this.patient});
}

class PatientDetailsLoadedState extends PatientState {
  final Patient patient;
  PatientDetailsLoadedState({required this.patient});
}

class PatientsSessionsLoadedState extends PatientState {
  final List<SessionModel> sessions;
  PatientsSessionsLoadedState({required this.sessions});
}

class PatientErrorState extends PatientState {
  final String message;
  PatientErrorState({required this.message});
}
