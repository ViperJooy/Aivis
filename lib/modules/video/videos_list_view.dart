import 'dart:math';

import 'package:aivis/app/app_style.dart';
import 'package:aivis/modules/video/videos_list_controller.dart';
import 'package:aivis/widgets/items/video_item_widget.dart';
import 'package:aivis/widgets/keep_alive_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/page_grid_view.dart';

class VideosListView extends StatelessWidget {
  final String tag;
  const VideosListView(this.tag, {super.key});
  VideosListController get controller =>
      Get.find<VideosListController>(tag: tag);
  @override
  Widget build(BuildContext context) {
    final double minItemWidth = 200; // 最小 item 宽度
    final double spacing = 5; // item 间距
    var screenWidth = MediaQuery.sizeOf(context).width; //获取屏幕宽度
    final column = max(2, screenWidth ~/ minItemWidth);
    // 计算 item 实际宽度
    final itemWidth = (screenWidth - (spacing * (column + 1))) / column;

    return KeepAliveWrapper(
      child: PageGridView(
        pageController: controller,
        padding: AppStyle.edgeInsetsA4,
        firstRefresh: true,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        crossAxisCount: column,
        itemBuilder: (_, i) {
          var item = controller.list[i];
          final itemHeight =
              itemWidth * ((item.height ?? 640) / (item.width ?? 360));
          return VideoItemWidget(item, itemWidth, itemHeight);
        },
      ),
    );
  }
}
