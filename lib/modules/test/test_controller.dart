import 'package:aivis/modules/test/video_player_controller.dart';
import 'package:aivis/modules/test/video_player_page.dart';
import 'package:get/get.dart';

class TestController extends GetxController {
  void navigateToSecondPage() {
    Get.to(
      () => VideoPlayerPage(),
      arguments: "http://192.168.2.110:5244/d/mnt/sda1/leee/%E6%A8%AA/015.mp4",
      // arguments:
      //     "http://101.69.252.69:5244/d/mnt/local/movie/TV/Severance%20(2022)/Season%201/Severance%20-%20S01E01%20-%20%E6%9C%89%E5%85%B3%E5%9C%B0%E7%8B%B1%E7%9A%84%E5%A5%BD%E6%B6%88%E6%81%AF.mkv?sign=k8XpkhaSLXH1glY9H6DAot6tPT91MB8xk6bqGuluUtk=:0",
      binding: BindingsBuilder(() {
        Get.put(VideoPlayerController());
      }),
    );
  }
}
