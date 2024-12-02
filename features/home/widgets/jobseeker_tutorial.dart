import 'dart:ui';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/logo_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobseekerTutorial extends StatefulWidget {
  const JobseekerTutorial({super.key,required this.setTutorial});

  final Function setTutorial;

  @override
  State<JobseekerTutorial> createState() => _JobseekerTutorialState();
}

class _JobseekerTutorialState extends State<JobseekerTutorial> {
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
          body: Stack(alignment: Alignment.center, children: [
            Column(
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
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10.w),
                                      padding: EdgeInsets.fromLTRB(
                                          12.w, 10.w, 12.w, 20.w),
                                      decoration: BoxDecoration(
                                        color: CommonColors.white,
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.grayF2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 4.w,
                                            color: const Color.fromRGBO(
                                                150, 150, 150, 0.25),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w,
                                                    vertical: 0.w),
                                                decoration: BoxDecoration(
                                                  color: CommonColors.red02,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50.0),
                                                ),
                                                child: Text(
                                                  'AD',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.w,
                                                    color: CommonColors.red,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 4.w,
                                              ),
                                              Expanded(
                                                child: Text.rich(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            localization.lotteWaterParkCastRecruitment,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14.w,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {},
                                                style: ButtonStyles.childBtn,
                                                child: Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      4.w, 4.w, 0, 4.w),
                                                  child: Image.asset(
                                                    'assets/images/icon/iconTag.png',
                                                    width: 24.w,
                                                    height: 24.w,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12.w,
                                          ),
                                          IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox(
                                                      width: 140.w,
                                                      height: 140.w / 360 * 244,
                                                      child: Image.asset(
                                                        'assets/images/default/imgTutorial01.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    Positioned(
                                                      top: 8.w,
                                                      left: 8.w,
                                                      child: Container(
                                                        height: 24.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              width: 1.w,
                                                              color:
                                                                  CommonColors
                                                                      .red),
                                                          color: const Color
                                                              .fromRGBO(255,
                                                              255, 255, 0.7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      300.w),
                                                        ),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                12.w,
                                                                0,
                                                                12.w,
                                                                0),
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'D-15',
                                                          style: TextStyle(
                                                            fontSize: 12.w,
                                                            color: CommonColors
                                                                .red,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        localization.chdanNetwork,
                                                        style: TextStyle(
                                                          fontSize: 12.w,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
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
                                                          Text(
                                                            '2.7km',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color:
                                                                  CommonColors
                                                                      .gray80,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4.w,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              localization.icheonSiIcheonDong,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize: 12.sp,
                                                                color:
                                                                    CommonColors
                                                                        .gray80,
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            localization.monthlySalary,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              color:
                                                                  CommonColors
                                                                      .red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4.w,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              localization.amount as String,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      TextButton(
                                                        onPressed: () {},
                                                        style: TextButton
                                                            .styleFrom(
                                                          minimumSize:
                                                              Size.zero,
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.w),
                                                          ),
                                                          fixedSize:
                                                              Size.fromHeight(
                                                                  34.w),
                                                          backgroundColor:
                                                              CommonColors.red,
                                                          side:
                                                              const BorderSide(
                                                            width: 0,
                                                            color: Colors
                                                                .transparent,
                                                          ),
                                                        ).copyWith(
                                                          overlayColor:
                                                              ButtonStyles
                                                                  .overlayNone,
                                                        ),
                                                        child: Text(
                                                          localization.applyForJob,
                                                          style: TextStyle(
                                                            color: CommonColors
                                                                .white,
                                                            fontSize: 14.w,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(top: 12.w),
                                            child: Wrap(
                                              spacing: 8.w,
                                              runSpacing: 4.w,
                                              runAlignment: WrapAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 26.w,
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Positioned.fill(
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                              4.w,
                                                            ),
                                                            color: CommonColors
                                                                .grayF7,
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                8.w, 0, 8.w, 0),
                                                        child: Text(
                                                          localization.serviceParkingGuidance,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: CommonColors
                                                                .gray66,
                                                          ),
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
                                    ),
                                  ],
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
            Positioned(
              bottom: 10.w,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                  height: 36.w,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                      )
                    ],
                    color: CommonColors.white,
                    borderRadius: BorderRadius.circular(100.w),
                    border: Border.all(
                      width: 2.w,
                      color: CommonColors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/icon/iconMapred.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Text(
                        localization.viewOnMap,
                        style: TextStyle(
                          color: CommonColors.red,
                          fontSize: 12.w,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
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
