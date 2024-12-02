import 'package:chodan_flutter_app/features/recommend/widgets/recommend_top.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendThemeSwiper extends StatefulWidget {
  const RecommendThemeSwiper({super.key});

  @override
  State<RecommendThemeSwiper> createState() => _RecommendThemeSwiperState();
}

class _RecommendThemeSwiperState extends State<RecommendThemeSwiper> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 102.w,
        child: Swiper(
          controller: swiperController,
          scrollDirection: Axis.horizontal,
          axisDirection: AxisDirection.left,
          itemCount: 3,
          viewportFraction: 0.85,
          onIndexChanged: (value) {
            setSwiper(value);
          },
          loop: false,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 0),
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(
                        width: 1.w,
                        color: CommonColors.red,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.w),
                          child: SizedBox(
                            width: 86.w,
                            height: 86.w,
                            child: Image.asset(
                              'assets/images/default/imgDefault.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '비빌디파크 스노우월드',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                                  Text(
                                    '비발디 스키장 및 리조트 / 골프 ',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 50.w),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/icon/iconPinGray.png',
                                      width: 14.w,
                                      height: 14.w,
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Text(
                                      '2.7km',
                                      style: TextStyle(
                                        fontSize: 12.w,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '이천시 이천동',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 12.w,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(right: 50.w),
                                child: Row(
                                  children: [
                                    Text(
                                      '월급',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.gray80,
                                        fontSize: 12.w,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 6.w,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '3,120,000원',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 6.w,
                    bottom: 6.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: Center(
                            child: CustomPaint(
                              size: Size(40.w, 40.w),
                              painter: RecommendProgress(80),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '매칭',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: CommonColors.red,
                              ),
                            ),
                            Text(
                              '80',
                              style: TextStyle(
                                height: 0.7,
                                color: CommonColors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

