import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/session_bloc/session_bloc.dart';

import '../../presentation/bloc/user_bloc/user_bloc.dart';

class AllSessionPage extends StatelessWidget {
  const AllSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = (context.read<UserBloc>().state as UserLoadedSuccessState).userId;
    context.read<SessionBloc>().add(LoadAllSessionsEvent(userId: userId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sessions'),
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SessionLoadedSuccessState) {
            final sessions = state.sessions;
            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text('Session ${session.id}'),
                  subtitle: Text(session.sessionSummary ?? 'Loading summary...'),
                );
              },
            );
          } else if (state is SessionErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('No sessions found.'));
        },
      ),
    );
  }
}
