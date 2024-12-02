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

class ThemeThumHalfDoubleColWidget extends ConsumerStatefulWidget {
  const ThemeThumHalfDoubleColWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumHalfDoubleColWidget> createState() =>
      _ThemeThumHalfDoubleColWidgetState();
}

class _ThemeThumHalfDoubleColWidgetState
    extends ConsumerState<ThemeThumHalfDoubleColWidget> {
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
              mainAxisExtent: widget.themeData.displayViewSummery == 0 &&
                      widget.themeData.displayViewTitle == 0
                  ? ((CommonSize.vw - 40.w - 8.w - 16.w) / 2 / 4 * 3) + 8.w
                  : 60.w,
            ),
            delegate: SliverChildBuilderDelegate(
                childCount: widget.themeSettingList.length, (context, index) {
              ThemeSettingModel theme = widget.themeSettingList[index];
              return GestureDetector(
                onTap: () {
                  context.push('/recommend/theme/${theme.key}');
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
                        color: const Color.fromRGBO(0, 0, 0, 0.06),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.w),
                        child: SizedBox(
                          width: widget.themeData.displayViewSummery == 0 &&
                                  widget.themeData.displayViewTitle == 0
                              ? (CommonSize.vw - 40.w - 8.w - 16.w) / 2
                              : 70.w,
                          height: widget.themeData.displayViewSummery == 0 &&
                                  widget.themeData.displayViewTitle == 0
                              ? (CommonSize.vw - 40.w - 8.w - 16.w) / 2 / 4 * 3
                              : 70.w / 4 * 3,
                          child: ExtendedImgWidget(
                            imgUrl: theme.files[0].url,
                            imgFit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (widget.themeData.displayViewSummery == 1 ||
                          widget.themeData.displayViewTitle == 1)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(left: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.themeData.displayViewTitle == 1)
                                  Text(
                                    widget.themeData.displayViewTitle == 1
                                        ? theme.title
                                        : '',
                                    maxLines: 1,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 12.sp,
                                      color: CommonColors.black2b,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                if (widget.themeData.displayViewSummery == 1)
                                  Text(
                                    widget.themeData.displayViewSummery == 1
                                        ? theme.summary
                                        : '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: CommonColors.gray66,
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
            }),
          ),
        ),
      ],
    );
  }
}
