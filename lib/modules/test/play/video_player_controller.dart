import 'package:aivis/modules/test/play/player_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

import '../../../app/app_style.dart';
import '../../../app/log.dart';
import '../../../app/utils.dart';

class VideoPlayerController extends PlayerController
    with WidgetsBindingObserver {
  late String playerUrl;
  final detail = "恩七直播标题".obs;
  var playerStatus = false.obs;

  /// 是否处于后台
  var isBackground = false;
  var loadError = false.obs;

  @override
  void onInit() {
    super.onInit();
    playerUrl = Get.arguments;
    setPlayer();
  }

  void setPlayer() async {
    errorMsg.value = "";

    player.open(
      Media(playerUrl),
    );

    Log.d("播放链接\r\n：$playerUrl");
  }

  @override
  void mediaEnd() async {
    super.mediaEnd();
    if (mediaErrorRetryCount < 2) {
      Log.d("播放结束，尝试第${mediaErrorRetryCount + 1}次刷新");
      if (mediaErrorRetryCount == 1) {
        //延迟一秒再刷新
        await Future.delayed(const Duration(seconds: 1));
      }
      mediaErrorRetryCount += 1;
      //刷新一次
      setPlayer();
      return;
    }

    Log.d("播放结束");
    playerStatus.value = false;
  }

  int mediaErrorRetryCount = 0;
  @override
  void mediaError(String error) async {
    super.mediaEnd();
    if (mediaErrorRetryCount < 2) {
      Log.d("播放失败，尝试第${mediaErrorRetryCount + 1}次刷新");
      if (mediaErrorRetryCount == 1) {
        //延迟一秒再刷新
        await Future.delayed(const Duration(seconds: 1));
      }
      mediaErrorRetryCount += 1;
      //刷新一次
      setPlayer();
      return;
    }
    errorMsg.value = "播放失败";
    Fluttertoast.showToast(msg: "播放失败:$error");
    // if (playUrls.length - 1 == currentLineIndex) {
    //   errorMsg.value = "播放失败";
    //   SmartDialog.showToast("播放失败:$error");
    // } else {
    //   //currentLineIndex += 1;
    //   //setPlayer();
    //   changePlayLine(currentLineIndex + 1);
    // }
  }

  void resetVideo() async {
    // 停止播放
    await player.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      Log.d("进入后台");
      //进入后台，关闭弹幕
      // danmakuController?.clear();
      isBackground = true;
    } else
    //返回前台
    if (state == AppLifecycleState.resumed) {
      Log.d("返回前台");
      isBackground = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void showPlayerSettingsSheet() {
    Utils.showBottomSheet(
      title: "画面尺寸",
      child: Obx(
        () => ListView(
          padding: AppStyle.edgeInsetsV12,
          children: [
            RadioListTile(
              value: 0,
              title: const Text("适应"),
              visualDensity: VisualDensity.compact,
              groupValue: 0,
              onChanged: (e) {
                // AppSettingsController.instance.setScaleMode(e ?? 0);
                updateScaleMode();
              },
            ),
            RadioListTile(
              value: 1,
              title: const Text("拉伸"),
              visualDensity: VisualDensity.compact,
              groupValue: 1,
              onChanged: (e) {
                // AppSettingsController.instance.setScaleMode(e ?? 1);
                updateScaleMode();
              },
            ),
            RadioListTile(
              value: 2,
              title: const Text("铺满"),
              visualDensity: VisualDensity.compact,
              groupValue: 2,
              onChanged: (e) {
                // AppSettingsController.instance.setScaleMode(e ?? 2);
                updateScaleMode();
              },
            ),
            RadioListTile(
              value: 3,
              title: const Text("16:9"),
              visualDensity: VisualDensity.compact,
              groupValue: 3,
              onChanged: (e) {
                // AppSettingsController.instance.setScaleMode(e ?? 3);
                updateScaleMode();
              },
            ),
            RadioListTile(
              value: 4,
              title: const Text("4:3"),
              visualDensity: VisualDensity.compact,
              groupValue: 4,
              onChanged: (e) {
                // AppSettingsController.instance.setScaleMode(e ?? 4);
                updateScaleMode();
              },
            ),
          ],
        ),
      ),
    );
  }
}
