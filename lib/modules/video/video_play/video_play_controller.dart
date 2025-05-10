import 'dart:async';
import 'dart:io';
import 'package:aivis/app/log.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:floating/floating.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:remixicon/remixicon.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../../app/easy_throttle.dart';
import '../../../app/utils.dart';

///播放器配置
final videoControllerConfiguration =
    ValueNotifier<VideoControllerConfiguration>(
  const VideoControllerConfiguration(enableHardwareAcceleration: true),
);

final playerConfiguration = ValueNotifier<PlayerConfiguration>(
  const PlayerConfiguration(bufferSize: 500 * 1024 * 1024),
);

class VideoPlayController extends GetxController {
  final VideoItemModel item;
  VideoPlayController(this.item);

  // 播放器核心
  late final Player player;
  late final VideoController controller;

  // 播放状态
  final Duration controlCancelTime = Duration(seconds: 5); //通用control显示时间
  RxBool isPlaying = false.obs;
  Rx<Duration> position = Duration.zero.obs;
  Rx<Duration> duration = const Duration(seconds: 1).obs;
  Rx<Duration> buffered = const Duration(seconds: 1).obs;
  RxBool isLocked = false.obs;
  RxBool isShowLocked = true.obs;
  RxBool showControls = true.obs;
  RxDouble playbackSpeed = 1.0.obs;
  RxBool isPortrait = false.obs;
  RxBool isFullScreen = false.obs; //全屏状态

  double _dragDelta = 0;
  bool isSliderDragging = false;
  RxBool showSeekHint = false.obs;
  RxString seekHintPosition = ''.obs;
  Rx<Duration> dragPosition = Duration.zero.obs;
  Rx<Duration> uiPosition = Duration.zero.obs;

  // 亮度控制
  final RxBool brightnessIndicator = false.obs;
  Timer? _brightnessTimer;
  final brightnessValue = 0.5.obs;

  // 音量控制
  final RxBool volumeIndicator = false.obs;
  Timer? _volumeTimer;
  final volumeValue = 0.0.obs;

  Timer? _hideUITimer;
  Timer? _hideLockTimer;

  late Floating pip;

  @override
  void onInit() {
    super.onInit();
    player = Player(configuration: playerConfiguration.value);
    controller = VideoController(player,
        configuration: videoControllerConfiguration.value);

    player.open(Media(item.videoFiles?.first.link ?? ''));

    if (Platform.isAndroid) {
      pip = Floating();
    }
    initListener();
  }

  void destroy() {
    player.dispose();
    Future.microtask(() async {
      try {
        await ScreenBrightness.instance.resetApplicationScreenBrightness();
      } catch (_) {}
    });
    _hideUITimer?.cancel();
    _hideLockTimer?.cancel();
  }

