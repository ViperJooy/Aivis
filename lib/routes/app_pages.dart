// ignore_for_file: prefer_inlined_adds

import 'package:aivis/modules/indexed/douban/top250_home_controller.dart';
import 'package:aivis/modules/indexed/indexed_controller.dart';
import 'package:aivis/modules/indexed/indexed_page.dart';
import 'package:aivis/modules/other/web_view/web_view_controller.dart';
import 'package:aivis/modules/other/web_view/web_view_page.dart';
import 'package:aivis/modules/user/home/user_home_controller.dart';
import 'package:aivis/modules/user/home/user_home_page.dart';
import 'package:aivis/modules/indexed/video/video_home_controller.dart';
import 'package:aivis/modules/indexed/video/video_play/video_play_controller.dart';
import 'package:aivis/modules/indexed/video/video_play/video_play_page.dart';
import 'package:aivis/modules/indexed/wallpaper/wallpaper_home_controller.dart';
import 'package:get/get.dart';

import 'route_path.dart';

class AppPages {
  AppPages._();
  static final routes = [
    // 首页
    GetPage(
      name: RoutePath.kIndex,
      page: () => const IndexedPage(),
      bindings: [
        BindingsBuilder.put(() => IndexedController()),
        BindingsBuilder.put(() => VideoHomeController()),
        BindingsBuilder.put(() => WallpaperHomeController()),
        BindingsBuilder.put(() => Top250HomeController()),
        BindingsBuilder.put(() => UserHomeController()),
      ],
    ),

    // 视频播放界面
    GetPage(
      name: RoutePath.kVideoPlayer,
      page: () => const VideoPlayPage(),
      binding: BindingsBuilder.put(() => VideoPlayController(Get.arguments)),
    ),

    // 用户界面
    GetPage(
      name: RoutePath.kUser,
      page: () => const UserHomePage(),
      binding: BindingsBuilder.put(() => UserHomePage()),
    ),

    GetPage(
      name: RoutePath.kWebView,
      page: () => const WebViewPage(),
      binding: BindingsBuilder.put(() => AppWebViewController(Get.arguments)),
    ),
  ];
}
