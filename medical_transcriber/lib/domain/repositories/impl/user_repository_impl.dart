import 'package:medical_transcriber/data/datasources/user_remote_data_source.dart';
import 'package:medical_transcriber/domain/models/user_id.dart';
import 'package:medical_transcriber/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  Future<UserId> getUserIdByEmail(String email) async {
    final id = await remote.getUserIdByEmail(email);
    return UserId(id);
  }
}