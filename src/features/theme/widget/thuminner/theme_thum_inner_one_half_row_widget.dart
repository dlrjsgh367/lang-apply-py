import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_title.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ThemeThumInnerOneHalfRowWidget extends ConsumerStatefulWidget {
  const ThemeThumInnerOneHalfRowWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumInnerOneHalfRowWidget> createState() =>
      _ThemeThumInnerOneHalfRowWidgetState();
}

class _ThemeThumInnerOneHalfRowWidgetState
    extends ConsumerState<ThemeThumInnerOneHalfRowWidget> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    double result = widget.themeSettingList.length / 2;
    int roundedResult = result.ceil();
    return SliverMainAxisGroup(
      slivers: [
        ThemeTitle(
          title: widget.themeData.title,
          text: widget.themeData.content,
          nameDisplay: widget.themeData.nameDisplay,
          summeryDisplay: widget.themeData.summeryDisplay,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: (CommonSize.vw * 0.9111 / 2 - 8.w) / 4 * 3 + 20.w,
            child: Swiper(
              controller: swiperController,
              scrollDirection: Axis.horizontal,
              axisDirection: AxisDirection.left,
              itemCount: roundedResult,
              viewportFraction: 0.9111,
              onIndexChanged: (value) {
                setSwiper(value);
              },
              loop: false,
              outer: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.w),
                  child: Row(
                    children: [
                      for (var i = 0; i < 2; i++)
                        if (widget.themeSettingList.length > index * 2 + i)
                          SizedBox(
                            width: CommonSize.vw * 0.9111 / 2,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                              child: GestureDetector(
                                onTap: () {
                                  context.push(
                                      '/recommend/theme/${widget.themeSettingList[index * 2 + i].key}');
                                },
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.w),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 2.w),
                                        blurRadius: 16.w,
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.06),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height:
                                            (CommonSize.vw * 0.9111 / 2 - 8.w) /
                                                4 *
                                                3,
                                        child: ExtendedImgWidget(
                                          imgUrl: widget
                                              .themeSettingList[index * 2 + i]
                                              .files[0]
                                              .url,
                                          imgFit: BoxFit.cover,
                                        ),
                                      ),
                                      if (widget.themeData.displayViewTitle ==
                                              1 ||
                                          widget.themeData.displayViewSummery ==
                                              1)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: ClipRRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 2.w, sigmaY: 2.w),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: CommonColors.themeBack,
                                                ),
                                                padding: EdgeInsets.fromLTRB(
                                                    8.w, 4.w, 8.w, 4.w),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    if (widget.themeData
                                                            .displayViewTitle ==
                                                        1)
                                                      Text(
                                                        widget
                                                            .themeSettingList[
                                                                index * 2 + i]
                                                            .title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                          color: CommonColors
                                                              .white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    if (widget.themeData
                                                                .displayViewTitle ==
                                                            1 &&
                                                        widget.themeData
                                                                .displayViewSummery ==
                                                            1)
                                                      SizedBox(
                                                        height: 2.w,
                                                      ),
                                                    if (widget.themeData
                                                            .displayViewSummery ==
                                                        1)
                                                      SizedBox(
                                                        height: 35.w,
                                                        child: Text(
                                                          widget
                                                              .themeSettingList[
                                                                  index * 2 + i]
                                                              .summary,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: CommonColors
                                                                .white,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
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
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if(widget.themeSettingList.length > 2)
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < roundedResult; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
                  width: activeIndex == i ? 20.w : 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(500.w),
                    color: activeIndex == i
                        ? CommonColors.black2b
                        : CommonColors.grayF2,
                  ),
                ),
            ],
          ),
        )
      ],
    );
  }
}
