import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ApplyCheckInner extends StatefulWidget {
  const ApplyCheckInner({super.key,
    required this.text,
    required this.title,
    required this.onChanged,
    required this.groupValue,
    required this.value,
  });
  final String text;
  final String title;
  final Function onChanged;
  final dynamic value;
  final dynamic groupValue;

  @override
  State<ApplyCheckInner> createState() => _ApplyCheckInnerState();
}

class _ApplyCheckInnerState extends State<ApplyCheckInner> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged();
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleCheck(
              onChanged: (value) {},
              readOnly: true,
              value: widget.groupValue == widget.value,
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.gray66,
                    ),
                  ),

                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 11.sp,

                      color: CommonColors.gray80,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

