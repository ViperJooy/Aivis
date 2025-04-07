import 'package:aivis/app/app_style.dart';
import 'package:aivis/models/video/video_list_model.dart';
import 'package:aivis/routes/app_navigation.dart';
import 'package:flutter/material.dart';

class VideoItemWidget extends StatelessWidget {
  final VideoItemModel item;

  const VideoItemWidget(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppStyle.edgeInsetsB8,
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: AppStyle.radius4,
        child: InkWell(
          onTap: () {
            // AppNavigator.toLiveRoomDetail(site: site, roomId: item.roomId);
            AppNavigator.toVideoPlayer(item);
          },
          borderRadius: AppStyle.radius4,
          child: Card(
            semanticContainer: true,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Hero(
              tag: item.id ?? 0,
              child: FadeInImage.assetNetwork(
                image: item.image ?? "",
                height: 200,
                fit: BoxFit.cover,
                placeholder: "assets/images/city.jpg",
                imageScale: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
