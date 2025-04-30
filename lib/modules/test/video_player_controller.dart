import 'dart:async';
import 'package:aivis/app/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:screen_brightness/screen_brightness.dart';

final configuration = ValueNotifier<VideoControllerConfiguration>(
  const VideoControllerConfiguration(enableHardwareAcceleration: true),
);

class VideoPlayerController extends GetxController {
  // 播放器核心
  late final Player player;
  late final VideoController controller;

  // 播放状态
  final isPlaying = false.obs;
  final position = Duration.zero.obs;
  final duration = const Duration(seconds: 1).obs;
  final isLocked = false.obs;
  final isShowLocked = true.obs;
  final showControls = true.obs;
  final playbackSpeed = 1.0.obs;
  final isPortrait = false.obs;

  // 进度控制
  double _dragDelta = 0;
  bool isSeekDragging = false;
  final showSeekHint = false.obs;
  final seekHintPosition = ''.obs;
  final dragPosition = Duration.zero.obs;
  final uiPosition = Duration.zero.obs;

  // 亮度控制
  final brightnessLevel = 0.5.obs;
  final showBrightnessHint = false.obs;
  double _initialBrightness = 0.5;
  double _brightnessDragDistance = 0.0;
  Timer? _brightnessHideTimer;

  // 音量控制
  final volumeLevel = 0.5.obs;
  final showVolumeHint = false.obs;
  double _initialVolume = 0.5;
  double _volumeDragDistance = 0.0;
  Timer? _volumeHideTimer;

  Timer? _hideUITimer;
  Timer? _hideLockTimer;

  // 屏幕方向状态
  final isFullScreen = true.obs;
  final systemOverlayVisible = true.obs;

  @override
  void onInit() {
    super.onInit();

    // 进入时强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    player = Player();
    controller = VideoController(player, configuration: configuration.value);
    player.open(Media(Get.arguments ?? ''));

    player.stream.width.listen((width) {
      player.stream.height.listen((height) {
        if (width != null && height != null) {
          isPortrait.value = width < height;
        }
      });
    });

    player.stream.playing.listen((event) {
      isPlaying.value = event;
      if (event) {
        _startHideUITimer();
        _startHideLockTimer();
      }
    });

    player.stream.position.listen((event) {
      if (!isSeekDragging) {
        position.value = event;
        uiPosition.value = event;
      }
    });

    player.stream.duration.listen((event) {
      duration.value = event;
    });
  }

  // 播放控制
  void togglePlay() => isPlaying.value ? player.pause() : player.play();

  void toggleControls() {
    if (isLocked.value) {
      isShowLocked.value = !isShowLocked.value;
    } else {
      showControls.value = !showControls.value;
      isShowLocked.value = showControls.value;
      if (showControls.value) _startHideUITimer();
    }
    _startHideLockTimer();
  }

  void toggleLock() {
    if (isLocked.value) {
      showControls.value = true;
      isLocked.value = false;
    } else {
      showControls.value = false;
      isLocked.value = true;
    }
    _startHideUITimer();
    _startHideLockTimer();
  }

  // 进度控制
  void onSeek(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    player.seek(d);
    dragPosition.value = d;
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (isLocked.value) return;

    isSeekDragging = true;
    showControls.value = false;
    isShowLocked.value = false;

    _dragDelta += details.primaryDelta ?? 0;

    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final totalSeconds = duration.value.inSeconds.clamp(1, double.infinity);
    final secondsPerPixel = totalSeconds / screenWidth;

    final offsetSeconds = (_dragDelta * secondsPerPixel).round();
    if (offsetSeconds == 0) return;

    final newPositionInSeconds = position.value.inSeconds + offsetSeconds;
    final clamped = newPositionInSeconds.clamp(0, duration.value.inSeconds);
    final target = Duration(seconds: clamped);

    dragPosition.value = target;
    uiPosition.value = target;

    seekHintPosition.value =
        '${Utils.formatDuration(target)} / ${Utils.formatDuration(duration.value)}';
    showSeekHint.value = true;
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    if (isLocked.value) return;

    isSeekDragging = false;
    player.seek(dragPosition.value);
    position.value = dragPosition.value;
    uiPosition.value = dragPosition.value;

    _dragDelta = 0;
    Future.delayed(const Duration(seconds: 1), () {
      showSeekHint.value = false;
    });
  }

  void startDragging() => isSeekDragging = true;

