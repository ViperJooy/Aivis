import 'dart:async';
import 'package:aivis/app/log.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:remixicon/remixicon.dart';

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
  final isCompleted = false.obs; // 添加视频完成状态

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
  final selectedQuality = ''.obs;

  // 快进退相关状态
  final isSeeking = false.obs;
  final seekDirection = ''.obs;
  final seekSeconds = 0.obs;
  static const double seekSensitivity = 0.5; // 滑动灵敏度
  double _cumulativeDeltaX = 0.0; // 累计横向滑动距离

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
    isCompleted.value = false; // 重置完成状态

    // 创建新的播放器实例
    player = Player();
    videoController = VideoController(player);

    // 设置播放器配置
    await player.setVolume(volume.value);
    await player.setRate(playbackSpeed.value);
    await player.setPlaylistMode(PlaylistMode.loop); // 设置为循环播放模式

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
      
      // 检查是否播放完成
      if (position.inMilliseconds > 0 && 
          duration.value.inMilliseconds > 0 && 
          position.inMilliseconds >= duration.value.inMilliseconds - 100) {
        // 视频接近结束，设置完成状态
        if (!isCompleted.value) {
          isCompleted.value = true;
          _handleVideoCompletion();
        }
      }
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

    // 监听完成事件
    player.stream.completed.listen((completed) {
      if (completed) {
        isCompleted.value = true;
        _handleVideoCompletion();
      }
    });

    // 默认选择次高清视频
    if (qualityOptions.isNotEmpty) {
      await playSelectedVideo(
        qualityOptions.length > 1 ? qualityOptions[1] : qualityOptions.first,
      );
      selectedQuality.value = qualityOptions[1]['label'] ?? "";
    }
  }

  // 处理视频完成事件
  void _handleVideoCompletion() {
    Log.i('Video completed');
    isPlaying.value = false;
    isCompleted.value = true;
    
    // 重置播放位置到开始
    player.seek(Duration.zero).then((_) {
      // 直接重新播放，因为我们已经在初始化时设置了循环播放模式
      player.play();
      isCompleted.value = false;
      isPlaying.value = true;
    }).catchError((error) {
      Log.e('Error resetting position: $error', StackTrace.current);
    });
  }

  // 获取清晰度图标的方法
  Widget getQualityIcon(String quality) {
    if (quality.contains('SD')) {
      return const Icon(Icons.sd); // SD 使用的图标
    } else if (quality.contains('HD') && !quality.contains('UHD')) {
      return const Icon(Icons.hd); // HD 使用的图标
    } else if (quality.contains('UHD')) {
      return const Text("UHD", style: TextStyle(fontSize: 12)); // UHD 使用的图标
    } else {
      return const Icon(Icons.hd); // 默认图标
    }
  }

  Future<void> _openVideo(String url) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      isCompleted.value = false; // 重置完成状态

      Log.i('Opening video: $url');
      await player.open(Media(url));

      // 监听视频准备完成事件
      player.stream.playing.listen((_) async {
        Log.i('Video is ready');
        // 在视频准备好后恢复到保存的位置
        final currentPosition = position.value;
        await seek(currentPosition);
        Log.i('恢复到保存的位置: $currentPosition');
      });

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
      isCompleted.value = false; // 重置完成状态
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
      
      // 如果视频已完成，重置完成状态
      if (isCompleted.value) {
        isCompleted.value = false;
      }
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

  void toggleFullScreen() {
    if (isFullScreen.value) {
      // 竖屏状态：恢复状态栏颜色和图标，并显示状态栏
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
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // 恢复边缘状态栏显示
    } else {
      // 全屏状态：隐藏状态栏和导航栏
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 全屏时状态栏透明
          statusBarIconBrightness: Brightness.light, // 全屏时状态栏图标颜色
        ),
      );
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.leanBack,
      ); // 全屏时隐藏状态栏和导航栏
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

    // 保存当前播放位置
    final currentPosition = position.value;
    Log.i('保存当前播放位置: $currentPosition');

    // 打开新视频
    await _openVideo(quality['link'] ?? '');

    // 在新视频加载完成后恢复到保存的位置
    await seek(currentPosition);
    Log.i('恢复到保存的位置: $currentPosition');
  }

  // 开始快进退
  void startSeek() {
    isSeeking.value = true;
    seekSeconds.value = 0;
    _cumulativeDeltaX = 0.0; // 重置累计滑动距离
  }

  // 更新快进退
  void updateSeek(double deltaX) {
    if (!isSeeking.value) return;

    // 累计滑动距离
    _cumulativeDeltaX += deltaX;

    // 计算快进退秒数 (使用累计值而不是单次滑动距离)
    final seconds = (_cumulativeDeltaX * seekSensitivity).abs().toInt();

    // 获取当前播放位置
    final currentPosition = position.value;

    // 根据方向限制快进退时间
    if (_cumulativeDeltaX > 0) {
      // 快进
      final maxForwardSeconds = (duration.value - currentPosition).inSeconds;
      seekSeconds.value = seconds.clamp(0, maxForwardSeconds);
      seekDirection.value = 'forward';
    } else {
      // 快退
      final maxBackwardSeconds = currentPosition.inSeconds;
      seekSeconds.value = seconds.clamp(0, maxBackwardSeconds);
      seekDirection.value = 'backward';
    }

    // 记录日志
    Log.i(
      'Seeking: direction=${seekDirection.value}, seconds=${seekSeconds.value}, delta=${_cumulativeDeltaX}',
    );
  }

  // 结束快进退
  void endSeek() async {
    if (!isSeeking.value || seekSeconds.value == 0) return;

    final currentPosition = position.value;
    final seekDuration = Duration(seconds: seekSeconds.value);

    Log.i(
      'End seeking from position: $currentPosition, seconds: ${seekSeconds.value}, direction: ${seekDirection.value}',
    );

    // 计算新的播放位置
    Duration newPosition;
    if (seekDirection.value == 'forward') {
      newPosition = currentPosition + seekDuration;
    } else {
      newPosition = currentPosition - seekDuration;
    }

    Log.i('Seeking to new position: $newPosition');

    // 执行快进退
    await seek(newPosition);

    // 重置状态
    isSeeking.value = false;
    seekDirection.value = '';
    seekSeconds.value = 0;
    _cumulativeDeltaX = 0.0;
  }
}
