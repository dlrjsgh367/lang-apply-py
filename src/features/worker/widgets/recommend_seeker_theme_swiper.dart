import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_top.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecommendSeekerThemeSwiper extends ConsumerStatefulWidget {
  const RecommendSeekerThemeSwiper(
      {required this.workerList, required this.currentPosition, super.key});

  final List<ProfileModel> workerList;
  final Map<String, dynamic> currentPosition;

  @override
  ConsumerState<RecommendSeekerThemeSwiper> createState() =>
      _RecommendSeekerThemeSwiperState();
}

class _RecommendSeekerThemeSwiperState
    extends ConsumerState<RecommendSeekerThemeSwiper> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  List<dynamic> mergeKeyword(
      List<dynamic> firstKeyword, List<dynamic> secondKeyword) {
    List<dynamic> result = [];
    result = [...firstKeyword, ...secondKeyword];
    return result;
  }

  String returnKeyWord(data) {
    var keyArr = '';

    for (int i = 0;
        i < mergeKeyword(data.keywordFirst, data.keywordSecond).length;
        i++) {
      if (i == 0) {
        keyArr += mergeKeyword(data.keywordFirst, data.keywordSecond)[i];
      } else {
        keyArr +=
            ' · ${mergeKeyword(data.keywordFirst, data.keywordSecond)[i]}';
      }
    }

    return keyArr;
  }

  SwiperController swiperController = SwiperController();

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - widget.currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - widget.currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(widget.currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
    return SliverPadding(
      padding: EdgeInsets.only(top: 20.w),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          height: 90.w,
          child: Swiper(
            controller: swiperController,
            scrollDirection: Axis.horizontal,
            axisDirection: AxisDirection.left,
            itemCount: widget.workerList.length,
            viewportFraction: 0.85,
            onIndexChanged: (value) {
              setSwiper(value);
            },
            loop: false,
            itemBuilder: (context, index) {
              ProfileModel workerItem = widget.workerList[index];
              return GestureDetector(
                onTap: (){
                  context.push('/seeker/${workerItem.key}');
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 0.w, 6.w, 0),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8.w, 12.w, 8.w, 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.w),
                      border: Border.all(
                        width: 1.w,
                        color: CommonColors.red,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                            borderRadius: BorderRadius.circular(500.w),
                            child:
                            workerItem.profileImg == null || workerItem.profileImg!.key == 0
                                ? ExtendedImgWidget(
                                    imgUrl: workerItem.profileImg!.url,
                                    imgWidth: 64.w,
                                    imgHeight: 64.w,
                                    imgFit: BoxFit.cover,
                                  )
                                :
                            WorkerDefaultImgWidget(
                              width: 64.w,
                              height: 64.w,
                              colorCode: workerItem.color,
                              name: workerItem.name,
                            )
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '${ConvertService.returnMaskingSiGuDong(matchedProfileKeyList.contains(workerItem.key), workerItem.profileAddress.si, workerItem.profileAddress.gu, workerItem.profileAddress.dongName)} ${distanceBetween(workerItem.profileAddress.lat, workerItem.profileAddress.long)}km',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                  Text(
                                    '${ConvertService.returnMaskingName(matchedProfileKeyList.contains(workerItem.key), workerItem.name)} (${ConvertService.calculateAge(workerItem.birth)}세, ${workerItem.gender.label})',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: CommonColors.black2b,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 4.w),
                                  // for (int i = 0;
                                  //     i <
                                  //         mergeKeyword(workerItem.keywordFirst,
                                  //                 workerItem.keywordSecond)
                                  //             .length;
                                  //     i++)
                                  Text(
                                    returnKeyWord(workerItem),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: CommonColors.gray80,
                                      fontSize: 12.w,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                          SizedBox(
                            width: 50.w,
                            height: 50.w,
                            child: Center(
                              child: CustomPaint(
                                size: Size(40.w, 40.w),
                                painter: RecommendProgress(
                                    workerItem.aitotalScore.toInt()),
                                child: SizedBox(
                                  width: 45.w,
                                  height: 45.w,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'AI ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 10.sp,
                                              color: CommonColors.red,
                                            ),
                                          ),
                                          Text(
                                            '매칭',
                                            style: TextStyle(
                                              height: 0.6,
                                              fontSize: 10.sp,
                                              color: CommonColors.red,
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 4.w),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${workerItem.aitotalScore.toInt()}',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              height: 0.7,
                                              color: CommonColors.red,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            '%',
                                            style: TextStyle(
                                              fontSize: 8.sp,
                                              height: 0.8,
                                              color: CommonColors.red,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
