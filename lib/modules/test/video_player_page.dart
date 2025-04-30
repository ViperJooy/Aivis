import 'package:aivis/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'video_player_controller.dart';

class VideoPlayerPage extends GetView<VideoPlayerController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              Center(
                child: Obx(() => controller.isPortrait.value
                    ? AspectRatio(
                        aspectRatio: 9 / 16,
                        child: Video(controller: controller.controller))
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Video(controller: controller.controller))),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: controller.toggleControls,
                  onHorizontalDragUpdate: controller.onHorizontalDragUpdate,
                  onHorizontalDragEnd: controller.onHorizontalDragEnd,
                  onVerticalDragStart: controller.onVerticalDragStart,
                  onVerticalDragUpdate: controller.onVerticalDragUpdate,
                  onVerticalDragEnd: controller.onVerticalDragEnd,
                ),
              ),
              _buildTopControls(context),
              _buildLockButton(),
              _buildSpeedControls(),
              _buildBottomControls(),
              _buildSeekHint(),
              _buildBrightnessHint(), // 亮度提示
              _buildVolumeHint(), // 音量提示（后添加的会显示在上层）
            ],
          ),
        ),
      ),
    );
  }

  // 顶部控制栏
  Widget _buildTopControls(BuildContext context) {
    return Obx(() => controller.showControls.value
        ? Positioned(
            top: 40,
            left: 5,
            right: 5,
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
                const IconButton(
                  icon: Icon(Icons.picture_in_picture, color: Colors.white),
                  onPressed: null,
                ),
                const IconButton(
                  icon: Icon(Icons.info_outlined, color: Colors.white),
                  onPressed: null,
                ),
              ],
            ),
          )
        : const SizedBox());
  }

  // 锁定按钮
  Widget _buildLockButton() {
    return Obx(() => Positioned(
          left: 16,
          top: MediaQuery.of(Get.context!).size.height / 2 - 30,
          child: Visibility(
            visible: controller.isShowLocked.value,
            child: IconButton(
              icon: Icon(
                controller.isLocked.value ? Icons.lock : Icons.lock_open,
                color: Colors.white,
              ),
              onPressed: controller.toggleLock,
            ),
          ),
        ));
  }

  // 速度控制
  Widget _buildSpeedControls() {
    return Obx(() => controller.showControls.value
        ? Positioned(
            right: 16,
            top: MediaQuery.of(Get.context!).size.height / 2 - 60,
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
          )
        : const SizedBox());
  }

  // 底部控制栏
  Widget _buildBottomControls() {
    return Obx(() => controller.showControls.value
        ? Positioned(
            left: 5,
            right: 5,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: SizedBox(
                        width: 90,
                        child: Text(
                          '${Utils.formatDuration(controller.uiPosition.value)} / ${Utils.formatDuration(controller.duration.value)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: controller.uiPosition.value.inSeconds.toDouble(),
                        min: 0.0,
                        max: controller.duration.value.inSeconds
                            .toDouble()
                            .clamp(1, double.infinity),
                        onChangeStart: (value) => controller.startDragging(),
                        onChanged: (value) =>
                            controller.updateDraggingPosition(value),
                        onChangeEnd: (value) => controller.stopDragging(value),
                        activeColor: Colors.red,
                        inactiveColor: Colors.grey.shade800,
                        thumbColor: Colors.white,
                      ),
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
                        SizedBox(width: 20),
                        Icon(Icons.closed_caption, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          )
        : const SizedBox());
  }

  // 进度提示
  Widget _buildSeekHint() {
    return Obx(() => controller.showSeekHint.value
        ? Positioned(
            top: 100,
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

  // 亮度提示组件
  Widget _buildBrightnessHint() {
    return Obx(() => controller.showBrightnessHint.value
        ? Positioned(
            child: _buildControlHint(
              icon: _getBrightnessIcon(controller.brightnessLevel.value),
              value: controller.brightnessLevel.value,
              label: '亮度',
            ),
          )
        : const SizedBox());
  }

// 音量提示组件
  Widget _buildVolumeHint() {
    return Obx(() => controller.showVolumeHint.value
        ? Positioned(
            child: _buildControlHint(
              icon: controller.volumeLevel.value > 0
                  ? Icons.volume_up
                  : Icons.volume_off,
              value: controller.volumeLevel.value,
              label: '音量',
            ),
          )
        : const SizedBox());
  }

  // 通用提示组件
  Widget _buildControlHint({
    required IconData icon,
    required double value,
    required String label,
  }) {
    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
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
      ),
    );
  }

  IconData _getBrightnessIcon(double level) {
    if (level < 0.33) return Icons.brightness_low;
    if (level < 0.66) return Icons.brightness_medium;
    return Icons.brightness_high;
  }
}
