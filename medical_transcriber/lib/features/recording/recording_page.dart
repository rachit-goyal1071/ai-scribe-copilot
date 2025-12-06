import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/recording_bloc/recording_bloc.dart';
import '../../presentation/bloc/user_bloc/user_bloc.dart';

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
    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final level = state.audioLevel.clamp(0.0, 1.0);
        final status = state.status;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Recording"),
            elevation: 0,
          ),

          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // ---------------- MIC ANIMATION ----------------
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 150 + (level * 80),
                    width: 150 + (level * 80),
                    decoration: BoxDecoration(
                      color: status == RecordingStatus.paused
                          ? Colors.grey.withOpacity(0.15)
                          : Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.15 + level * 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status == RecordingStatus.paused
                          ? Icons.mic_off_rounded
                          : Icons.mic_rounded,
                      size: 80,
                      color: status == RecordingStatus.paused
                          ? Colors.grey
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------------- STATUS TEXT ----------------
                  Text(
                    status == RecordingStatus.paused
                        ? "Paused"
                        : "Listening...",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "Audio Level: ${(level * 100).toInt()}%",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // ---------------- LINEAR LEVEL BAR ----------------
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
                          label: const Text("Resume"),
                        )
                      else if (status == RecordingStatus.recording)
                        FilledButton.icon(
                          onPressed: () => context
                              .read<RecordingBloc>()
                              .add(PauseRecordingEvent()),
                          icon: const Icon(Icons.pause_rounded),
                          label: const Text("Pause"),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.15),
                      foregroundColor: Colors.redAccent,
                    ),
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text("Stop Recording"),
                    onPressed: () {
                      context
                          .read<RecordingBloc>()
                          .add(StopRecordingEvent(isLast: true));
                      Navigator.pop(context);
                    },
                  ),

                  const Spacer(),

                  Text(
                    "Chunks Received: ${state.receivedChunks.length}",
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
