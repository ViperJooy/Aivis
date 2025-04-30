import 'package:aivis/models/version_model.dart';
import 'package:dio/dio.dart';

/// 通用的请求
class CommonRequest {
  /// 检查更新
  Future<VersionModel> checkUpdate() async {
    var result = await Dio().get(
      "https://cdn.jsdelivr.net/gh/xiaoyaocz/flutter_cnblogs@master/document/new_version.json",
      queryParameters: {"ts": DateTime.now().millisecondsSinceEpoch},
      options: Options(responseType: ResponseType.json),
    );
    return VersionModel.fromJson(result.data);
  }
}
