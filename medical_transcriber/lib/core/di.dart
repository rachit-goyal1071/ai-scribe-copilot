import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_transcriber/data/datasources/impl/patient_remote_data_source_impl.dart';
import 'package:medical_transcriber/data/datasources/impl/recording_remote_data_source_impl.dart';
import 'package:medical_transcriber/data/datasources/impl/session_remote_data_source_impl.dart';
import 'package:medical_transcriber/data/datasources/impl/user_data_source_impl.dart';
import 'package:medical_transcriber/data/datasources/patient_remote_data_source.dart';
import 'package:medical_transcriber/data/datasources/recording_remote_data_source.dart';
import 'package:medical_transcriber/data/datasources/session_remote_data_source.dart';
import 'package:medical_transcriber/data/datasources/template_remote_data_source.dart';
import 'package:medical_transcriber/data/datasources/user_remote_data_source.dart';
import 'package:medical_transcriber/data/local/chunk_local_data_source.dart';
import 'package:medical_transcriber/data/services/upload_queue_worker.dart';
import 'package:medical_transcriber/domain/repositories/patient_repository.dart';
import 'package:medical_transcriber/domain/repositories/recording_repository.dart';
import 'package:medical_transcriber/domain/repositories/session_repository.dart';
import 'package:medical_transcriber/domain/repositories/template_repository.dart';
import 'package:medical_transcriber/domain/repositories/user_repository.dart';
import 'package:medical_transcriber/presentation/bloc/patient_bloc/patient_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/recording_bloc/recording_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/session_bloc/session_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/setting_bloc/settings_cubit.dart';
import 'package:medical_transcriber/presentation/bloc/template_bloc/template_bloc.dart';
import 'package:medical_transcriber/presentation/bloc/user_bloc/user_bloc.dart';

import '../data/datasources/impl/template_remote_data_source_impl.dart';
import '../domain/repositories/impl/patient_repository_impl.dart';
import '../domain/repositories/impl/recording_repository_impl.dart';
import '../domain/repositories/impl/session_repository_impl.dart';
import '../domain/repositories/impl/template_repository_impl.dart';
import '../domain/repositories/impl/user_repository_impl.dart';
import 'network/app_dio.dart';

class AppDI {
  late final AppDio appDio;

  late final UserRemoteDataSource userRemoteDataSource;
  late final PatientRemoteDataSource patientRemoteDataSource;
  late final TemplateRemoteDataSource templateRemoteDataSource;
  late final RecordingRemoteDataSource recordingRemoteDataSource;
  late final SessionRemoteDataSource sessionRemoteDataSource;

  late final UserRepository userRepository;
  late final PatientRepository patientRepository;
  late final TemplateRepository templateRepository;
  late final RecordingRepository recordingRepository;
  late final SessionRepository sessionRepository;

  late final ChunkLocalDataSource chunkLocalDataSource;
  late final UploadQueueWorker uploadQueueWorker;

  void init() {
    appDio = AppDio();

    userRemoteDataSource = UserRemoteDataSourceImpl();
    patientRemoteDataSource = PatientRemoteDataSourceImpl();
    templateRemoteDataSource = TemplateRemoteDataSourceImpl();
    recordingRemoteDataSource = RecordingRemoteDataSourceImpl();
    sessionRemoteDataSource = SessionRemoteDataSourceImpl();

    userRepository = UserRepositoryImpl(userRemoteDataSource);
    patientRepository = PatientRepositoryImpl(patientRemoteDataSource);
    templateRepository = TemplateRepositoryImpl(templateRemoteDataSource);
    recordingRepository = RecordingRepositoryImpl(recordingRemoteDataSource);
    sessionRepository = SessionRepositoryImpl(sessionRemoteDataSource);

    chunkLocalDataSource = ChunkLocalDataSource();
    uploadQueueWorker = UploadQueueWorker(
      local: chunkLocalDataSource,
      recordingRepo: recordingRepository,
    );
  }

  List<RepositoryProvider> get repositories => [
        RepositoryProvider<UserRepository>(
          create: (_) => userRepository,
        ),
        RepositoryProvider<PatientRepository>(
          create: (_) => patientRepository,
        ),
        RepositoryProvider<TemplateRepository>(
          create: (_) => templateRepository,
        ),
        RepositoryProvider<RecordingRepository>(
          create: (_) => recordingRepository,
        ),
        RepositoryProvider<SessionRepository>(
          create: (_) => sessionRepository,
        ),
      ];

  List<BlocProvider> get blocProviders => [
    BlocProvider<SettingsCubit>(create: (_) => SettingsCubit()),
    BlocProvider<UserBloc>(create: (_) => UserBloc(userRepository)),
    BlocProvider<PatientBloc>(create: (_) => PatientBloc(patientRepository)),
    BlocProvider<SessionBloc>(create: (_) => SessionBloc(sessionRepository)),
    BlocProvider<TemplateBloc>(create: (_) => TemplateBloc(templateRepository)),
    BlocProvider<RecordingBloc>(create: (_) => RecordingBloc(recordingRepository, chunkLocalDataSource)),
  ];
}