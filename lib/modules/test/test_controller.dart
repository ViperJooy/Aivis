import 'package:aivis/modules/test/video_player_controller.dart';
import 'package:aivis/modules/test/video_player_page.dart';
import 'package:get/get.dart';

class TestController extends GetxController {
  void navigateToSecondPage() {
    Get.to(
      () => VideoPlayerPage(),
      arguments:
          "http://192.168.1.110:5244/d/sda1/enqi/2024-10-09%E4%B8%8A-%5B%E6%81%A9%E4%B8%83%E4%B8%8D%E7%94%9C%EF%BC%88%E5%A3%B0%E6%8E%A7%E5%8A%A9%E7%9C%A0%EF%BC%89%5D%E6%8E%8F%E8%80%B3%E3%80%81%E9%9B%B7%E5%88%87%E3%80%81%E5%8D%83%E9%B8%9F%E3%80%81%E7%9C%A9%E6%99%95%E3%80%81%E8%BD%BB%E8%AF%AD%E3%80%81%E6%B4%97%E5%A4%B4%E5%8A%A9%E7%9C%A0%E3%80%81%E5%BF%83%E7%81%B5%E6%8C%87%E5%AF%BC.mp4",
      binding: BindingsBuilder(() {
        Get.put(VideoPlayerController());
      }),
    );
  }
}
