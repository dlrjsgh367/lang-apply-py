import 'dart:io';

import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_jobseeker_chat_bottom_sheet.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class ResignationCreateDialogWidget extends ConsumerStatefulWidget {
  const ResignationCreateDialogWidget({
    super.key,
    required this.uuid,
    required this.chatUsers,
    required this.companyName,
  });

  final String uuid;
  final Map<String, dynamic> chatUsers;
  final String companyName;

  @override
  ConsumerState<ResignationCreateDialogWidget> createState() =>
      _ResignationCreateDialogWidgetState();
}

class _ResignationCreateDialogWidgetState
    extends ConsumerState<ResignationCreateDialogWidget> with Files {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  Uint8List? signImgData;
  File? signImgFile;
  Map<String, dynamic> signFileMap = {};

  TextEditingController nameController = TextEditingController();
  TextEditingController startDateController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController resignationDateController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  bool isRunning = false;

  final SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  Map<String, dynamic> params = {
    'reName': '',
    'reStartDate': '',
    'reDepartment': '',
    'rePosition': '',
    'reResignationDate': '',
    'reReason': '',
  };

  Map<String, dynamic> resignationValidator = {
    'name': false,
    'startDate': false,
    'resignationDate': false,
    'reason': false,
  };

  formValidator(String type) {
    switch (type) {
      case 'name':
        (params['reName'] == null || params['reName'].isEmpty) &&
                ValidateService.isValidName(params['reName'])
            ? setState(() {
                resignationValidator['name'] = false;
              })
            : setState(() {
                resignationValidator['name'] = true;
              });
      case 'startDate':
        params['reStartDate'] == null ||
                params['reStartDate'].isEmpty ||
                ContractValidator.validateDateNumber(params['reStartDate']) ==
                    false
            ? setState(() {
                resignationValidator['startDate'] = false;
              })
            : setState(() {
                resignationValidator['startDate'] = true;
              });
      case 'resignationDate':
        params['reResignationDate'] == null ||
                params['reResignationDate'].isEmpty ||
                ContractValidator.validateDateNumber(
                        params['reResignationDate']) ==
                    false
            ? setState(() {
                resignationValidator['resignationDate'] = false;
              })
            : setState(() {
                resignationValidator['resignationDate'] = true;
              });
      case 'reason':
        params['reReason'] == null || params['reReason'].isEmpty
            ? setState(() {
                resignationValidator['reason'] = false;
              })
            : setState(() {
                resignationValidator['reason'] = true;
              });
    }
  }

  initSet() {
    UserModel? userInfo = ref.watch(userProvider);
    setState(() {
      nameController.text = userInfo!.name;
      params['reName'] = userInfo.name;
    });

    formValidator('name');
  }

  sendResignation() async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .createDocument(widget.uuid, 'RESIGNATION', params);

    if (apiUploadResult.type == 1) {
      await uploadSingImg();

      if (signFileMap.isNotEmpty) {
        await sendDocumentMsg(apiUploadResult.data);
      }
      setState(() {
        isRunning = false;
      });
    } else {
      showDefaultToast('사직서 제출에 실패했습니다.');
      setState(() {
        isRunning = false;
      });
      return false;
    }
  }

  uploadSingImg() async {
    var result =
        await fileChatUploadS3(signImgFile, 'JOBSEEKER_SIGNATURE', widget.uuid);

    if (result != null && result != false) {
      setState(() {
        signFileMap = result;
      });
    } else {
      showDefaultToast('서명 이미지 업로드에 실패했습니다.');
    }
  }

  sendDocumentMsg(int caIdx) async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);

    List<Map<String, dynamic>> fileList = [signFileMap];

    var msgKey = await ref.read(chatControllerProvider.notifier).newDocument(
        widget.uuid,
        chatUser!,
        widget.chatUsers,
        partnerStatus,
        fileList,
        'resignation',
        DateTime.now());

    await updateContract(msgKey, caIdx);
  }

  updateContract(String msgKey, int caIdx) async {
    if (widget.chatUsers.isNotEmpty) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .updateChatMsgUuid(msgKey, caIdx);

      if (apiUploadResult.type == 1) {
        showDefaultToast('사직서 제출에 성공했습니다.');
        context.pop();
        context.pop();
      } else {
        showDefaultToast('사직서 제출에 실패했습니다.');
        return false;
      }
    } else {
      showDefaultToast('유저 정보가 비정상입니다.');
    }
  }

  showSignDialog() {
    showModalBottomSheet<void>(
      isDismissible: false,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const TitleBottomSheet(title: '제출하기'),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
                child: Text(
                  '서명 시 이름을 정자로 써주세요.',
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
                    border: Border.all(width: 1.w, color: CommonColors.grayD9),
                  ),
                  child: AspectRatio(
                    aspectRatio: 320 / 189,
                    child: Signature(
                      controller: signController,
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
                          signController.clear();
                        },
                        text: '서명 지우기'),
                    SizedBox(
                      width: 8.w,
                    ),
                    Expanded(
                      child: CommonButton(
                        onPressed: () async {
                          if (isRunning) {
                            return;
                          }
                          setState(() {
                            isRunning = true;
                          });
                          signImgData = await signController.toPngBytes();

                          // 애플리케이션의 임시 디렉터리 가져오기
                          final Directory directory =
                              await getTemporaryDirectory();

                          // 변환할 파일 경로 지정
                          String filePath =
                              '${directory.path}/signImage.png'; // 저장될 파일 경로

                          // Uint8List를 File로 변환
                          File file = uint8ListToFile(signImgData!, filePath);

                          setState(() {
                            signImgFile = file;
                          });

                          if (signImgData != null) {
                            sendResignation();
                          }
                        },
                        fontSize: 15,
                        text: '서명 후 제출하기',
                        confirm: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Uint8List를 File로 변환하는 함수
  File uint8ListToFile(Uint8List data, String filePath) {
    File file = File(filePath);
    file.writeAsBytesSync(data);
    return file;
  }

  returnValidator() {
    String msg = '';
    if (!resignationValidator['name']) {
      msg = '이름을 확인해주세요.';
    } else if (!resignationValidator['startDate']) {
      msg = '입사 일자를 확인해주세요.';
    } else if (!resignationValidator['resignationDate']) {
      msg = '퇴사 일자를 확인해주세요.';
    } else if (!resignationValidator['reason']) {
      msg = '퇴사 사유를 확인해주세요.';
    }
    return msg;
  }

  checkValid() {
    List<String> validateArr = [
      'name',
      'startDate',
      'resignationDate',
      'reason',
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => resignationValidator[key] == true);
  }

  @override
  void initState() {
    Future(() {
      initSet();
    });
    super.initState();
  }

  @override
  void dispose() {
    signController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        children: [
          PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (MediaQuery.of(context).viewInsets.bottom > 0) {
                FocusManager.instance.primaryFocus?.unfocus();
              } else {
                if (!didPop) {
                  context.pop();
                }
              }
            },
            child: Scaffold(
              appBar: const ModalAppbar(
                title: '사직서 작성',
              ),
              body:Column(
                children: [
                  Expanded(child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 20.w, 20.w, CommonSize.commonBottom + 30.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '신청자 정보',
                          style: commonTitleAuth(),
                        ),
                        SizedBox(height: 16.w),
                        TextField(
                          controller: nameController,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['reName'] = nameController.text;

                              formValidator('name');
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: '이름을 입력해주세요.',
                          ),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        TextField(
                          controller: startDateController,
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 10,
                          inputFormatters: [DateTextInputFormatter()],
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['reStartDate'] =
                                  startDateController.text.replaceAll('-', '');

                              formValidator('startDate');
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: '입사일자 8자리를 확인해주세요.',
                          ),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        TextField(
                          controller: departmentController,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['reDepartment'] = departmentController.text;
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: '(선택) 소속 부서를 입력해주세요.',
                          ),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        TextField(
                          controller: positionController,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['rePosition'] = positionController.text;
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: '(선택) 직위를 입력해주세요.',
                          ),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(
                          height: 36.w,
                        ),
                        Text(
                          '내용',
                          style: commonTitleAuth(),
                        ),
                        SizedBox(height: 16.w),
                        TextField(
                          controller: resignationDateController,
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 10,
                          inputFormatters: [DateTextInputFormatter()],
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['reResignationDate'] =
                                  resignationDateController.text
                                      .replaceAll('-', '');

                              formValidator('resignationDate');
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: '퇴사 일자 8자리를 확인해주세요.',
                          ),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(
                          height: 12.w,
                        ),
                        Stack(
                          children: [
                            CommonKeyboardAction(
                              focusNode: textAreaNode,
                              child: TextField(
                                onTap: () {
                                  ScrollCenter(textAreaKey);
                                },
                                key: textAreaKey,
                                focusNode: textAreaNode,
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                controller: reasonController,
                                maxLines: 5,
                                maxLength: 500,
                                autocorrect: false,
                                textAlignVertical: TextAlignVertical.top,
                                cursorColor: Colors.black,
                                onChanged: (value) {
                                  setState(() {
                                    params['reReason'] = reasonController.text;

                                    formValidator('reason');
                                  });
                                },
                                style: areaInputText(),
                                minLines: 5,
                                decoration: areaInput(
                                  hintText: '퇴사 사유를 입력해주세요.',
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10.w,
                              bottom: 10.w,
                              child: Text(
                                '${reasonController.text.length}/500',
                                style: TextStyles.counter,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.w),
                        Text(
                          returnValidator(),
                          style: commonErrorAuth(),
                        ),
                        SizedBox(height: 12.w),
                        CommonButton(
                          fontSize: 15,
                          onPressed: () {
                            if (checkValid()) {
                              showSignDialog();
                            }
                          },
                          text: '제출하기',
                          confirm: checkValid(),
                        )
                      ],
                    ),
                  ),),
                  KeyboardVisibilityBuilder(
                    builder: (context, visibility) {
                      return SizedBox(
                        height: visibility ? 44 : 0,
                      );
                    },
                  ),
                ],

              )

            ),
          )
        ],
      ),
    );
  }
}
