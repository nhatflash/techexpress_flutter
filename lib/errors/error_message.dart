import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ErrorMessage implements Exception {
  final int statusCode;
  final String message;

  static final logger = Logger();

  ErrorMessage({
    required this.statusCode,
    required this.message
  });

  factory ErrorMessage.fromDioException(DioException e) {
    logger.e('Exception thrown', error: e, stackTrace: e.stackTrace);
    final response = e.response;
    if (response != null) {
      final data = response.data;
      String message = data['message'];
      int statusCode = data['statusCode'];
      return ErrorMessage(statusCode: statusCode, message: message);
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ErrorMessage(statusCode: 504, message: 'Kết nối quá giờ. Vui lòng thử lại');
      case DioExceptionType.connectionError:
        return ErrorMessage(statusCode: 502, message: 'Lỗi mạng. Vui lòng thử lại');
      default:
        return ErrorMessage(statusCode: 500, message: 'Đã xảy ra lỗi $response');
    }
  }
}