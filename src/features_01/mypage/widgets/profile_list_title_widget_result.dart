import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileListTitleWidget extends StatefulWidget {
  const ProfileListTitleWidget({
    super.key,
    required this.onTap,
    required this.title,
    required this.data,
    this.required = false,
  });

  final Function onTap;
  final String title;
  final Map<String, dynamic> data;
  final bool required;

  @override
  State<ProfileListTitleWidget> createState() => _ProfileListTitleWidgetState();
}

class _ProfileListTitleWidgetState extends State<ProfileListTitleWidget> {
  final titleController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 56.w,
              color: Colors.transparent,
              padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ),
                        if (widget.required)
                          Container(
                            margin: EdgeInsets.only(left: 4.w),
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CommonColors.red),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0.w),
            child: GestureDetector(
              onTap: () {
                widget.onTap();
              },
              child: Container(
                // width: CommonSize.vw,
                padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 12.w),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    width: 1.w,
                    color: CommonColors.grayF2,
                  ),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.data['mpTitle'].isNotEmpty
                            ? widget.data['mpTitle']
                            : localization.setProfileTitle,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: widget.data['mpTitle'].isNotEmpty
                              ? CommonColors.black2b
                              : CommonColors.grayB2,
                        ),
                      ),
                    ),
                    Text(
                      localization.recommendation,
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.red),
                    ),
                    Image.asset(
                      'assets/images/icon/iconArrowDownRed.png',
                      width: 16.w,
                      height: 16.w,
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 16.w,
          )
        ],
      ),
    );
  }
}
