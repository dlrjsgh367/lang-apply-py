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
import 'package:chodan_flutter_app/features/chat/widgets/parent_step_01.dart';
import 'package:chodan_flutter_app/features/chat/widgets/parent_step_02.dart';
import 'package:chodan_flutter_app/features/chat/widgets/parent_step_03.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class ParentAgreeCreateDialogWidget extends ConsumerStatefulWidget {
  const ParentAgreeCreateDialogWidget({
    super.key,
    required this.uuid,
    required this.chatUsers,
  });

  final String uuid;
  final Map<String, dynamic> chatUsers;

  @override
  ConsumerState<ParentAgreeCreateDialogWidget> createState() =>
      _ParentAgreeCreateDialogWidgetState();
}

class _ParentAgreeCreateDialogWidgetState
    extends ConsumerState<ParentAgreeCreateDialogWidget> with Files {
  bool rendered = false;
  Uint8List? signImgData;
  File? signImgFile;
  Map<String, dynamic> signFileMap = {};
  int step = 1;
  bool isAgree = false;
  bool isRunning = false;

  Map<String, dynamic> params = {
    'paType': 0,
    'paParentName': '',
    'paParentBirth': '',
    'paParentPhone': '',
    'paParentAddress': '',
    'paParentAddressDetail': '',
    'paWorkerName': '',
    'paWorkerBirth': '',
    'paWorkerPhone': '',
    'paWorkerAddress': '',
    'paWorkerAddressDetail': '',
    'paCompanyName': '',
    'paCompanyPhone': '',
    'paCompanyAddress': '',
  };

  Map<String, dynamic> parentValidator = {
    'paType': false,
    'paParentName': false,
    'paParentBirth': false,
    'paParentPhone': false,
    'paParentAddress': false,
    'paWorkerName': false,
    'paWorkerBirth': false,
    'paWorkerPhone': false,
    'paWorkerAddress': false,
    'paCompanyName': false,
    'paCompanyPhone': false,
    'paCompanyAddress': false,
  };

  TextEditingController workerNameController = TextEditingController();
  TextEditingController workerBirthController = TextEditingController();
  TextEditingController workerPhoneController = TextEditingController();
  TextEditingController workerAddressController = TextEditingController();
  TextEditingController workerAddressDetailController = TextEditingController();
  TextEditingController parentNameController = TextEditingController();
  TextEditingController parentBirthController = TextEditingController();
  TextEditingController parentPhoneController = TextEditingController();
  TextEditingController parentAddressController = TextEditingController();
  TextEditingController parentAddressDetailController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyPhoneController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();

  formValidator(String type) {
    switch (type) {
      case 'paType':
        params['paType'] == null || params['paType'] == 0
            ? setState(() {
                parentValidator['paType'] = false;
              })
            : setState(() {
                parentValidator['paType'] = true;
              });
      case 'paParentName':
        params['paParentName'] == null || params['paParentName'].isEmpty
            ? setState(() {
                parentValidator['paParentName'] = false;
              })
            : setState(() {
                parentValidator['paParentName'] = true;
              });
      case 'paParentBirth':
        setState(() {
          parentValidator['paParentBirth'] =
              ValidationService.validateBirthdate(params['paParentBirth']);
        });
      case 'paParentPhone':
        params['paParentPhone'] == null ||
                params['paParentPhone'].isEmpty ||
                ContractValidator.validatePhoneNumber(
                        params['paParentPhone']) ==
                    false
            ? setState(() {
                parentValidator['paParentPhone'] = false;
              })
            : setState(() {
                parentValidator['paParentPhone'] = true;
              });
      case 'paParentAddress':
        params['paParentAddress'] == null || params['paParentAddress'].isEmpty
            ? setState(() {
                parentValidator['paParentAddress'] = false;
              })
            : setState(() {
                parentValidator['paParentAddress'] = true;
              });
      case 'paWorkerName':
        params['paWorkerName'] == null || params['paWorkerName'].isEmpty
            ? setState(() {
                parentValidator['paWorkerName'] = false;
              })
            : setState(() {
                parentValidator['paWorkerName'] = true;
              });
      case 'paWorkerBirth':
        setState(() {
          parentValidator['paWorkerBirth'] =
              ValidationService.validateBirthdate(params['paWorkerBirth']);
        });
      case 'paWorkerPhone':
        params['paWorkerPhone'] == null ||
                params['paWorkerPhone'].isEmpty ||
                ContractValidator.validatePhoneNumber(
                        params['paWorkerPhone']) ==
                    false
            ? setState(() {
                parentValidator['paWorkerPhone'] = false;
              })
            : setState(() {
                parentValidator['paWorkerPhone'] = true;
              });
      case 'paWorkerAddress':
        params['paWorkerAddress'] == null || params['paWorkerAddress'].isEmpty
            ? setState(() {
                parentValidator['paWorkerAddress'] = false;
              })
            : setState(() {
                parentValidator['paWorkerAddress'] = true;
              });
      case 'paCompanyName':
        params['paCompanyName'] == null || params['paCompanyName'].isEmpty
            ? setState(() {
                parentValidator['paCompanyName'] = false;
              })
            : setState(() {
                parentValidator['paCompanyName'] = true;
              });
      case 'paCompanyPhone':
        params['paCompanyPhone'] == null || params['paCompanyPhone'].isEmpty
            ? setState(() {
                parentValidator['paCompanyPhone'] = false;
              })
            : setState(() {
                parentValidator['paCompanyPhone'] = true;
              });
      case 'paCompanyAddress':
        params['paCompanyAddress'] == null || params['paCompanyAddress'].isEmpty
            ? setState(() {
                parentValidator['paCompanyAddress'] = false;
              })
            : setState(() {
                parentValidator['paCompanyAddress'] = true;
              });
    }
  }

  returnValidator() {
    String msg = '';
    if (!parentValidator['paParentName']) {
      msg = '친권자 이름을 확인해주세요.';
    } else if (!parentValidator['paParentBirth']) {
      msg = '친권자 생년월일을 확인해주세요.';
    } else if (!parentValidator['paParentPhone']) {
      msg = '친권자 휴대폰 번호를 확인해주세요.';
    } else if (!parentValidator['paType']) {
      msg = '근로자와의 관계를 확인해주세요.';
    } else if (!parentValidator['paParentAddress']) {
      msg = '친권자 주소를 확인해주세요.';
    } else if (!parentValidator['paWorkerName'] &&
        !parentValidator['paWorkerBirth'] &&
        !parentValidator['paWorkerPhone'] &&
        !parentValidator['paWorkerAddress']) {
      msg = '';
    } else if (!parentValidator['paWorkerName']) {
      msg = '근로자 이름을 확인해주세요.';
    } else if (!parentValidator['paWorkerBirth']) {
      msg = '근로자 생년월일을 확인해주세요.';
    } else if (!parentValidator['paWorkerPhone']) {
      msg = '근로자 휴대폰 번호를 확인해주세요.';
    } else if (!parentValidator['paWorkerAddress']) {
      msg = '근로자 주소를 확인해주세요.';
    } else if (!parentValidator['paCompanyName'] &&
        !parentValidator['paCompanyPhone'] &&
        !parentValidator['paCompanyAddress']) {
      msg = '';
    }
    return msg;
  }

  initSet() {
    UserModel? userInfo = ref.watch(userProvider);
    setState(() {
      workerNameController.text = userInfo!.name;
      workerBirthController.text = ConvertService.convertDateISOtoString(
          userInfo.birth, ConvertService.YYYY_MM_DD);
      workerPhoneController.text =
          ConvertService.formatPhoneNumber(userInfo.phoneNumber);
      workerAddressController.text = userInfo.address;
      workerAddressDetailController.text = userInfo.addressDetail;
      params['paWorkerName'] = userInfo.name;
      params['paWorkerBirth'] = userInfo.birth.replaceAll('-', '');
      params['paWorkerPhone'] = userInfo.phoneNumber.replaceAll('-', '');
      params['paWorkerAddress'] = userInfo.address;
      params['paWorkerAddressDetail'] = userInfo.addressDetail;
    });

    formValidator('paWorkerName');
    formValidator('paWorkerBirth');
    formValidator('paWorkerPhone');
    formValidator('paWorkerAddress');
    formValidator('paWorkerAddressDetail');
  }

  final SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  sendParentAgree() async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .createDocument(widget.uuid, 'PARENT', params);

    if (apiUploadResult.type == 1) {
      await uploadSingImg();

      if (signFileMap.isNotEmpty) {
        await sendDocumentMsg(apiUploadResult.data);
      }
      setState(() {
        isRunning = false;
      });
    } else {
      showDefaultToast('서류 저장에 실패했습니다.');
      setState(() {
        isRunning = false;
      });
      return false;
    }
  }

  updateParentAgree(String msgKey, int caIdx) async {
    if (widget.chatUsers.isNotEmpty) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .updateChatMsgUuid(msgKey, caIdx);

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
        'consent',
        DateTime.now());

    await updateParentAgree(msgKey, caIdx);
  }

  showSignDialog() {
    showModalBottomSheet<void>(
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
                            sendParentAgree();
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

  late List<Widget> screenList;

  setData(key, value) {
    setState(() {
      params[key] = value;
    });

    formValidator(key);
  }

  void movePage(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      step = index;
    });
  }

  getPartnerCompanyInfo() async {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    UserModel? partnerInfo;
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .getPartnerUserData('recruiter', roomInfo!.partnerKey);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          partnerInfo = result.data;
        });

        if (partnerInfo != null) {
          setState(() {
            setData('paCompanyName', partnerInfo!.companyInfo!.name);
            companyNameController.text = partnerInfo!.companyInfo!.name;
            setData(
                'paCompanyPhone',
                partnerInfo!.companyInfo!.managerPhoneNumber
                    .replaceAll("-", ""));
            companyPhoneController.text = partnerInfo!
                .companyInfo!.managerPhoneNumber
                .replaceAll("-", "");
            companyAddressController.text =
                '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}' ==
                        ' '
                    ? ''
                    : '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}';
            setData(
                'paCompanyAddress',
                '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}' ==
                        ' '
                    ? ''
                    : '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}');
          });
        }
      }
    }
  }

  @override
  void initState() {
    Future(() {
      getPartnerCompanyInfo();
      initSet();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        rendered = true;
      });
    });

    super.initState();
  }

  Map<String, dynamic>? parentSelectedDropdown;
  List<Map<String, dynamic>> parentList = [
    {'name': '부', 'key': 1},
    {'name': '모', 'key': 2},
    {'name': '법정대리인', 'key': 3},
  ];

  showParentDialog() {
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
        return ContentBottomSheet(
          contents: [
            for (var i = 0; i < parentList.length; i++)
              BottomSheetButton(
                onTap: () {
                  setState(() {
                    parentSelectedDropdown = parentList[i];

                    setData('paType', parentList[i]['key']);
                  });
                  context.pop();
                },
                text: parentList[i]['name'],
                isRed: parentSelectedDropdown == parentList[i],
              ),
          ],
        );
      },
    );
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        parentAddressController.text = data.address;
        setData('paParentAddress', data.address);
      });
    }
  }

  showWorkerPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        workerAddressController.text = data.address;
        setData('paWorkerAddress', data.address);
      });
    }
  }

  returnStep2Validator() {
    if (!parentValidator['paWorkerName'] &&
        !parentValidator['paWorkerBirth'] &&
        !parentValidator['paWorkerPhone'] &&
        !parentValidator['paWorkerAddress']) {
      return '';
    } else if (!parentValidator['paWorkerName']) {
      return '근로자 이름을 확인해주세요.';
    } else if (!parentValidator['paWorkerBirth']) {
      return '근로자 생년월일을 확인해주세요.';
    } else if (!parentValidator['paWorkerPhone']) {
      return '근로자 휴대폰 번호를 확인해주세요.';
    } else if (!parentValidator['paWorkerAddress']) {
      return '근로자 주소를 확인해주세요.';
    } else {
      return '';
    }
  }

  bool isStep1Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'paType',
      'paParentName',
      'paParentBirth',
      'paParentPhone',
      'paParentAddress'
    ];

    for (String data in validateArr) {
      formValidator(data);
    }
    return validateArr.every((key) => validator[key] == true);
  }

  bool isStep2Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'paWorkerName',
      'paWorkerBirth',
      'paWorkerPhone',
      'paWorkerAddress',
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => validator[key] == true);
  }

  void onNextStep() {
    if (step == 1 && isStep1Valid(parentValidator)) {
      setState(() {
        step = 2;
      });
    } else if (step == 2 && isStep2Valid(parentValidator)) {
      setState(() {
        step = 3;
      });
    } else if (step == 3 && isAgree) {
      setState(() {
        showSignDialog();
      });
    }
  }

  bool isConfirmEnabled() {
    if (step == 1) {
      return isStep1Valid(parentValidator);
    } else if (step == 2) {
      return isStep2Valid(parentValidator);
    } else if (step == 3) {
      return isAgree;
    }
    return false;
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
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (MediaQuery.of(context).viewInsets.bottom > 0) {
            FocusManager.instance.primaryFocus?.unfocus();
          } else {
            if (!didPop) {
              if (step == 1) {
                context.pop();
              } else {
                movePage(step - 1);
              }
            }
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: const ModalAppbar(
            title: '친권 동의서 작성',
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.w),
                if (rendered)
                  Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 33,
                        child: Row(
                          children: [
                            for (var i = 0; i < 8; i++)
                              Expanded(
                                child: Container(
                                  width: CommonSize.vw,
                                  height: 1.w,
                                  color: i < 2 || i > 8 - 3
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
                              text: '친권자정보',
                              stepNumber: '1',
                              isComplete: step > 1,
                              isChecked: step == 1,
                              onTap: () {
                                if (isStep1Valid(parentValidator)) {
                                  movePage(1);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SignUpStepWidget(
                              text: '근로자정보',
                              stepNumber: '2',
                              isComplete: step > 2,
                              isChecked: step == 2,
                              onTap: () {
                                if (isStep2Valid(parentValidator)) {
                                  movePage(2);
                                }
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SignUpStepWidget(
                              text: '근로동의',
                              stepNumber: '3',
                              isComplete: step > 3,
                              isChecked: step == 3,
                              onTap: () {
                                if (step < 3) {
                                  movePage(3);
                                }
                              },
                            ),
                          ),
                          const Expanded(flex: 1, child: SizedBox()),
                        ],
                      ),
                    ],
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w, 0.w),
                  child: Column(
                    children: [
                      if (step == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '친권자 정보',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 16.w),
                            TextFormField(
                              controller: parentNameController,
                              maxLength: 50,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paParentName', parentNameController.text);
                              },
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '이름을 확인해주세요.',
                              ),
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              controller: parentBirthController,
                              maxLength: 10,
                              inputFormatters: [DateTextInputFormatter()],
                              keyboardType: TextInputType.number,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paParentBirth',
                                    parentBirthController.text
                                        .replaceAll('-', ''));
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
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              controller: parentPhoneController,
                              maxLength: 13,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                PhoneNumberTextInputFormatter()
                              ],
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paParentPhone',
                                    parentPhoneController.text
                                        .replaceAll('-', ''));
                              },
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '휴대폰 번호를 확인해주세요.',
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            SelectButton(
                                onTap: () {
                                  showParentDialog();
                                },
                                text: parentList.map((e) {
                                  if (e == parentSelectedDropdown) {
                                    return e['name'];
                                  } else {
                                    return '';
                                  }
                                }).join(),
                                hintText: '근로자와의 관계를 선택해주세요'),
                            SizedBox(
                              height: 36.w,
                            ),
                            Text(
                              '주소',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            GestureDetector(
                              onTap: showPost,
                              child: TextFormField(
                                enabled: false,
                                controller: parentAddressController,
                                maxLines: null,
                                autocorrect: false,
                                cursorColor: Colors.black,
                                style: commonInputText(),
                                decoration: commonInput(
                                  disable: true,
                                  hintText: '[주소 검색] 도로명 또는 지번 주소를 입력해 주세요.',
                                ),
                                readOnly: true,
                                onChanged: (value) {
                                  setData('paParentAddress',
                                      parentAddressController.text);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: parentAddressDetailController,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    style: commonInputText(),
                                    decoration: commonInput(
                                      hintText:
                                          '(선택) 층, 동, 호수 등 상세 주소를 입력해 주세요.',
                                    ),
                                    onChanged: (value) {
                                      setData('paParentAddress',
                                          parentAddressDetailController.text);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Text(
                              returnValidator(),
                              style: commonErrorAuth(),
                            )
                          ],
                        ),
                      if (step == 2)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '근로자 정보',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 16.w),
                            TextFormField(
                              controller: workerNameController,
                              maxLength: 50,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paWorkerName', workerNameController.text);
                              },
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '이름을 입력해주세요',
                              ),
                              textInputAction: TextInputAction.next,
                              onEditingComplete: () {
                                FocusScope.of(context).nextFocus();
                              },
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              controller: workerBirthController,
                              maxLength: 10,
                              inputFormatters: [DateTextInputFormatter()],
                              keyboardType: TextInputType.number,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paWorkerBirth',
                                    workerBirthController.text
                                        .replaceAll('-', ''));
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
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              inputFormatters: [
                                PhoneNumberTextInputFormatter()
                              ],
                              controller: workerPhoneController,
                              maxLength: 13,
                              keyboardType: TextInputType.phone,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              onChanged: (value) {
                                setData(
                                    'paWorkerPhone',
                                    workerPhoneController.text
                                        .replaceAll('-', ''));
                              },
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '휴대폰 번호를 입력해주세요',
                              ),
                            ),
                            SizedBox(
                              height: 36.w,
                            ),
                            Text(
                              '주소',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            GestureDetector(
                              onTap: showWorkerPost,
                              child: TextFormField(
                                enabled: false,
                                controller: workerAddressController,
                                maxLines: null,
                                autocorrect: false,
                                cursorColor: Colors.black,
                                readOnly: true,
                                style: commonInputText(),
                                decoration: commonInput(
                                    hintText: '[주소 검색] 도로명 또는 지번 주소를 입력해 주세요.',
                                    disable: true),
                                onChanged: (value) {
                                  setData('paWorkerAddress',
                                      workerAddressController.text);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: workerAddressDetailController,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    style: commonInputText(),
                                    decoration: commonInput(
                                      hintText:
                                          '(선택) 층, 동, 호수 등 상세 주소를 입력해 주세요.',
                                    ),
                                    onChanged: (value) {
                                      setData('paWorkerAddressDetail',
                                          workerAddressDetailController.text);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Text(
                              returnStep2Validator(),
                              style: commonErrorAuth(),
                            )
                          ],
                        ),
                      if (step == 3)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '사업장 정보',
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 16.w),
                            TextFormField(
                              enabled: false,
                              controller: companyNameController,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '회사명',
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              enabled: false,
                              controller: companyPhoneController,
                              keyboardType: TextInputType.phone,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              style: commonInputText(),
                              decoration: commonInput(
                                hintText: '회사 전화번호',
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            TextFormField(
                              enabled: false,
                              controller: companyAddressController,
                              maxLines: null,
                              autocorrect: false,
                              cursorColor: Colors.black,
                              style: commonInputText(),
                              decoration: commonInput(),
                            ),
                            SizedBox(
                              height: 40.w,
                            ),
                            Text(
                              '본인은 위 근로자 ${params['paWorkerName']}(이)가 위 사업장에서\n'
                              '근로를 하는것에 대하여 동의합니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CommonColors.gray66,
                                fontWeight: FontWeight.w500,
                                fontSize: 15.sp,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            Text(
                              DateFormat('yyyy년 MM월 dd일')
                                  .format(DateTime.now()),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CommonColors.gray80,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(
                              height: 24.w,
                            ),
                            Text(
                              '친권자 : ${params['paParentName']}',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: CommonColors.gray4d,
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(
                              height: 68.w,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isAgree = !isAgree;
                                });
                              },
                              child: ColoredBox(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    CircleCheck(
                                      onChanged: (value) {},
                                      readOnly: true,
                                      value: isAgree,
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Text(
                                      '(필수)',
                                      style: TextStyle(
                                        color: CommonColors.red,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        ' 내용에 이상이 없음을 확인하였습니다.',
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: CommonColors.gray80),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 12.w,
                          ),
                          CommonButton(
                            fontSize: 15,
                            onPressed: onNextStep,
                            confirm: isConfirmEnabled(),
                            text: step == 3 ? '제출하기' : '다음',
                          ),
                          SizedBox(
                            height: 12.w,
                          ),
                        ],
                      ),
                    ],
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
