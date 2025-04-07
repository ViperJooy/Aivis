import 'package:aivis/app/app_style.dart';
import 'package:aivis/modules/video/videos_list_controller.dart';
import 'package:aivis/widgets/items/video_item_widget.dart';
import 'package:aivis/widgets/keep_alive_wrapper.dart';
import 'package:aivis/widgets/page_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideosListView extends StatelessWidget {
  final String tag;
  const VideosListView(this.tag, {super.key});
  VideosListController get controller =>
      Get.find<VideosListController>(tag: tag);
  @override
  Widget build(BuildContext context) {
    return KeepAliveWrapper(
      child: PageListView(
        pageController: controller,
        padding: AppStyle.edgeInsetsA4,
        firstRefresh: true,
        itemBuilder: (_, i) {
          var item = controller.list[i];
          return VideoItemWidget(item);
        },
      ),
    );
  }
}
