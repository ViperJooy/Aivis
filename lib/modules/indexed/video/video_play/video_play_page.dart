import 'dart:io';

import 'package:aivis/app/utils.dart';
import 'package:aivis/modules/indexed/video/video_play/video_play_controller.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayPage extends GetView<VideoPlayController> {
  const VideoPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return _buildPage(context);
    }
    return PiPSwitcher(
      floating: controller.pip,
      childWhenDisabled: _buildPage(context),
      childWhenEnabled: _buildMediaPlayer(context),
    );
  }

  //页面
  Widget _buildPage(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Obx(() => Center(
                    child: AspectRatio(
                      aspectRatio:
                          controller.isPortrait.value ? 9 / 16 : 16 / 9,
                      child: Video(controller: controller.controller),
                    ),
                  )),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.toggleControls,
                  onHorizontalDragUpdate: controller.onHorizontalDragUpdate,
                  onHorizontalDragEnd: controller.onHorizontalDragEnd,
                  onVerticalDragUpdate: controller.onVerticalDragUpdate,
                ),
              ),
              _buildTopControls(context),
              _buildLockButton(context),
              _buildSpeedControls(context),
              _buildBottomControls(context),
              _buildSeekHint(),
              _buildBrightnessHint(), //亮度提示
              _buildVolumeHint(), //音量提示
              _buildLittleProgress(context), //小进度条
            ],
          ),
        ),
      ),
    );
  }

  //小窗
  Widget _buildMediaPlayer(BuildContext context) {
    var boxFit = BoxFit.contain;
    double? aspectRatio = 16 / 9;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Video(
              controller: controller.controller, controls: null, fit: boxFit),
        )
      ],
    );
  }

  //只用来显示进度的小进度条
  Widget _buildLittleProgress(BuildContext context) {
    return Obx(() => Positioned(
        left: 0,
        right: 0,
        bottom: -1.5,
        child: ProgressBar(
          progress: controller.uiPosition.value,
          buffered: controller.buffered.value,
          total: controller.duration.value,
          progressBarColor: Theme.of(context).colorScheme.primary,
          baseBarColor: Colors.white.withOpacity(0.2),
          bufferedBarColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.4),
          timeLabelLocation: TimeLabelLocation.none,
          thumbColor: Theme.of(context).colorScheme.primary,
          barHeight: 3,
          thumbRadius: 0.0,
        )));
  }

  // 顶部控制栏
  Widget _buildTopControls(BuildContext context) {
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Obx(() => AnimatedPositioned(
        left: 0,
        right: 0,
        top: controller.showControls.value
            ? statusBarHeight
            : -(40 + statusBarHeight),
        duration: const Duration(milliseconds: 200),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const Spacer(),
            const IconButton(
              icon: Icon(Icons.h_plus_mobiledata, color: Colors.white),
              onPressed: null,
            ),
            IconButton(
              icon: Icon(Icons.screen_rotation, color: Colors.white),
              onPressed: controller.toggleFullScreen,
            ),
            const IconButton(
              icon: Icon(Icons.fit_screen_outlined, color: Colors.white),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.picture_in_picture, color: Colors.white),
              onPressed: () {
                controller.toggleFloating();
              },
            ),
            const IconButton(
              icon: Icon(Icons.info_outlined, color: Colors.white),
              onPressed: null,
            ),
          ],
        )));
  }

  // 底部控制栏
  Widget _buildBottomControls(BuildContext context) {
    const TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    return Obx(() => AnimatedPositioned(
          left: 0,
          right: 0,
          bottom: controller.showControls.value ? 0 : -100,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            // 拦截横向拖动，防止滑动误触冲突
            onHorizontalDragStart: (_) {},
            onHorizontalDragUpdate: (_) {},
            onHorizontalDragEnd: (_) {},
            behavior: HitTestBehavior.opaque, // 确保区域点击有效
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      ///时间文本
                      SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Utils.formatDuration(
                                    controller.uiPosition.value),
                                style: textStyle,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text("/", style: textStyle),
                              ),
                              // 优化：使用Expanded让文本自动换行或截断
                              Text(
                                Utils.formatDuration(controller.duration.value),
                                style: textStyle,
                              ),
                            ],
                          )),

                      ///可操控的进度条
                      Expanded(
                        child: ProgressBar(
                          progress: controller.uiPosition.value,
                          buffered: controller.buffered.value,
                          total: controller.duration.value,
                          progressBarColor: Colors.red,
                          baseBarColor: Colors.white.withOpacity(0.2),
                          bufferedBarColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.4),
                          barHeight: 5,
                          timeLabelLocation: TimeLabelLocation.none,
                          thumbColor: Colors.grey,
                          thumbCanPaintOutsideBar: false,
                          thumbRadius: 10,
                          onDragStart: (duration) {
                            controller.onDragStart();
                          },
                          onDragUpdate: (duration) {},
                          onDragEnd: () {
                            controller.onDragEnd();
                          },
                          onSeek: (duration) {
                            controller.seekTo(duration);
                          },
                        ),
                        // child: Slider(
                        //   value: controller.uiPosition.value.inSeconds.toDouble(),
                        //   min: 0.0,
                        //   max: controller.duration.value.inSeconds
                        //       .toDouble()
                        //       .clamp(1, double.infinity),
                        //   onChangeStart: (value) => controller.startDragging(),
                        //   onChanged: (value) =>
                        //       controller.updateDraggingPosition(value.seconds),
                        //   onChangeEnd: (value) => controller.stopDragging(value),
                        //   activeColor: Colors.red,
                        //   inactiveColor: Colors.grey.shade800,
                        //   thumbColor: Colors.white,
                        // ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.isPlaying.value
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: controller.togglePlay,
                      ),
                      const Row(
                        children: [
                          Icon(Icons.music_note, color: Colors.white),
                          SizedBox(width: 16),
                          Icon(Icons.closed_caption, color: Colors.white),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }

  // 左侧锁定按钮
  Widget _buildLockButton(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight = MediaQuery.of(context).size.height;
    double topValue = screenHeight / 2 - padding.top;

    return Obx(() => AnimatedPositioned(
        top: topValue,
        left:
            controller.isShowLocked.value ? padding.left : -(50 + padding.left),
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            controller.isLocked.value ? Icons.lock : Icons.lock_open,
            color: Colors.white,
          ),
          onPressed: controller.toggleLock,
        )));
  }

  // 右侧速度控制
  Widget _buildSpeedControls(BuildContext context) {
    var padding = MediaQuery.of(context).padding;
    var screenHeight = MediaQuery.of(context).size.height;
    // 假设控件高度为50，根据实际情况调整
    double controlHeight = 50;
    // 计算垂直居中的top值
    double topValue = (screenHeight - controlHeight) / 2 - padding.top;

    return Obx(() => AnimatedPositioned(
        top: topValue,
        bottom: 0,
        right: controller.isShowLocked.value
            ? padding.right
            : -(50 + padding.right),
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
          height: 50,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: controller.increaseSpeed,
              ),
              Text(
                '${controller.playbackSpeed.value.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.remove, color: Colors.white),
                onPressed: controller.decreaseSpeed,
              ),
            ],
          ),
        )));
  }

  // 进度提示
  Widget _buildSeekHint() {
    return Obx(() => controller.showSeekHint.value
        ? Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      controller.seekHintPosition.value,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(
                      width: 150,
                      child: LinearProgressIndicator(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        value: controller.dragPosition.value.inSeconds /
                            controller.duration.value.inSeconds
                                .clamp(1, double.infinity),
                        backgroundColor: Colors.grey,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox());
  }

  // 竖向手势亮度提示组件
  Widget _buildBrightnessHint() {
    return Obx(
      () => Offstage(
        offstage: !controller.brightnessIndicator.value,
        child: _buildControlHint(
            icon: controller.brightnessValue.value < 0.33
                ? Icons.brightness_low
                : controller.brightnessValue.value < 0.66
                    ? Icons.brightness_medium
                    : Icons.brightness_high,
            value: controller.brightnessValue.value,
            label: "亮度"),
      ),
    );
  }

  // 竖向手势声音提示组件
  Widget _buildVolumeHint() {
    return Obx(() => Offstage(
          offstage: !controller.volumeIndicator.value,
          child: _buildControlHint(
              icon: controller.volumeValue.value == 0.0
                  ? Icons.volume_off
                  : controller.volumeValue.value < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up,
              value: controller.volumeValue.value,
              label: "音量"),
        ));
  }

  // 通用提示组件
  Widget _buildControlHint({
    required IconData icon,
    required double value,
    required String label,
  }) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: 50),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(8),
                    value: value,
                    backgroundColor: Colors.grey,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "${(value * 100).toInt()}%",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
