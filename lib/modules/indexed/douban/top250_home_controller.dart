import 'dart:async';
import 'package:aivis/app/controller/base_controller.dart';
import 'package:aivis/app/event_bus.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/modules/indexed/douban/top250_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class Top250HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  Top250HomeController() {
    tabController = TabController(length: tabs.length, vsync: this);
  }

  final tabs = [
    LocaleKeys.indexed_dou_ban_top_250,
  ];

  StreamSubscription<dynamic>? streamSubscription;

  @override
  void onInit() {
    streamSubscription = EventBus.instance.listen(
      EventBus.kBottomNavigationBarClicked,
      (index) {
        if (index == 2) {
          refreshOrScrollTop();
        }
      },
    );
    for (var tag in tabs) {
      Get.put(Top250ListController(tag), tag: tag);
    }

    super.onInit();
  }

  void refreshOrScrollTop() {
    var tabIndex = tabController.index;
    BasePageController controller;
    controller = Get.find<Top250ListController>(tag: tabs[tabIndex]);
    controller.scrollToTopOrRefresh();
  }

  @override
  void onClose() {
    streamSubscription?.cancel();
    super.onClose();
  }
}
