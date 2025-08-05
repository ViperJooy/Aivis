import 'package:aivis/app/app_style.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/modules/indexed/video/video_home_controller.dart';
import 'package:aivis/modules/indexed/video/videos_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoHomePage extends GetView<VideoHomeController> {
  const VideoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: Container(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: controller.tabController,
            padding: EdgeInsets.zero,
            tabs: controller.tabs.map((e) => Tab(text: e.tr)).toList(),
            labelPadding: AppStyle.edgeInsetsH20,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: controller.tabs.map((e) => VideosListView(e)).toList(),
      ),
    );
  }
}
