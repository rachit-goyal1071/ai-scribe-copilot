import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/main.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage>{

  @override
  void initState() {
    super.initState();
    userIdMain ??= (context.read<UserBloc>().state as UserLoadedSuccessState).userId;
    context.read<PatientBloc>().add(LoadPatientEvent(userId: userIdMain!));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 0,
          title: const Text('Patients'),
          leading: SizedBox.shrink(),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/settings',
                );
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pushNamed(context, '/add-patient'),
            child: const Icon(Icons.add)
        ),
        body: BlocBuilder<PatientBloc, PatientState>(
            builder: (context, state) {
              if (state is PatientLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PatientLoadedSuccessState) {
                final patients = state.patients;
                return ListView.builder(
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      final patient = patients[index];
                      return ListTile(
                        title: Text(patient.name),
                        onTap: () {
                          Navigator.pushNamed(
                          context,
                          '/patient-details',
                          arguments: patient.id,
                          );
                        }
                      );
                    }
                );
              } else if (state is PatientErrorState) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const Center(child: Text('No patients found.'));
            }
        )
      ),
    );
  }
}
