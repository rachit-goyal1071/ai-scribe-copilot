import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/main.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';
import 'package:medical_transcriber/l10n/app_localizations.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({super.key});

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  @override
  void initState() {
    super.initState();
    userIdMain ??=
        (context.read<UserBloc>().state as UserLoadedSuccessState).userId;
    context.read<PatientBloc>().add(LoadPatientEvent(userId: userIdMain!));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 0,
          leading: const SizedBox.shrink(),
          title: Text(t.patients),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-patient'),
          child: const Icon(Icons.add),
        ),

        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PatientLoadedSuccessState) {
              final patients = state.patients;

              if (patients.isEmpty) {
                return _buildEmptyState(theme, t);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: patients.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final patient = patients[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/patient-details',
                        arguments: patient.id,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              patient.name[0].toUpperCase(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              patient.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right)
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            if (state is PatientErrorState) {
              return Center(
                child: Text(
                  '${t.error}: ${state.message}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }

            return Center(child: Text(t.noPatientsFound));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined,
                size: 80, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              t.noPatientsYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.tapToAddPatient,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
