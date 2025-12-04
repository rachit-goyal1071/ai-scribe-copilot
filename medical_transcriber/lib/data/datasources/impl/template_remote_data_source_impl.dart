import 'package:medical_transcriber/core/network/app_dio.dart';
import 'package:medical_transcriber/data/datasources/template_remote_data_source.dart';

class TemplateRemoteDataSourceImpl implements TemplateRemoteDataSource {
  final _dio = AppDio();

  @override
  Future<List<dynamic>> getUserTemplates(String userId) async {
    final response = await _dio.client.get(
      '/v1/fetch-default-template-ext',
      queryParameters: {"userId": userId},
    );
    return response.data["data"];
  }
}