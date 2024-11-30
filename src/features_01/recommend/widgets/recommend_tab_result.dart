import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendTab extends StatefulWidget {
  const RecommendTab({super.key});

  @override
  State<RecommendTab> createState() => _RecommendTabState();
}

class _RecommendTabState extends State<RecommendTab> {
  int activeTab = 0;

  void setTab(data) {
    setState(() {
      activeTab = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setTab(0);
            },
            child: ColoredBox(
              color: Colors.transparent,
              child: Stack(
                children: [
                  SizedBox(
                    height: 46.w,
                    child: Center(
                      child: Text(
                        localization.workInformation,
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: activeTab == 0
                                ? CommonColors.red
                                : CommonColors.grayB2),
                      ),
                    ),
                  ),
                  if (activeTab == 0)
                    Positioned(
                      left: 5.w,
                      right: 5.w,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CommonColors.red,
                          borderRadius: BorderRadius.circular(500.w),
                        ),
                        height: 3.w,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setTab(1);
            },
            child: ColoredBox(
              color: Colors.transparent,
              child: Stack(
                children: [
                  SizedBox(
                    height: 46.w,
                    child: Center(
                      child: Text(
                        localization.companyInformation,
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: activeTab == 1
                                ? CommonColors.red
                                : CommonColors.grayB2),
                      ),
                    ),
                  ),
                  if (activeTab == 1)
                    Positioned(
                      left: 5.w,
                      right: 5.w,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: CommonColors.red,
                          borderRadius: BorderRadius.circular(500.w),
                        ),
                        height: 3.w,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
