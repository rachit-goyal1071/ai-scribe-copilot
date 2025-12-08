import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/l10n/app_localizations.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientId;
  const PatientDetailsPage({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    context.read<PatientBloc>().add(
      LoadPatientSessionsEvent(patientId: patientId),
    );

    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final player = AudioPlayer();

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
          title: Text(t.patientDetails),
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
                return _buildEmptyState(theme, t);
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async{
                      showAudioPlayerDialog(context, session.id);
                    },
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
                                  "${t.session} ${session.id}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  session.sessionSummary ?? t.loadingSummary,
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
                  '${t.error}: ${state.message}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            }

            return Center(child: Text(t.noDetailsAvailable));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations t) {
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
              t.noSessionsYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t.startNewRecording,
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


Future<void> showAudioPlayerDialog(BuildContext context, String sessionId) async {
  final player = AudioPlayer();
  final url = "http://142.93.211.149:8000/v1/session-audio/$sessionId";

  await player.setUrl(url);

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Session Audio"),
        content: StreamBuilder<Duration?>(
          stream: player.durationStream,
          builder: (context, snapshotDuration) {
            final total = snapshotDuration.data ?? Duration.zero;

            return StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snapshotPosition) {
                final position = snapshotPosition.data ?? Duration.zero;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Slider ---
                    Slider(
                      value: position.inSeconds.toDouble(),
                      min: 0,
                      max: total.inSeconds.toDouble(),
                      onChanged: (value) {
                        player.seek(Duration(seconds: value.toInt()));
                      },
                    ),

                    // --- Time Info ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position)),
                        Text(_formatDuration(total)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- Play / Pause button ---
                    StreamBuilder<PlayerState>(
                      stream: player.playerStateStream,
                      builder: (context, snapshotState) {
                        final playing = snapshotState.data?.playing ?? false;

                        return IconButton(
                          iconSize: 50,
                          icon: Icon(playing ? Icons.pause_circle : Icons.play_circle),
                          onPressed: () {
                            playing ? player.pause() : player.play();
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              player.dispose();
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      );
    },
  );
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return "$minutes:$seconds";
}
