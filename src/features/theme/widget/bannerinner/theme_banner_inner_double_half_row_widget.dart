import 'dart:ui';

import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/service/banner_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_title.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemeBannerInnerDoubleHalfRowWidget extends ConsumerStatefulWidget {
  const ThemeBannerInnerDoubleHalfRowWidget(
      {super.key,
      required this.themeData,
      required this.themeSettingList,
      required this.moveUrl});

  final ThemeModel themeData;
  final List themeSettingList;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerInnerDoubleHalfRowWidget> createState() =>
      _ThemeBannerInnerDoubleHalfRowWidgetState();
}

class _ThemeBannerInnerDoubleHalfRowWidgetState
    extends ConsumerState<ThemeBannerInnerDoubleHalfRowWidget> {
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
            // height: (CommonSize.vw * 0.777) + 18,
            height: widget.themeSettingList.length < 2
                ? (CommonSize.vw * 0.9111 / 2 - 8.w) / 320 * 88 + 20.w
                : (CommonSize.vw * 0.9111 / 2 - 8.w) / 320 * 88 * 2 + 30.w,
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
                                      widget.moveUrl(widget.themeSettingList[
                                          index * 4 + (i * 2)]);
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(6.w),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2.w),
                                            blurRadius: 16.w,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.06),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height:
                                                (CommonSize.vw * 0.9111 / 2 -
                                                        8.w) /
                                                    320 *
                                                    88,
                                            child: ExtendedImgWidget(
                                              imgUrl: widget
                                                  .themeSettingList[
                                                      index * 4 + (i * 2)]
                                                  .files[0]
                                                  .url,
                                              imgFit: BoxFit.cover,
                                            ),
                                          ),
                                          if (widget
                                                  .themeData.displayViewTitle ==
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
                                                      color: CommonColors
                                                          .themeBack,
                                                    ),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            12.w,
                                                            2.w,
                                                            12.w,
                                                            2.w),
                                                    child: Text(
                                                      widget
                                                          .themeSettingList[
                                                              index * 4 +
                                                                  (i * 2)]
                                                          .title,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color:
                                                            CommonColors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
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
                            SizedBox(
                              height: 10.w,
                            ),
                            if (widget.themeSettingList.length >
                                index * 4 + 1 + (i * 2))
                              SizedBox(
                                width: CommonSize.vw * 0.9111 / 2,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      widget.moveUrl(widget.themeSettingList[
                                          index * 4 + 1 + (i * 2)]);
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(6.w),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, 2.w),
                                            blurRadius: 16.w,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.06),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height:
                                                (CommonSize.vw * 0.9111 / 2 -
                                                        8.w) /
                                                    320 *
                                                    88,
                                            child: ExtendedImgWidget(
                                              imgUrl: widget
                                                  .themeSettingList[
                                                      index * 4 + 1 + (i * 2)]
                                                  .files[0]
                                                  .url,
                                              imgFit: BoxFit.cover,
                                            ),
                                          ),
                                          if (widget
                                                  .themeData.displayViewTitle ==
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
                                                      color: CommonColors
                                                          .themeBack,
                                                    ),
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            12.w,
                                                            2.w,
                                                            12.w,
                                                            2.w),
                                                    child: Text(
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
                                                        fontSize: 11.sp,
                                                        color:
                                                            CommonColors.white,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
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
