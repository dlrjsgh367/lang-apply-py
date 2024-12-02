import 'dart:ui';

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

class ThemeThumInnerOneColWidget extends ConsumerStatefulWidget {
  const ThemeThumInnerOneColWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumInnerOneColWidget> createState() =>
      _ThemeThumInnerOneColWidgetState();
}

class _ThemeThumInnerOneColWidgetState
    extends ConsumerState<ThemeThumInnerOneColWidget> {
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
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: widget.themeSettingList.length,
              (context, index) {
                ThemeSettingModel theme = widget.themeSettingList[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/recommend/theme/${theme.key}');
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 10.w),
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
                        SizedBox(
                          height: (CommonSize.vw - 40.w) / 4 * 3,
                          child: ExtendedImgWidget(
                            imgUrl: theme.files[0].url,
                            imgFit: BoxFit.cover,
                          ),
                        ),
                        if (widget.themeData.displayViewTitle == 1 ||
                            widget.themeData.displayViewSummery == 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ClipRRect(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 2.w, sigmaY: 2.w),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CommonColors.themeBack,
                                  ),
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 10.w, 20.w, 10.w),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (widget.themeData.displayViewTitle ==
                                          1)
                                        Text(
                                          theme.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: CommonColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      if (widget.themeData.displayViewTitle ==
                                              1 &&
                                          widget.themeData.displayViewSummery ==
                                              1)
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                      if (widget.themeData.displayViewSummery ==
                                          1)
                                        SizedBox(
                                          height: 42.w,
                                          child: Text(
                                            theme.summary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
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
              },
            ),
          ),
        ),
      ],
    );
  }
}
