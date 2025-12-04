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

class _RecordingPageState extends State<RecordingPage> {
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
  late RecordingBloc recordingBloc;

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
        final level = state.audioLevel;
        final status = state.status;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Recording"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Audio Level",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 16),

                  LinearProgressIndicator(
                    value: level.clamp(0.0, 1.0),
                    minHeight: 12,
                  ),

                  const SizedBox(height: 24),

                  if (status == RecordingStatus.paused)
                    ElevatedButton(
                      onPressed: () => context
                          .read<RecordingBloc>()
                          .add(ResumeRecordingEvent()),
                      child: const Text("Resume"),
                    )
                  else if (status == RecordingStatus.recording)
                    ElevatedButton(
                      onPressed: () => context
                          .read<RecordingBloc>()
                          .add(PauseRecordingEvent()),
                      child: const Text("Pause"),
                    ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<RecordingBloc>()
                          .add(StopRecordingEvent(isLast: true));
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text("Stop Recording"),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    "Chunks Received: ${state.receivedChunks.length}",
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
