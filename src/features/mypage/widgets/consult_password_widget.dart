import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/style/password_input_style.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';

class ConsultPasswordWidget extends ConsumerStatefulWidget {
  const ConsultPasswordWidget(
      {super.key, required this.idx, required this.afterFunc});

  final Function afterFunc;
  final int idx;

  @override
  ConsumerState createState() => _ConsultPasswordWidgetState();
}

class _ConsultPasswordWidgetState extends ConsumerState<ConsultPasswordWidget> {
  final passwordController = TextEditingController();

  String passwordErrorMessage = '';

  bool passwordMatchRegex = false;

  bool passwordVisible = true;
  bool pwdError = false;
  int step = 1;
  Map<String, dynamic> inputData = {'password': ''};
  Map<String, dynamic> validatorList = {
    'password': true,
  };

  void checkPassword() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .checkBoardPassword(widget.idx, inputData['password']);
    if (result.type == 1) {
      widget.afterFunc();
      context.pop();
    } else if (result.type == -908) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.521,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    } else {
      setState(() {
        pwdError = true;
      });
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.w),
      ),
      elevation: 0.0,
      actionsAlignment: MainAxisAlignment.center,
      contentPadding:
          EdgeInsets.fromLTRB(20.w, 0, 20.w, pwdError ? 10.w : 24.w),
      titlePadding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 12.w),
      actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
      title: Text(
        localization.522,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: SizedBox(
        width: CommonSize.vw,
        child: TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.text,
          obscureText: passwordVisible,
          cursorColor: CommonColors.black,
          style: commonInputText(),
          maxLength: null,
          decoration: passwordInput(
            hintText: localization.523,
            isVisible: !passwordVisible,
            hasString: passwordController.text.isNotEmpty,
            hasClear: passwordController.text.isNotEmpty,
            iconFunc: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
          ),
          minLines: 1,
          maxLines: 1,
          onChanged: (value) {
            setState(() {
              inputData['password'] = value;
              if (value != '') {
                validatorList['password'] = false;
              } else {
                validatorList['password'] = true;
              }
            });
          },
        ),
      ),
      actions: [
        if (pwdError)
          SizedBox(
            width: CommonSize.vw,
            height: 20.w,
            child: Text(
              textAlign: TextAlign.center,
              localization.524,
              style: commonErrorAuth(),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: CommonButton(
                  confirm: false,
                  textColor: Colors.black,
                  onPressed: () {
                    context.pop();
                  },
                  text: localization.closed),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CommonButton(
                  confirm: true,
                  onPressed: () {
                    if (!validatorList['password']) {
                      checkPassword();
                    }
                  },
                  text: localization.confirm),
            ),
          ],
        ),
      ],
    );
  }
}
