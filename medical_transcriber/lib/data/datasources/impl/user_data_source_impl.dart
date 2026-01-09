import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:medical_transcriber/core/network/app_dio.dart';
import '../user_remote_data_source.dart';

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final _dio = AppDio();

  @override
  Future<String> getUserIdByEmail(String email) async {
    final response = await _dio.client.get(
      '/users/asd3fd2faec',
      queryParameters: {"email": email},
    );
    if (kDebugMode) {
      debugPrint('UserRemoteDataSourceImpl.getUserIdByEmail response: ${response.data}');
    }
    return response.data['id'].toString();
  }
}