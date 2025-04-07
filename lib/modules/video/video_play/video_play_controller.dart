import 'dart:async';
import 'package:aivis/app/log.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoPlayController extends GetxController {
  late final Player player;
  late final VideoController videoController;

  final VideoItemModel item;
  VideoPlayController(this.item);

  // 播放状态
  final isFullScreen = false.obs;
  final isPlaying = false.obs;
  final isLoading = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // 播放进度
  final duration = Duration.zero.obs;
  final position = Duration.zero.obs;
  final buffering = false.obs;

  // 播放控制
  final volume = 70.0.obs;
  final playbackSpeed = 1.0.obs;

  // 控制UI显示状态
  final showControls = true.obs;
  Timer? _hideTimer;

  // 清晰度列表
  List<Map<String, String>> qualityOptions = [];

  @override
  void onInit() {
    super.onInit();
    _initializeQualityOptions();
    _initializePlayer();
  }

  ///对 videoFiles 按 size 降序排序，
  void _initializeQualityOptions() {
    // 空安全处理
    final videoFiles = item.videoFiles ?? [];
    videoFiles.sort((a, b) {
      final sizeA = a.size ?? 0; // 将 null 视为 0 或其他默认值
      final sizeB = b.size ?? 0;
      return sizeB.compareTo(sizeA); // 降序
    });
    // 2. 转换为 Map 列表（带格式化 label）
    qualityOptions =
        videoFiles.map((video) {
          return {
            'label':
                "${video.quality!.toUpperCase()} (${video.width}×${video.height}) ${((video.size ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB", // 拼接名称和大小
            'link': video.link ?? "", // 保留原始 url
          };
        }).toList();
  }

  Future<void> _initializePlayer() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    // 创建新的播放器实例
    player = Player();
    videoController = VideoController(player);

    // 设置播放器配置
    await player.setVolume(volume.value);
    await player.setRate(playbackSpeed.value);
    await player.setPlaylistMode(PlaylistMode.loop);

    // 监听播放状态
    player.stream.playing.listen((playing) {
      isPlaying.value = playing;
      Log.i('Playing state changed: $playing');
    });

    // 监听视频时长
    player.stream.duration.listen((duration) {
      this.duration.value = duration;
      Log.i('Duration updated: $duration');
    });

    // 监听播放位置
    player.stream.position.listen((position) {
      this.position.value = position;
    });

    // 监听缓冲状态
    player.stream.buffering.listen((buffering) {
      this.buffering.value = buffering;
      Log.i('Buffering state: $buffering');
    });

    // 监听错误
    player.stream.error.listen((error) {
      hasError.value = true;
      errorMessage.value = error.toString();
      Log.e('Player error: $error', StackTrace.current);
    });

    // 默认选择次高清视频
    if (qualityOptions.isNotEmpty) {
      await playSelectedVideo(
        qualityOptions.length > 1 ? qualityOptions[1] : qualityOptions.first,
      );
    }
  }

  Future<void> _openVideo(String url) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      Log.i('Opening video: $url');
      await player.open(Media(url));

      Log.i('Starting playback');
      await player.play();
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Log.e('Error opening video: $e', stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  // 播放控制方法
  Future<void> play() async {
    try {
      Log.i('Playing video');
      await player.play();
      isPlaying.value = true;
    } catch (e) {
      Log.e('Error playing video: $e', StackTrace.current);
    }
  }

  Future<void> pause() async {
    try {
      Log.i('Pausing video');
      await player.pause();
      isPlaying.value = false;
    } catch (e) {
      Log.e('Error pausing video: $e', StackTrace.current);
    }
  }

  Future<void> seek(Duration position) async {
    try {
      isLoading.value = true; // 开始加载动画
      Log.i('Seeking to: $position');
      await player.seek(position);
      isLoading.value = false; // 停止加载动画
    } catch (e) {
      Log.e('Error seeking video: $e', StackTrace.current);
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      this.volume.value = volume;
      await player.setVolume(volume);
    } catch (e) {
      Log.e('Error setting volume: $e', StackTrace.current);
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    try {
      playbackSpeed.value = speed;
      await player.setRate(speed);
    } catch (e) {
      Log.e('Error setting playback speed: $e', StackTrace.current);
    }
  }

  // 切换全屏模式
  void toggleFullScreen() {
    if (isFullScreen.value) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 竖屏时状态栏透明
          statusBarIconBrightness: Brightness.dark, // 竖屏时状态栏图标颜色
        ),
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.black, // 全屏时状态栏黑色
          statusBarIconBrightness: Brightness.light, // 全屏时状态栏图标颜色
        ),
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    isFullScreen.value = !isFullScreen.value;
  }

  // 切换控制UI显示
  void toggleControls() {
    showControls.value = !showControls.value;
    if (showControls.value) {
      resetHideTimer();
    }
  }

  // 重置隐藏计时器
  void resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      showControls.value = false;
    });
  }

  @override
  void onClose() {
    Log.i('Disposing player');
    player.dispose();
    _hideTimer?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  // 切换清晰度
  Future<void> playSelectedVideo(Map<String, String> quality) async {
    Log.i('当前选择的播放清晰度是: $quality');
    await _openVideo(quality['link'] ?? '');
  }
}
