import 'package:aivis/app/app_style.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:aivis/routes/app_navigation.dart';
import 'package:flutter/material.dart';

import '../cached_image.dart';
import '../net_image.dart';

class VideoItemWidget extends StatelessWidget {
  final VideoItemModel item;
  final double itemWidth;
  final double itemHeight;
  const VideoItemWidget(
    this.item,
    this.itemWidth,
    this.itemHeight, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: AppStyle.radius4,
      child: InkWell(
        onTap: () {
          AppNavigator.toVideoPlayer(item);
        },
        child: Hero(
          tag: item.image ?? "",
          child: CachedImage(
            imageUrl: item.image ?? "",
            width: itemWidth,
            height: itemHeight,
            borderRadius: 6,
          ),
        ),
        // borderRadius: AppStyle.radius4,
        // child: Card(
        //   semanticContainer: true,
        //   clipBehavior: Clip.antiAliasWithSaveLayer,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Hero(
        //     tag: item.id ?? 0,
        //     child: FadeInImage.assetNetwork(
        //       image: item.image ?? "",
        //       height: 200,
        //       fit: BoxFit.cover,
        //       placeholder: "assets/images/city.jpg",
        //       imageScale: 1,
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
