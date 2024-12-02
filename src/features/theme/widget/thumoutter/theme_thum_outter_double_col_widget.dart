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

class ThemeThumOutterDoubleColWidget extends ConsumerStatefulWidget {
  const ThemeThumOutterDoubleColWidget(
      {super.key, required this.themeData, required this.themeSettingList});

  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumOutterDoubleColWidget> createState() =>
      _ThemeThumOutterDoubleColWidgetState();
}

class _ThemeThumOutterDoubleColWidgetState
    extends ConsumerState<ThemeThumOutterDoubleColWidget> {
  var imgHeight = (CommonSize.vw - 48.w) / 2 * 0.75;
  var titleHeight =  23.w;
  var textHeight = 38.w;
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
              mainAxisExtent: setGridHeight(),
            ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: imgHeight,
                        child: ExtendedImgWidget(
                          imgUrl: theme.files[0].url,
                          imgFit: BoxFit.cover,
                        ),
                      ),
                      if (widget.themeData.displayViewTitle == 1 ||
                          widget.themeData.displayViewSummery == 1)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12.w, 8.w, 12.w, 8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (widget.themeData.displayViewTitle == 1)
                                  Text(
                                    theme.title,
                                    maxLines: 1,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (widget.themeData.displayViewSummery == 1 && widget.themeData.displayViewTitle == 1)
                                SizedBox(height: spaceHeight,),
                                if (widget.themeData.displayViewSummery == 1)
                                  Text(
                                    theme.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: CommonColors.grayB2,
                                      fontWeight: FontWeight.w500,
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
