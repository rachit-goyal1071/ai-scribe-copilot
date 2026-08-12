import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/features/recording/widgets/mic_animation.dart';

import '../../presentation/bloc/patient_bloc/patient_bloc.dart';
import '../../presentation/bloc/recording_bloc/recording_bloc.dart';
import '../../presentation/bloc/user_bloc/user_bloc.dart';
import 'package:medical_transcriber/l10n/app_localizations.dart';

class RecordingPage extends StatefulWidget {
  final String patientId;
  final String templateId;

  const RecordingPage({
    super.key,
    required this.patientId,
    required this.templateId,
  });

  @override
  State<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends State<RecordingPage>
    with SingleTickerProviderStateMixin {
  late RecordingBloc recordingBloc;

  @override
  void initState() {
    super.initState();

    final userId =
        (context.read<UserBloc>().state as UserLoadedSuccessState).userId;

    context.read<RecordingBloc>().add(
      StartRecordingEvent(
        patientId: widget.patientId,
        userId: userId,
        patientName: 'Patient',
        templateId: widget.templateId,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recordingBloc = context.read<RecordingBloc>();
  }

  @override
  void dispose() {
    recordingBloc.add(StopRecordingEvent(isLast: true));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final level = state.audioLevel.clamp(0.0, 1.0);
        final status = state.status;

        return Scaffold(
          appBar: AppBar(
            title: Text(t.recordingTitle),
            elevation: 0,
          ),

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  MicAnimation(level: int.parse((level*4).ceil().toString())),

                  const SizedBox(height: 30),

                  // ---------------- STATUS TEXT ----------------
                  Text(
                    status == RecordingStatus.paused
                        ? t.paused
                        : t.listening,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "${t.audioLevel}: ${(level * 100).toInt()}%",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // ---------------- LEVEL BAR ----------------
                  LinearProgressIndicator(
                    value: level,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 40),

                  // ---------------- CONTROLS ----------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (status == RecordingStatus.paused)
                        FilledButton.icon(
                          onPressed: () => context
                              .read<RecordingBloc>()
                              .add(ResumeRecordingEvent()),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(t.resume),
                        )
                      else if (status == RecordingStatus.recording)
                        FilledButton.icon(
                          onPressed: () => context
                              .read<RecordingBloc>()
                              .add(PauseRecordingEvent()),
                          icon: const Icon(Icons.pause_rounded),
                          label: Text(t.pause),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(35),
                      foregroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(Icons.stop_rounded),
                    label: Text(t.stopRecording),
                    onPressed: () {
                      context
                          .read<RecordingBloc>()
                          .add(StopRecordingEvent(isLast: true));
                      context.read<PatientBloc>().add(
                        LoadPatientSessionsEvent(patientId: widget.patientId),
                      );
                      Navigator.pop(context);
                    },
                  ),

                  const Spacer(),

                  Text(
                    "${t.chunksReceived}: ${state.receivedChunks.length}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
