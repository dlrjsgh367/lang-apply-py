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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ThemeBannerHalfOneRowWidget extends ConsumerStatefulWidget {
  const ThemeBannerHalfOneRowWidget(
      {super.key,
        required this.themeData,
        required this.themeSettingList,
        required this.moveUrl});

  final ThemeModel themeData;
  final List themeSettingList;
  final Function moveUrl;

  @override
  ConsumerState<ThemeBannerHalfOneRowWidget> createState() =>
      _ThemeBannerHalfOneRowWidgetState();
}

class _ThemeBannerHalfOneRowWidgetState
    extends ConsumerState<ThemeBannerHalfOneRowWidget> {
  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();



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
        SliverToBoxAdapter(
          child: SizedBox(
            // height: (CommonSize.vw * 0.777) + 18,
            height:
            widget.themeData.displayViewTitle == 1 ?
            192.w / 320 * 88 + 20.w:
            (CommonSize.vw * 0.9166 - 10.w) / 320 * 88 + 20.w,
            child: Swiper(
              controller: swiperController,
              scrollDirection: Axis.horizontal,
              axisDirection: AxisDirection.left,
              itemCount: widget.themeSettingList.length,
              viewportFraction: 0.9166,
              onIndexChanged: (value) {
                setSwiper(value);
              },
              // scale: 0.87,
              loop: false,
              outer: true,
              itemBuilder: (context, index) {
                ThemeSettingModel theme = widget.themeSettingList[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 20.w),
                  child: GestureDetector(
                    onTap: () {
                      widget.moveUrl(theme);
                    },
                    child: Container(
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
                            width:
                            widget.themeData.displayViewTitle == 1
                            ?
                            192.w
                            :CommonSize.vw * 0.9166 - 10.w
                            ,
                            height:
                            widget.themeData.displayViewTitle == 1
                                ?
                            192.w / 320 * 88 : (CommonSize.vw * 0.9166 - 10.w) / 320 * 88,
                            child:ExtendedImgWidget(
                              imgUrl: theme.files[0].url,
                              imgFit: BoxFit.cover,
                            ),
                          ),
                          if(widget.themeData.displayViewTitle == 1)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(left: 12.w),
                              child:  Text(
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
                  ),
                );
              },
            ),
          ),
        ),
        if(widget.themeSettingList.length > 1)
        SliverToBoxAdapter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.themeSettingList.length; i++)
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
