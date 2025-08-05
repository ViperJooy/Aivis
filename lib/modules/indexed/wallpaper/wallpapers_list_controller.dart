import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/models/wallpaper/wallpaper_list_model.dart';
import 'package:aivis/requests/wallpapers_request.dart';

class WallpapersListController extends BasePageController<WallpaperItemModel> {
  final String title;
  WallpapersListController(this.title);
  final WallpapersRequest wallpapersRequest = WallpapersRequest();

  @override
  Future<List<WallpaperItemModel>> getData(int page, int pageSize) async {
    return await wallpapersRequest.getWallpaperList(
      Locales.en[title],
      pageIndex: page,
    );
  }
}
