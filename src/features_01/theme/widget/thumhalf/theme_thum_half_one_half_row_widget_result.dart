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

class ThemeThumHalfOneHalfRowWidget extends ConsumerStatefulWidget {
  const ThemeThumHalfOneHalfRowWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumHalfOneHalfRowWidget> createState() =>
      _ThemeThumHalfOneHalfRowWidgetState();
}

class _ThemeThumHalfOneHalfRowWidgetState
    extends ConsumerState<ThemeThumHalfOneHalfRowWidget> {
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
            // height: (CommonSize.vw * 0.777) + 18,
            height:
            widget.themeData
                .displayViewTitle ==
                0 &&
                widget.themeData
                    .displayViewSummery ==
                    0
                ? (CommonSize.vw * 0.9111 / 2 -
                16.w) / 4 * 3 + 8.w:

            70.w / 4 * 3 + 20.w + 8.w,
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
                                  padding: EdgeInsets.all(4.w),
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.w),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 2.w),
                                        blurRadius: 16.w,
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.06),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        child: SizedBox(
                                          width: widget.themeData
                                                          .displayViewTitle ==
                                                      0 &&
                                                  widget.themeData
                                                          .displayViewSummery ==
                                                      0
                                              ? CommonSize.vw * 0.9111 / 2 -
                                                  16.w
                                              : 70.w,
                                          height:
                                          widget.themeData
                                              .displayViewTitle ==
                                              0 &&
                                              widget.themeData
                                                  .displayViewSummery ==
                                                  0
                                              ? (CommonSize.vw * 0.9111 / 2 -
                                              16.w) * 4/3
                                              :   70.w / 4 * 3,


                                          child: ExtendedImgWidget(
                                            imgUrl: widget
                                                .themeSettingList[index * 2 + i]
                                                .files[0]
                                                .url,
                                            imgFit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      if (widget.themeData.displayViewTitle ==
                                              1 ||
                                          widget.themeData.displayViewSummery ==
                                              1)
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: 4.w),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
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
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.black2b,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                if (widget.themeData
                                                        .displayViewSummery ==
                                                    1)
                                                  Text(
                                                    widget
                                                        .themeSettingList[
                                                            index * 2 + i]
                                                        .summary,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10.sp,
                                                      color:
                                                          CommonColors.gray66,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        )
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
