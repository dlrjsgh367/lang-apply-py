import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_bottom.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_top.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

class RecommendSwiper extends StatefulWidget {
   RecommendSwiper(
      {super.key, required this.recommendData,
        required this.scrapJobseeker,
        required this.applyJobposting,
        required this.currentPosition
      });

   Map<String, dynamic> currentPosition;
  final List recommendData;
  final Function scrapJobseeker;
  final Function applyJobposting;

  @override
  State<RecommendSwiper> createState() => _RecommendSwiperState();
}

class _RecommendSwiperState extends State<RecommendSwiper> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return  SliverToBoxAdapter(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const RedBack(extraHeight: 80),
          SizedBox(
            height: (((CommonSize.vw * 0.87) - 16.w) / 336 * 236) +
                24.w +
                12.w +
                20.w +
                2.w +
                48.w +
                8.w +
                38.w+24.w

                //  bottom
                +
                36.w +
                36.w +
                4.w +
                36.w +
                4.w +
                36.w +
                4.w +
                36.w +
                4.w +
                36.w +
                50.w +
                1.9.w,
            child:
            Swiper(
              controller: swiperController,
              scrollDirection: Axis.horizontal,
              axisDirection: AxisDirection.left,
              itemCount: widget.recommendData.length,
              viewportFraction: 0.87,
              onIndexChanged: (value) {
                setSwiper(value);
              },
              scale: 0.936,
              loop: false,
              itemBuilder: (context, index) {
                JobpostRecommendModel jobpostData =
                widget.recommendData[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RecommendTop(
                      jobpostData: jobpostData, currentPosition: widget.currentPosition,
                    ),
                    RecommendBottom(
                      jobpostData: jobpostData,
                      scrapJobseeker: widget.scrapJobseeker,
                      applyJobposting: widget.applyJobposting,
                    ),
                  ],
                );
              },
            ),


          ),
        ],
      ),
    );

  }
}
