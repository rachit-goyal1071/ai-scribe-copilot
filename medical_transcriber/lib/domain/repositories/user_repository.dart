import 'package:medical_transcriber/domain/models/user_id.dart';

abstract class UserRepository {
  Future<UserId> getUserIdByEmail(String email);
}