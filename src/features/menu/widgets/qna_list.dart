import 'package:flutter/material.dart';

import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QnaList extends StatelessWidget {
  const QnaList(
      {super.key,
      required this.onTap,
      required this.text,
      required this.date,
      required this.index,
      required this.hasReply,
      this.url});

  final Function onTap;
  final String text;
  final String date;
  final String? url;
  final int index;
  final bool hasReply;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
        margin: EdgeInsets.only(top: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: Colors.transparent,
          border: Border.all(
            width: 1.w,
            color: CommonColors.grayF2,
          ),
        ),
        child: Row(
          children: [
            hasReply
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500.w),
                      border: Border.all(
                        width: 1.w,
                        color: CommonColors.red,
                      ),
                    ),
                    alignment: Alignment.center,
                    width: 54.w,
                    height: 24.w,
                    child: Text(
                      '답변완료',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CommonColors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(500.w),
                        color: CommonColors.grayF2),
                    alignment: Alignment.center,
                    width: 70.w,
                    height: 24.w,
                    child: Text(
                      '답변 대기중',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CommonColors.grayB2,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                    color: CommonColors.black2b,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: 8.w,
            ),
            Text(
              date,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: CommonColors.grayB2,
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
