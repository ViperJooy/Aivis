import 'dart:ffi';

import 'package:aivis/app/app_style.dart';
import 'package:aivis/app/utils.dart';
import 'package:aivis/models/doubantop250/top250_list_model.dart';
import 'package:aivis/models/wallpaper/wallpaper_list_model.dart';
import 'package:aivis/routes/app_navigation.dart' show AppNavigator;
import 'package:aivis/widgets/cached_image.dart';
import 'package:aivis/widgets/net_image.dart';
import 'package:flutter/material.dart';

class Top250ItemWidget extends StatelessWidget {
  final Top250ItemModel item;
  final double itemWidth;
  final double itemHeight;

  const Top250ItemWidget(
    this.item,
    this.itemWidth,
    this.itemHeight, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        AppNavigator.toWebView(item.movieUrl??"");
        // AppNavigator.toBlogContent(url: item.url);
        // Utils.showImageViewer(item.id?.toInt() ?? 0, [item.src?.large ?? ""]);
      },
      child: Hero(
        tag: item.poster ?? "",
        child: CachedImage(
          imageUrl: item.poster ?? "",
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
