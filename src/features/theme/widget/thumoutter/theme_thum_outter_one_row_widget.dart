import 'package:card_swiper/card_swiper.dart';
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

class ThemeThumOutterOneRowWidget extends ConsumerStatefulWidget {
  const ThemeThumOutterOneRowWidget({super.key,required this.themeData, required this.themeSettingList});
  final ThemeModel themeData;
  final List themeSettingList;

  @override
  ConsumerState<ThemeThumOutterOneRowWidget> createState() =>
      _ThemeThumOutterOneRowWidgetState();
}

class _ThemeThumOutterOneRowWidgetState
    extends ConsumerState<ThemeThumOutterOneRowWidget> {
  var imgHeight = (CommonSize.vw * 0.9166 - 10.w)/4*3;
  var titleHeight =  27.w;
  var textHeight = 44.w;
  var paddingHeight = 20.w;
  var spaceHeight = 6.w;
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
            height: setGridHeight() + 20.w,
            child: Swiper(
              controller: swiperController,
              scrollDirection: Axis.horizontal,
              axisDirection: AxisDirection.left,
              itemCount: widget.themeSettingList.length,
              viewportFraction: 0.9166,
              onIndexChanged: (value) {
                setSwiper(value);
              },
              loop: false,
              outer: true,
              itemBuilder: (context, index) {
                ThemeSettingModel theme = widget.themeSettingList[index];
                return Padding(
                  padding: EdgeInsets.fromLTRB(5.w, 0, 5.w, 20.w),
                  child: GestureDetector(
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
                            child:ExtendedImgWidget(
                              imgUrl: theme.files[0].url,
                              imgFit: BoxFit.cover,

                            ),
                          ),

                          if(widget.themeData.displayViewTitle == 1
                          ||widget.themeData.displayViewSummery == 1
                          )
                          Padding(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if(widget.themeData.displayViewTitle == 1)
                                Text(
                                  theme.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: CommonColors.black2b,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if(widget.themeData.displayViewTitle == 1 && widget.themeData.displayViewSummery == 1)
                                SizedBox(
                                  height: spaceHeight,
                                ),
                                if(widget.themeData.displayViewSummery == 1)
                                Text(
                                  theme.summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.grayB2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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
