import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ApiService {
  final Dio _dio = ApiClient().dio;

  final Dio _dio2 = Dio(
    BaseOptions(
      baseUrl: "https://thebluebamboo.in/APIs/Anamak_APIs",
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Map<String, dynamic>> postRequestFornotification(
    String endpoint, // e.g. "/sendNotification"
    Map<String, dynamic> payload, {
    bool useFormData = false,
  }) async {
    final url = "${_dio2.options.baseUrl}$endpoint";

    GlobalUtils().customLog("📤 POST: $url");
    GlobalUtils().customLog("📦 Payload: $payload");

    try {
      final response = await _dio2.post(
        endpoint,
        data: useFormData ? FormData.fromMap(payload) : payload,
      );

      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {'success': false, 'error': 'Invalid response format'};
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return {'success': false, 'error': e.message ?? 'Dio error'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postRequest(
    Map<String, dynamic> payload, {
    bool useFormData = false,
  }) async {
    GlobalUtils().customLog("📤 POST: ${_dio.options.baseUrl}");
    GlobalUtils().customLog("📦 Payload: $payload");

    try {
      Response response = await _dio.post(
        '',
        data: useFormData ? FormData.fromMap(payload) : payload,
      );

      dynamic data = response.data;

      // ✅ Force decode if raw string
      if (data is String) {
        data = jsonDecode(data);
      }

      // ✅ Ensure it's a map
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        throw Exception("Response is not a valid Map");
      }
    } on DioException catch (e) {
      _handleDioError(e);
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getRequest(
    Map<String, dynamic> queryParams,
  ) async {
    GlobalUtils().customLog("📤 GET: ${_dio.options.baseUrl}");
    GlobalUtils().customLog("🔍 Query Params: $queryParams");

    try {
      Response response = await _dio.get('', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      return {'success': false, 'error': e.message};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  void _handleDioError(DioException e) {
    if (kDebugMode) {
      print("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
      if (e.response != null) {
        print("🔹 Response Data: ${e.response?.data}");
      }
    }
  }
}
