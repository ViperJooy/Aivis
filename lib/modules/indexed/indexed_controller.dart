import 'package:aivis/app/event_bus.dart';
import 'package:aivis/app/log.dart';
import 'package:aivis/modules/indexed/video/video_home_controller.dart';
import 'package:aivis/modules/indexed/video/video_home_page.dart';
import 'package:aivis/modules/indexed/wallpaper/wallpaper_home_controller.dart';
import 'package:aivis/modules/indexed/wallpaper/wallpaper_home_page.dart';
import 'package:aivis/modules/indexed/douban/top250_home_controller.dart';
import 'package:aivis/modules/indexed/douban/top250_home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IndexedController extends GetxController {
  var index = 0.obs;
  RxList<Widget> pages = RxList<Widget>([
    const VideoHomePage(),
    const SizedBox(),
    const SizedBox(),
  ]);

  void setIndex(i) {
    if (pages[i] is SizedBox) {
      switch (i) {
        case 1:
          pages[i] = const WallpaperHomePage();
          break;
        case 2:
          pages[i] = const Top250HomePage();
          break;
        // case 3:
        //   Get.put(QuestionsHomeController());
        //   pages[i] = const QuestionsHomePage();
        //   break;
        // case 4:
        //   pages[i] = const UserHomePage();
        //   break;
        // default:
      }
    }
    if (index.value == i) {
      EventBus.instance.emit<int>(EventBus.kBottomNavigationBarClicked, i);
    }
    index.value = i;
  }

  @override
  void onInit() {
    // Utils.checkUpdate();
    super.onInit();
  }
}
