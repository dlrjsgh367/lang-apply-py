import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostingTag extends StatelessWidget {
  PostingTag({
    super.key,
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.w,
      alignment: Alignment.center,
      width: 54.w,
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.w,
          color: type == '마감' || type == '반려' ?CommonColors.grayF2: CommonColors.red,
        ),
        color: type == '마감' || type == '반려' ?CommonColors.grayF2:  CommonColors.white,
        borderRadius: BorderRadius.circular(
          500.w,
        ),
      ),
      child: Text(
        type,
        style: TextStyle(
            fontSize: 12.sp,
            color: type == '마감' || type == '반려' ?CommonColors.grayB2 : CommonColors.red,
            fontWeight: FontWeight.w500),
      ),
    );
  }
}
