import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBottomMenuWidget extends ConsumerStatefulWidget {
  const ChatBottomMenuWidget(
      {super.key,
      required this.getFiles,
      required this.showMediaSelectDialog,
      required this.showSalaryCreateDialog,
      required this.showEmploymentContractSelectDialog,
      required this.showDocumentSelectDialog,
      required this.showAttendanceSelectDialog});

  final Function getFiles;
  final Function showMediaSelectDialog;
  final Function showSalaryCreateDialog;
  final Function showEmploymentContractSelectDialog;
  final Function showDocumentSelectDialog;
  final Function showAttendanceSelectDialog;

  @override
  ConsumerState<ChatBottomMenuWidget> createState() =>
      _ChatBottomMenuWidgetState();
}

class _ChatBottomMenuWidgetState extends ConsumerState<ChatBottomMenuWidget> {

  @override
  void initState() {
    super.initState();

    Future(() {
      savePageLog();

    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }


  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    var chatUser = ref.watch(chatUserAuthProvider);
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    return Row(
      children: [
        if (user!.role == 'ROLE_JOBSEEKER')
          Expanded(
            child: TextButton(
              style: ButtonStyles.childBtn,
              onPressed: () {
                if (roomInfo!.contractAgree) {
                  widget.showAttendanceSelectDialog();
                } else {
                  showDefaultToast('근로 계약 생성 후에만 사용 가능합니다.');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon/iconChatCheck.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    '근태체크',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CommonColors.gray66,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (user.role == 'ROLE_JOBSEEKER')
          Expanded(
            child: TextButton(
              style: ButtonStyles.childBtn,
              onPressed: () {
                if (roomInfo!.contractAgree) {
                  widget.showDocumentSelectDialog();
                } else {
                  showDefaultToast('근로 계약 생성 후에만 사용 가능합니다.');
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon/iconChatDoc.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    '서류작성',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CommonColors.gray66,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (user.role == 'ROLE_RECRUITER')
          Expanded(
            child: TextButton(
              style: ButtonStyles.childBtn,
              onPressed: () {
                widget.showEmploymentContractSelectDialog();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon/iconChatWork.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    '근로계약서',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CommonColors.gray66,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (user.role == 'ROLE_RECRUITER')
          Expanded(
            child: TextButton(
              style: ButtonStyles.childBtn,
              onPressed: () {
                // if(chatUser!.contractAgree){
                  widget.showSalaryCreateDialog();
                // }else {
                //   showDefaultToast('근로 계약 생성 후에만 사용 가능합니다.');
                // }

              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/icon/iconChatMoney.png',
                    width: 36.w,
                    height: 36.w,
                  ),
                  SizedBox(
                    height: 8.w,
                  ),
                  Text(
                    '급여내역서',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: CommonColors.gray66,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: TextButton(
            style: ButtonStyles.childBtn,
            onPressed: () {
              widget.showMediaSelectDialog();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon/iconChatPhoto.png',
                  width: 36.w,
                  height: 36.w,
                ),
                SizedBox(
                  height: 8.w,
                ),
                Text(
                  '사진첨부',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CommonColors.gray66,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TextButton(
            style: ButtonStyles.childBtn,
            onPressed: () {
              widget.getFiles();
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icon/iconChatFile.png',
                  width: 36.w,
                  height: 36.w,
                ),
                SizedBox(
                  height: 8.w,
                ),
                Text(
                  '파일첨부',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: CommonColors.gray66,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
