// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';

// class ApiClientForN {
//   late final Dio dio;

//   // Singleton pattern to ensure a single Dio instance
//   static final ApiClient _instance = ApiClient._internal();
//   factory ApiClient() => _instance;

//   ApiClient._internal() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl:
//             "https://thebluebamboo.in/APIs/Anamak_APIs/send_notification_lgbt_togo.php",
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 10),
//         headers: {
//           'Content-Type': 'application/json',
//         }, // ✅ Use JSON for all requests
//       ),
//     );

//     // Add logging and error handling interceptors
//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) {
//           if (kDebugMode) {
//             print(
//               "📤 Request: ${options.method} ${options.baseUrl}${options.path}",
//             );
//             print("🔹 Headers: ${options.headers}");
//             print("📩 Payload: ${options.data}");
//           }
//           return handler.next(options);
//         },
//         onResponse: (response, handler) {
//           if (kDebugMode) {
//             print("✅ Response (${response.statusCode}): ${response.data}");
//           }
//           return handler.next(response);
//         },
//         onError: (DioException e, handler) {
//           if (kDebugMode) {
//             print("❌ Dio Error: ${e.message}");
//           }
//           return handler.next(e);
//         },
//       ),
//     );
//   }
// }

// class ApiService {
//   final Dio _dio = ApiClient().dio;

//   // ✅ Generic POST Request (Handles both JSON & FormData)
//   Future<Map<String, dynamic>> postRequest(
//     String endpoint,
//     Map<String, dynamic> payload, {
//     bool useFormData = false, // If true, sends data as FormData
//   }) async {
//     // customLog("Payload: $payload");
//     try {
//       Response response = await _dio.post(
//         endpoint,
//         data: useFormData ? FormData.fromMap(payload) : payload,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       _handleDioError(e);
//       return {'success': false, 'error': e.message};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // ✅ Generic GET Request (With Query Parameters)
//   Future<Map<String, dynamic>> getRequest(
//     String endpoint,
//     Map<String, dynamic> queryParams,
//   ) async {
//     // customLog("queryParams: $queryParams");
//     try {
//       Response response = await _dio.get(
//         endpoint,
//         queryParameters: queryParams,
//       );
//       return response.data;
//     } on DioException catch (e) {
//       _handleDioError(e);
//       return {'success': false, 'error': e.message};
//     } catch (e) {
//       return {'success': false, 'error': e.toString()};
//     }
//   }

//   // 🔥 Handles Dio errors centrally
//   void _handleDioError(DioException e) {
//     if (kDebugMode) {
//       print("❌ Dio Error: ${e.response?.statusCode} - ${e.message}");
//       if (e.response != null) {
//         print("🔹 Response Data: ${e.response?.data}");
//       }
//     }
//   }
// }
