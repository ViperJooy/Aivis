import 'dart:async';
import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/app/event_bus.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/modules/wallpaper/wallpapers_list_controller.dart';
import 'package:aivis/requests/wallpapers_request.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WallpaperHomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final WallpapersRequest wallpapersRequest = WallpapersRequest();
  late TabController tabController;
  WallpaperHomeController() {
    tabController = TabController(length: tabs.length, vsync: this);
  }

  final tabs = [
    LocaleKeys.indexed_wallpaper_wallpaper,
    LocaleKeys.indexed_wallpaper_background,
    LocaleKeys.indexed_wallpaper_travel,
    LocaleKeys.indexed_wallpaper_minimalism,
    LocaleKeys.indexed_wallpaper_car,
    LocaleKeys.indexed_wallpaper_white,
    LocaleKeys.indexed_wallpaper_black,
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
      Get.put(WallpapersListController(tag), tag: tag);
    }

    super.onInit();
  }

  void refreshOrScrollTop() {
    var tabIndex = tabController.index;
    BasePageController controller;
    controller = Get.find<WallpapersListController>(tag: tabs[tabIndex]);
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