  @override
  void onClose() {
    destroy();
    _exitFullScreen(); // 离开页面时恢复
    super.onClose();
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

  void toggleFullScreen() {
    isFullScreen.value = !isFullScreen.value;
    isFullScreen.value ? _enterFullScreen() : _exitFullScreen();
  }

  void _enterFullScreen() {
    FullScreenWindow.setFullScreen(true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    FullScreenWindow.setFullScreen(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  //开始拖动进度条
  void onDragStart() {
    _hideUITimer?.cancel();
  }

  //结束拖动进度条
  void onDragEnd() {
    _startHideUITimer();
    _startHideLockTimer();
  }

  // 进度控制
  void seekTo(Duration duration) {
    player.seek(duration);
  }

  //横屏滑动视频进度
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (isLocked.value) return;

    isSliderDragging = true;
    //滑动的时候ui不隐藏
    showControls.value = false;
    isShowLocked.value = false;

    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final totalSeconds = duration.value.inSeconds.clamp(1, double.infinity);
    final secondsPerPixel = totalSeconds / screenWidth;
    _dragDelta += details.primaryDelta ?? 0;
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

    isSliderDragging = false;
    player.seek(dragPosition.value);
    position.value = dragPosition.value;
    uiPosition.value = dragPosition.value;

    _dragDelta = 0;
    Future.delayed(const Duration(seconds: 1), () {
      showSeekHint.value = false;
    });
  }

  void startDragging() => isSliderDragging = true;

  void updateDraggingPosition(Duration duration) {
    dragPosition.value = duration;
    uiPosition.value = duration;
    seekHintPosition.value =
        '${Utils.formatDuration(duration)} / ${Utils.formatDuration(duration)}';
    showSeekHint.value = true;
  }

  void stopDragging(double seconds) {
    isSliderDragging = false;
    final d = Duration(seconds: seconds.toInt());
    player.seek(d);
    position.value = d;
    uiPosition.value = d;
    dragPosition.value = d;
    Future.delayed(
        const Duration(seconds: 1), () => showSeekHint.value = false);
  }

  //竖向手势操作，亮度/音量
  void onVerticalDragUpdate(DragUpdateDetails details) async {
    final double widgetWidth = MediaQuery.sizeOf(Get.context!).width;
    final double delta = details.delta.dy;
    final Offset position = details.localPosition;

    /// 锁定时禁用
    if (isLocked.value) return;
    if (position.dx <= widgetWidth / 2) {
      // 左边区域 👈
      final double level =
          (isFullScreen.value ? Get.size.height : Get.size.width * 9 / 16) * 3;
      final double brightness = brightnessValue.value - delta / level;
      final double result = brightness.clamp(0.0, 1.0);
      setBrightness(result);
    } else {
      // 右边区域 👈
      EasyThrottle.throttle('setVolume', const Duration(milliseconds: 30), () {
        final double level =
            (isFullScreen.value ? Get.size.height : Get.size.width * 9 / 16);
        // 音量调节 - 使用动态灵敏度因子
        final double clampedVolume =
            (volumeValue.value - (delta / level) * 0.8).clamp(0.0, 1.0);
        // 更新音量
        setVolume(clampedVolume);
      });
    }
  }

  Future<void> setVolume(double value) async {
    //此时如果正在显示亮度提示组件这里应该立即隐藏
    brightnessIndicator.value = false;
    showControls.value = false;
    isShowLocked.value = false;

    try {
      VolumeController.instance.showSystemUI = false;
      await VolumeController.instance.setVolume(value);
    } catch (_) {}
    volumeValue.value = value;
    volumeIndicator.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(seconds: 1), () {
      volumeIndicator.value = false;
    });
  }

  Future<void> setBrightness(double value) async {
    //此时如果正在显示声音提示组件这里应该立即隐藏
    isShowLocked.value = false;
    volumeIndicator.value = false;
    showControls.value = false;

    try {
      await ScreenBrightness().setApplicationScreenBrightness(value);
    } catch (_) {}
    brightnessIndicator.value = true;
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(seconds: 1), () {
      brightnessIndicator.value = false;
    });
  }

  // 设置倍速
  void increaseSpeed() {
    playbackSpeed.value = (playbackSpeed.value + 0.1).clamp(0.5, 2.0);
    player.setRate(playbackSpeed.value);
  }

  // 设置倍速
  void decreaseSpeed() {
    playbackSpeed.value = (playbackSpeed.value - 0.1).clamp(0.5, 2.0);
    player.setRate(playbackSpeed.value);
  }

  // 隐藏ui
  void _startHideUITimer() {
    _hideUITimer?.cancel();
    _hideUITimer = Timer(controlCancelTime, () {
      showControls.value = false;
    });
  }

  //隐藏lock
  void _startHideLockTimer() {
    _hideLockTimer?.cancel();
    _hideLockTimer = Timer(controlCancelTime, () {
      isShowLocked.value = false;
    });
  }

  //初始化播放器监听
  void initListener() {
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
      if (!isSliderDragging) {
        position.value = event;
        uiPosition.value = event;
      }
    });

    player.stream.duration.listen((event) {
      if (event > Duration.zero) {
        duration.value = event;
      }
    });

    player.stream.buffer.listen((event) {
      buffered.value = event;
    });

    // player.stream.buffering.listen((event) {
    //   isBuffering.value = event;
    // });

    Future.microtask(() async {
      try {
        brightnessValue.value = await ScreenBrightness.instance.application;
        ScreenBrightness.instance.onApplicationScreenBrightnessChanged
            .listen((double value) {
          brightnessValue.value = value;
        });
      } catch (_) {}
    });
  }

  void toggleFloating() async {
    showControls.value = false;
    isShowLocked.value = false;

    final isAvailable = await pip.isPipAvailable;
    if (isAvailable) {
      await pip.enable(ImmediatePiP());
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('当前设备不支持画中画模式')),
      );
    }
  }
}
