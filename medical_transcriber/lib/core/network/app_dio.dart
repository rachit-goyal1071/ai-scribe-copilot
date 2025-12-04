import 'package:dio/dio.dart';

class AppDio {

  static final AppDio _instance = AppDio._internal();
  factory AppDio() => _instance;

  final baseUrl = 'http://142.93.211.149:8000';
  final String backendUrl = "http://142.93.211.149:8000/";

  late final Dio dio;

  AppDio._internal(){
    dio = Dio(
        BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: Duration(seconds: 10),
            receiveTimeout: Duration(seconds: 30),
            headers: {
              "Content-Type": "application/json",
            }
        )
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if(token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          return handler.next(e);
        }
      )
    );
  }

  Future<String?> getToken() async {
    // TODO: Load from secure storage
    return null;
  }

  Dio get client => dio;

  Dio get backendClient {
    return Dio(BaseOptions(baseUrl: backendUrl));
  }
}