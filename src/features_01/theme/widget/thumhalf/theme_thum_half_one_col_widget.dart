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

class ThemeThumHalfOneColWidget extends ConsumerStatefulWidget {
  const ThemeThumHalfOneColWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumHalfOneColWidget> createState() =>
      _ThemeThumHalfOneColWidgetState();
}

class _ThemeThumHalfOneColWidgetState
    extends ConsumerState<ThemeThumHalfOneColWidget> {
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
                    padding: EdgeInsets.fromLTRB(12.w, 10.w, 12.w, 10.w),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.w),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 2.w),
                          blurRadius: 16.w,
                          color: const Color.fromRGBO(0, 0, 0, 0.06),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.w),
                          child: SizedBox(
                            width: widget.themeData.displayViewTitle == 0 &&
                                    widget.themeData.displayViewSummery == 0
                                ? CommonSize.vw - 64.w
                                : 112.w,
                            height: widget.themeData.displayViewTitle == 0 &&
                                    widget.themeData.displayViewSummery == 0
                                ? (CommonSize.vw - 64.w) / 4 * 3
                                : 112.w / 4 * 3,
                            child: ExtendedImgWidget(
                              imgUrl: theme.files[0].url,
                              imgFit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (widget.themeData.displayViewTitle == 1 ||
                            widget.themeData.displayViewSummery == 1)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (widget.themeData.displayViewTitle == 1)
                                    Text(
                                      theme.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.black2b,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (widget.themeData.displayViewTitle == 1 &&
                                      widget.themeData.displayViewSummery == 1)
                                    SizedBox(
                                      height: 6.w,
                                    ),
                                  if (widget.themeData.displayViewSummery == 1)
                                    SizedBox(
                                      height: 55.w,
                                      child: Text(
                                        theme.summary,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: CommonColors.gray66,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
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
