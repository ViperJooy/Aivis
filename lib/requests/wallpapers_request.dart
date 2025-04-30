import 'package:aivis/models/wallpaper/wallpaper_list_model.dart';
import 'package:aivis/requests/base/http_client.dart';

class WallpapersRequest {
  /// 分页获取图片列表 根据传递keyword
  /// - "https://api.pexels.com/v1/search?query=nature&page=1&per_page=1"
  Future<List<WallpaperItemModel>> getWallpaperList(
    String? keyword, {
    required int pageIndex,
    int pageSize = 30,
  }) async {
    var result = await HttpClient.instance.get(
      path: "v1/search",
      queryParameters: {
        "query": keyword,
        "page": pageIndex,
        "per_page": pageSize,
      },
    );
    var data = WallpaperListModel.fromJson(result);
    return data.photos ?? [];
  }
}
