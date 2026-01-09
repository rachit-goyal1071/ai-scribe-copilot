import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:medical_transcriber/presentation/bloc/session_bloc/session_bloc.dart';

import '../../core/router/router.dart';
import '../../domain/models/session_model.dart';
import '../../presentation/bloc/user_bloc/user_bloc.dart';

class AllSessionPage extends StatefulWidget {
  const AllSessionPage({super.key});

  @override
  State<AllSessionPage> createState() => _AllSessionPageState();
}

class _AllSessionPageState extends State<AllSessionPage> {
  final Set<String> _expandedGroups = {};

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<UserBloc>().state as UserLoadedSuccessState).userId;
    context.read<SessionBloc>().add(LoadAllSessionsEvent(userId: userId));
  }

  String _dayLabel(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return 'Unknown date';

    final today = DateTime.now();
    final d0 = DateTime(today.year, today.month, today.day);
    final d1 = DateTime(dt.year, dt.month, dt.day);
    final diff = d0.difference(d1).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE, dd MMM yyyy').format(dt);
  }

  String _timeLabel(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat('hh:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Sessions'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final userId =
                  (context.read<UserBloc>().state as UserLoadedSuccessState)
                      .userId;
              context.read<SessionBloc>().add(LoadAllSessionsEvent(userId: userId));
            },
          )
        ],
      ),
      body: BlocBuilder<SessionBloc, SessionState>(
        builder: (context, state) {
          if (state is SessionLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SessionErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is! SessionLoadedSuccessState) {
            return const Center(child: Text('No sessions found.'));
          }

          final sessions = state.sessions;
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions found.'));
          }

          // Sort newest first
          final sorted = [...sessions]
            ..sort((a, b) {
              final ad = DateTime.tryParse(a.startTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
              final bd = DateTime.tryParse(b.startTime) ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bd.compareTo(ad);
            });

          final grouped = <String, List<SessionModel>>{};
          for (final s in sorted) {
            final label = _dayLabel(s.startTime);
            (grouped[label] ??= []).add(s);
          }

          final groupKeys = grouped.keys.toList();

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: groupKeys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final group = groupKeys[index];
              final items = grouped[group]!;

              return Material(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  initiallyExpanded: _expandedGroups.contains(group),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      if (expanded) {
                        _expandedGroups.add(group);
                      } else {
                        _expandedGroups.remove(group);
                      }
                    });
                  },
                  title: Text(
                    group,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text('${items.length} session(s)'),
                  children: [
                    Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i != 0)
                            Divider(
                              height: 1,
                              color: theme.dividerColor.withOpacity(0.5),
                            ),
                          Builder(
                            builder: (context) {
                              final session = items[i];
                              final time = _timeLabel(session.startTime);

                              final title =
                                  session.sessionTitle?.trim().isNotEmpty == true
                                      ? session.sessionTitle!.trim()
                                      : 'Session ${session.id.substring(0, session.id.length.clamp(0, 8))}';

                              return ListTile(
                                title: Text('$time  •  $title'),
                                subtitle: Text(
                                  session.sessionSummary?.trim().isNotEmpty ==
                                          true
                                      ? session.sessionSummary!.trim()
                                      : 'Tap to view details',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.sessionDetails,
                                    arguments: session,
                                  );
                                },
                              );
                            },
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
