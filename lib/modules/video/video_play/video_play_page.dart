import 'package:aivis/app/utils.dart';
import 'package:aivis/modules/video/video_play/video_play_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayPage extends GetView<VideoPlayController> {
  const VideoPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: !controller.isFullScreen.value,
        onPopInvokedWithResult: (didPop, result) {
          if (controller.isFullScreen.value) {
            controller.toggleFullScreen(); // Handle fullscreen exit
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: Container(
              color: Colors.black12,
              child: Stack(
                children: [
                  VideoPlayer(controller: controller),
                  if (controller.buffering.value)
                    Center(child: CircularProgressIndicator()),
                  if (controller.showControls.value)
                    VideoControls(controller: controller),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class VideoPlayer extends StatelessWidget {
  final VideoPlayController controller;

  const VideoPlayer({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: controller.toggleControls,
        onDoubleTap: controller.toggleFullScreen,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio:
                    controller.isFullScreen.value
                        ? MediaQuery.of(context).size.aspectRatio
                        : 16 / 9,
                child: Video(
                  controller: controller.videoController,
                  controls: NoVideoControls,
                ),
              ),
              if (controller.showControls.value)
                IconButton(
                  iconSize: 64.0,
                  icon: Icon(
                    controller.isPlaying.value
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (controller.isPlaying.value) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    controller.resetHideTimer();
                  },
                ),
            ],
          ),
        ),
      );
    });
  }
}

///  UI控件
class VideoControls extends StatelessWidget {
  final VideoPlayController controller;

  const VideoControls({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (controller.isPlaying.value) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    controller.resetHideTimer();
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      // 显示当前时间和总时长
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Utils.formatDuration(controller.position.value),
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              Utils.formatDuration(controller.duration.value),
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      // 进度条
                      Slider(
                        value:
                            controller.position.value.inMilliseconds.toDouble(),
                        max:
                            controller.duration.value.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          controller.position.value = Duration(
                            milliseconds: value.toInt(),
                          );
                        },
                        onChangeEnd: (value) {
                          controller.isLoading.value = true;
                          controller
                              .seek(Duration(milliseconds: value.toInt()))
                              .then((_) {
                                controller.isLoading.value = false;
                              });
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    controller.isFullScreen.value
                        ? Icons.fullscreen_exit
                        : Icons.fullscreen,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    controller.toggleFullScreen();
                    controller.toggleControls();
                  },
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      color: Colors.white,
                      child: Wrap(
                        children: List.generate(
                          controller.qualityOptions.length,
                          (index) {
                            return ListTile(
                              title: Text(
                                controller.qualityOptions[index]['label'] ?? "",
                              ),
                              onTap: () {
                                controller.playSelectedVideo(
                                  controller.qualityOptions[index],
                                );
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    });
  }
}
