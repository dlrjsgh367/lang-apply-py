import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyTitle extends StatelessWidget {
  const ApplyTitle({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.w,
                color: CommonColors.grayB2,
              ),
            ),
          ),
          height: 56.w,
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CommonColors.gray66,
                ),
              ),
            ],
          ),
        ),
      )
    ;
  }
}
