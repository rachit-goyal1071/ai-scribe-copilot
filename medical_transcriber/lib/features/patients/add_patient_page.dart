import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';

class AddPatientPage extends StatelessWidget {
  final nameController = TextEditingController();
  AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<UserBloc>().state as UserLoadedSuccessState).userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Patient Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PatientBloc>().add(
                  AddPatientEvent(
                    name: nameController.text.trim(),
                    userId: userId
                  )
                );
              },
              child: const Text('Save')
            ),
            BlocListener<PatientBloc, PatientState>(
                listener: (context, state) {
                  if (state is PatientCreatedState) {
                    Navigator.pushNamed(context, '/patients');
                  } else if (state is PatientErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${state.message}'))
                    );
                  }
                },
                child: const SizedBox()
            )
          ],
        ),
      )
    );
  }
}
