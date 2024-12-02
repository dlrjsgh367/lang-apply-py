import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/worker/widgets/recommend_seeker_bottom.dart';
import 'package:chodan_flutter_app/features/worker/widgets/recommend_seeker_top.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendSeekerSwiper extends StatefulWidget {
  const RecommendSeekerSwiper(
      {required this.workerList, required this.currentPosition, super.key});

  final List<ProfileModel> workerList;
  final Map<String, dynamic> currentPosition;

  @override
  State<RecommendSeekerSwiper> createState() => _RecommendSeekerSwiperState();
}

class _RecommendSeekerSwiperState extends State<RecommendSeekerSwiper> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: 13.w,
      ),
      sliver: SliverToBoxAdapter(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const RedBack(
              extraHeight: 80,
            ),
            SizedBox(
              height: (((CommonSize.vw * 0.87) - 16.w) ) +
                  24.w +
                  12.w +
                  20.w +
                  2.w +
                  48.w +
                  8.w +
                  38.w +
                  3.5.w +
                  280.w,
              child: Swiper(
                controller: swiperController,
                scrollDirection: Axis.horizontal,
                axisDirection: AxisDirection.left,
                itemCount: widget.workerList.length,
                viewportFraction: 0.87,
                onIndexChanged: (value) {
                  setSwiper(value);
                },
                scale: 0.936,
                loop: false,
                itemBuilder: (context, index) {
                  ProfileModel workerItem = widget.workerList[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RecommendSeekerTop(
                          workerItem: workerItem,
                          currentPosition: widget.currentPosition),
                      // RecommendTab(),
                      RecommendSeekerBottom(
                        workerItem: workerItem,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
