import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

final configuration = ValueNotifier<VideoControllerConfiguration>(
  const VideoControllerConfiguration(enableHardwareAcceleration: true),
);

class VideoPlayerController extends GetxController {
  late final String url;
  // Create a [Player] to control playback.
  late final Player player;
  // Create a [VideoController] to handle video output from [Player].
  late final VideoController controller;

  @override
  void onInit() {
    super.onInit();
    url = Get.arguments ?? 'No url';
    player = Player();
    controller = VideoController(player, configuration: configuration.value);
    player.open(Media(url));
    player.stream.error.listen((error) => debugPrint(error));
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
