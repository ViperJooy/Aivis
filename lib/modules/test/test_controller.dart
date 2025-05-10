import 'package:aivis/modules/test/video_player_controller.dart';
import 'package:aivis/modules/test/video_player_page.dart';
import 'package:get/get.dart';

class TestController extends GetxController {
  void navigateToSecondPage() {
    Get.to(
      () => VideoPlayerPage(),
      arguments: "http://192.168.1.110:5244/d/mnt/sda1/leee/%E6%A8%AA/015.mp4",
      binding: BindingsBuilder(() {
        Get.put(VideoPlayerController());
      }),
    );
  }
}
