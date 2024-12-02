import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/models/alarm_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AlarmListWidget extends StatefulWidget {
  const AlarmListWidget(
      {required this.alarmItem,
      required this.idx,
      required this.deleteAlarm,
      super.key});

  final AlarmModel alarmItem;
  final int idx;

  final Function deleteAlarm;

  @override
  State<AlarmListWidget> createState() => _AlarmListWidgetState();
}

class _AlarmListWidgetState extends State<AlarmListWidget> {
  String activeDelete = '';

  bool canSwipe = true;

  void scrollLeft(detail, data) async {
    double delta = detail.primaryDelta;
    if (canSwipe) {
      setState(() {
        canSwipe = false;
        if (delta < 0) {
          activeDelete = data.toString();
        }
        if (delta > 0) {
          activeDelete = '';
        }
      });

      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        canSwipe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        scrollLeft(details, widget.idx);
      },
      onTap: () {
        if (widget.alarmItem.route == '') {
          context.go('/');
        } else {
          context.push(widget.alarmItem.route);
        }
      },
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 20.w,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () {
                    widget.deleteAlarm(widget.alarmItem.alarmKey);
                    setState(() {
                      canSwipe = true;
                      activeDelete = '';
                    });
                  },
                  child: Container(
                    width: 48.w,
                    decoration: BoxDecoration(color: CommonColors.red),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/images/icon/iconTrash.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            transform: Matrix4.translationValues(
                activeDelete == widget.idx.toString() ? -68.w : 0, 0, 0),
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: CommonColors.white,
              border: Border(
                bottom: BorderSide(
                  width: 1.w,
                  color: CommonColors.grayF7,
                ),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: ClipOval(
                        child: ExtendedImgWidget(
                          imgUrl: widget.alarmItem.iconUrl,
                          imgFit: BoxFit.cover,
                          imgWidth: 40.w,
                          imgHeight: 40.w,
                        ),
                      ),
                    ),
                    // if (!widget.alarmItem.isRead)
                    //   Positioned(
                    //     top: 1.w,
                    //     right: 19.w,
                    //     child: Container(
                    //       width: 8.w,
                    //       height: 8.w,
                    //       decoration: BoxDecoration(
                    //           color: CommonColors.red, shape: BoxShape.circle),
                    //     ),
                    //   ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.alarmItem.title,
                              maxLines: 2,

                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.alarmItem.content,
                        style: TextStyle(
                          color: CommonColors.gray66,
                          fontSize: 13.sp,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            ConvertService.convertDateISOtoString(
                                widget.alarmItem.createdAt,
                                ConvertService.YYYY_MM_DD_HH_MM_dot),
                            style: TextStyle(
                              color: CommonColors.grayB2,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
