import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostingSwiperWidget extends StatefulWidget {
  const PostingSwiperWidget({required this.data, super.key});

  final List data;

  @override
  State<PostingSwiperWidget> createState() => _PostingSwiperWidgetState();
}

class _PostingSwiperWidgetState extends State<PostingSwiperWidget> {
  int activeIndex = 0;
  List postImageList = [];

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  setImage() {
    setState(() {
      postImageList = widget.data;
    });

    // for (int i = widget.data.length - 1; i >= 0; i--) {
    //   postImageList.add(widget.data[i]);
    // }
  }

  SwiperController swiperController = SwiperController();

  @override
  void initState() {
    setImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 360 / 244,
      child: postImageList.length > 1
          ? Swiper(
              controller: swiperController,
              scrollDirection: Axis.horizontal,
              axisDirection: AxisDirection.left,
              itemCount: postImageList.length,
              viewportFraction: 1,
              onIndexChanged: (value) {
                setSwiper(value);
              },
              scale: 1,
              loop: false,
              itemBuilder: (context, index) {
                dynamic item = postImageList[index];
                return ExtendedImgWidget(
                  imgUrl: item.url,
                  imgFit: BoxFit.cover,
                );
              },
              pagination: SwiperPagination(
                margin: EdgeInsets.only(bottom: 8.w),
                alignment: Alignment.bottomCenter,
                builder: DotSwiperPaginationBuilder(
                  activeColor: CommonColors.gray66,
                  color: const Color.fromRGBO(255, 255, 255, 0.7),
                  activeSize: 8.w,
                  size: 8.w,
                  space: 4.w,
                ),
              ),
            )
          : ExtendedImgWidget(
              imgUrl: postImageList[0].url,
              imgFit: BoxFit.cover,
            ),
    );
  }
}
