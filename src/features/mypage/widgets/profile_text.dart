
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileText extends StatelessWidget {
  ProfileText({super.key,required this.text});

  final String text;



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 4.w, 0, 0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: CommonColors.grayB2,
        ),
      ),
    );
  }
}
