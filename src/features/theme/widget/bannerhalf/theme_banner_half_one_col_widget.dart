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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemeBannerHalfOneColWidget extends ConsumerStatefulWidget {
  const ThemeBannerHalfOneColWidget(
      {super.key,
      required this.themeData,
      required this.themeSettingList,
      required this.moveUrl});

  final ThemeModel themeData;
  final List themeSettingList;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerHalfOneColWidget> createState() =>
      _ThemeBannerHalfOneColWidgetState();
}

class _ThemeBannerHalfOneColWidgetState
    extends ConsumerState<ThemeBannerHalfOneColWidget> {
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
                    widget.moveUrl(theme);
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: index == 0 ? 0 : 16.w),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6.w),
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
                        SizedBox(
                          height: widget.themeData.displayViewTitle == 1
                              ? 192.w / 320 * 88
                              : (CommonSize.vw - 40.w) / 320 * 88,
                          width: widget.themeData.displayViewTitle == 1
                              ? 192.w
                              : (CommonSize.vw - 40.w),
                          child: ExtendedImgWidget(
                            imgUrl: theme.files[0].url,
                            imgFit: BoxFit.cover,
                          ),
                        ),
                        if (widget.themeData.displayViewTitle == 1)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child: Text(
                                theme.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                  fontWeight: FontWeight.w600,
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
