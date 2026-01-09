import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import 'package:medical_transcriber/domain/models/session_model.dart';

/// Session Details (Step 2)
///
/// - Shows session id
/// - Provides in-app audio playback with scrubber
/// - Shows Summary + Transcript via tabs
class SessionDetailsPage extends StatefulWidget {
  const SessionDetailsPage({super.key, required this.session});

  final SessionModel session;

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final TabController _tabController;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player = AudioPlayer();
    _tabController = TabController(length: 2, vsync: this);

    _player.durationStream.listen((d) {
      if (!mounted) return;
      setState(() {
        _duration = d ?? Duration.zero;
      });
    });

    _player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
      });
    });

    _load();
  }

  Future<void> _load() async {
    final url =
        'http://142.93.213.55:8000/v1/session-audio/${widget.session.id}';
    try {
      await _player.setUrl(url);
    } catch (_) {
      // no-op
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _player.dispose();
    super.dispose();
  }

  static String _fmt(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Widget _textCard({required String title, required String body}) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (body.trim().isNotEmpty)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: () => _copyToClipboard(body),
                    icon: const Icon(Icons.copy),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SelectableText(
              body.trim().isNotEmpty ? body.trim() : 'Not available yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _markdownCard({required String title, required String body}) {
    final theme = Theme.of(context);
    final safeBody = body.trim();

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (safeBody.isNotEmpty)
                  IconButton(
                    tooltip: 'Copy',
                    onPressed: () => _copyToClipboard(safeBody),
                    icon: const Icon(Icons.copy),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (safeBody.isEmpty)
              Text(
                'Not available yet.',
                style: theme.textTheme.bodyMedium,
              )
            else
              MarkdownBody(
                data: safeBody,
                selectable: true,
                styleSheet: MarkdownStyleSheet.fromTheme(theme),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme = Theme.of(context);

    final summary = widget.session.sessionSummary ?? '';
    final transcript = widget.session.transcript ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Session ${widget.session.id}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Playback card
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Audio playback',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _position.inMilliseconds
                        .toDouble()
                        .clamp(
                          0,
                          _duration.inMilliseconds
                              .toDouble()
                              .clamp(0, double.infinity),
                        ),
                    min: 0,
                    max: _duration.inMilliseconds.toDouble().clamp(0, double.infinity),
                    onChanged: (value) {
                      _player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(_position)),
                      Text(_fmt(_duration)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? false;
                      return FilledButton.tonalIcon(
                        onPressed: () =>
                            playing ? _player.pause() : _player.play(),
                        icon: Icon(
                          playing ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(playing ? 'Pause' : 'Play'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tabs for Summary / Transcript
          Material(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Summary'),
                      Tab(text: 'Transcript'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SingleChildScrollView(
                          child: _markdownCard(
                            title: 'Session summary',
                            body: summary,
                          ),
                        ),
                        SingleChildScrollView(
                          child: _textCard(
                            title: 'Transcript',
                            body: transcript,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
