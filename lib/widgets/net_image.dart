import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class NetImage extends StatelessWidget {
  final String picUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double borderRadius;
  const NetImage(
    this.picUrl, {
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (picUrl.isEmpty) {
      return Image.asset(
        'assets/images/city.jpg',
        width: width,
        height: height,
      );
    }
    var pic = picUrl;
    if (pic.startsWith("//")) {
      pic = 'https:$pic';
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ExtendedImage.network(
        pic,
        fit: fit,
        height: height,
        width: width,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(borderRadius),
        loadStateChanged: (e) {
          if (e.extendedImageLoadState == LoadState.loading) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: SizedBox(height: height, width: width),
              // child: Image.asset(
              //   'assets/images/city.jpg',
              //   width: width,
              //   height: height,
              // ),
            );
          }
          if (e.extendedImageLoadState == LoadState.failed) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Icon(Icons.broken_image, color: Colors.grey, size: height),
            );
          }
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: e.completedWidget,
          );
        },
      ),
    );
  }
}
