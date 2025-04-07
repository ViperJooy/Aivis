import 'package:aivis/app/app_style.dart';
import 'package:aivis/app/utils.dart';
import 'package:aivis/models/wallpaper/wallpaper_list_model.dart';
import 'package:aivis/widgets/net_image.dart';
import 'package:flutter/material.dart';

class WallpaperItemWidget extends StatelessWidget {
  final WallpaperItemModel item;

  const WallpaperItemWidget(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppStyle.edgeInsetsB4,
      child: InkWell(
        onTap: () {
          // AppNavigator.toBlogContent(url: item.url);
          Utils.showImageViewer(item.id?.toInt() ?? 0, [item.src?.large ?? ""]);
        },
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          child: Hero(
            tag: item.src?.portrait ?? "",
            child: NetImage(
              item.src?.portrait ?? "",
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
