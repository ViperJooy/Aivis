import 'package:aivis/app/app_style.dart';
import 'package:aivis/modules/wallpaper/wallpapers_list_controller.dart';
import 'package:aivis/widgets/items/wallpaper_item_widget.dart';
import 'package:aivis/widgets/keep_alive_wrapper.dart';
import 'package:aivis/widgets/page_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WallpapersListView extends StatelessWidget {
  final String tag;
  const WallpapersListView(this.tag, {super.key});
  WallpapersListController get controller =>
      Get.find<WallpapersListController>(tag: tag);
  @override
  Widget build(BuildContext context) {
    var c = MediaQuery.of(context).size.width ~/ 200;
    if (c < 2) {
      c = 2;
    }
    return KeepAliveWrapper(
      child: PageGridView(
        pageController: controller,
        padding: AppStyle.edgeInsetsA4,
        firstRefresh: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        crossAxisCount: c,
        itemBuilder: (_, i) {
          var item = controller.list[i];
          return WallpaperItemWidget(item);
        },
      ),
    );
  }
}
