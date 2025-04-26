import 'dart:io';

import 'package:aivis/app/app_style.dart';
import 'package:aivis/app/log.dart';
import 'package:aivis/generated/locales.g.dart';
import 'package:aivis/requests/common_request.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Utils {
  static late PackageInfo packageInfo;
  static DateFormat dateFormat = DateFormat("MM-dd HH:mm");
  static DateFormat dateFormatWithYear = DateFormat("yyyy-MM-dd HH:mm");

  /// 处理时间
  static String parseTime(DateTime? dt) {
    if (dt == null) {
      return "";
    }

    var dtNow = DateTime.now();
    if (dt.year == dtNow.year &&
        dt.month == dtNow.month &&
        dt.day == dtNow.day) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }

    if (dt.year == dtNow.year) {
      return dateFormat.format(dt);
    }

    return dateFormatWithYear.format(dt);
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// 提示弹窗
  /// - `content` 内容
  /// - `title` 弹窗标题
  /// - `confirm` 确认按钮内容，留空为确定
  /// - `cancel` 取消按钮内容，留空为取消
  static Future<bool> showAlertDialog(
    String content, {
    String title = '',
    String confirm = '',
    String cancel = '',
    bool selectable = false,
    List<Widget>? actions,
  }) async {
    var result = await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Padding(
          padding: AppStyle.edgeInsetsV12,
          child: selectable ? SelectableText(content) : Text(content),
        ),
        actions: [
          TextButton(
            onPressed: (() => Get.back(result: false)),
            child: Text(cancel.isEmpty ? LocaleKeys.dialog_cancel.tr : cancel),
          ),
          TextButton(
            onPressed: (() => Get.back(result: true)),
            child: Text(
              confirm.isEmpty ? LocaleKeys.dialog_confirm.tr : confirm,
            ),
          ),
          ...?actions,
        ],
      ),
    );
    return result ?? false;
  }

  /// 提示弹窗
  /// - `content` 内容
  /// - `title` 弹窗标题
  /// - `confirm` 确认按钮内容，留空为确定
  static Future<bool> showMessageDialog(
    String content, {
    String title = '',
    String confirm = '',
    bool selectable = false,
  }) async {
    var result = await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Padding(
          padding: AppStyle.edgeInsetsV12,
          child: selectable ? SelectableText(content) : Text(content),
        ),
        actions: [
          TextButton(
            onPressed: (() => Get.back(result: true)),
            child: Text(
              confirm.isEmpty ? LocaleKeys.dialog_confirm.tr : confirm,
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// 文本编辑的弹窗
  /// - `content` 编辑框默认的内容
  /// - `title` 弹窗标题
  /// - `confirm` 确认按钮内容
  /// - `cancel` 取消按钮内容
  static Future<String?> showEditTextDialog(
    String content, {
    String title = '',
    String? hintText,
    String confirm = '',
    String cancel = '',
  }) async {
    final TextEditingController textEditingController = TextEditingController(
      text: content,
    );
    var result = await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Padding(
          padding: AppStyle.edgeInsetsT12,
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              //prefixText: title,
              contentPadding: AppStyle.edgeInsetsA12,
              hintText: hintText ?? title,
            ),
            // style: TextStyle(
            //     height: 1.0,
            //     color: Get.isDarkMode ? Colors.white : Colors.black),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(LocaleKeys.dialog_cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back(result: textEditingController.text);
            },
            child: Text(LocaleKeys.dialog_confirm.tr),
          ),
        ],
      ),
      // barrierColor:
      //     Get.isDarkMode ? Colors.grey.withOpacity(.3) : Colors.black38,
    );
    return result;
  }

  static Future<T?> showOptionDialog<T>(
    List<T> contents,
    T value, {
    String title = '',
  }) async {
    var result = await Get.dialog(
      SimpleDialog(
        title: Text(title),
        children:
            contents
                .map(
                  (e) => RadioListTile<T>(
                    title: Text(e.toString()),
                    value: e,
                    groupValue: value,
                    onChanged: (e) {
                      Get.back(result: e);
                    },
                  ),
                )
                .toList(),
      ),
    );
    return result;
  }

  static Future<T?> showMapOptionDialog<T>(
    Map<T, String> contents,
    T value, {
    String title = '',
  }) async {
    var result = await Get.dialog(
      SimpleDialog(
        title: Text(title),
        children:
            contents.keys
                .map(
                  (e) => RadioListTile<T>(
                    title: Text((contents[e] ?? '-').tr),
                    value: e,
                    groupValue: value,
                    onChanged: (e) {
                      Get.back(result: e);
                    },
                  ),
                )
                .toList(),
      ),
    );
    return result;
  }

  static void showImageViewer(int initIndex, List<String> images) {
    var index = initIndex.obs;
    Get.dialog(
      Scaffold(
        backgroundColor: Colors.black87,
        body: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: images.length,
              builder: (_, i) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: CachedNetworkImageProvider(images[i]),
                  onTapUp: ((context, details, controllerValue) => Get.back()),
                );
              },
              loadingBuilder:
                  (context, event) =>
                      const Center(child: CircularProgressIndicator()),
              pageController: PageController(initialPage: index.value),
              onPageChanged: ((i) {
                index.value = i;
              }),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              margin: AppStyle.edgeInsetsA24,
              child: Obx(
                () => Text(
                  "${index.value + 1}/${images.length}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: TextButton.icon(
                onPressed: () {
                  // saveImage(images[index.value]);
                },
                icon: const Icon(Icons.save),
                label: Text(LocaleKeys.dialog_save.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 检查相册权限
  static Future<bool> checkPhotoPermission() async {
    try {
      var status = await Permission.photos.status;
      if (status == PermissionStatus.granted) {
        return true;
      }
      status = await Permission.photos.request();
      if (status.isGranted) {
        return true;
      } else {
        Fluttertoast.showToast(
          msg: LocaleKeys.permission_denied_msg.trParams({
            "permission": LocaleKeys.permission_photo.tr,
          }),
        );
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 保存图片
  // static void saveImage(String url) async {
  //   if (Platform.isIOS && !await Utils.checkPhotoPermission()) {
  //     return;
  //   }
  //   try {
  //     var provider = ExtendedNetworkImageProvider(url, cache: true);
  //     var data = await provider.getNetworkImageData();
  //     if (data == null) {
  //       Fluttertoast.showToast(msg: LocaleKeys.dialog_save_image_failure.tr);
  //       return;
  //     }
  //     var cacheDir = await getTemporaryDirectory();
  //     var file = File(p.join(cacheDir.path, p.basename(url)));
  //     await file.writeAsBytes(data);
  //     final result = await ImageGallerySaver.saveFile(
  //       file.path,
  //       name: p.basename(url),
  //       isReturnPathOfIOS: true,
  //     );
  //     Log.d(result.toString());
  //     Fluttertoast.showToast(msg: LocaleKeys.dialog_save_image_successful.tr);
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: LocaleKeys.dialog_save_image_failure.tr);
  //   }
  // }

  /// Markdown图片转为Html
  static String markdownImageConvert(String content) {
    //\!\[.*?\]\((.*?)\)
    var reg = RegExp(r"\!\[.*?\]\((.*?)\)");
    var matches = reg.allMatches(content);
    for (var match in matches) {
      var mdImg = match.group(0) ?? "";
      var src = match.group(1) ?? "";
      var imgHtml = '<img src="$src"/>';

      content = content.replaceAll(mdImg, imgHtml);
    }
    return content;
  }

  static void checkUpdate({bool showMsg = false}) async {
    try {
      int currentVer = Utils.parseVersion(packageInfo.version);
      CommonRequest request = CommonRequest();
      var versionInfo = await request.checkUpdate();
      if (versionInfo.versionNum > currentVer) {
        Get.dialog(
          AlertDialog(
            title: Text(
              "${LocaleKeys.about_new_version.tr} ${versionInfo.version}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            content: Text(
              versionInfo.versionDesc,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actionsPadding: AppStyle.edgeInsetsH12,
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(LocaleKeys.dialog_cancel.tr),
                    ),
                  ),
                  AppStyle.hGap12,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onPressed: () {
                        launchUrlString(
                          versionInfo.downloadUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(LocaleKeys.about_update.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      } else {
        if (showMsg) {
          Fluttertoast.showToast(msg: LocaleKeys.about_not_new_version.tr);
        }
      }
    } catch (e) {
      Log.logPrint(e);
      if (showMsg) {
        Fluttertoast.showToast(msg: LocaleKeys.about_not_new_version.tr);
      }
    }
  }

  static int parseVersion(String version) {
    var sp = version.split('.');
    var num = "";
    for (var item in sp) {
      num = num + item.padLeft(2, '0');
    }
    return int.parse(num);
  }
}
