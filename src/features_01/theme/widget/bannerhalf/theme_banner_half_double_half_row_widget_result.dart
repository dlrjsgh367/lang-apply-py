import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_title.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemeBannerHalfDoubleHalfRowWidget extends ConsumerStatefulWidget {
  const ThemeBannerHalfDoubleHalfRowWidget(
      {super.key,
      required this.themeData,
      required this.themeSettingList,
      required this.moveUrl});

  final ThemeModel themeData;
  final List themeSettingList;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerHalfDoubleHalfRowWidget> createState() =>
      _ThemeBannerHalfDoubleHalfRowWidgetState();
}

class _ThemeBannerHalfDoubleHalfRowWidgetState
    extends ConsumerState<ThemeBannerHalfDoubleHalfRowWidget> {
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

            height: widget.themeData.displayViewTitle == 1
                ? widget.themeSettingList.length < 2
                    ? 96.w / 320 * 88 + 20.w
                    : 96.w / 320 * 88 * 2 + 28.w
                : widget.themeSettingList.length < 2
                    ? (CommonSize.vw * 0.9111 / 2 - 8.w) / 320 * 88 + 20.w
                    : (CommonSize.vw * 0.9111 / 2 - 8.w) / 320 * 88 * 2 + 28.w,

            // 60.w + 20.w + 8.w,
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
                // dynamic item = widget.data[index];
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
                                      child: Row(
                                        children: [
                                          SizedBox(
                                              height: widget.themeData
                                                          .displayViewTitle ==
                                                      1
                                                  ? 96.w / 320 * 88
                                                  : (CommonSize.vw *
                                                              0.9111 /
                                                              2 -
                                                          8.w) /
                                                      320 *
                                                      88,
                                              width: widget.themeData
                                                          .displayViewTitle ==
                                                      1
                                                  ? 96.w
                                                  : (CommonSize.vw *
                                                          0.9111 /
                                                          2 -
                                                      8.w),
                                              child: ExtendedImgWidget(
                                                imgUrl: widget
                                                    .themeSettingList[
                                                        index * 4 + (i * 2)]
                                                    .files[0]
                                                    .url,
                                                imgFit: BoxFit.cover,
                                              )),
                                          if (widget
                                                  .themeData.displayViewTitle ==
                                              1)
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 4.w),
                                                child: Text(
                                                  widget
                                                      .themeSettingList[
                                                          index * 4 + (i * 2)]
                                                      .title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 8.sp,
                                                    color: CommonColors.black2b,
                                                    fontWeight: FontWeight.w500,
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
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            height: widget.themeData
                                                        .displayViewTitle ==
                                                    1
                                                ? 96.w / 320 * 88
                                                : (CommonSize.vw * 0.9111 / 2 -
                                                        8.w) /
                                                    320 *
                                                    88,
                                            width: widget.themeData
                                                        .displayViewTitle ==
                                                    1
                                                ? 96.w
                                                : (CommonSize.vw * 0.9111 / 2 -
                                                    8.w),
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
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(left: 4.w),
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
                                                    fontSize: 8.sp,
                                                    color: CommonColors.black2b,
                                                    fontWeight: FontWeight.w500,
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