  void updateDraggingPosition(double seconds) {
    final d = Duration(seconds: seconds.toInt());
    dragPosition.value = d;
    uiPosition.value = d;
    seekHintPosition.value =
        '${Utils.formatDuration(d)} / ${Utils.formatDuration(duration.value)}';
    showSeekHint.value = true;
  }

  void stopDragging(double seconds) {
    isSeekDragging = false;
    final d = Duration(seconds: seconds.toInt());
    player.seek(d);
    position.value = d;
    uiPosition.value = d;
    dragPosition.value = d;
    Future.delayed(
        const Duration(seconds: 1), () => showSeekHint.value = false);
  }

  // 亮度/音量控制
  void onVerticalDragStart(DragStartDetails details) async {
    if (isLocked.value) return;

    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final isLeftSide = details.globalPosition.dx < screenWidth / 2;

    // 取消之前的隐藏计时器
    _brightnessHideTimer?.cancel();
    _volumeHideTimer?.cancel();

    if (isLeftSide) {
      showVolumeHint.value = false; // 立即隐藏音量提示
      showBrightnessHint.value = true;
      try {
        _initialBrightness = await ScreenBrightness.instance.application;
        brightnessLevel.value = _initialBrightness;
      } catch (e) {
        _initialBrightness = 0.5;
        brightnessLevel.value = 0.5;
      }
      _brightnessDragDistance = 0.0;
    } else {
      showBrightnessHint.value = false; // 立即隐藏亮度提示
      showVolumeHint.value = true;
      _initialVolume = player.state.volume / 100;
      volumeLevel.value = _initialVolume;
      _volumeDragDistance = 0.0;
    }
  }

  void onVerticalDragUpdate(DragUpdateDetails details) async {
    if (isLocked.value) return;

    final delta = -details.delta.dy;
    final screenHeight = MediaQuery.of(Get.context!).size.height;

    if (showBrightnessHint.value) {
      _brightnessDragDistance += delta;
      final change = _brightnessDragDistance / screenHeight;

      double newValue = (_initialBrightness + change).clamp(0.0, 1.0);
      brightnessLevel.value = newValue;
      await ScreenBrightness.instance.setApplicationScreenBrightness(newValue);
    }

    if (showVolumeHint.value) {
      _volumeDragDistance += delta;
      final change = _volumeDragDistance / screenHeight;

      double newValue = (_initialVolume + change).clamp(0.0, 1.0);
      volumeLevel.value = newValue;
      player.setVolume(newValue * 100);
    }
  }

  void onVerticalDragEnd(DragEndDetails details) {
    if (showBrightnessHint.value) {
      _brightnessHideTimer = Timer(const Duration(seconds: 1), () {
        showBrightnessHint.value = false;
      });
    }

    if (showVolumeHint.value) {
      _volumeHideTimer = Timer(const Duration(seconds: 1), () {
        showVolumeHint.value = false;
      });
    }
  }

  // 其他功能
  void increaseSpeed() {
    playbackSpeed.value = (playbackSpeed.value + 0.1).clamp(0.5, 2.0);
    player.setRate(playbackSpeed.value);
  }

  void decreaseSpeed() {
    playbackSpeed.value = (playbackSpeed.value - 0.1).clamp(0.5, 2.0);
    player.setRate(playbackSpeed.value);
  }

  // 辅助方法
  void _startHideUITimer() {
    _hideUITimer?.cancel();
    _hideUITimer = Timer(const Duration(seconds: 5), () {
      showControls.value = false;
    });
  }

  void _startHideLockTimer() {
    _hideLockTimer?.cancel();
    _hideLockTimer = Timer(const Duration(seconds: 5), () {
      isShowLocked.value = false;
    });
  }

  // 切换横竖屏
  void toggleFullScreen() {
    isFullScreen.toggle();
    systemOverlayVisible.value = !isFullScreen.value;

    if (isFullScreen.value) {
      // 横屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      // 竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  // 退出播放时调用
  Future<void> exitFullScreen() async {
    // 恢复竖屏
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: SystemUiOverlay.values,
    );
  }

  void destroy() {
    player.dispose();
    _brightnessHideTimer?.cancel();
    _volumeHideTimer?.cancel();
    Future.microtask(() async {
      try {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      } catch (_) {}
    });
    _hideUITimer?.cancel();
    _hideLockTimer?.cancel();
    exitFullScreen(); // 控制器关闭时恢复竖屏
  }

  @override
  void onClose() {
    super.onClose();
    destroy();
  }

  @override
  void dispose() {
    destroy();
    super.dispose();
  }
}
