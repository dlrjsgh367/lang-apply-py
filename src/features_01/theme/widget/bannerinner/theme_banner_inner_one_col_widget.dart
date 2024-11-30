import 'dart:ui';

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

class ThemeBannerInnerOneColWidget extends ConsumerStatefulWidget {
  const ThemeBannerInnerOneColWidget(
      {super.key,
        required this.themeData,
        required this.themeSettingList,
        required this.moveUrl});

  final ThemeModel themeData;
  final List themeSettingList;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerInnerOneColWidget> createState() =>
      _ThemeBannerInnerOneColWidgetState();
}

class _ThemeBannerInnerOneColWidgetState
    extends ConsumerState<ThemeBannerInnerOneColWidget> {



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
                      borderRadius: BorderRadius.circular(12.w),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 2.w),
                          blurRadius: 16.w,
                          color: const Color.fromRGBO(0, 0, 0, 0.06),
                        ),
                      ],
                    ),
                    child:
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: (CommonSize.vw - 40.w) / 320 * 88,
                          child: ExtendedImgWidget(
                            imgUrl: theme.files[0].url,
                            imgFit: BoxFit.cover,
                          ),
                        ),
                        if(   widget.themeData.displayViewTitle == 1)
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
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 4.w),
                                child: Text(
                                  theme.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: CommonColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
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
