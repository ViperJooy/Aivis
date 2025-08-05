import 'dart:async';
import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/app/event_bus.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/modules/indexed/video/videos_list_controller.dart';
// import 'package:aivis/requests/videos_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // final VideosRequest videosRequest = VideosRequest();
  late TabController tabController;
  VideoHomeController() {
    tabController = TabController(length: tabs.length, vsync: this);
  }

  final tabs = [
    LocaleKeys.indexed_video_nature,
    LocaleKeys.indexed_video_abstract,
    LocaleKeys.indexed_video_city,
    LocaleKeys.indexed_video_life,
    LocaleKeys.indexed_video_sports,
    LocaleKeys.indexed_video_art,
  ];

  StreamSubscription<dynamic>? streamSubscription;

  @override
  void onInit() {
    streamSubscription = EventBus.instance.listen(
      EventBus.kBottomNavigationBarClicked,
      (index) {
        if (index == 0) {
          refreshOrScrollTop();
        }
      },
    );
    for (var tag in tabs) {
      Get.put(VideosListController(tag), tag: tag);
    }

    super.onInit();
  }

  void refreshOrScrollTop() {
    var tabIndex = tabController.index;
    BasePageController controller;
    controller = Get.find<VideosListController>(tag: tabs[tabIndex]);
    controller.scrollToTopOrRefresh();
  }

  // void toSearch() {
  //   AppNavigator.toSearch(SearchType.blog);
  // }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }
}
