import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientId;
  const PatientDetailsPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    context.read<PatientBloc>().add(
      LoadPatientSessionsEvent(patientId: patientId),
    );

    final theme = Theme.of(context);

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
          title: const Text("Patient Details"),
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(
            context,
            '/recording',
            arguments: {'patientId': patientId},
          ),
          child: const Icon(Icons.mic_none),
        ),

        body: BlocBuilder<PatientBloc, PatientState>(
          builder: (context, state) {
            if (state is PatientLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PatientsSessionsLoadedState) {
              final sessions = state.sessions;

              if (sessions.isEmpty) {
                return _buildEmptyState(theme);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = sessions[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {}, // You can add session details navigation here
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primaryContainer,
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Session ${session.id}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  session.sessionSummary ?? "Loading summary...",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(Icons.chevron_right),
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
                  'Error: ${state.message}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }

            return const Center(child: Text("No details available."));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              "No Sessions Yet",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Start a new recording using the mic button below.",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
