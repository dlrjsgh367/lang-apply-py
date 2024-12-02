import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TitleItem extends StatelessWidget {
  const TitleItem({super.key,required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(20.w),
      sliver: SliverToBoxAdapter(
        child: Text(
          title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: CommonColors.black2b),
        ),
      ),
    );
  }
}
