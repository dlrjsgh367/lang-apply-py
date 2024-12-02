
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileBox extends StatelessWidget {
  ProfileBox({super.key,this.isRed = false,required this.text,this.hasClose=false});

  final String text;

  final bool isRed;
  final bool hasClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30.w,
      padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
      decoration: BoxDecoration(
        color:isRed ? CommonColors.red02: CommonColors.grayF7,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Text(
            text,
            style: TextStyle(
                fontSize: 13.sp,
                color:
                isRed ? CommonColors.red:
                CommonColors.black2b),
          ),
           if(hasClose)
           Padding(padding: EdgeInsets.only(left: 4.w),

            child: Image.asset('assets/images/icon/iconX.png',width: 16.w,
              height: 16.w,
            ),
          ),
        ],
      ),
    );
  }
}
