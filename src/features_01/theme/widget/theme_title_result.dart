import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeTitle extends StatelessWidget {
  ThemeTitle({
    super.key,
    required this.title,
    required this.text,
    required this.nameDisplay,
    required this.summeryDisplay,
  });

  final String title;
  final int nameDisplay;
  final String text;
  final int summeryDisplay;

  @override
  Widget build(BuildContext context) {
    return nameDisplay == 1 || summeryDisplay == 1
        ? SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w,20.w,20.w,12.w),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (nameDisplay == 1)
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: CommonColors.black2b,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (nameDisplay == 1)
                    SizedBox(
                      height: 8.w,
                    ),
                  if (summeryDisplay == 1)
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: CommonColors.gray66,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          )
        :  SliverPadding(padding:EdgeInsets.all(10.w) );
  }
}
