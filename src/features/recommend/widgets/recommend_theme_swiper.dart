import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_service.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_top.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RecommendThemeSwiper extends StatefulWidget {
  const RecommendThemeSwiper({super.key, required this.recommendData});

  final List recommendData;

  @override
  State<RecommendThemeSwiper> createState() => _RecommendThemeSwiperState();
}

class _RecommendThemeSwiperState extends State<RecommendThemeSwiper> {
  final formatCurrency = NumberFormat('#,###');
  Map<String, dynamic> currentPosition = {'lat': 37.5665, 'lng': 126.9780};
  bool isLoading = false;

  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();


  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 102.w,
        child: Swiper(
          controller: swiperController,
          scrollDirection: Axis.horizontal,
          axisDirection: AxisDirection.left,
          itemCount: widget.recommendData.length,
          viewportFraction: 0.85,
          onIndexChanged: (value) {
            setSwiper(value);
          },
          loop: false,
          itemBuilder: (context, index) {
            JobpostRecommendModel jobpostData = widget.recommendData[index];
            return GestureDetector(
              onTap: () {
                context.push('/jobpost/${jobpostData.key}');
              },
              child: Padding(
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
                              child: ExtendedImgWidget(
                                imgFit: BoxFit.cover,
                                imgUrl: jobpostData.files[0].url,
                                imgWidth: 86.w,
                                imgHeight: 86.w,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      jobpostData.companyName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: CommonColors.black2b,
                                      ),
                                    ),
                                    Text(
                                      jobpostData.title,
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
                                        '${distanceBetween(jobpostData.lat, jobpostData.lng)}km',
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
                                          '${jobpostData.addressData['si']} ${jobpostData.addressData['gu']}',
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
                                        ContractService.returnSalaryType(
                                            jobpostData.salaryType),
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
                                          '${formatCurrency.format(jobpostData.salary)}원',
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
                    if (jobpostData.score > 0)
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
                                  localization.665,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: CommonColors.red,
                                  ),
                                ),
                                Text(
                                  jobpostData.score.toString(),
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
              ),
            );
          },
        ),
      ),
    );
  }
}
