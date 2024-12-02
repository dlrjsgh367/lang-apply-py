import 'dart:ui';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../theme_title.dart';

class ThemeThumInnerDoubleColWidget extends ConsumerStatefulWidget {
  const ThemeThumInnerDoubleColWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumInnerDoubleColWidget> createState() =>
      _ThemeThumInnerDoubleColWidgetState();
}

class _ThemeThumInnerDoubleColWidgetState
    extends ConsumerState<ThemeThumInnerDoubleColWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        ThemeTitle(
          title: widget.themeData.title,
          text: widget.themeData.content,
          nameDisplay: widget.themeData.nameDisplay,
          summeryDisplay: widget.themeData.summeryDisplay,
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 그리드의 열 수
                mainAxisSpacing: 8.w, // 그리드 아이템 사이의 수직 간격
                crossAxisSpacing: 8.w, // 그리드 아이템 사이의 수평 간격
                mainAxisExtent: (CommonSize.vw - 48.w) / 2 * 0.93),
            delegate: SliverChildBuilderDelegate(
                childCount: widget.themeSettingList.length, (context, index) {
              ThemeSettingModel theme = widget.themeSettingList[index];
              return GestureDetector(
                onTap: () {
                  context.push('/recommend/theme/${theme.key}');
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
                        color: const Color.fromRGBO(0, 0, 0, 0.06),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: ExtendedImgWidget(
                          imgUrl: theme.files[0].url,
                          imgFit: BoxFit.cover,
                        ),
                      ),

                      if( widget.themeData.displayViewTitle == 1 ||
                          widget.themeData.displayViewSummery == 1)
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
                                  crossAxisAlignment: CrossAxisAlignment
                                      .stretch,
                                  children: [
                                    if( widget.themeData.displayViewTitle == 1)
                                      Text(theme.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if( widget.themeData.displayViewTitle ==
                                        1 &&
                                        widget.themeData.displayViewSummery ==
                                            1)
                                      SizedBox(
                                        height: 2.w,
                                      ),
                                    if(widget.themeData.displayViewSummery == 1)
                                      SizedBox(
                                        height: 33.w,
                                        child: Text(theme.summary,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: CommonColors.white,
                                            fontWeight: FontWeight.w500,
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
              );
            }),
          ),
        ),
      ],
    );
  }
}
