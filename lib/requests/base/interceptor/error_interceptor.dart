import 'package:aivis/app/app_error.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final result = await _handleError(err);
      if (result) {
        // If the error was handled successfully and we want to continue
        handler.resolve(err.response!);
      } else {
        // If the error should be propagated
        handler.reject(err);
      }
    } catch (e) {
      // If our error handler throws an error, propagate it
      handler.reject(err);
    }
  }

  Future<bool> _handleError(DioException e) async {
    if (e.type == DioExceptionType.badResponse) {
      var msg = '';
      if (e.response?.data is Map) {
        Map? data = e.response?.data;
        msg = data.toString();
      }

      var statusCode = e.response?.statusCode ?? 400;

      if (statusCode == 200 && msg.isNotEmpty) {
        return true;
      }
      throw AppError(msg, code: statusCode, isHttpError: true);
    } else {
      throw AppError(LocaleKeys.network_status_no_network.tr);
    }
  }
}
