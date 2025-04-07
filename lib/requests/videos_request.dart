import 'package:aivis/models/video/video_list_model.dart';
import 'package:aivis/requests/base/http_client.dart';

class VideosRequest {
  /// 分页获取视频列表 根据传递keyword
  /// - "https://api.pexels.com/videos/search?query=nature&page=1"
  Future<List<VideoItemModel>> getVideoList(
    String? keyword, {
    required int pageIndex,
    int pageSize = 30,
  }) async {
    var result = await HttpClient.instance.get(
      path: "videos/search",
      queryParameters: {"query": keyword, "page": pageIndex},
    );
    var data = VideoListModel.fromJson(result);
    return data.videos ?? [];
  }
}
