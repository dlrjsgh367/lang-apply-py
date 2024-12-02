import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SendEmailDialog extends ConsumerStatefulWidget {
  const SendEmailDialog({
    super.key,
    required this.updateAt,
    required this.jpIdx,
  });

  final String updateAt;
  final int jpIdx;


  @override
  ConsumerState<SendEmailDialog> createState() => _SendEmailDialogState();
}

class _SendEmailDialogState extends ConsumerState<SendEmailDialog> {
  String email = '';
  bool isEmailActive = false;

  bool isRunning = false;

  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  returnTitle(String type) {
    switch (type) {
      case 'STANDARD':
        return localization.standardLaborContract;
      case 'SHORT':
        return localization.shortTermEmployeeContract;
      case 'YOUNG':
        return localization.minorEmployeeContract;
      case 'CONSTRUCTION':
        return localization.constructionDailyEmployeeContract;
      default:
        return localization.standardLaborContract;
    }
  }

  sendEmail(String email) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    UserModel? userInfo = ref.read(userProvider);
    var detailData = ref.watch(contractDetailProvider);
    Map<String, dynamic> params = {
      'email': email,
      'name': userInfo!.name,
      'documentType': detailData!.caContractType,
      'jpIdx': widget.jpIdx,
      'date': widget.updateAt,
      'atIdx': detailData.file!['atIdx'],
      'mcName': detailData.chatRecruiterDto.mcName,
      'mcMeName': detailData.chatRecruiterDto.meName,
      'meName': detailData.contractDetailDto.ccdEmployeeName,
    };

    var result =
        await ref.read(chatControllerProvider.notifier).sendEmail(params);
    isRunning = false;
    if (result.type == 1) {
      showDefaultToast(localization.emailSentSuccessfully);
      context.pop();
    } else if (result.status == 406) {
      showDefaultToast(localization.notLatestDocument);
    } else {
      showDefaultToast(localization.emailSendFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ColoredBox(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.keyboardMediaHeight(context) + CommonSize.keyboardBottom(context) + 30.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleBottomSheet(title: localization.sendViaEmail),
                SizedBox(
                  height: 14.w,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.w),
                  child: Text(
                    localization.enterEmailAddress,
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: CommonColors.gray80),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                  child: TextFormField(
                    maxLines: null,
                    autocorrect: false,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      setState(() {
                        email = value;

                        if (email.isEmpty || !emailRegExp.hasMatch(email)) {
                          isEmailActive = false;
                        } else {
                          isEmailActive = true;
                        }
                      });
                    },
                    style: commonInputText(),
                    decoration: commonInput(
                      hintText: localization.enterEmailAddress,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 20.w),
                  height: 40.w,
                  child: Text(
                    email.isNotEmpty && !isEmailActive ? localization.checkEmailFormat : '',
                    style: TextStyles.error,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: CommonButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();

                      if (isEmailActive) {
                        sendEmail(email);
                      }
                    },
                    text: localization.send,
                    fontSize: 15,
                    confirm: isEmailActive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
