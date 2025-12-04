import 'package:medical_transcriber/domain/models/session_model.dart';

abstract class SessionRepository {
  Future<List<SessionModel>> getAllSessions(String userId);
}