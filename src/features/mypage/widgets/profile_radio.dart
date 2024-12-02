import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileRadio extends StatefulWidget {
  final Function onChanged;
  final dynamic value;
  final dynamic groupValue;
  final String label;

  const ProfileRadio({
    super.key,
    required this.onChanged,
    required this.groupValue,
    required this.value,
    required this.label
  });



  @override
  State<ProfileRadio> createState() => _ProfileRadioState();
}

class _ProfileRadioState extends State<ProfileRadio> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.value != widget.groupValue) {
          widget.onChanged(widget.value);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.w),
          color: CommonColors.white,
          border: Border.all(
              width: 1.w,
              color: widget.value == widget.groupValue
                  ? CommonColors.red
                  : CommonColors.grayF7),
        ),
        child: Row(
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: widget.value == widget.groupValue
                  ? BoxDecoration(
                shape: BoxShape.circle,
                color: CommonColors.red02,
                border: Border.all(
                  width: 3.w,
                  color: CommonColors.red,
                ),
              )
                  : BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 1.w,
                  color: CommonColors.grayB2,
                ),
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              widget.label,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: widget.value == widget.groupValue
                      ? CommonColors.black2b
                      : CommonColors.grayB2),
            ),
          ],
        ),
      ),
    );
  }
}
