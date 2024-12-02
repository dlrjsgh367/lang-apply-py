import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlarmToggleRadioButton extends StatefulWidget {
  final ValueChanged<dynamic> onChanged;
  dynamic value;
  dynamic groupValue;
  bool readOnly;
  final String text;
  final bool isTop;
  final String? caption;

  AlarmToggleRadioButton({
    Key? key,
    required this.onChanged,
    required this.groupValue,
    required this.value,
    this.readOnly = false,
    required this.text,
    this.isTop = false,
    this.caption,
  }) : super(key: key);

  @override
  State<AlarmToggleRadioButton> createState() => _CommonRadioState();
}

class _CommonRadioState extends State<AlarmToggleRadioButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: widget.readOnly
            ? null
            : () {
                widget.onChanged(widget.value);
              },
        child: Container(
          padding: EdgeInsets.fromLTRB(widget.isTop ? 20.w : 40.w, 0, 20.w, 0),
          height: 52.w,
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: CommonColors.black2b,
                        fontWeight:
                            widget.isTop ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 42.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(500.w),
                          color: widget.value == widget.groupValue
                              ? CommonColors.red
                              : CommonColors.grayF2,
                        ),
                      ),
                      AnimatedPositioned(
                        left: widget.value == widget.groupValue ? 20.w : 2.w,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: CommonColors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        duration: const Duration(milliseconds: 200),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.caption != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.w),
                  child: Text(
                    widget.caption!,
                    style:
                        TextStyle(fontSize: 11.sp, color: CommonColors.gray80),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
