import 'package:aivis/models/doubantop250/top250_list_model.dart';
import 'package:aivis/requests/base/http_client.dart';

class Top250Request {
  /// 分页获取豆瓣top250列表
  /// - "https://doubantop250.viper.pub/movies?page=1&per_page=10"
  Future<List<Top250ItemModel>> getTop250List({
    required int pageIndex,
    int pageSize = 10,
  }) async {
    var result = await HttpClient.instance.get(
      path: "movies",
      queryParameters: {
        "page": pageIndex,
        "per_page": pageSize,
      },
    );
    var data = Top250ListModel.fromJson(result);
    return data.results ?? [];
  }
}
