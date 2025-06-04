import 'package:dio/dio.dart';

import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ApiClient {
  late final Dio dio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: BaseURL().baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        }, // ✅ Use JSON for all requests
      ),
    );

    // Add logging and error handling interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          GlobalUtils().customLog(''' 
          "📤 Request: ${options.method} ${options.baseUrl}${options.path}"
          "🔹 Headers: ${options.headers}"
          "📩 Payload: ${options.data}"
          ''');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("✅ Response (${response.statusCode}): ${response.data}");
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print("❌ Dio Error: ${e.message}");
          }
          return handler.next(e);
        },
      ),
    );
  }
}
