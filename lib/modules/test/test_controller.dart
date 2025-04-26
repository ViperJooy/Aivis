import 'package:aivis/modules/test/video_player_controller.dart';
import 'package:aivis/modules/test/video_player_page.dart';
import 'package:get/get.dart';

class TestController extends GetxController {
  void navigateToSecondPage() {
    Get.to(
      () => VideoPlayerPage(),
      arguments:
          "http://192.168.1.110:5244/d/sda1/downloads/movie/%E4%B8%BA%E4%BA%BA%E6%B0%91%E6%9C%8D%E5%8A%A1%20(2022)/%E4%B8%BA%E4%BA%BA%E6%B0%91%E6%9C%8D%E5%8A%A1%20(2022).mkv",
      binding: BindingsBuilder(() {
        Get.put(VideoPlayerController());
      }),
    );
  }
}
