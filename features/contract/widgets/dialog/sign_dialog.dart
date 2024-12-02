import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';

class SignDialog extends StatefulWidget {
  const SignDialog({super.key, required this.signFunc, required this.signController,});

  final Function signFunc;
  final dynamic signController;

  @override
  State<SignDialog> createState() => _SignDialogState();
}

class _SignDialogState extends State<SignDialog> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBottomSheet(title: localization.submit),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
            child: Text(
              localization.signatureWriteInFullName,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.grayB2),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
            child: Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.w),
                border:
                Border.all(width: 1.w, color: CommonColors.grayD9),
              ),
              child: AspectRatio(
                aspectRatio: 320 / 189,
                child: Signature(
                  controller: widget.signController,
                  width: double.infinity,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Row(
              children: [
                BorderButton(
                    width: 120.w,
                    onPressed: () {
                      widget.signController.clear();
                    },
                    text: localization.clearSignature),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: CommonButton(
                    onPressed: () async {
                      widget.signFunc();
                    },
                    fontSize: 15,
                    text: localization.submitAfterSignature,
                    confirm: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
