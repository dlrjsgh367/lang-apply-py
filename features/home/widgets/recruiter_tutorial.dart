import 'dart:ui';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/logo_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecruiterTutorial extends StatefulWidget {
  const RecruiterTutorial({super.key,required this.setTutorial});

  final Function setTutorial;

  @override
  State<RecruiterTutorial> createState() => _RecruiterTutorialState();
}

class _RecruiterTutorialState extends State<RecruiterTutorial> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          bottomNavigationBar: const CommonBottomAppbar(type: 'search'),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(48.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: CommonSize.safePaddingTop,
                ),
                const LogoAppbar(),
              ],
            ),
          ),
          body:  Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100.w,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/icon/iconPin.png',
                            width: 20.w,
                            height: 20.w,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Flexible(
                            child: Text(
                              localization.yangjaeDong,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.black2b,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Image.asset(
                            'assets/images/icon/iconArrowDown.png',
                            width: 16.w,
                            height: 16.w,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/icon/iconSearch.png',
                          width: 24.w,
                          height: 24.w,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Image.asset(
                          'assets/images/icon/iconFilter.png',
                          width: 24.w,
                          height: 24.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ColoredBox(
                  color: CommonColors.grayF7,
                  child: CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: 10,
                                (context, index) {
                              return Container(
                                margin: EdgeInsets.only(top: 10.w),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: CommonColors.white,
                                  borderRadius: BorderRadius.circular(12.w),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 4.w,
                                        color: const Color.fromRGBO(150, 150, 150, 0.25))
                                  ],
                                  border: Border(
                                    bottom: BorderSide(
                                      color: CommonColors.grayF2,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      localization.diverseExperienceInAllFields,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w600,
                                        color: CommonColors.black2b,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16.w,
                                    ),
                                    IntrinsicHeight(
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: SizedBox(
                                                width: 106.w,
                                                height: 106.w,
                                                child: Image.asset(
                                                  'assets/images/default/imgTutorial02.png',
                                                  fit: BoxFit.cover,
                                                )),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      localization.userNameExam,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 14.sp,
                                                        color: CommonColors.black2b,
                                                      ),
                                                    ),
                                                    Text(
                                                      localization.userInfoExam,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color: CommonColors.black2b,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                        'assets/images/icon/iconPinGray.png',
                                                        width: 14.w,
                                                        height: 14.w,
                                                      ),
                                                      SizedBox(
                                                        width: 4.w,
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          localization.distanceIcheonSiIcheonDong,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w500,
                                                            fontSize: 12.sp,
                                                            color: CommonColors.gray80,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  Text(
                                                    localization.servingPackagingAllDistributionSalesAll,
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: CommonColors.gray80,
                                                    ),
                                                  ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(child:   CommonButton(
                                                            height: 32.w,
                                                            confirm: true,
                                                            onPressed: () {
                                                            },
                                                            text: localization.jobProposal,
                                                          ),),

                                                          SizedBox(
                                                            width: 8.w,
                                                          ),
                                                          Image.asset(
                                                            'assets/images/icon/iconHeart.png',
                                                            width: 24.w,
                                                            height: 24.w,
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
        Positioned.fill(
          child: Scaffold(
            appBar: AppBar(
              primary: true,
              toolbarHeight: 48.w,
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: SizedBox(),
              actions: [

                      // SizedBox(width: 32.w,height: 32.w,),
                      TextButton(
                    onPressed: () {
                      widget.setTutorial();
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      fixedSize: Size(64.w, 48.w),
                      backgroundColor: Colors.transparent,
                    ).copyWith(
                      overlayColor: ButtonStyles.overlayNone,
                    ),
                    child:   Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(),
                      width: 32.w,
                      height: 32.w,
                      child:
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                      child: Image.asset(
                        'assets/images/default/iconXTuto.png',
                        width: 32.w,
                        height: 32.w,
                      ),
                    ),
                  ),
                ),
              ],
              titleSpacing: 0,
              centerTitle: true,
              leadingWidth: 0,
              leading: SizedBox(),
            ),
            backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
            body: Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.w)),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/iconPin.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              localization.yangjaeDong,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.black2b,
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              'assets/images/icon/iconArrowDown.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Image.asset(
                    'assets/images/default/imgBalloonTuto.png',
                    width: 170.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
