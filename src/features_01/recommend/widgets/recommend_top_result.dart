import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class RecommendTop extends StatefulWidget {
  RecommendTop(
      {super.key, required this.jobpostData, required this.currentPosition});

  Map<String, dynamic> currentPosition;
  final JobpostRecommendModel jobpostData;

  @override
  State<RecommendTop> createState() => _RecommendTopState();
}

class _RecommendTopState extends State<RecommendTop> {
  int activeIndex = 0;
  bool showOverFlow = false;
  List gKArr = [];
  GlobalKey _rowKey = GlobalKey();
  GlobalKey _scrollKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  List<dynamic> mergeKeyword(
      List<dynamic> firstKeyword, List<dynamic> secondKeyword) {
    List<dynamic> result = [];
    result = [...firstKeyword, ...secondKeyword];
    return result;
  }

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.jobpostData.keyword.length; i++) {
      gKArr.add(GlobalKey(debugLabel: 'gk$i'));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkFirstOverFlow();
    });
  }

  checkFirstOverFlow() {
    if (_scrollController.position.maxScrollExtent > 0) {
      setState(() {
        showOverFlow = true;
      });
    }
  }

  returnKeyword() {
    String keyword = '';
    for (var key in widget.jobpostData.keyword) {
      keyword = '$keyword#$key';
    }
    return keyword;
  }

  moveScroll(data) {
    if (data == 'plus') {
      if (activeIndex < widget.jobpostData.keyword.length - 1) {
        setState(() {
          activeIndex = activeIndex + 1;
          var activeGk = gKArr[activeIndex];
          RenderBox? box =
              activeGk.currentContext?.findRenderObject() as RenderBox?;
          RenderBox? rowBox =
              _rowKey.currentContext?.findRenderObject() as RenderBox?;

          if (box != null && rowBox != null) {
            Offset boxPosition = box.localToGlobal(Offset.zero);
            Offset rowPosition = rowBox.localToGlobal(Offset.zero);
            double positionInRow = boxPosition.dx - rowPosition.dx;

            _scrollController.animateTo(positionInRow,
                duration: Duration(milliseconds: 100), curve: Curves.linear);
            if (box.size.width + positionInRow >
                _scrollController.position.maxScrollExtent) {
              setState(() {
                showOverFlow = false;
              });
            }
          }
        });
      }
    } else {
      if (activeIndex > 0) {
        setState(() {
          activeIndex = activeIndex - 1;
          var activeGk = gKArr[activeIndex];
          RenderBox? box =
              activeGk.currentContext?.findRenderObject() as RenderBox?;
          RenderBox? rowBox =
              _rowKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null && rowBox != null) {
            Offset boxPosition = box.localToGlobal(Offset.zero);
            Offset rowPosition = rowBox.localToGlobal(Offset.zero);
            double positionInRow = boxPosition.dx - rowPosition.dx;

            _scrollController.animateTo(positionInRow,
                duration: Duration(milliseconds: 100), curve: Curves.linear);
          }

          setState(() {
            showOverFlow = true;
          });
        });
      }
    }
  }

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - widget.currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - widget.currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(widget.currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
  }

  int calculateRemainingDays(DateTime publishDate) {
    DateTime currentDate = DateTime.now();
    Duration difference = publishDate.difference(currentDate);
    return difference.inDays;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/jobpost/${widget.jobpostData.key}');
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(8.w, 8.w, 8.w, 16.w),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 16.w,
                  color: const Color.fromRGBO(0, 0, 0, 0.12),
                )
              ],
              color: CommonColors.white,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 336 / 236,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.w),
                        child: ExtendedImgWidget(
                          imgUrl: widget.jobpostData.files[0].url,
                          imgFit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        height: 24.w,
                        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(width: 1.w, color: CommonColors.red),
                            color: const Color.fromRGBO(255, 255, 255, 0.7),
                            borderRadius: BorderRadius.circular(500.w)),
                        alignment: Alignment.center,
                        child: Text(
                          ConvertService.returnDiffDateDateType(
                              widget.jobpostData.postPeriod),
                          style: TextStyle(
                              fontSize: 12.w,
                              color: CommonColors.red,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 12.w, 4.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                            '${distanceBetween(widget.jobpostData.lat, widget.jobpostData.lng)}km',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Expanded(
                            child: Text(
                              '${widget.jobpostData.addressData['si']} ${widget.jobpostData.addressData['gu']}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 12.sp, color: CommonColors.gray80),
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Image.asset(
                            'assets/images/icon/iconStarS.png',
                            width: 16.w,
                            height: 16.w,
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Text(
                            widget.jobpostData.postScore.toStringAsFixed(1),
                            style: TextStyle(
                                fontSize: 12.sp, color: CommonColors.gray80),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 2.w,
                      ),
                      SizedBox(
                        height: 48.w,
                        child: Text(
                          widget.jobpostData.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 64.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              widget.jobpostData.companyName != ''
                                  ? '[ ${widget.jobpostData.companyName} ]'
                                  : '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                            SizedBox(
                              height: 6.w,
                            ),
                            Row(
                              children: [
                                if (activeIndex > 0)
                                  Padding(
                                    padding: EdgeInsets.only(right: 10.w),
                                    child: GestureDetector(
                                      onTap: () {
                                        moveScroll('minus');
                                      },
                                      child: Container(
                                        width: 20.w,
                                        height: 28.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.w),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(
                                                0,
                                                2,
                                              ),
                                              blurRadius: 16,
                                              color: Color(0x14000000),
                                            ),
                                            // box-shadow: 0px 2px 16px 0px #00000014;
                                          ],
                                        ),
                                        child: RotatedBox(
                                          quarterTurns: 90,
                                          child: Image.asset(
                                            'assets/images/icon/iconArrowRight.png',
                                            width: 20.w,
                                            height: 20.w,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    key:_scrollKey,
                                    physics:
                                    const NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      key: _rowKey,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                widget
                                                    .jobpostData.keyword.length;
                                            i++)
                                          Container(
                                            key: gKArr[i],
                                            margin: EdgeInsets.only(right: 6.w),
                                            padding: EdgeInsets.fromLTRB(
                                                8.w,
                                                4.w,
                                                i ==
                                                        widget
                                                                .jobpostData
                                                                .keyword
                                                                .length -
                                                            1
                                                    ? 8.w + 6.w
                                                    : 8.w,
                                                4.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.w),
                                              color: CommonColors.grayF7,
                                            ),
                                            child: Text(
                                              widget.jobpostData.keyword[i],
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: CommonColors.gray66,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (showOverFlow)
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: GestureDetector(
                                      onTap: () {
                                        moveScroll('plus');
                                      },
                                      child: Container(
                                        width: 20.w,
                                        height: 28.w,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.w),
                                          boxShadow: [
                                            BoxShadow(
                                              offset: Offset(
                                                0,
                                                2,
                                              ),
                                              blurRadius: 16,
                                              color: Color(0x14000000),
                                            ),
                                            // box-shadow: 0px 2px 16px 0px #00000014;
                                          ],
                                        ),
                                        child: Image.asset(
                                          'assets/images/icon/iconArrowRight.png',
                                          width: 20.w,
                                          height: 20.w,
                                        ),
                                      ),
                                    ),
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
          Positioned(
            right: 8.w,
            bottom: 8.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64.w,
                  height: 64.w,
                  child: Center(
                    child: CustomPaint(
                      size: Size(52.w, 52.w),
                      painter: RecommendProgress(widget.jobpostData.score),
                    ),
                  ),
                ),
                // if(widget.jobpostData.score >0)
                Column(
                  children: [
                    Text(
                      localization.aiMatching,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: CommonColors.red,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          widget.jobpostData.score.toString(),
                          style: TextStyle(
                            height: 1.02.sp,
                            fontSize: 16.sp,
                            color: CommonColors.red,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                            fontSize: 10.w,
                            color: CommonColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendProgress extends CustomPainter {
  final int data;

  RecommendProgress(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawArc(
      rect,
      0,
      pi * 2,
      false,
      Paint()
        ..color = CommonColors.red02
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round, // 둥근 스트로크 끝
    );
    canvas.drawArc(
      rect,
      (-pi / 2) + (pi * 2 / 100 * (100 - data)),
      pi * 2 / 100 * data,
      false,
      Paint()
        ..color = CommonColors.red
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round, // 둥근 스트로크 끝
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
