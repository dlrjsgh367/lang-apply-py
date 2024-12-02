import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTitle extends StatelessWidget {
  const ProfileTitle({
    super.key,
    required this.title,
    required this.required,
    required this.text,
    this.hasArrow = true,
    this.extraText,
    this.onTap,
  });

  final bool required;

  final String title;
  final String text;
  final bool hasArrow;
  final Function? onTap;
  final String? extraText;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          onTap!();

        },
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            ),
                            if (required)
                              Container(
                                margin: EdgeInsets.only(left: 4.w),
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.red),
                              ),
                            if (extraText != null)
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Text(
                                  extraText!,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.gray80,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasArrow)
                    Image.asset(
                      'assets/images/icon/iconArrowRightThin.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                ],
              ),
              if (text != '')
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CommonColors.grayB2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
