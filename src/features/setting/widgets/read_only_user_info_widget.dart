import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReadOnlyUserInfoWidget extends StatelessWidget {
  const ReadOnlyUserInfoWidget({
    super.key,
    required this.title,
    required this.content,
    this.hasIcon = false,
  });

  final String title;
  final String content;
  final bool? hasIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.5.sp,
            color: CommonColors.black,
          ),
        ),
        SizedBox(height: 12.w),
        Container(
          height: 50.w,
          padding: EdgeInsets.fromLTRB(12.w, 0.w, 12.w, 0.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.w),
            color: CommonColors.grayF7,
            border: Border.all(
              color: CommonColors.grayF2,
              width: 1.w,
            ),
          ),
          child: Row(
            children: [
              if (hasIcon == true)
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/iconPerson.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              Expanded(
                child: Text(
                  content,
                  style: commonInputText(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
