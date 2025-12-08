import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:medical_transcriber/l10n/app_localizations.dart';

class AddPatientPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();

  AddPatientPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId =
        (context.read<UserBloc>().state as UserLoadedSuccessState).userId;

    final t = AppLocalizations.of(context)!;

    return BlocListener<PatientBloc, PatientState>(
      listener: (context, state) {
        if (state is PatientCreatedState) {
          Navigator.pushNamed(context, '/patients');
        } else if (state is PatientErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${t.error}: ${state.message}")),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        appBar: AppBar(
          title: Text(t.addPatient),
        ),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                // ------------ FORM ------------
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.patientDetails,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: t.patientName,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------ FLOATING SAVE BUTTON ------------
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
                              SnackBar(content: Text(t.nameCannotBeEmpty)),
                            );
                            return;
                          }

                          context.read<PatientBloc>().add(
                            AddPatientEvent(name: name, userId: userId),
                          );
                        },
                        child: Text(t.savePatient),
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
