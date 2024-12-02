import 'dart:io';

import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/core/utils/validate_service.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/widgets/sign_up_step_widget.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/check_map_plus_list_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/chat/salary_list.dart';
import 'package:chodan_flutter_app/widgets/chat/salary_sum.dart';
import 'package:chodan_flutter_app/widgets/chat/salary_title.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import 'package:intl/intl.dart';

class SalaryCreateDialogWidget extends ConsumerStatefulWidget {
  const SalaryCreateDialogWidget({
    super.key,
    required this.uuid,
    required this.sendDocument,
    required this.chatUsers,
    required this.partnerIdx,
  });

  final Function sendDocument;
  final String uuid;
  final Map<String, dynamic> chatUsers;
  final int partnerIdx;

  @override
  ConsumerState<SalaryCreateDialogWidget> createState() =>
      _SalaryCreateDialogWidgetState();
}

class _SalaryCreateDialogWidgetState
    extends ConsumerState<SalaryCreateDialogWidget> with Files {
  int step = 1;
  bool isAgree = false;
  bool isValidate = false;
  int linePop = 8;

  bool isRunning = false;

  final formatCurrency = NumberFormat('#,###');

  Uint8List? signImgData;
  File? signImgFile;
  Map<String, dynamic> signFileMap = {};

  List<Map<String, dynamic>?> paymentSelectedDropdown = [null];
  List<Map<String, dynamic>?> deductionSelectedDropdown = [null];

  TextEditingController workerNameController = TextEditingController();
  TextEditingController workerBirthController = TextEditingController();
  TextEditingController workerStartDateController = TextEditingController();
  TextEditingController workerDepartmentController = TextEditingController();
  TextEditingController workerPositionController = TextEditingController();
  List<TextEditingController> paymentControllerList = [TextEditingController()];
  List<TextEditingController> deductionControllerList = [
    TextEditingController()
  ];

  Map<String, dynamic> params = {
    'salaryStatementDto': {
      'ssWorkerName': '',
      'ssWorkerBirthdate': '',
      'ssStartDate': '',
      'ssDepartment': '',
      'ssPosition': '',
    },
    'salaryPaymentDto': [
      {
        'spType': 0,
        'spAmount': 0,
      }
    ],
    'salaryDeductionDto': [
      {
        'sdType': 0,
        'sdAmount': 0,
      }
    ],
  };

  Map<String, dynamic> salaryValidator = {
    'workerName': false,
    'workerBirth': false,
    'workerStartDate': false,
    'payment': false,
    'deduction': false,
  };

  List<Map<String, dynamic>> paymentTypeDropdownList = [
    {'type': '식대', 'key': 1},
    {'type': '차량유지비', 'key': 2},
    {'type': '연장근로수당', 'key': 3},
    {'type': '야간근로수당', 'key': 4},
    {'type': '휴일근로수당', 'key': 5},
    {'type': '직급수당', 'key': 6},
    {'type': '보육수당', 'key': 7},
    {'type': '근속수당', 'key': 8},
    {'type': '가족수당', 'key': 9},
    {'type': '당직수당', 'key': 10},
    {'type': '상여금', 'key': 11},
    {'type': '기타', 'key': 12},
  ];

  List<Map<String, dynamic>> deductionTypeDropdownList = [
    {'type': '지방소득세', 'key': 1},
    {'type': '국민연금', 'key': 2},
    {'type': '건강보험', 'key': 3},
    {'type': '고용보험', 'key': 4},
    {'type': '산재보험', 'key': 5},
    {'type': '장기요양보험', 'key': 6},
    {'type': '주민세', 'key': 7},
    {'type': '상조회비', 'key': 8},
    {'type': '연말정산', 'key': 9},
    {'type': '기타', 'key': 10},
  ];

  returnPaymentType(int value) {
    switch (value) {
      case 0:
        return '기본급';
      case 1:
        return '식대';
      case 2:
        return '차량유지비';
      case 3:
        return '연장근로수당';
      case 4:
        return '야간근로수당';
      case 5:
        return '휴일근로수당';
      case 6:
        return '직급수당';
      case 7:
        return '보육수당';
      case 8:
        return '근속수당';
      case 9:
        return '가족수당';
      case 10:
        return '당직수당';
      case 11:
        return '상여금';
      case 12:
        return '기타';
    }
  }

  returnDeductionType(int value) {
    switch (value) {
      case 0:
        return '소득세';
      case 1:
        return '지방소득세';
      case 2:
        return '국민연금';
      case 3:
        return '건강보험';
      case 4:
        return '고용보험';
      case 5:
        return '산재보험';
      case 6:
        return '장기요양보험';
      case 7:
        return '주민세';
      case 8:
        return '상조회비';
      case 9:
        return '연말정산';
      case 10:
        return '기타';
    }
  }

  returnTotal(String type) {
    int total = 0;

    if (type == 'payment') {
      for (var data in params['salaryPaymentDto']) {
        int price = data['spAmount'];
        total += price;
      }
    } else {
      for (var data in params['salaryDeductionDto']) {
        int price = data['sdAmount'];
        total += price;
      }
    }

    return total;
  }

  getEmployeeInfo() async {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .getOtherUserData((roomInfo!.partnerKey).toString());
    if (result.type == 1) {
      if (result.status == 200) {
        setState(() {
          ref.read(otherUserProvider.notifier).update((state) => result.data);

          var userInfo = ref.watch(otherUserProvider);

          setState(() {
            workerNameController.text = userInfo!.name;
            workerBirthController.text = userInfo.birth;
            params['salaryStatementDto']['ssWorkerName'] = userInfo.name;
            params['salaryStatementDto']['ssWorkerBirthdate'] =
                userInfo.birth.replaceAll('-', '');
            formValidator('workerName');
            formValidator('workerBirth');
          });
        });
      }
    }
  }

  final SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  sendSalary() async {
    if (widget.chatUsers.isNotEmpty) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .createDocument(widget.uuid, 'SALARY', params);

      setState(() {
        isRunning = false;
      });

      if (apiUploadResult.type == 1) {
        await uploadSingImg();

        if (signFileMap.isNotEmpty) {
          await sendDocumentMsg(apiUploadResult.data);
        }
      } else {
        showDefaultToast('서류 저장에 실패했습니다.');
        return false;
      }
    } else {
      showDefaultToast('유저 정보가 비정상입니다.');
    }
  }

  updateSalary(String msgKey, int caIdx) async {
    if (widget.chatUsers.isNotEmpty) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .updateChatMsgUuid(msgKey, caIdx);

      setState(() {
        isRunning = false;
      });

      if (apiUploadResult.type == 1) {
        showDefaultToast('서류 등록에 성공했습니다.');
        context.pop();
        context.pop();
      } else {
        showDefaultToast('서류 등록에 실패했습니다.');
        return false;
      }
    } else {
      showDefaultToast('유저 정보가 비정상입니다.');
    }
  }

  uploadSingImg() async {
    var result =
        await fileChatUploadS3(signImgFile, 'RECRUITER_SIGNATURE', widget.uuid);

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
        'salary',
        DateTime.now());

    await updateSalary(msgKey, caIdx);
  }

  formValidator(String type) {
    setState(() {
      isValidate = true;
    });
    switch (type) {
      case 'workerName':
        params['salaryStatementDto']['ssWorkerName'] == null ||
                params['salaryStatementDto']['ssWorkerName'].isEmpty
            ? setState(() {
                salaryValidator['workerName'] = false;
              })
            : setState(() {
                salaryValidator['workerName'] = true;
              });
      case 'workerBirth':
        setState(() {
          salaryValidator['workerBirth'] = ValidationService.validateBirthdate(
              params['salaryStatementDto']['ssWorkerBirthdate']);
        });
      case 'workerStartDate':
        setState(() {
          salaryValidator['workerStartDate'] =
              ValidationService.validateStartDate(
                  params['salaryStatementDto']['ssStartDate']);
        });
      case 'payment':
        if (params['salaryPaymentDto'].length > 1) {
          for (int i = 1; i < params['salaryPaymentDto'].length; i++) {
            (params['salaryPaymentDto'][0]['spAmount'] == null ||
                        params['salaryPaymentDto'][0]['spAmount'] == 0) ||
                    ((params['salaryPaymentDto'][i]['spAmount'] == null ||
                            params['salaryPaymentDto'][i]['spAmount'] == 0) ||
                        (params['salaryPaymentDto'][i]['spType'] == null ||
                            params['salaryPaymentDto'][i]['spType'] == -1))
                ? setState(() {
                    salaryValidator['payment'] = false;
                  })
                : setState(() {
                    salaryValidator['payment'] = true;
                  });
          }
        } else {
          params['salaryPaymentDto'][0]['spAmount'] == null ||
                  params['salaryPaymentDto'][0]['spAmount'] == 0
              ? setState(() {
                  salaryValidator['payment'] = false;
                })
              : setState(() {
                  salaryValidator['payment'] = true;
                });
        }
      case 'deduction':
        if (params['salaryDeductionDto'].length > 1) {
          for (int i = 1; i < params['salaryDeductionDto'].length; i++) {
            (params['salaryDeductionDto'][0]['sdAmount'] == null ||
                        params['salaryDeductionDto'][0]['sdAmount'] == 0) ||
                    ((params['salaryDeductionDto'][i]['sdAmount'] == null ||
                            params['salaryDeductionDto'][i]['sdAmount'] == 0) ||
                        (params['salaryDeductionDto'][i]['sdType'] == null ||
                            params['salaryDeductionDto'][i]['sdType'] == -1))
                ? setState(() {
                    salaryValidator['deduction'] = false;
                  })
                : setState(() {
                    salaryValidator['deduction'] = true;
                  });
          }
        } else {
          params['salaryDeductionDto'][0]['sdAmount'] == null ||
                  params['salaryDeductionDto'][0]['sdAmount'] == 0
              ? setState(() {
                  salaryValidator['deduction'] = false;
                })
              : setState(() {
                  salaryValidator['deduction'] = true;
                });
        }
    }
  }

  bool validateBirthdate(String value) {
    if (value.length != 8) return false;
    try {
      int year = int.parse(value.substring(0, 4));
      int month = int.parse(value.substring(4, 6));
      int day = int.parse(value.substring(6, 8));

      DateTime birthdate = DateTime(year, month, day);
      DateTime today = DateTime.now();

      if (birthdate.year != year ||
          birthdate.month != month ||
          birthdate.day != day) {
        return false;
      }
      if (birthdate.isAfter(today)) {
        return false;
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  showSignDialog() {
    showModalBottomSheet<void>(
      isDismissible: true,
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
        return Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TitleBottomSheet(title: '급여 내역서 작성 완료'),
                SizedBox(height: 12.w),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20.w, 0, 20.w, CommonSize.commonBottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '서명 시 이름을 정자로 써주세요.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.grayB2,
                        ),
                      ),
                      SizedBox(height: 8.w),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: CommonColors.grayD9,
                          ),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Signature(
                          controller: signController,
                          width: CommonSize.vw,
                          height: 189.w,
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      SizedBox(height: 16.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              signController.clear();
                            },
                            child: Container(
                              width: 120.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayE6,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '서명 지우기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.sp,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: CommonButton(
                                onPressed: () async {
                                  if (isRunning) {
                                    return;
                                  }
                                  setState(() {
                                    isRunning = true;
                                  });

                                  signImgData =
                                      await signController.toPngBytes();

                                  // 애플리케이션의 임시 디렉터리 가져오기
                                  final Directory directory =
                                      await getTemporaryDirectory();

                                  // 변환할 파일 경로 지정
                                  String filePath =
                                      '${directory.path}/signImage.png'; // 저장될 파일 경로

                                  // Uint8List를 File로 변환
                                  File file =
                                      uint8ListToFile(signImgData!, filePath);

                                  setState(() {
                                    signImgFile = file;
                                  });

                                  if (signImgData != null) {
                                    sendSalary();
                                  }
                                },
                                text: '서명 후 제출하기',
                                confirm: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        );
      },
    );
  }

  showPaymentDataDialog(BuildContext context, int index) {
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
        return CheckMapPlusListBottomSheet(
          checkList: paymentTypeDropdownList,
          selected: 1,
          title: '지급 항목명 선택',
          returnData: paymentSelectedDropdown[index],
          keyName: 'type',
          setData: setPaymentValue,
          index: index,
        );
      },
    );
  }

  setPaymentValue(Map<String, dynamic> item, int index) {
    setState(() {
      paymentSelectedDropdown[index] = item;
      params['salaryPaymentDto'][index]['spType'] = item['key'];
    });
  }

  showDeductionDataDialog(BuildContext context, int index) {
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
        return CheckMapPlusListBottomSheet(
          checkList: deductionTypeDropdownList,
          selected: 1,
          title: '공제 항목명 선택',
          returnData: deductionSelectedDropdown[index],
          keyName: 'type',
          setData: setDeductionValue,
          index: index,
        );
      },
    );
  }

  setDeductionValue(Map<String, dynamic> item, int index) {
    setState(() {
      deductionSelectedDropdown[index] = item;
      params['salaryDeductionDto'][index]['sdType'] = item['key'];
    });
  }

  // Uint8List를 File로 변환하는 함수
  File uint8ListToFile(Uint8List data, String filePath) {
    File file = File(filePath);
    file.writeAsBytesSync(data);
    return file;
  }

  @override
  void initState() {
    Future(() {
      getEmployeeInfo();
    });
    super.initState();
  }

  @override
  void dispose() {
    signController.dispose();
    super.dispose();
  }

  returnValidateMsg() {
    String msg = '';
    if (!salaryValidator['workerName']) {
      msg = '이름을 입력해주세요.';
    } else if (!salaryValidator['workerBirth']) {
      msg = '생년월일을 확인해주세요.';
    } else if (!salaryValidator['workerStartDate']) {
      msg = '입사날짜를 확인해주세요.';
    }
    return msg;
  }

  void _handleButtonPress() {
    if (step == 1 && isStep1Valid(salaryValidator)) {
      setState(() {
        step = 2;
      });
    } else if (step == 2 && isStep2Valid(salaryValidator)) {
      setState(() {
        step = 3;
      });
    } else if (step == 3 && isAgree) {
      setState(() {
        showSignDialog();
      });
    }
  }

  bool isStep1Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'workerName',
      'workerBirth',
      'workerStartDate',
    ];

    for (String data in validateArr) {
      formValidator(data);
    }
    return validateArr.every((key) => validator[key] == true);
  }

  bool isStep2Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'payment',
      'deduction',
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => validator[key] == true);
  }

  bool isConfirmEnabled() {
    if (step == 1) {
      return isStep1Valid(salaryValidator);
    } else if (step == 2) {
      return isStep2Valid(salaryValidator);
    } else if (step == 3 && isAgree) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              title: '급여내역서 작성',
            ),
            body: GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus(); // keyboard hide
              },
              child: ColoredBox(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 55.w,
                          child: Row(
                            children: [
                              for (var i = 0; i < linePop; i++)
                                Expanded(
                                  child: Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    color: i < 2 || i > linePop - 3
                                        ? CommonColors.grayF2
                                        : i < (step.toInt()) * 2
                                            ? CommonColors.red
                                            : CommonColors.grayF2,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Expanded(flex: 1, child: SizedBox()),
                            Expanded(
                              flex: 2,
                              child: SignUpStepWidget(
                                text: '근로자 정보',
                                stepNumber: '1',
                                isComplete: step > 1,
                                isChecked: step == 1,
                                onTap: () {
                                  if (isStep1Valid(salaryValidator)) {
                                    setState(() {
                                      step = 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SignUpStepWidget(
                                text: '지급/공제',
                                stepNumber: '2',
                                isComplete: step > 2,
                                isChecked: step == 2,
                                onTap: () {
                                  if (isStep2Valid(salaryValidator)) {
                                    setState(() {
                                      step = 2;
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: SignUpStepWidget(
                                text: '내역확인',
                                stepNumber: '3',
                                isComplete: step > 3,
                                isChecked: step == 3,
                              ),
                            ),
                            const Expanded(flex: 1, child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w, 100.w),
                        child: Column(
                          children: [
                            if (step == 1)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '근로자정보',
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  TextFormField(
                                    controller: workerNameController,
                                    maxLength: 50,
                                    keyboardType: TextInputType.text,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['salaryStatementDto']
                                                ['ssWorkerName'] =
                                            workerNameController.text;
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
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: workerBirthController,
                                    maxLength: 10,
                                    inputFormatters: [DateTextInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['salaryStatementDto']
                                                ['ssWorkerBirthdate'] =
                                            workerBirthController.text
                                                .replaceAll('-', '');
                                      });
                                    },
                                    style: commonInputText(),
                                    decoration: commonInput(
                                      hintText: '생년월일 8자리를 확인해주세요.',
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () {
                                      FocusScope.of(context).nextFocus();
                                    },
                                  ),
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: workerStartDateController,
                                    maxLength: 10,
                                    inputFormatters: [DateTextInputFormatter()],
                                    keyboardType: TextInputType.number,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['salaryStatementDto']
                                                ['ssStartDate'] =
                                            workerStartDateController.text
                                                .replaceAll('-', '');
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
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: workerDepartmentController,
                                    maxLength: 50,
                                    keyboardType: TextInputType.text,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['salaryStatementDto']
                                                ['ssDepartment'] =
                                            workerDepartmentController.text;
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
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: workerPositionController,
                                    maxLength: 50,
                                    keyboardType: TextInputType.text,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['salaryStatementDto']
                                                ['ssPosition'] =
                                            workerPositionController.text;
                                      });
                                    },
                                    style: commonInputText(),
                                    decoration: commonInput(
                                      hintText: '(선택) 직위를 입력해주세요.',
                                    ),
                                  ),
                                  if (isValidate)
                                    Text(
                                      returnValidateMsg(),
                                      style: commonErrorAuth(),
                                    )
                                ],
                              ),
                            if (step == 2)
                              Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '지급항목',
                                        style: commonTitleAuth(),
                                      ),
                                      SizedBox(height: 20.w),
                                      Row(
                                        children: [
                                          Container(
                                            width: 140.w,
                                            height: 50.w,
                                            padding: EdgeInsets.fromLTRB(
                                                12.w, 12.w, 12.w, 0.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              border: Border.all(
                                                width: 1.w,
                                                color: CommonColors.grayF2,
                                              ),
                                            ),
                                            child: Text(
                                              '기본급',
                                              style: commonInputText(),
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  paymentControllerList[0],
                                              maxLength: 11,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLines: null,
                                              autocorrect: false,
                                              cursorColor: Colors.black,
                                              textAlign: TextAlign.end,
                                              onChanged: (value) {
                                                setState(() {
                                                  params['salaryPaymentDto'][0]
                                                          ['spAmount'] =
                                                      ConvertService.convertStringToInt(
                                                          ConvertService
                                                              .removeAllComma(
                                                                  paymentControllerList[
                                                                          0]
                                                                      .text));
                                                });
                                              },
                                              inputFormatters: [
                                                CurrencyTextInputFormatter
                                                    .currency(
                                                        locale: 'ko',
                                                        decimalDigits: 0,
                                                        symbol: ''),
                                              ],
                                              style: commonInputText(),
                                              decoration: suffixInput(
                                                  suffixText: '원',
                                                  suffixSize: 14.sp,
                                                  suffixColor:
                                                      CommonColors.black2b),
                                              textInputAction: TextInputAction.next,
                                              onEditingComplete: () {
                                                FocusScope.of(context).nextFocus();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.w),
                                      if (params['salaryPaymentDto'].length > 1)
                                        Column(
                                          children: [
                                            for (int i = 1;
                                                i <
                                                    params['salaryPaymentDto']
                                                        .length;
                                                i++)
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 140.w,
                                                        child: SelectButton(
                                                          onTap: () {
                                                            showPaymentDataDialog(
                                                                context, i);
                                                          },
                                                          text: paymentSelectedDropdown[
                                                                      i] !=
                                                                  null
                                                              ? paymentSelectedDropdown[
                                                                  i]!['type']
                                                              : '',
                                                          hintText: '항목명 선택',
                                                        ),
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller:
                                                              paymentControllerList[
                                                                  i],
                                                          maxLength: 11,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          maxLines: null,
                                                          autocorrect: false,
                                                          cursorColor:
                                                              Colors.black,
                                                          textAlign:
                                                              TextAlign.end,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              params['salaryPaymentDto']
                                                                          [i][
                                                                      'spAmount'] =
                                                                  ConvertService.convertStringToInt(
                                                                      ConvertService.removeAllComma(
                                                                          paymentControllerList[i]
                                                                              .text));
                                                            });
                                                          },
                                                          inputFormatters: [
                                                            CurrencyTextInputFormatter
                                                                .currency(
                                                                    locale:
                                                                        'ko',
                                                                    decimalDigits:
                                                                        0,
                                                                    symbol: ''),
                                                          ],
                                                          style:
                                                              commonInputText(),
                                                          decoration:
                                                              suffixInput(
                                                            suffixText: '원',
                                                            suffixSize: 14.sp,
                                                            suffixColor:
                                                                CommonColors
                                                                    .black2b,
                                                          ),
                                                          textInputAction: TextInputAction.next,
                                                          onEditingComplete: () {
                                                            FocusScope.of(context).nextFocus();
                                                          },
                                                        ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(width: 4.w),
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                params['salaryPaymentDto']
                                                                    .remove(params[
                                                                            'salaryPaymentDto']
                                                                        [i]);
                                                                paymentSelectedDropdown
                                                                    .remove(
                                                                        paymentSelectedDropdown[
                                                                            i]);
                                                                paymentControllerList
                                                                    .remove(
                                                                        paymentControllerList[
                                                                            i]);
                                                              });
                                                              formValidator(
                                                                  'payment');
                                                            },
                                                            child: Container(
                                                              width: 36.w,
                                                              height: 50.w,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  width: 1.w,
                                                                  color:
                                                                      CommonColors
                                                                          .grayF2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.w),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    Image.asset(
                                                                  width: 20.w,
                                                                  height: 20.w,
                                                                  'assets/images/appbar/iconClose.png',
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8.w),
                                                ],
                                              ),
                                          ],
                                        ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            params['salaryPaymentDto'].add({
                                              'spType': -1,
                                              'spAmount': 0,
                                            });
                                            paymentSelectedDropdown.add(null);
                                            paymentControllerList
                                                .add(TextEditingController());
                                          });
                                          formValidator('payment');
                                        },
                                        child: Container(
                                          height: 50.w,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              color: CommonColors.red02),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/icon/iconPlusRed.png',
                                                width: 18.w,
                                                height: 18.w,
                                              ),
                                              SizedBox(
                                                width: 6.w,
                                              ),
                                              Text(
                                                '항목 추가하기',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 36.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '공제항목',
                                        style: commonTitleAuth(),
                                      ),
                                      SizedBox(height: 20.w),
                                      Row(
                                        children: [
                                          Container(
                                            width: 140.w,
                                            height: 50.w,
                                            padding: EdgeInsets.fromLTRB(
                                                12.w, 12.w, 12.w, 0.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              border: Border.all(
                                                width: 1.w,
                                                color: CommonColors.grayF2,
                                              ),
                                            ),
                                            child: Text(
                                              '소득세',
                                              style: commonInputText(),
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: TextFormField(
                                              controller:
                                                  deductionControllerList[0],
                                              maxLength: 11,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLines: null,
                                              autocorrect: false,
                                              cursorColor: Colors.black,
                                              textAlign: TextAlign.end,
                                              onChanged: (value) {
                                                setState(() {
                                                  params['salaryDeductionDto']
                                                          [0]['sdAmount'] =
                                                      ConvertService.convertStringToInt(
                                                          ConvertService
                                                              .removeAllComma(
                                                                  deductionControllerList[
                                                                          0]
                                                                      .text));
                                                });
                                              },
                                              style: commonInputText(),
                                              inputFormatters: [
                                                CurrencyTextInputFormatter
                                                    .currency(
                                                        locale: 'ko',
                                                        decimalDigits: 0,
                                                        symbol: ''),
                                              ],
                                              decoration: suffixInput(
                                                  suffixText: '원',
                                                  suffixSize: 14.sp,
                                                  suffixColor:
                                                      CommonColors.black2b),

                                              textInputAction: TextInputAction.next,
                                              onEditingComplete: () {
                                                FocusScope.of(context).nextFocus();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.w),
                                      if (params['salaryDeductionDto'].length >
                                          1)
                                        Column(
                                          children: [
                                            for (int i = 1;
                                                i <
                                                    params['salaryDeductionDto']
                                                        .length;
                                                i++)
                                              Column(children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 140.w,
                                                      child: SelectButton(
                                                        onTap: () {
                                                          showDeductionDataDialog(
                                                              context, i);
                                                        },
                                                        text: deductionSelectedDropdown[
                                                                    i] !=
                                                                null
                                                            ? deductionSelectedDropdown[
                                                                i]!['type']
                                                            : '',
                                                        hintText: '항목명 선택',
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            deductionControllerList[
                                                                i],
                                                        maxLength: 11,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        maxLines: null,
                                                        autocorrect: false,
                                                        cursorColor:
                                                            Colors.black,
                                                        textAlign:
                                                            TextAlign.end,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            params['salaryDeductionDto']
                                                                        [i][
                                                                    'sdAmount'] =
                                                                ConvertService.convertStringToInt(
                                                                    ConvertService
                                                                        .removeAllComma(
                                                                            deductionControllerList[i].text));
                                                          });
                                                        },
                                                        style:
                                                            commonInputText(),
                                                        inputFormatters: [
                                                          CurrencyTextInputFormatter
                                                              .currency(
                                                                  locale: 'ko',
                                                                  decimalDigits:
                                                                      0,
                                                                  symbol: ''),
                                                        ],
                                                        decoration: suffixInput(
                                                          suffixText: '원',
                                                          suffixSize: 14.sp,
                                                          suffixColor:
                                                              CommonColors
                                                                  .black2b,
                                                        ),
                                                        textInputAction: TextInputAction.next,
                                                        onEditingComplete: () {
                                                          FocusScope.of(context).nextFocus();
                                                        },
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SizedBox(width: 4.w),
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              params['salaryDeductionDto']
                                                                  .remove(params[
                                                                          'salaryDeductionDto']
                                                                      [i]);
                                                              deductionSelectedDropdown
                                                                  .remove(
                                                                      deductionSelectedDropdown[
                                                                          i]);
                                                              deductionControllerList
                                                                  .remove(
                                                                      deductionControllerList[
                                                                          i]);
                                                            });

                                                            formValidator(
                                                                'deduction');
                                                          },
                                                          child: Container(
                                                            width: 36.w,
                                                            height: 50.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              border:
                                                                  Border.all(
                                                                width: 1.w,
                                                                color:
                                                                    CommonColors
                                                                        .grayF2,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.w),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  Image.asset(
                                                                width: 20.w,
                                                                height: 20.w,
                                                                'assets/images/appbar/iconClose.png',
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 8.w),
                                              ]),
                                          ],
                                        ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            params['salaryDeductionDto'].add({
                                              'sdType': -1,
                                              'sdAmount': 0,
                                            });
                                            deductionSelectedDropdown.add(null);
                                            deductionControllerList
                                                .add(TextEditingController());
                                          });
                                          formValidator('deduction');
                                        },
                                        child: Container(
                                          height: 50.w,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.w),
                                              color: CommonColors.red02),
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/icon/iconPlusRed.png',
                                                width: 18.w,
                                                height: 18.w,
                                              ),
                                              SizedBox(
                                                width: 6.w,
                                              ),
                                              Text(
                                                '항목 추가하기',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            if (step == 3)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const SalaryTitle(text: '지급항목'),
                                  SizedBox(height: 20.w),
                                  for (var data in params['salaryPaymentDto'])
                                    SalaryList(
                                      text: returnPaymentType(data['spType']),
                                      value: formatCurrency
                                          .format(data['spAmount'])
                                          .toString(),
                                    ),
                                  SizedBox(height: 8.w),
                                  SalarySum(
                                    text: '지급합계',
                                    value: formatCurrency
                                        .format(returnTotal('payment'))
                                        .toString(),
                                  ),
                                  SizedBox(height: 24.w),
                                  const SalaryTitle(text: '공제항목'),
                                  SizedBox(height: 20.w),
                                  for (var data in params['salaryDeductionDto'])
                                    SalaryList(
                                      text: returnDeductionType(data['sdType']),
                                      value: formatCurrency
                                          .format(data['sdAmount'])
                                          .toString(),
                                    ),
                                  SizedBox(height: 8.w),
                                  SalarySum(
                                    text: '공제합계',
                                    value: formatCurrency
                                        .format(returnTotal('deduction'))
                                        .toString(),
                                  ),
                                  SizedBox(height: 24.w),
                                  Container(
                                    padding:
                                        EdgeInsets.fromLTRB(0, 13.w, 0, 13.w),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1.w,
                                          color: CommonColors.gray66,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '실수령액',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.gray4d,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            formatCurrency.format(
                                                returnTotal('payment') -
                                                    returnTotal('deduction')),
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w600,
                                              color: CommonColors.gray4d,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.w),
                                  Text(
                                    DateFormat('yyyy년 MM월 dd일')
                                        .format(DateTime.now()),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                  SizedBox(height: 40.w),
                                  Row(
                                    children: [
                                      CircleCheck(
                                        value: isAgree,
                                        onChanged: (value) {
                                          setState(() {
                                            isAgree = !isAgree;
                                          });
                                        },
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        '(필수)',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.red,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        '내용에 이상이 없음을 확인하였습니다.',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 20.w),
                                CommonButton(
                                  fontSize: 15,
                                  onPressed: _handleButtonPress,
                                  confirm: isConfirmEnabled(),
                                  text: step == 3 ? '급여내역서 작성 완료' : '다음',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
