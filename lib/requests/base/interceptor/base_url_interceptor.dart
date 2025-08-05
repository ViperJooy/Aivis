import 'package:aivis/app/log.dart';
import 'package:aivis/requests/base/api.dart';
import 'package:dio/dio.dart';

/// baseurl 切换拦截器
class BaseUrlInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 根据条件动态设置 baseUrl
    if (options.uri.toString().contains('movies')) {
      options.baseUrl = 'https://doubantop250.viper.pub/';
    } else {
      options.baseUrl = 'https://api.pexels.com/';
    }
    return handler.next(options);
  }
}
