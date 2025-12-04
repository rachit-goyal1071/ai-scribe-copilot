import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientId;
  const PatientDetailsPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    // context.read<PatientBloc>().add(LoadPatientDetailsEvent(patientId: patientId));
    context.read<PatientBloc>().add(LoadPatientSessionsEvent(patientId: patientId));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (canPop, result) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/patients',
          (route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Patient Details"),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(
              context,
              '/recording',
              arguments: {
                'patientId': patientId,
              },
            ),
        ),
        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoadingState) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientsSessionsLoadedState) {
              final sessions = state.sessions;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return ListTile(
                      title: Text("Session ${session.id}"),
                      subtitle: Text(session.sessionSummary ?? 'Loading summary...'),
                    );
                  },
                ),
              );
            } else if (state is PatientErrorState) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('No details available.'));
          },
        )
      ),
    );
  }
}
