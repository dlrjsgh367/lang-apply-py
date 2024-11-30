import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawalCheck extends StatelessWidget {
  WithdrawalCheck({
    super.key,
    required this.onTap,
    required this.active,
    required this.text,
  });

  final Function onTap;
  final bool active;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        color: Colors.transparent,
        padding:
        EdgeInsets.fromLTRB(0.w, 12.w, 0.w, 12.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: active ? CommonColors.red : CommonColors.gray66,
                ),
              ),
            ),
            CircleCheck(
              onChanged: (value) {},
              readOnly: true,
              value: active,
            ),
          ],
        ),
      ),
    );
  }
}
