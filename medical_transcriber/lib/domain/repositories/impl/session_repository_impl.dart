import 'package:medical_transcriber/domain/repositories/session_repository.dart';

import '../../../data/datasources/session_remote_data_source.dart';
import '../../models/session_model.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remote;

  SessionRepositoryImpl(this.remote);

  @override
  Future<List<SessionModel>> getAllSessions(String userId) async {
    final sessions = await remote.getAllSessions(userId);
    return sessions.map((e) => SessionModel.fromJson(e)).toList();
  }
}