import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:medical_transcriber/data/local/chunk_status.dart';
import 'package:medical_transcriber/l10n/app_localizations.dart';
import 'package:medical_transcriber/l10n/l10n.dart';
import 'package:medical_transcriber/presentation/bloc/setting_bloc/settings_cubit.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';

import 'core/di.dart';
import 'core/router/router.dart';
import 'data/local/recording_chunk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);

  Hive.registerAdapter(RecordingChunkAdapter());
  Hive.registerAdapter(ChunkStatusAdapter());

  final di = AppDI();
  di.init();

  di.uploadQueueWorker.start();

  await Permission.microphone.request();

  await Hive.openBox<RecordingChunk>('recording_chunks');

  runApp(
    MultiRepositoryProvider(
      providers: di.repositories,
      child: MultiBlocProvider(
          providers: di.blocProviders,
          child: MyApp()
      ),
    ),
  );
}

String? userIdMain;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Medical Transcriber',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settings.themeMode,
            locale: settings.locale,
            supportedLocales: L10n.all,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate
            ],
            onGenerateRoute: AppRouter.onGeneratedRoute,
            initialRoute: AppRouter.login,
          );
        }
    );
  }
}
