import 'dart:io';

import 'package:aivis/modules/test/play/player_controls.dart';
import 'package:aivis/modules/test/play/video_player_controller.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerPage extends GetView<VideoPlayerController> {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final page = buildMediaPlayer();
    // final page = Obx(
    //   () {
    //     if (controller.fullScreenState.value) {
    //       return PopScope(
    //         canPop: false,
    //         onPopInvoked: (e) {
    //           controller.exitFull();
    //         },
    //         child: Scaffold(
    //           body: buildMediaPlayer(),
    //         ),
    //       );
    //     } else {
    //       return buildPageUI();
    //     }
    //   },
    // );
    if (!Platform.isAndroid) {
      return page;
    }
    return PiPSwitcher(
      floating: controller.pip,
      childWhenDisabled: page,
      childWhenEnabled: buildMediaPlayer(),
    );
  }

  Widget buildMediaPlayer() {
    var boxFit = BoxFit.contain;
    double? aspectRatio = 16 / 9;
    return Stack(
      children: [
        Video(
          key: controller.globalPlayerKey,
          controller: controller.videoController,
          pauseUponEnteringBackgroundMode: true,
          resumeUponEnteringForegroundMode: false,
          controls: (state) {
            return playerControls(state, controller);
          },
          aspectRatio: aspectRatio,
          fit: boxFit,
          // 自己实现
          wakelock: false,
        ),
      ],
    );
  }

  // Widget buildPageUI() {
  //   return OrientationBuilder(
  //     builder: (context, orientation) {
  //       return Scaffold(
  //         backgroundColor: Colors.black,
  //         body: buildPhoneUI(context),
  //       );
  //     },
  //   );
  // }
  //
  // Widget buildPhoneUI(BuildContext context) {
  //   return Center(
  //     child: AspectRatio(
  //       aspectRatio: 16 / 9,
  //       child: buildMediaPlayer(),
  //     ),
  //   );
  // }
}
