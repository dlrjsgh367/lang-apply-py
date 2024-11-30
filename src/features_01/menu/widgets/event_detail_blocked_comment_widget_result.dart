import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetailBlockedCommentWidget extends StatelessWidget {
  const EventDetailBlockedCommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CommonColors.grayF7,
        border: Border(
          bottom: BorderSide(width: 1.w, color: CommonColors.grayF2),
          top: BorderSide(width: 1.w, color: CommonColors.grayF2),
        ),
      ),
      padding: EdgeInsets.fromLTRB(0, 24.w, 0, 24.w),
      child: Text(
        localization.hiddenComment,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: CommonColors.grayB2,
        ),
      ),
    );
  }
}
