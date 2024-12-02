import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyImgWidget extends StatelessWidget {
  const CompanyImgWidget(
      {required this.imgUrl,
      this.imgWidth,
      this.imgHeight,
      required this.color,
      required this.text,
      super.key});

  final String imgUrl;
  final Color color;
  final String text;

  final double? imgWidth;
  final double? imgHeight;

  String setImageOptions(context, String url, double? width, double? height) {
    int widthPX = 0;
    int heightPX = 0;
    String result = '';
    if (width == null && height != null) {
      heightPX = (height * MediaQuery.of(context).devicePixelRatio).toInt();
      result = '$url?h=$heightPX&f=webp';
    } else if (height == null && width != null) {
      widthPX = (width * MediaQuery.of(context).devicePixelRatio).toInt();
      result = '$url?w=$widthPX&f=webp';
    } else if (height == null && width == null) {
      result = '$url?f=webp';
    } else if (height != null && width != null) {
      widthPX = (width * MediaQuery.of(context).devicePixelRatio).toInt();
      heightPX = (height * MediaQuery.of(context).devicePixelRatio).toInt();
      result = '$url?w=$widthPX&h=$heightPX&f=webp';
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 360 / 244,
      child: ExtendedImage.network(
        setImageOptions(context, imgUrl, imgWidth, imgHeight),
        fit: BoxFit.cover,
        cache: true,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return const Loader();
            case LoadState.completed:
              return state.completedWidget;
            case LoadState.failed:
              return Image.asset(
                'assets/images/icon/imgProfileRecruiter.png',
                fit: BoxFit.cover,
              );
          }
        },
      ),
    );
  }
}
