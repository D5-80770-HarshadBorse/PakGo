import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:pakgo/core/constants/api_constants.dart'; // Ensure this path is correct

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status Code: $statusCode)' : ''}';
  }
}

class ApiClient {
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {"Content-Type": "application/json"},
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
        maxWidth: 120,
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get<T>(path, queryParameters: query);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<Response<T>> post<T>(String path, {Object? data}) async {
    try {
      final response = await dio.post<T>(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<Response<T>> put<T>(String path, {Object? data}) async {
    try {
      final response = await dio.put<T>(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  ApiException _handleDioError(DioException error) {
    String errorMessage = 'Failed to connect to the server.';
    int? statusCode;
    final dynamic responseData = error.response!.data;

    if (error.response != null) {
      statusCode = error.response!.statusCode;
      switch (statusCode) {
        case 400:
          errorMessage = responseData["message"].toString();
          break;
        case 401:
          errorMessage = 'Unauthorized: Invalid authentication credentials.';
          break;
        case 403:
          errorMessage = 'Forbidden: You do not have permission to access this resource.';
          break;
        case 404:
          errorMessage = 'Not Found: The requested resource was not found.';
          break;
        case 500:
          errorMessage = 'Internal Server Error: Something went wrong on the server.';
          break;
        default:
          errorMessage = 'Received an unexpected status code: $statusCode';
      }
    } else if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timed out. Please check your internet connection.';
    } else if (error.type == DioExceptionType.badResponse) {
      errorMessage = 'Bad response from server.';
    } else if (error.type == DioExceptionType.unknown) {
      errorMessage = 'Network error. Please check your internet connection.';
    }
    return ApiException(errorMessage, statusCode: statusCode);
  }

  void setAuthToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  void clearAuthToken() {
    dio.options.headers.remove("Authorization");
  }
}