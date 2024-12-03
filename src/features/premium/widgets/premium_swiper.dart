import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'transformer_page_view/transformer_page_view.dart';

class PremiumSwiper extends StatefulWidget {
  const PremiumSwiper({super.key});

  @override
  State<PremiumSwiper> createState() => _PremiumSwiperState();
}

class _PremiumSwiperState extends State<PremiumSwiper> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: (CommonSize.vw * 0.777) + 18,
      height: 176,
      child: Swiper(
        controller: swiperController,
        scrollDirection: Axis.horizontal,
        axisDirection: AxisDirection.left,
        itemCount: 2,
        viewportFraction: 1,
        onIndexChanged: (value) {
          setSwiper(value);
        },
        scale: 1,
        loop: false,
        outer: true,
        itemBuilder: (context, index) {
          return index == 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/icon/imgWingLeft.png',
                          width: 29.w,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 4.w, left: 16.w, right: 16.w),
                          child: Text(
                            '우수한 인재를\n더빨리! 더 많이!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24.sp,
                                color: CommonColors.black2b,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        Image.asset(
                          'assets/images/icon/imgWingRight.png',
                          width: 29.w,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 12.w,
                    ),
                    Text(
                      localization.624,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15.sp,
                          color: CommonColors.gray80,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Padding(
                  padding: EdgeInsets.only(left: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localization.625,
                        style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.brown02),
                      ),
                      SizedBox(
                        height: 12.w,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/icon/iconCheckBrown.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Text(
                            localization.626,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12.w,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/icon/iconCheckBrown.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Text(
                            localization.627,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 12.w,
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/icon/iconCheckBrown.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Text(
                            localization.628,
                            style: TextStyle(
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
        pagination: SwiperPagination(
          margin: EdgeInsets.zero,
          alignment: Alignment.bottomCenter,
          builder: DotSwiperPaginationBuilder(
            activeColor: CommonColors.grayB2,
            color: CommonColors.grayE6,
            activeSize: 6.w,
            size: 5.w,
            space: 4.w,
          ),
        ),
      ),
    );
  }
}
