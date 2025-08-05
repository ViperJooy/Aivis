import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:aivis/requests/videos_request.dart';

class VideosListController extends BasePageController<VideoItemModel> {
  final String title;
  VideosListController(this.title);
  final VideosRequest videosRequest = VideosRequest();

  @override
  Future<List<VideoItemModel>> getData(int page, int pageSize) async {
    return await videosRequest.getVideoList(Locales.en[title], pageIndex: page);
  }
}
