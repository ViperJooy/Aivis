import 'package:aivis/app/utils.dart';
import 'package:aivis/modules/video/video_play/video_play_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayPage extends GetView<VideoPlayController> {
  const VideoPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 设置状态栏样式
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // 使用白色图标
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 视频播放器作为背景，充满整个屏幕
            Positioned.fill(child: VideoPlayer(controller: controller)),

            // 手势检测区域 - 放在最底层，但排除顶部区域
            Positioned(
              top: MediaQuery.of(context).padding.top + 60, // 排除顶部区域
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: controller.toggleControls,
                onDoubleTap: controller.toggleFullScreen,
                onHorizontalDragStart: (details) {
                  controller.startSeek();
                },
                onHorizontalDragUpdate: (details) {
                  controller.updateSeek(details.delta.dx);
                },
                onHorizontalDragEnd: (details) {
                  controller.endSeek();
                },
                child: Container(color: Colors.transparent),
              ),
            ),

            // 自定义顶部栏，无论是否全屏都显示
            if (controller.showControls.value)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        // 返回按钮 - 使用Material确保点击效果
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // 如果当前是全屏状态，先退出全屏
                              if (controller.isFullScreen.value) {
                                controller.toggleFullScreen();
                              } else {
                                // 否则直接返回上一页
                                Get.back();
                              }
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 标题
                        Expanded(
                          child: Text(
                            controller.item.user?.name ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 加载指示器 - 显示在视频加载或缓冲时
            if (controller.isLoading.value || controller.buffering.value)
              const Center(child: SpinKitCubeGrid(color: Colors.white)),

            // 视频完成提示
            if (controller.isCompleted.value)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.replay, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        '视频播放完成',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          controller.seek(Duration.zero);
                          controller.play();
                        },
                        child: const Text(
                          '重新播放',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 控制UI - 只在showControls为true时显示
            if (controller.showControls.value)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoControls(controller: controller),
              ),

            // 中央播放/暂停按钮 - 只在特定条件下显示
            if (controller.showControls.value ||
                controller.isLoading.value ||
                controller.buffering.value ||
                controller.isCompleted.value)
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (controller.isCompleted.value) {
                        // 如果视频已完成，点击重新播放
                        controller.seek(Duration.zero);
                        controller.play();
                      } else if (controller.isPlaying.value) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                      controller.resetHideTimer();
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      color: Colors.transparent,
                      child: Obx(() {
                        // 如果正在加载或缓冲，显示加载动画
                        if (controller.isLoading.value ||
                            controller.buffering.value) {
                          return const SpinKitCubeGrid(
                            color: Colors.white,
                            size: 50,
                          );
                        }
                        // 否则显示播放/暂停按钮
                        return Icon(
                          controller.isPlaying.value
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                          size: 50,
                        );
                      }),
                    ),
                  ),
                ),
              ),
          ],
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
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 视频播放器
          Obx(() {
            return AspectRatio(
              aspectRatio:
                  controller.isFullScreen.value
                      ? MediaQuery.of(context).size.aspectRatio
                      : 16 / 9,
              child: Video(
                fit: BoxFit.contain, // 修改为contain以保持视频比例
                controller: controller.videoController,
                controls: NoVideoControls,
              ),
            );
          }),
          // 快进退提示
          Obx(() {
            if (!controller.isSeeking.value) return const SizedBox.shrink();

            final currentPosition = controller.position.value;
            final seekDuration = Duration(
              seconds: controller.seekSeconds.value,
            );
            final targetPosition =
                controller.seekDirection.value == 'forward'
                    ? currentPosition + seekDuration
                    : currentPosition - seekDuration;

            return Positioned(
              top: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.seekDirection.value == 'forward'
                              ? Icons.fast_forward
                              : Icons.fast_rewind,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${controller.seekSeconds.value}秒',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${Utils.formatDuration(targetPosition)} / ${Utils.formatDuration(controller.duration.value)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value:
                              targetPosition.inMilliseconds /
                              (controller.duration.value.inMilliseconds > 0
                                  ? controller.duration.value.inMilliseconds
                                  : 1),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            controller.seekDirection.value == 'forward'
                                ? Colors.red
                                : Colors.blue,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

///  UI控件
class VideoControls extends StatefulWidget {
  final VideoPlayController controller;

  const VideoControls({required this.controller, super.key});

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 播放/暂停按钮
                Obx(() {
                  return IconButton(
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      controller.isPlaying.value
                          ? controller.pause()
                          : controller.play();
                      controller.resetHideTimer();
                    },
                  );
                }),

                // 时间 + 进度条
                Expanded(
                  child: Obx(() {
                    final durationMs =
                        controller.duration.value.inMilliseconds.toDouble();
                    final positionMs =
                        controller.position.value.inMilliseconds.toDouble();

                    return Column(
                      children: [
                        // 时间显示
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                Utils.formatDuration(
                                  Duration(
                                    milliseconds:
                                        (_dragValue ?? positionMs).toInt(),
                                  ),
                                ),
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                Utils.formatDuration(controller.duration.value),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        // 拖动条
                        Slider(
                          value: (_dragValue ?? positionMs).clamp(
                            0.0,
                            durationMs,
                          ),
                          max: durationMs > 0 ? durationMs : 1,
                          onChanged: (value) {
                            setState(() {
                              _dragValue = value;
                            });
                            controller.resetHideTimer();
                          },
                          onChangeEnd: (value) async {
                            setState(() {
                              _dragValue = null;
                            });
                            controller.isLoading.value = true;
                            await controller.seek(
                              Duration(milliseconds: value.toInt()),
                            );
                            controller.isLoading.value = false;
                          },
                        ),
                      ],
                    );
                  }),
                ),

                // 清晰度按钮
                IconButton(
                  icon: controller.getQualityIcon(
                    controller.selectedQuality.value,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Wrap(
                          children: List.generate(
                            controller.qualityOptions.length,
                            (index) {
                              final quality = controller.qualityOptions[index];
                              return Obx(() {
                                bool isSelected =
                                    quality['label'] ==
                                    controller.selectedQuality.value;
                                return ListTile(
                                  title: Text(quality['label'] ?? ""),
                                  trailing:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            color: Colors.blue,
                                          )
                                          : null,
                                  onTap: () {
                                    controller.selectedQuality.value =
                                        quality['label'] ?? "";
                                    controller.playSelectedVideo(quality);
                                    Navigator.pop(context);
                                  },
                                );
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                // 全屏按钮
                Obx(() {
                  return IconButton(
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
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
