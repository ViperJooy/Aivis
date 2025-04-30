import 'dart:ffi';

import 'package:aivis/app/app_style.dart';
import 'package:aivis/app/utils.dart';
import 'package:aivis/models/wallpaper/wallpaper_list_model.dart';
import 'package:aivis/widgets/cached_image.dart';
import 'package:aivis/widgets/net_image.dart';
import 'package:flutter/material.dart';

class WallpaperItemWidget extends StatelessWidget {
  final WallpaperItemModel item;
  final double itemWidth;
  final double itemHeight;

  const WallpaperItemWidget(
    this.item,
    this.itemWidth,
    this.itemHeight, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // AppNavigator.toBlogContent(url: item.url);
        Utils.showImageViewer(item.id?.toInt() ?? 0, [item.src?.large ?? ""]);
      },
      child: Hero(
        tag: item.src?.portrait ?? "",
        child: CachedImage(
          imageUrl: item.src?.portrait ?? "",
          width: itemWidth,
          height: itemHeight,
          borderRadius: 6,
        ),

        // child: NetImage(
        //   borderRadius: 6,
        //   item.src?.portrait ?? "",
        //   fit: BoxFit.cover,
        //   width: itemWidth,
        //   height: itemHeight,
        // ),
      ),
    );
  }
}
