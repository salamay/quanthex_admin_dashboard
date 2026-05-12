import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class CoinImage extends StatelessWidget {
  CoinImage({super.key,required this.imageUrl, required this.height, required this.width});
  String imageUrl;
  double height;
  double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        shape: BoxShape.circle
      ),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
        placeholder: (context, url) => SizedBox(),
        errorWidget: (context, url, error) => SizedBox(
            child: Icon(Icons.error,size: 10.sp)
        ),
      ),
    );
  }
}
