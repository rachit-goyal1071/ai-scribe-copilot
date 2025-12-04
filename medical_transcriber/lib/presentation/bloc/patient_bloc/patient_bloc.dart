import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:medical_transcriber/domain/models/patient.dart';
import 'package:medical_transcriber/domain/models/session_model.dart';
import 'package:medical_transcriber/domain/repositories/patient_repository.dart';
import 'package:meta/meta.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final PatientRepository repo;
  PatientBloc(this.repo) : super(PatientInitial()) {
    on<LoadPatientEvent>(loadPatientEvent);
    on<AddPatientEvent>(addPatientEvent);
    on<LoadPatientDetailsEvent>(loadPatientDetailsEvent);
    on<LoadPatientSessionsEvent>(loadPatientSessionsEvent);
  }

  Future<void> loadPatientEvent(LoadPatientEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoadingState());
    try {
      final patients = await repo.getPatients(event.userId);
      emit(PatientLoadedSuccessState(patients: patients));
    } catch (e) {
      emit(PatientErrorState(message: e.toString()));
    }
  }

  FutureOr<void> addPatientEvent(AddPatientEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoadingState());
    try {
      print('Adding patient for userId: ${event.userId} with name: ${event.name}');
      final patient = await repo.createPatient(event.name, event.userId);
      emit(PatientCreatedState(patient: patient));
    } catch (e) {
      emit(PatientErrorState(message: e.toString()));
    }
  }


  FutureOr<void> loadPatientDetailsEvent(LoadPatientDetailsEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoadingState());
    try {
      final patient = await repo.getPatientsDetails(event.patientId);
      emit(PatientDetailsLoadedState(patient: patient));
    } catch (e) {
      emit(PatientErrorState(message: e.toString()));
    }
  }

  FutureOr<void> loadPatientSessionsEvent(LoadPatientSessionsEvent event, Emitter<PatientState> emit) async {
    emit(PatientLoadingState());
    try {
      final sessions = await repo.getPatientSessions(event.patientId);
      print('Loaded ${sessions.length} sessions for patientId: ${event.patientId}');
      emit(PatientsSessionsLoadedState(sessions: sessions));
    } catch (e) {
      emit(PatientErrorState(message: e.toString()));
    }
  }
}
