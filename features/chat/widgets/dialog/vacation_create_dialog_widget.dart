import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/check_map_list_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/vacation_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class VacationCreateDialogWidget extends ConsumerStatefulWidget {
  const VacationCreateDialogWidget({
    super.key,
    required this.uuid,
    required this.chatUsers,
  });

  final String uuid;
  final Map<String, dynamic> chatUsers;

  @override
  ConsumerState<VacationCreateDialogWidget> createState() =>
      _VacationCreateDialogWidgetState();
}

class _VacationCreateDialogWidgetState
    extends ConsumerState<VacationCreateDialogWidget> {

  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  @override
  void initState() {
    Future((){
      initSet();
    });
    super.initState();
  }

  DateTime? vsStartDate;
  DateTime? vsEndDate;

  Map<String, dynamic>? vacationSelectedDropdown;
  bool isRunning = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  List<Map<String, dynamic>> vacationDropdownList = [
    {'name': '연차', 'key': 1},
    {'name': '경조휴가', 'key': 2},
    {'name': '포상휴가', 'key': 3},
    {'name': '생리휴가', 'key': 4},
    {'name': '기타휴가', 'key': 5},
  ];

  Map<String, dynamic> params = {
    'vaType': 0,
    'vaWorkerName': '',
    'vaWorkerPhone': '',
    'vaDepartment': '',
    'vaPosition': '',
    'vaStartDate': '',
    'vaEndDate': '',
    'vaReason': '',
  };

  Map<String, dynamic> vacationValidator = {
    'type': false,
    'name': false,
    'phone': false,
    'useDate': false,
    'reason': false,
  };

  formValidator(String type) {
    switch (type) {
      case 'type':
        params['vaType'] == null || params['vaType'] == 0
            ? setState(() {
                vacationValidator['type'] = false;
              })
            : setState(() {
                vacationValidator['type'] = true;
              });
      case 'name':
        params['vaWorkerName'] == null || params['vaWorkerName'].isEmpty
            ? setState(() {
                vacationValidator['name'] = false;
              })
            : setState(() {
                vacationValidator['name'] = true;
              });
      case 'phone':
        params['vaWorkerPhone'] == null ||
                params['vaWorkerPhone'].isEmpty ||
                ContractValidator.validatePhoneNumber(
                        params['vaWorkerPhone']) ==
                    false
            ? setState(() {
                vacationValidator['phone'] = false;
              })
            : setState(() {
                vacationValidator['phone'] = true;
              });
      case 'useDate':
        params['vaStartDate'].isEmpty || params['vaEndDate'].isEmpty
            ? setState(() {
                vacationValidator['useDate'] = false;
              })
            : setState(() {
                vacationValidator['useDate'] = true;
              });
      case 'reason':
        params['vaReason'] == null || params['vaReason'].isEmpty
            ? setState(() {
                vacationValidator['reason'] = false;
              })
            : setState(() {
                vacationValidator['reason'] = true;
              });
    }
  }

  initSet() {
    UserModel? userInfo = ref.watch(userProvider);
    setState(() {
      nameController.text = userInfo!.name;
      phoneController.text = ConvertService.formatPhoneNumber(userInfo.phoneNumber);
      params['vaWorkerName'] = userInfo.name;
      params['vaWorkerPhone'] = userInfo.phoneNumber;
    });

    formValidator('name');
    formValidator('phone');
  }

  sendVacation() async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .createDocument(widget.uuid, 'VACATION', params);

    if (apiUploadResult.type == 1) {
      await sendDocumentMsg(apiUploadResult.data);
      setState(() {
        isRunning = false;
      });
    } else {
      showDefaultToast('휴가 신청서 제출에 실패했습니다.');
      setState(() {
        isRunning = false;
      });
      return false;
    }
  }

  showCalendar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return VacationBottomSheet(
          setSelectDate: setSelectDate,
          selectedDate: [params['vaStartDate'], params['vaEndDate']],
        );
      },
    );
  }

  setSelectDate(start, end) {
    params['vaStartDate'] = start;
    params['vaEndDate'] = end;
    formValidator('useDate');
  }

  sendDocumentMsg(int caIdx) async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);

    var msgKey = await ref.read(chatControllerProvider.notifier).newDocument(
        widget.uuid,
        chatUser!,
        widget.chatUsers,
        partnerStatus,
        null,
        'vacation',
        DateTime.now());

    await updateContract(msgKey, caIdx);
  }

  updateContract(String msgKey, int caIdx) async {
    if (widget.chatUsers.isNotEmpty) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .updateChatMsgUuid(msgKey, caIdx);

      if (apiUploadResult.type == 1) {
        showDefaultToast('휴가 신청서 제출에 성공했습니다.');
        context.pop();
      } else {
        showDefaultToast('휴가 신청서 제출에 실패했습니다.');
        return false;
      }
    } else {
      showDefaultToast('유저 정보가 비정상입니다.');
    }
  }

  showSelectVacationType(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CheckMapListBottomSheet(
          checkList: vacationDropdownList,
          selected: 1,
          title: '휴가 종류',
          returnData: params['vaType'],
          setData: setValue,
          keyName: 'name',
        );
      },
    );
  }

  setValue(dynamic value) {
    setState(() {
      vacationSelectedDropdown = value;
      params['vaType'] = value['key'];

      formValidator('type');
    });
  }

  returnValidator() {
    String msg = '';
    if (!vacationValidator['name']) {
      msg = '이름을 확인해주세요.';
    } else if (!vacationValidator['phone']) {
      msg = '휴대폰 번호를 확인해주세요.';
    } else if (!vacationValidator['type']) {
      msg = '휴가 종류를 확인해주세요.';
    } else if (!vacationValidator['useDate']) {
      msg = '휴가 기간을 확인해주세요.';
    } else if (!vacationValidator['reason']) {
      msg = '휴가 사유를 확인해주세요.';
    }
    return msg;
  }

  checkValid() {
    List<String> validateArr = [
      'name',
      'type',
      'useDate',
      'reason',
      'phone',
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => vacationValidator[key] == true);
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
                FocusScope.of(context).unfocus();
              } else {
                if (!didPop) {
                  context.pop();
                }
              }
            },
            child: Scaffold(
              appBar: const ModalAppbar(
                title: '휴가 신청서 작성',
              ),
              body:  Column(
                children: [
                  Expanded(child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 32.w, 20.w,  CommonSize.commonBottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '신청자 정보',
                          style: commonTitleAuth(),
                        ),
                        SizedBox(height: 20.w),
                        TextFormField(
                          controller: nameController,
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['vaWorkerName'] = value;

                              formValidator('name');
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(hintText: '이름을 입력해주세요.'),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(height: 12.w),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [PhoneNumberTextInputFormatter()],
                          maxLength: 13,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['vaWorkerPhone'] = value.replaceAll('-', '');
                              formValidator('phone');
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(hintText: '휴대폰 번호를 입력해주세요.'),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(height: 12.w),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['vaDepartment'] = value;
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(hintText: '(선택) 소속 부서를 입력해주세요.'),
                          textInputAction: TextInputAction.next,
                          onEditingComplete: () {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        SizedBox(height: 12.w),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          maxLines: null,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              params['vaPosition'] = value;
                            });
                          },
                          style: commonInputText(),
                          decoration: commonInput(hintText: '(선택) 직위를 입력해주세요.'),
                        ),
                        SizedBox(height: 36.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '내용',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 20.w),
                            SelectButton(
                              onTap: () {
                                showSelectVacationType(context);
                              },
                              text: vacationSelectedDropdown != null
                                  ? vacationSelectedDropdown!['name']
                                  : '',
                              hintText: '휴가 종류를 선택해주세요.',
                            ),
                            SizedBox(height: 12.w),
                            SelectButton(
                              onTap: () {
                                showCalendar();
                              },
                              text: params['vaStartDate'].isEmpty ||
                                  params['vaEndDate'].isEmpty
                                  ? ''
                                  : '${params['vaStartDate'].toString()} ~ ${params['vaEndDate'].toString()}',
                              hintText: '휴가 기간을 선택해주세요.',
                              isDate: true,
                            ),
                            SizedBox(height: 12.w),
                            CommonKeyboardAction(
                              focusNode: textAreaNode,
                              child:
                              TextFormField(
                                onTap: () {
                                  ScrollCenter(textAreaKey);
                                },
                                key: textAreaKey,
                                focusNode: textAreaNode,
                                textInputAction: TextInputAction.newline,
                                keyboardType: TextInputType.multiline,
                                minLines: 3,
                                maxLines: 3,
                                maxLength: 500,
                                autocorrect: false,
                                cursorColor: Colors.black,
                                textAlignVertical: TextAlignVertical.top,
                                onChanged: (value) {
                                  setState(() {
                                    params['vaReason'] = value;
                                    formValidator('reason');
                                  });
                                },
                                style: commonInputText(),
                                decoration: areaInput(
                                  hintText: '휴가 사유를 입력해주세요.',
                                ),
                              ),
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
                                  sendVacation();
                                }
                              },
                              text: '제출하기',
                              confirm: checkValid(),
                            ),

                          ],
                        ),
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
              ),

            ),
          ),
        ],
      ),
    );
  }
}
