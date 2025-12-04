import 'package:medical_transcriber/core/network/app_dio.dart';
import 'package:medical_transcriber/data/datasources/patient_remote_data_source.dart';

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final _dio = AppDio();

  @override
  Future<List<dynamic>> getPatients(String userId) async {
    final response = await _dio.client.get(
      '/v1/patients',
      queryParameters: {"userId": userId},
    );
    print('PatientRemoteDataSourceImpl.getPatients response: ${response.data}');
    return response.data["patients"];
  }

  @override
  Future<Map<String, dynamic>> createPatient(String name, String userId) async {
    final response = await _dio.client.post(
      "/v1/add-patient-ext",
      data: {
        "name": name,
        "userId": userId
      });
    print('PatientRemoteDataSourceImpl.createPatient response: ${response.data}');
    return response.data["patient"];
  }

  @override
  Future<Map<String, dynamic>> getPatientDetails(String patientId) async {
    final response = await _dio.client.get(
      "/v1/patient-details/$patientId",
    );
    print('PatientRemoteDataSourceImpl.getPatientDetails response: ${(response.data)}');
    return response.data;
  }

  @override
  Future<List<dynamic>> getPatientSessions(String patientId) async {
    final response = await _dio.client.get(
      "/v1/fetch-session-by-patient/$patientId"
    );
    print('PatientRemoteDataSourceImpl.getPatientSessions response: ${response.data}');
    return response.data["sessions"];
  }
}