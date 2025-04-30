import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment alignment;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
    this.placeholder,
    this.errorWidget,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget:
            (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      ),
    );
  }

  Color getRandomPrimaryColor() {
    final random = Random();
    return Colors.primaries[random.nextInt(Colors.primaries.length)];
  }

  Widget _defaultPlaceholder() {
    return SpinKitCubeGrid(color: getRandomPrimaryColor(), size: 50.0);
    // return Container(
    //   color: Colors.grey.shade200,
    //   child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    // );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
    );
  }
}
