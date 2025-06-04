import 'package:dio/dio.dart';
import 'package:lgbt_togo/Features/Utils/barrel/imports.dart';

class ApiService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> postRequest(
    Map<String, dynamic> payload, {
    bool useFormData = false,
  }) async {
    GlobalUtils().customLog("📤 POST: ${_dio.options.baseUrl}");
    GlobalUtils().customLog("📦 Payload: $payload");

    try {
      Response response = await _dio.post(
        '', // ⬅️ No endpoint, just base URL
        data: useFormData ? FormData.fromMap(payload) : payload,
      );
      return response.data;
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
      Response response = await _dio.get(
        '', // ⬅️ No endpoint, just base URL
        queryParameters: queryParams,
      );
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
