import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostingCheck extends StatelessWidget {
  const PostingCheck(
      {Key? key,
      required this.onChanged,
      required this.groupValue,
      required this.value,
      required this.label})
      : super(key: key);
  final ValueChanged<dynamic> onChanged;
  final dynamic value;
  final dynamic groupValue;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          onChanged(value);
        },
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 8.w, 20.w, 20.w),
          color: Colors.transparent,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20.w,
                height: 20.w,
                alignment: Alignment.center,
                child: Image.asset(
                  groupValue == value
                      ? 'assets/images/icon/IconCheckActive.png'
                      : 'assets/images/icon/IconCheck.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
              SizedBox(
                width: 4.w,
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  color: groupValue == value
                      ? CommonColors.red
                      : CommonColors.grayB2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
