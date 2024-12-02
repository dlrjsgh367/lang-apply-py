import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/search_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/search_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';

class ApplyTypeWidget extends ConsumerStatefulWidget {
  const ApplyTypeWidget({
    super.key,
    required this.btnTitle,
    required this.type,
  });

  final String btnTitle;
  final int type;

  @override
  ConsumerState<ApplyTypeWidget> createState() => _ApplyTypeWidgetState();
}

class _ApplyTypeWidgetState extends ConsumerState<ApplyTypeWidget> {
  @override
  void initState() {
    super.initState();
  }

  // 0: 취소, 1:미확인(미열람), 2:승낙, 3:거절, 4:프로필/공고 열람(확인)
  returnBorderLineColor() {
    switch (widget.type) {
      case 0:
        return CommonColors.gray60;
      case 1:
        return CommonColors.gray60;
      case 2:
        return CommonColors.red;
      case 3:
        return CommonColors.gray60;
      case 4:
        return CommonColors.red;
      default:
        return CommonColors.gray60;
    }
  }

  returnBorderColor() {
    switch (widget.type) {
      case 0:
        return CommonColors.gray60;
      case 1:
        return CommonColors.white;
      case 2:
        return CommonColors.red;
      case 3:
        return CommonColors.gray60;
      case 4:
        return CommonColors.white;
      default:
        return CommonColors.white;
    }
  }

  returnTextColor() {
    switch (widget.type) {
      case 0:
        return CommonColors.white;
      case 1:
        return CommonColors.gray60;
      case 2:
        return CommonColors.white;
      case 3:
        return CommonColors.white;
      case 4:
        return CommonColors.red;
      default:
        return CommonColors.gray60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100.w),
        border: Border.all(
          width: 1.w,
          color: returnBorderLineColor(),
        ),
        color: returnBorderColor(),
      ),
      padding: EdgeInsets.fromLTRB(0, 3.w, 0, 3.w),
      child: Text(
        textAlign: TextAlign.center,
        widget.btnTitle,
        style: TextStyle(
          fontSize: 12.sp,
          color: returnTextColor(),
        ),
      ),
    );
  }
}
