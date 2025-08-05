import 'package:aivis/app/log.dart';
import 'package:aivis/requests/base/api.dart';
import 'package:dio/dio.dart';

/// apikey认证拦截器
class OAuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.uri.toString().contains('movies')) {
      var apikey = Api.kApiKey;
      options.headers.addAll({"Authorization": apikey});
    }
    super.onRequest(options, handler);
  }
}
