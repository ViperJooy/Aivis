import 'package:aivis/requests/base/api.dart';
import 'package:aivis/requests/base/interceptor/base_url_interceptor.dart';
import 'package:aivis/requests/base/interceptor/app_log_interceptor.dart';
import 'package:aivis/requests/base/interceptor/error_interceptor.dart';
import 'package:aivis/requests/base/interceptor/oauth_interceptor.dart';
import 'package:dio/dio.dart';

class HttpClient {
  static HttpClient? _httpUtil;

  static HttpClient get instance {
    _httpUtil ??= HttpClient();
    return _httpUtil!;
  }

  late Dio dio;
  final _defaultTime = const Duration(seconds: 15);
  HttpClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: Api.kBaseUrl,
        connectTimeout: _defaultTime,
        receiveTimeout: _defaultTime,
        sendTimeout: _defaultTime,
      ),
    );
    dio.interceptors.addAll([
      BaseUrlInterceptor(),//动态切换baseurl拦截器
      AppLogInterceptor(), //日志拦截器
      OAuthInterceptor(), //apikey认证拦截器
      ErrorInterceptor(), //错误处理拦截器
    ]);
  }

  //GET请求
  Future<dynamic> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var result = await dio.get(
      path,
      queryParameters: queryParameters,
      options:
          options ??
          Options(
            responseType: ResponseType.json,
            receiveTimeout: _defaultTime,
            sendTimeout: _defaultTime,
          ),
      cancelToken: cancelToken,
    );
    return result.data;
  }

  //POST请求
  Future<dynamic> post({
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    bool formUrlEncoded = false,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options:
          options ??
          Options(
            responseType: ResponseType.json,
            receiveTimeout: _defaultTime,
            sendTimeout: _defaultTime,
            contentType:
                formUrlEncoded ? Headers.formUrlEncodedContentType : null,
          ),
      cancelToken: cancelToken,
    );
  }
}
