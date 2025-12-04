import 'package:medical_transcriber/core/network/app_dio.dart';
import 'package:medical_transcriber/data/datasources/session_remote_data_source.dart';

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final _dio = AppDio();

  @override
  Future<List<dynamic>> getAllSessions(String userId) async {
    final response = await _dio.client.get(
      '/v1/all-sessions',
      queryParameters: {"userId": userId},
    );
    return response.data["sessions"];
  }
}