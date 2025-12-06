import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';

class AddPatientPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.read<UserBloc>().state as UserLoadedSuccessState).userId;

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientCreatedState) {
          Navigator.pop(context);
        } else if (state is PatientErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true, // important

        appBar: AppBar(
          title: const Text('Add Patient'),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                // ---------- FORM ----------
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Patient Details",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Patient Name",
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------- FLOATING BOTTOM BUTTON ----------
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          final name = nameController.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Name cannot be empty")),
                            );
                            return;
                          }

                          context.read<PatientBloc>().add(
                            AddPatientEvent(name: name, userId: userId),
                          );
                        },
                        child: const Text("Save Patient"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
