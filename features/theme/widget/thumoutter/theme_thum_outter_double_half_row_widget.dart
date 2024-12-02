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

class ThemeThumOutterDoubleHalfRowWidget extends ConsumerStatefulWidget {
  const ThemeThumOutterDoubleHalfRowWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumOutterDoubleHalfRowWidget> createState() =>
      _ThemeThumOutterDoubleHalfRowWidgetState();
}

class _ThemeThumOutterDoubleHalfRowWidgetState
    extends ConsumerState<ThemeThumOutterDoubleHalfRowWidget> {
  var imgHeight = (CommonSize.vw * 0.9111 / 2 - 8.w) * 0.75;
  var titleHeight = 23.w;
  var textHeight = 44.w;
  var paddingHeight = 16.w;
  var spaceHeight = 4.w;

  setGridHeight() {
    if (widget.themeData.displayViewTitle == 1 &&
        widget.themeData.displayViewSummery == 1) {
      return imgHeight + paddingHeight + titleHeight + textHeight + spaceHeight;
    }

    if (widget.themeData.displayViewTitle == 1 &&
        widget.themeData.displayViewSummery == 0) {
      return imgHeight + paddingHeight + titleHeight;
    }
    if (widget.themeData.displayViewTitle == 0 &&
        widget.themeData.displayViewSummery == 1) {
      return imgHeight + paddingHeight + textHeight;
    }

    return imgHeight;
  }

  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    double result = widget.themeSettingList.length / 4;
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
            height: widget.themeSettingList.length < 2
                ? setGridHeight() + 20.w
                : setGridHeight() * 2 + 20.w + 8.w,
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
                        Column(
                          children: [
                            if (widget.themeSettingList.length >
                                index * 4 + (i * 2))
                              SizedBox(
                                width: CommonSize.vw * 0.9111 / 2,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(
                                          '/recommend/theme/${widget.themeSettingList[index * 4 + (i * 2)].key}');
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.w),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2.w),
                                            blurRadius: 16.w,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.06),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            height: imgHeight,
                                            child: ExtendedImgWidget(
                                              imgUrl: widget
                                                  .themeSettingList[
                                                      index * 4 + (i * 2)]
                                                  .files[0]
                                                  .url,
                                              imgFit: BoxFit.cover,
                                            ),
                                          ),
                                          if (widget.themeData
                                                      .displayViewTitle ==
                                                  1 ||
                                              widget.themeData
                                                      .displayViewSummery ==
                                                  1)
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  12.w, 8.w, 12.w, 8.w),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  if (widget.themeData
                                                          .displayViewTitle ==
                                                      1)
                                                    Text(
                                                      widget
                                                          .themeSettingList[
                                                              index * 4 +
                                                                  (i * 2)]
                                                          .title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: CommonColors
                                                            .black2b,
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
                                                      height: spaceHeight,
                                                    ),
                                                  if (widget.themeData
                                                          .displayViewSummery ==
                                                      1)
                                                    SizedBox(
                                                      height: textHeight,
                                                      child: Text(
                                                        widget
                                                            .themeSettingList[
                                                                index * 4 +
                                                                    (i * 2)]
                                                            .summary,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .grayB2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 8.w,
                            ),
                            if (widget.themeSettingList.length >
                                index * 4 + 1 + (i * 2))
                              SizedBox(
                                width: CommonSize.vw * 0.9111 / 2,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.push(
                                          '/recommend/theme/${widget.themeSettingList[index * 4 + 1 + (i * 2)].key}');
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(16.w),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2.w),
                                            blurRadius: 16.w,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.06),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(
                                            height: imgHeight,
                                            child: ExtendedImgWidget(
                                              imgUrl: widget
                                                  .themeSettingList[
                                                      index * 4 + 1 + (i * 2)]
                                                  .files[0]
                                                  .url,
                                              imgFit: BoxFit.cover,
                                            ),
                                          ),
                                          if (widget.themeData
                                                      .displayViewTitle ==
                                                  1 ||
                                              widget.themeData
                                                      .displayViewSummery ==
                                                  1)
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  12.w, 8.w, 12.w, 8.w),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  if (widget.themeData
                                                          .displayViewTitle ==
                                                      1)
                                                    Text(
                                                      widget
                                                          .themeSettingList[
                                                              index * 4 +
                                                                  1 +
                                                                  (i * 2)]
                                                          .title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color: CommonColors
                                                            .black2b,
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
                                                      height: spaceHeight,
                                                    ),
                                                  if (widget.themeData
                                                          .displayViewSummery ==
                                                      1)
                                                    SizedBox(
                                                      height: textHeight,
                                                      child: Text(
                                                        widget
                                                            .themeSettingList[
                                                                index * 4 +
                                                                    1 +
                                                                    (i * 2)]
                                                            .summary,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .grayB2,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
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
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (widget.themeSettingList.length > 4)
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
