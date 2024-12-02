import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/address_service.dart';
import 'package:chodan_flutter_app/features/auth/widgets/sign_up_step_widget.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_service.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_template.dart';
import 'package:chodan_flutter_app/features/contract/service/pdf_api.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/features/contract/widgets/document_radio.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/calednar_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/check_list_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/check_map_list_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_radio_button_text.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/input/TimeInput.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

class MinorContractDialogWidget extends ConsumerStatefulWidget {
  const MinorContractDialogWidget({
    super.key,
    required this.uuid,
    required this.chatUsers,
    this.msgKey,
    this.detailData,
  });

  final String uuid;
  final Map<String, dynamic> chatUsers;
  final String? msgKey;
  final dynamic detailData;

  @override
  ConsumerState<MinorContractDialogWidget> createState() =>
      _MinorContractDialogWidgetState();
}

class _MinorContractDialogWidgetState
    extends ConsumerState<MinorContractDialogWidget> with Files {
  bool isLoading = false;
  bool isConfirmLoading = false;
  int step = 1;
  Map<String, dynamic>? workSelectedDropdown;
  bool isAgree = false;
  File? pdfFile;
  DateTime? workStartDate;
  DateTime? workEndDate;
  String msgKey = '';
  Uint8List? signImgData;
  File? signImgFile;
  int linePop = 8;
  bool isRunning = false;

  NumberFormat formatter = NumberFormat('#,###');

  Map<String, dynamic> pdfFileMap = {};
  Map<String, dynamic> signFileMap = {};
  final ScrollController _scrollController = ScrollController();
  TextEditingController workSpaceController = TextEditingController();
  TextEditingController jobDesController = TextEditingController();
  TextEditingController salaryController = TextEditingController();
  TextEditingController bonusController = TextEditingController();
  List<TextEditingController> etcNameControllerList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  List<TextEditingController> etcAmountControllerList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  TextEditingController paymentCycleController = TextEditingController();
  TextEditingController employeeNameController = TextEditingController();
  TextEditingController employeeContactController = TextEditingController();
  TextEditingController employeeAddressController = TextEditingController();
  TextEditingController employeeAddressDetailController =
      TextEditingController();

  TextEditingController restHourTextController =
      TextEditingController();

  Map<String, dynamic> params = {
    'ccdWorkStartDate': '',
    'ccdWorkEndDate': '',
    'ccdWorkplace': '',
    'ccdJobDescription': '',
    'ccdWorkingDays': 0,
    "ccdWorkingStartTime": '',
    "ccdWorkingEndTime": '',
    "ccdRestHour": 0,
    'holidayLists': [],
    'ccdSalaryType': 'HOUR',
    'ccdSalaryAmount': 0,
    'ccdBonusExist': 0,
    'ccdBonusAmount': 0,
    'ccdPaymentMethodType': 'ACCOUNT',
    'ccdPaymentCycleType': 'EVERY',
    'ccdPaymentCycleMonth': 0,
    'ccdPaymentMethodOther': 0,
    'otherSalaryClassList': [],
    'ccdEmploymentInsuranceStatus': 0, //고용보험
    'ccdWorkersCompensationStatus': 0, //산재보험
    'ccdNationalPensionStatus': 0, //국민연금
    'ccdHealthInsuranceStatus': 0, //건강보험
    'ccdEmployeeName': '',
    'ccdEmployeeContact': '',
    'ccdEmployeeAddress': '',
    'adSi': '',
    'adGu': '',
    'adDong': '',
    'ccdEmployeeAddressDetail': '',
    'ccdFamilyRelationCertificate': 0,
    'ccdParentalConsent': 0,
  };

  Map<String, dynamic> contractValidator = {
    'workDate': false,
    'workEndDate': false,
    'workPlace': false,
    'jobDescription': false,
    'workingDays': false,
    "workingTime": false,
    "breakTime": true,
    'salaryAmount': false,
    'bonusAmount': true,
    'paymentCycleMonth': true,
    'otherSalary': true,
    'insurance': false,
    'employeeName': true,
    'employeeContact': true,
    'employeeAddress': true,
    'employeeAddressDetail': true,
    'document': false,
  };

  final SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  void requestStoragePermission() async {
    if (Platform.isIOS) {
      createPdf();
      return;
    } else if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        openAppSettings();
      }
      if (status.isGranted) {
        createPdf();
      } else {
        showDefaultToast(localization.permissionRequired);
      }
    }
  }

  createPdf() async {
    var user = ref.watch(userProvider);

    final pdfFirstColumn = await ContractTemplate.returnNormalFistContract(
        params, user, signImgData!, null, false, 'YOUNG', null);


    String today = DateFormat('yyyyMMdd').format(DateTime.now());

    String documentTitle = '${localization.minorEmployeeContract}_${params['ccdEmployeeName']}_${user!.companyInfo!.name}_$today';

    final tempFile =
    await PdfApi.generateNormal(documentTitle, pdfFirstColumn);

    setState(() {
      pdfFile = tempFile;
    });

    if (widget.msgKey != null) {
      await updateContract();
    } else {
      await sendContract();
    }
    setState(() {
      isConfirmLoading = false;
    });
  }

  sendContract() async {
    if (widget.chatUsers.isNotEmpty && pdfFile != null) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .createContract(widget.uuid, 'YOUNG', params, 1);
      setState(() {
        isRunning = false;
      });

      if (apiUploadResult.type == 1) {
        await uploadSingImg();
        await uploadPdfFile(apiUploadResult.data);

        if (pdfFileMap.isNotEmpty && signFileMap.isNotEmpty) {
          await sendDocumentMsg(apiUploadResult.data);
        }
      } else {
        showDefaultToast(localization.documentSaveFailed);
        return false;
      }
    } else {
      showDefaultToast(localization.invalidUserInfo);
    }
  }

  updateContract() async {
    if (widget.chatUsers.isNotEmpty && pdfFile != null) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .createContract(widget.uuid, 'YOUNG', params, 2);
      setState(() {
        isRunning = false;
      });

      if (apiUploadResult.type == 1) {
        await uploadSingImg();
        await uploadPdfFile(apiUploadResult.data);

        if (pdfFileMap.isNotEmpty && signFileMap.isNotEmpty) {
          await sendUpdateDocumentMsg(apiUploadResult.data);
        }
      } else {
        showDefaultToast(localization.documentEditFailed);
        return false;
      }
    } else {
      showDefaultToast(localization.invalidUserInfo);
    }
  }

  updateStatusContract(String msgKey, int caIdx) async {
    if (widget.chatUsers.isNotEmpty && pdfFile != null) {
      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .updateChatMsgUuid(msgKey, caIdx);

      if (apiUploadResult.type == 1) {
        showDefaultToast(
            widget.msgKey != null ? localization.documentEditSuccess : localization.documentRegisterSuccess);
        context.pop();
        context.pop();
      } else {
        showDefaultToast(
            widget.msgKey != null ? localization.documentEditFailed : localization.documentRegisterFailed);
        return false;
      }
    } else {
      showDefaultToast(localization.invalidUserInfo);
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
      showDefaultToast(localization.signatureImageUploadFailed);
    }
  }

  uploadPdfFile(int key) async {
    var result = await fileInfoUploadS3(pdfFile, 'ATTACHMENT_DOCUMENT', key);

    if (result != null && result != false) {
      setState(() {
        pdfFileMap = result;
      });
    } else {
      showDefaultToast(localization.fileUploadFailed);
    }
  }

  sendUpdateDocumentMsg(int caIdx) async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);

    List<Map<String, dynamic>> fileList = [pdfFileMap, signFileMap];

    var msgKey = await ref.read(chatControllerProvider.notifier).updateDocument(
        widget.uuid,
        chatUser!,
        widget.chatUsers,
        partnerStatus,
        fileList,
        'minorContractUpdate',
        widget.detailData.created,
        widget.msgKey!);

    String createTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(widget.detailData.created));
    String chatValue = localization.urgentMinorEmployeeContractModification(createTime);

    await ref.read(chatControllerProvider.notifier).newMessage(
        widget.uuid, chatValue, chatUser, widget.chatUsers, partnerStatus);
    await updateStatusContract(msgKey, caIdx);
  }

  sendDocumentMsg(int caIdx) async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);

    List<Map<String, dynamic>> fileList = [pdfFileMap, signFileMap];

    var msgKey = await ref.read(chatControllerProvider.notifier).newDocument(
        widget.uuid,
        chatUser!,
        widget.chatUsers,
        partnerStatus,
        fileList,
        'minorContractCreate',
        DateTime.now());

    await updateStatusContract(msgKey, caIdx);
  }

  formValidator(String type) {
    switch (type) {
      case 'workDate':
        params['ccdWorkStartDate'] == null || params['ccdWorkStartDate'] == ''
            ? setState(() {
                contractValidator['workDate'] = false;
              })
            : setState(() {
                contractValidator['workDate'] = true;
              });
        if (params['ccdWorkStartDate'] != '' &&
            params['ccdWorkEndDate'] != '') {
          DateTime startDate = DateTime.parse(params['ccdWorkStartDate']);
          DateTime endDate = DateTime.parse(params['ccdWorkEndDate']);
          setState(() {
            contractValidator['workEndDate'] = endDate.isAfter(startDate);
          });
        }
      case 'workEndDate':
        if (params['ccdWorkEndDate'] == '') {
          setState(() {
            contractValidator['workEndDate'] = true;
          });
        } else if (params['ccdWorkStartDate'] != '') {
          DateTime startDate = DateTime.parse(params['ccdWorkStartDate']);
          DateTime endDate = DateTime.parse(params['ccdWorkEndDate']);
          setState(() {
            contractValidator['workEndDate'] = endDate.isAfter(startDate);
          });
        } else {
          setState(() {
            contractValidator['workEndDate'] = false;
          });
        }
      case 'workPlace':
        params['ccdWorkplace'] == null || params['ccdWorkplace'].isEmpty
            ? setState(() {
                contractValidator['workPlace'] = false;
              })
            : setState(() {
                contractValidator['workPlace'] = true;
              });
      case 'jobDescription':
        params['ccdJobDescription'] == null ||
                params['ccdJobDescription'].isEmpty
            ? setState(() {
                contractValidator['jobDescription'] = false;
              })
            : setState(() {
                contractValidator['jobDescription'] = true;
              });
      case 'workingDays':
        params['ccdWorkingDays'] == 0
            ? setState(() {
                contractValidator['workingDays'] = false;
              })
            : setState(() {
                contractValidator['workingDays'] = true;
              });
      case 'workingTime':
        params['ccdWorkingStartTime'] == '' || params['ccdWorkingEndTime'] == ''
            ? setState(() {
                contractValidator['workingTime'] = false;
              })
            : setState(() {
                contractValidator['workingTime'] = true;
              });
      case 'breakTime':
        params['ccdRestHour'] == 0
            ? setState(() {
                contractValidator['breakTime'] = false;
              })
            : setState(() {
                contractValidator['breakTime'] = true;
              });
      case 'salaryAmount':
        params['ccdSalaryAmount'] == null || params['ccdSalaryAmount'] == 0
            ? setState(() {
                contractValidator['salaryAmount'] = false;
              })
            : setState(() {
                contractValidator['salaryAmount'] = true;
              });
      case 'bonusAmount':
        if (params['ccdBonusExist'] == 1) {
          params['ccdBonusAmount'] == null || params['ccdBonusAmount'] == 0
              ? setState(() {
                  contractValidator['bonusAmount'] = false;
                })
              : setState(() {
                  contractValidator['bonusAmount'] = true;
                });
        } else {
          setState(() {
            contractValidator['bonusAmount'] = true;
          });
        }
      case 'paymentCycleMonth':
        if (params['ccdPaymentCycleType'] == 'MONTH') {
          if (params['ccdPaymentCycleMonth'] == null ||
              params['ccdPaymentCycleMonth'] == 0) {
            setState(() {
              contractValidator['paymentCycleMonth'] = false;
            });
          } else {
            int paymentCycleMonth = 0;
            paymentCycleMonth = params['ccdPaymentCycleMonth'].isNotEmpty
                ? int.parse(params['ccdPaymentCycleMonth'])
                : 0;
            if (paymentCycleMonth > 0 && paymentCycleMonth < 32) {
              setState(() {
                contractValidator['paymentCycleMonth'] = true;
              });
            } else {
              setState(() {
                contractValidator['paymentCycleMonth'] = false;
              });
            }
          }
        } else {
          setState(() {
            contractValidator['paymentCycleMonth'] = true;
          });
        }

      case 'otherSalary':
        if (params['ccdPaymentMethodOther'] == 1) {
          for (var data in params['otherSalaryClassList']) {
            data['osName'].isEmpty || data['osName'] == 0
                ? setState(() {
                    contractValidator['otherSalary'] = false;
                    return;
                  })
                : setState(() {
                    contractValidator['otherSalary'] = true;
                  });
          }
        } else {
          setState(() {
            contractValidator['otherSalary'] = true;
          });
        }
      case 'insurance':
        params['ccdEmploymentInsuranceStatus'] == 0 &&
                params['ccdWorkersCompensationStatus'] == 0 &&
                params['ccdNationalPensionStatus'] == 0 &&
                params['ccdHealthInsuranceStatus'] == 0
            ? setState(() {
                contractValidator['insurance'] = false;
              })
            : setState(() {
                contractValidator['insurance'] = true;
              });
      case 'document':
        params['ccdFamilyRelationCertificate'] == 0 &&
                params['ccdParentalConsent'] == 0
            ? setState(() {
                contractValidator['document'] = false;
              })
            : setState(() {
                contractValidator['document'] = true;
              });
      case 'employeeName':
        params['ccdEmployeeName'] == null || params['ccdEmployeeName'].isEmpty
            ? setState(() {
                contractValidator['employeeName'] = false;
              })
            : setState(() {
                contractValidator['employeeName'] = true;
              });
      case 'employeeContact':
        params['ccdEmployeeContact'] == null ||
                params['ccdEmployeeContact'].isEmpty ||
                (ContractValidator.validateTelephoneNumber(
                            params['ccdEmployeeContact']) ==
                        false &&
                    ContractValidator.validatePhoneNumber(
                            params['ccdEmployeeContact']) ==
                        false)
            ? setState(() {
                contractValidator['employeeContact'] = false;
              })
            : setState(() {
                contractValidator['employeeContact'] = true;
              });
      case 'employeeAddress':
        params['ccdEmployeeAddress'] == null ||
                params['ccdEmployeeAddress'].isEmpty
            ? setState(() {
                contractValidator['employeeAddress'] = false;
              })
            : setState(() {
                contractValidator['employeeAddress'] = true;
              });
      case 'employeeAddressDetail':
        params['ccdEmployeeAddressDetail'] == null ||
                params['ccdEmployeeAddressDetail'].isEmpty
            ? setState(() {
                contractValidator['employeeAddressDetail'] = false;
              })
            : setState(() {
                contractValidator['employeeAddressDetail'] = true;
              });
    }
  }

  showStartWorkTime(BuildContext context) {
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
        return CheckListBottomSheet(
          checkList: ContractService.workTimeList,
          selected: 1,
          title: localization.startTime,
          returnData: params['ccdWorkingStartTime'],
          setData: setValue,
          bottomType: 'ccdWorkingStartTime',
        );
      },
    );
  }

  showEndWorkTime(BuildContext context) {
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
        return CheckListBottomSheet(
          checkList: ContractService.workTimeList,
          selected: 1,
          title: localization.endTime,
          returnData: params['ccdWorkingEndTime'],
          setData: setValue,
          bottomType: 'ccdWorkingEndTime',
        );
      },
    );
  }

  showWorkDate(BuildContext context) {
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
          checkList: ContractService.workDropdownList,
          selected: 1,
          title: localization.workDays,
          returnData: workSelectedDropdown,
          setData: setWorkDays,
          keyName: 'day',
        );
      },
    );
  }

  setWorkDays(dynamic value) {
    setState(() {
      workSelectedDropdown = value;
      params['ccdWorkingDays'] = value['key'];
    });
  }

  setValue(String type, dynamic value) {
    setState(() {
      params[type] = value;
    });
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
                TitleBottomSheet(title: localization.contractCreationCompleted),
                SizedBox(height: 12.w),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20.w, 0, 20.w, CommonSize.commonBottom),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localization.signatureWriteInFullName,
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
                                  localization.clearSignature,
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
                                  if (isRunning || isConfirmLoading) {
                                    return;
                                  }
                                  setState(() {
                                    isRunning = true;
                                    isConfirmLoading = true;
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
                                    context.pop();
                                    createPdf();
                                  }
                                },
                                text: localization.submitAfterSignature,
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

  // Uint8List를 File로 변환하는 함수
  File uint8ListToFile(Uint8List data, String filePath) {
    File file = File(filePath);
    file.writeAsBytesSync(data);
    return file;
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        employeeAddressController.text = data.roadAddress;
        params['ccdEmployeeAddress'] = employeeAddressController.text;

        int siIndex = AddressService.siNameDefine
            .indexWhere((el) => el['daumName'] == data.sido);
        if (siIndex > -1) {
          params['adSi'] = AddressService.siNameDefine[siIndex]['dbName'];
        } else {
          params['adSi'] = data.sido;
        }
        params['adGu'] = data.sigungu;
        params['adDong'] = data.bname;
      });
    }
  }

  convertTime(String timeString) {
    // 시간 문자열을 DateTime 객체로 파싱
    DateTime parsedTime = DateFormat('HH:mm:ss').parse(timeString);

    // DateTime 객체를 다시 문자열로 포맷
    String formattedTime = DateFormat('HH:mm').format(parsedTime);

    return formattedTime;
  }

  setInitValue() {
    setState(() {
      isLoading = true;
    });
    var detailData = ref.watch(contractDetailProvider)!.contractDetailDto;

    setState(() {
      params = {
        'ccdWorkStartDate': detailData.ccdWorkStartDate,
        'ccdWorkEndDate': detailData.ccdWorkEndDate,
        'ccdWorkplace': detailData.ccdWorkplace,
        'ccdJobDescription': detailData.ccdJobDescription,
        'ccdWorkingDays': detailData.ccdWorkingDays,
        "ccdWorkingStartTime": convertTime(detailData.ccdWorkingStartTime),
        "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
            ? ''
            : convertTime(detailData.ccdWorkingEndTime),
        "ccdRestHour": detailData.ccdRestHour,
        'ccdSalaryType': detailData.ccdSalaryType,
        'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
        'ccdBonusExist': detailData.ccdBonusExist,
        'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
        'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
        'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
        'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
        'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
        'otherSalaryClassList': detailData.otherSalaryDto,
        'ccdEmploymentInsuranceStatus': detailData.ccdEmploymentInsuranceStatus,
        //고용보험
        'ccdWorkersCompensationStatus': detailData.ccdWorkersCompensationStatus,
        //산재보험
        'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
        //국민연금
        'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
        //건강보험
        'ccdEmployeeName': detailData.ccdEmployeeName,
        'ccdEmployeeContact': detailData.ccdEmployeeContact,
        'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
        'adSi': '',
        'adGu': '',
        'adDong': '',
        'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
        'ccdFamilyRelationCertificate': detailData.ccdFamilyRelationCertificate,
        'ccdParentalConsent': detailData.ccdParentalConsent,
      };

      List tempHoliday = [];

      for (var data in detailData.holidayDto) {
        tempHoliday.add(data['hmDayOfWeek']);
      }

      params['holidayLists'] = tempHoliday;

      workSpaceController.text = params['ccdWorkplace'];
      jobDesController.text = params['ccdJobDescription'];
      salaryController.text = formatter.format(params['ccdSalaryAmount']);
      bonusController.text = formatter.format(params['ccdBonusAmount']);
      paymentCycleController.text = params['ccdPaymentCycleMonth'].toString();
      employeeNameController.text = params['ccdEmployeeName'];
      employeeContactController.text = params['ccdEmployeeContact'];
      employeeAddressController.text = params['ccdEmployeeAddress'];
      employeeAddressDetailController.text = params['ccdEmployeeAddressDetail'];
      restHourTextController.text = params['ccdRestHour'].toString();

      for (var data in ContractService.workDropdownList) {
        if (data['key'] == params['ccdWorkingDays']) {
          workSelectedDropdown = data;
        }
      }

      for (int i = 0; i < params['otherSalaryClassList'].length; i++) {
        etcNameControllerList[i].text =
            params['otherSalaryClassList'][i]['osName'];
      }

      for (int i = 0; i < params['otherSalaryClassList'].length; i++) {
        etcAmountControllerList[i].text =
            formatter.format(params['otherSalaryClassList'][i]['osAmount']);
      }
    });

    setState(() {
      isLoading = false;
    });
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
            employeeNameController.text = userInfo!.name;
            employeeContactController.text = ConvertService.formatPhoneNumber(userInfo.phoneNumber);
            employeeAddressController.text = userInfo.address;
            employeeAddressDetailController.text = userInfo.addressDetail;
            params['ccdEmployeeName'] = userInfo.name;
            params['ccdEmployeeContact'] = userInfo.phoneNumber.replaceAll('-', '');
            params['ccdEmployeeAddress'] = userInfo.address;
            params['ccdEmployeeAddressDetail'] = userInfo.addressDetail;
          });
        });
      }
    }
  }

  @override
  void initState() {
    Future(() {
      getEmployeeInfo();
      if (widget.msgKey != null) {
        setInitValue();
      }
    });

    super.initState();
  }

  calendarOpen(type) {
    if (type == 'start') {
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
          return CalendarBottomSheet(
              disableAfterDay: workEndDate,
              selectedDay: workStartDate,
              title: localization.workStartDateChioce,
              setSelectDate: (value) {
                setState(() {
                  workStartDate = value;
                  params['ccdWorkStartDate'] =
                      DateFormat('yyyy-MM-dd').format(value);
                });
              });
        },
      );
    } else {
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
          return CalendarBottomSheet(
              title: localization.workEndDateChioce,
              selectedDay: workEndDate,
              disablePreDay: workStartDate,
              setSelectDate: (value) {
                setState(() {
                  workEndDate = value;
                  params['ccdWorkEndDate'] =
                      DateFormat('yyyy-MM-dd').format(value);
                });
              });
        },
      );
    }
  }

  bool isStep1Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'workDate',
      'workPlace',
      'jobDescription',
      'workingDays',
      'workingTime'
    ];

    for (String data in validateArr) {
      formValidator(data);
    }
    return validateArr.every((key) => validator[key] == true);
  }

  bool isStep2Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'salaryAmount',
      'bonusAmount',
      'paymentCycleMonth',
      'otherSalary',
      'insurance',
      'document'
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => validator[key] == true);
  }

  bool isStep3Valid(Map<String, dynamic> validator) {
    List<String> validateArr = [
      'employeeName',
      'employeeContact',
      'employeeAddress'
    ];

    for (String data in validateArr) {
      formValidator(data);
    }

    return validateArr.every((key) => validator[key] == true) && isAgree;
  }

  void onNextStep() {
    if (step == 1 && isStep1Valid(contractValidator)) {
      setState(() {
        step = 2;
        _scrollController.jumpTo(0);
      });
    } else if (step == 2 && isStep2Valid(contractValidator)) {
      setState(() {
        step = 3;
        _scrollController.jumpTo(0);
      });
    } else if (step == 3 && isStep3Valid(contractValidator)) {
      setState(() {
        showSignDialog();
      });
    }
  }

  bool isConfirmEnabled() {
    if (step == 1) {
      return isStep1Valid(contractValidator);
    } else if (step == 2) {
      return isStep2Valid(contractValidator);
    } else if (step == 3) {
      return isStep3Valid(contractValidator);
    }
    return false;
  }

  @override
  void dispose() {
    workSpaceController.dispose();
    jobDesController.dispose();
    salaryController.dispose();
    bonusController.dispose();
    paymentCycleController.dispose();
    employeeNameController.dispose();
    employeeContactController.dispose();
    employeeAddressController.dispose();
    employeeAddressDetailController.dispose();
    restHourTextController.dispose();

    for (var controller in etcNameControllerList) {
      controller.dispose();
    }
    for (var controller in etcAmountControllerList) {
      controller.dispose();
    }

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (!isConfirmLoading) {
                if (step == 1) {
                  if (!didPop) {
                    context.pop();
                  }
                } else {
                  setState(() {
                    step -= 1;
                    _scrollController.jumpTo(0);
                  });
                }
              }
            },
            child: Scaffold(
              appBar: ModalAppbar(
                title:
                    widget.msgKey != null ? localization.minorEmployeeContractEdit : localization.minorEmployeeContractCreate,
              ),
              body: Column(
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
                                      : i < (step!.toInt()) * 2
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
                              text: localization.workInformation,
                              stepNumber: '1',
                              isComplete: step > 1,
                              isChecked: step == 1,
                              onTap: () {
                                if (isStep1Valid(contractValidator)) {
                                  setState(() {
                                    _scrollController.jumpTo(0);
                                    step = 1;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SignUpStepWidget(
                              text: localization.salaryInformation,
                              stepNumber: '2',
                              isComplete: step > 2,
                              isChecked: step == 2,
                              onTap: () {
                                if (isStep2Valid(contractValidator)) {
                                  setState(() {
                                    _scrollController.jumpTo(0);
                                    step = 2;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SignUpStepWidget(
                              text: localization.others,
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
                      controller: _scrollController,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w,
                            100.w + CommonSize.commonBoard(context)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (step == 1)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    localization.workInformation,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SelectButton(
                                          isDate: true,
                                          onTap: () async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            calendarOpen('start');
                                          },
                                          text: params['ccdWorkStartDate'] != ''
                                              ? params['ccdWorkStartDate']
                                                  .toString()
                                              : '',
                                          hintText:
                                              params['ccdWorkStartDate'] == ''
                                                  ? localization.workStartDate
                                                  : '',
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      const Text('~'),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: SelectButton(
                                          isDate: true,
                                          onTap: () async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            calendarOpen('end');
                                          },
                                          text: params['ccdWorkEndDate'] != ''
                                              ? params['ccdWorkEndDate']
                                                  .toString()
                                              : '',
                                          hintText:
                                              params['ccdWorkEndDate'] == ''
                                                  ? localization.workEndDate
                                                  : '',
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (params['ccdWorkEndDate'].isNotEmpty)
                                    Column(
                                      children: [
                                        SizedBox(height: 4.w),
                                        GestureDetector(
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            setState(() {
                                              params['ccdWorkEndDate'] = '';
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                                color: CommonColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6.w),
                                                border: Border.all(
                                                    width: 1.w,
                                                    color:
                                                        CommonColors.grayF2)),
                                            child: Center(
                                              child: Text(
                                                localization.resetEndOfContractDate,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.grayB2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.w),
                                      ],
                                    ),
                                  if (!contractValidator['workDate'])
                                    Text(
                                      '* ${localization.checkWorkStartDate}',
                                      style: commonErrorAuth(),
                                    ),
                                  Text(
                                    localization.checkWorkStartDateOnly,
                                    style: commonErrorAuth(),
                                  ),
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: workSpaceController,
                                    maxLength: 50,
                                    maxLines: 1,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['ccdWorkplace'] =
                                            workSpaceController.text;
                                      });
                                    },
                                    style: TextStyle(fontSize: 12.w),
                                    decoration: suffixInput(
                                      hintText: localization.checkWorkPlace,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () {
                                      FocusScope.of(context).nextFocus();
                                    },
                                  ),
                                  if (!contractValidator['workPlace'])
                                    Text(
                                      '* ${localization.checkWorkPlace}',
                                      style: commonErrorAuth(),
                                    ),
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    controller: jobDesController,
                                    maxLength: 50,
                                    maxLines: 1,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    onChanged: (value) {
                                      setState(() {
                                        params['ccdJobDescription'] =
                                            jobDesController.text;
                                      });
                                    },
                                    style: TextStyle(fontSize: 12.w),
                                    decoration: suffixInput(
                                      hintText: localization.checkJobContent,
                                    ),
                                  ),
                                  if (!contractValidator['jobDescription'])
                                    Text(
                                      '* ${localization.checkJobContent}',
                                      style: commonErrorAuth(),
                                    ),
                                  SizedBox(height: 20.w),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.workSchedule,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  SelectButton(
                                    hintText: localization.workDaysSelect,
                                    text: workSelectedDropdown != null
                                        ? workSelectedDropdown!['day']
                                        : '',
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      showWorkDate(context);
                                    },
                                  ),
                                  SizedBox(height: 8.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TimeInput(
                                              titleHint : localization.workStartTime,
                                              setFunc: (value) {
                                                params['ccdWorkingStartTime'] =
                                                    value;
                                              },
                                              initTime:
                                                  params['ccdWorkingStartTime'],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                8.w, 0, 8.w, 0),
                                            child: Text(
                                              '~',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: TimeInput(
                                              titleHint : localization.workEndTime,
                                              setFunc: (value) {
                                                params['ccdWorkingEndTime'] =
                                                    value;
                                              },
                                              initTime:
                                                  params['ccdWorkingEndTime'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.w),
                                  Text(
                                    '※ ${localization.timeIn24HourFormat}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.sp,
                                      color: CommonColors.grayB2,
                                    ),
                                  ),
                                  SizedBox(height: 8.w),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: TextFormField(
                                            controller: restHourTextController,
                                            key: const Key('jobposting_restHour'),
                                            keyboardType: TextInputType.number,
                                            autocorrect: false,
                                            cursorColor: CommonColors.black,
                                            style: commonInputText(),
                                            maxLength: 3,
                                            textAlign: TextAlign.center,
                                            onTapOutside: (value) {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                            },
                                            decoration: commonInput(
                                              hintText: localization.breakTime,
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                params['ccdRestHour'] =
                                                    int.parse(value);
                                              });
                                            },
                                            inputFormatters: [
                                              CurrencyTextInputFormatter.currency(
                                                  locale: 'ko', decimalDigits: 0, symbol: ''),
                                            ],
                                            minLines: 1,
                                            maxLines: 1,
                                            textInputAction: TextInputAction.next,
                                            onEditingComplete: () {
                                              FocusScope.of(context).nextFocus();
                                            },
                                          )),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      Text(localization.breakTimeMinutesProvided,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                            color: CommonColors.grayB2,
                                          )),
                                    ],
                                  ),
                                  if (!contractValidator['workingDays'])
                                    Padding(
                                      padding: EdgeInsets.only(top: 4.w),
                                      child: Text(
                                        '* ${localization.workScheduleSelect}',
                                        style: commonErrorAuth(),
                                      ),
                                    ),
                                  SizedBox(height: 20.w),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.holidayOptional,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      for (var data in ContractService.restList)
                                        GestureDetector(
                                          onTap: params['ccdWorkingDays'] == 0
                                              ? null
                                              : () {
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                  setState(() {
                                                    if (params['holidayLists']
                                                        .contains(
                                                            data['key'])) {
                                                      params['holidayLists']
                                                          .remove(data['key']);
                                                    } else {
                                                      if (params['holidayLists']
                                                              .length <
                                                          (7 -
                                                              params[
                                                                  'ccdWorkingDays'])) {
                                                        params['holidayLists']
                                                            .add(data['key']);
                                                      }
                                                    }
                                                  });
                                                },
                                          child: Container(
                                            width: 38.w,
                                            height: 48.w,
                                            decoration: BoxDecoration(
                                                color: params['holidayLists'].contains(
                                                            data['key']) ||
                                                        params['holidayLists'].contains(
                                                            {'hmDayOfWeek': data['key']})
                                                    ? CommonColors.red02
                                                    : CommonColors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6.w),
                                                border: Border.all(
                                                    width: params['holidayLists'].contains(
                                                                data['key']) ||
                                                            params['holidayLists']
                                                                .contains({'hmDayOfWeek': data['key']})
                                                        ? 0
                                                        : 1.w,
                                                    color: CommonColors.grayF2)),
                                            child: Center(
                                              child: Text(
                                                data['weekday'],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: params['holidayLists']
                                                              .contains(data[
                                                                  'key']) ||
                                                          params['holidayLists']
                                                              .contains({
                                                            'hmDayOfWeek':
                                                                data['key']
                                                          })
                                                      ? CommonColors.red
                                                      : CommonColors.grayB2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (!contractValidator['breakTime'])
                                    Text(
                                      '* ${localization.checkBreakTimeAgain}',
                                      style: TextStyles.error,
                                    ),
                                ],
                              ),
                            if (step == 2)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    localization.salary,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdSalaryType'] = 'HOUR';
                                            });
                                          },
                                          groupValue: params['ccdSalaryType'],
                                          value: 'HOUR',
                                          label: localization.hourlyRate,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdSalaryType'] = 'DAY';
                                            });
                                          },
                                          groupValue: params['ccdSalaryType'],
                                          value: 'DAY',
                                          label: localization.dailyRate,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdSalaryType'] = 'MONTH';
                                            });
                                          },
                                          groupValue: params['ccdSalaryType'],
                                          value: 'MONTH',
                                          label: localization.monthlySalary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.w),
                                  TextFormField(
                                    controller: salaryController,
                                    maxLength: 11,
                                    keyboardType: TextInputType.number,
                                    maxLines: null,
                                    autocorrect: false,
                                    cursorColor: Colors.black,
                                    textAlign: TextAlign.end,
                                    onChanged: (value) {
                                      params['ccdSalaryAmount'] =
                                          ConvertService.convertStringToInt(
                                              ConvertService.removeAllComma(
                                                  salaryController.text));
                                    },
                                    style: commonInputText(),
                                    inputFormatters: [
                                      CurrencyTextInputFormatter.currency(
                                          locale: 'ko',
                                          decimalDigits: 0,
                                          symbol: ''),
                                    ],
                                    decoration: suffixInput(
                                        suffixText: localization.won,
                                        suffixSize: 14.sp,
                                        suffixColor: CommonColors.black2b),
                                  ),
                                  if (!contractValidator['salaryAmount'])
                                    Text(
                                      '* ${localization.salaryConfirm}',
                                      style: commonErrorAuth(),
                                    ),
                                  SizedBox(height: 20.w),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.bonus,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdBonusExist'] = 0;
                                              contractValidator['bonusAmount'] =
                                                  true;
                                            });
                                          },
                                          groupValue: params['ccdBonusExist'],
                                          value: 0,
                                          label: localization.bonusNotIncluded,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdBonusExist'] = 1;
                                              contractValidator['bonusAmount'] =
                                                  false;
                                            });
                                          },
                                          groupValue: params['ccdBonusExist'],
                                          value: 1,
                                          label: localization.bonusIncluded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (params['ccdBonusExist'] == 1)
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 20.w, 0, 0),
                                      child: TextFormField(
                                        controller: bonusController,
                                        maxLength: 11,
                                        keyboardType: TextInputType.number,
                                        maxLines: null,
                                        autocorrect: false,
                                        cursorColor: Colors.black,
                                        textAlign: TextAlign.end,
                                        onChanged: (value) {
                                          params['ccdBonusAmount'] =
                                              ConvertService.convertStringToInt(
                                                  ConvertService.removeAllComma(
                                                      bonusController.text));
                                        },
                                        style: commonInputText(),
                                        inputFormatters: [
                                          CurrencyTextInputFormatter.currency(
                                              locale: 'ko',
                                              decimalDigits: 0,
                                              symbol: ''),
                                        ],
                                        decoration: suffixInput(
                                            suffixText: localization.won,
                                            suffixSize: 14.sp,
                                            suffixColor: CommonColors.black2b),
                                      ),
                                    ),
                                  SizedBox(height: 20.w),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.otherBenefits,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentMethodOther'] =
                                                  0;
                                              contractValidator['otherSalary'] =
                                                  true;
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentMethodOther'],
                                          value: 0,
                                          label: localization.otherBenefitsNotIncluded,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentMethodOther'] =
                                                  1;
                                              contractValidator['otherSalary'] =
                                                  false;
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentMethodOther'],
                                          value: 1,
                                          label: localization.otherBenefitsIncluded,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.w),
                                  if (params['ccdPaymentMethodOther'] == 1)
                                    Column(
                                      children: [
                                        for (int i = 0;
                                            i <
                                                params['otherSalaryClassList']
                                                    .length;
                                            i++)
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 48,
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 120.w,
                                                      child: TextFormField(
                                                        controller:
                                                            etcNameControllerList[
                                                                i],
                                                        maxLength: 20,
                                                        keyboardType:
                                                            TextInputType.text,
                                                        maxLines: null,
                                                        autocorrect: false,
                                                        cursorColor:
                                                            Colors.black,
                                                        onChanged: (value) {
                                                          params['otherSalaryClassList']
                                                                      [i]
                                                                  ['osName'] =
                                                              etcNameControllerList[
                                                                      i]
                                                                  .text;
                                                        },
                                                        style:
                                                            commonInputText(),
                                                        decoration: commonInput(
                                                            hintText: localization.fieldNameInput),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            etcAmountControllerList[
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
                                                          params['otherSalaryClassList']
                                                                      [i]
                                                                  ['osAmount'] =
                                                              ConvertService.convertStringToInt(
                                                                  ConvertService.removeAllComma(
                                                                      etcAmountControllerList[
                                                                              i]
                                                                          .text));
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
                                                            suffixText: localization.won,
                                                            suffixSize: 14.sp,
                                                            suffixColor:
                                                                CommonColors
                                                                    .black2b),
                                                      ),
                                                    ),
                                                    if (i > 0)
                                                      Row(
                                                        children: [
                                                          SizedBox(width: 4.w),
                                                          GestureDetector(
                                                            onTap: () {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              setState(() {
                                                                params['otherSalaryClassList']
                                                                    .remove(params[
                                                                            'otherSalaryClassList']
                                                                        [i]);
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 36.w,
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
                                              ),
                                              SizedBox(height: 8.w),
                                            ],
                                          ),
                                        if (params['otherSalaryClassList']
                                                .length <=
                                            3)
                                          GestureDetector(
                                            onTap:
                                                params['otherSalaryClassList']
                                                            .length ==
                                                        4
                                                    ? null
                                                    : () {
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                        setState(() {
                                                          params['otherSalaryClassList']
                                                              .add({
                                                            'osName': '',
                                                            'osAmount': 0
                                                          });
                                                        });
                                                      },
                                            child: Container(
                                              height: 50.w,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.w),
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
                                                    localization.addField,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color: CommonColors.red,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 20.w,
                                    child: !contractValidator['otherSalary']
                                        ? Text(
                                            '* ${localization.checkOtherBenefits}',
                                            style: commonErrorAuth(),
                                          )
                                        : const Text(''),
                                  ),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.paymentMethod,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentMethodType'] =
                                                  'ACCOUNT';
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentMethodType'],
                                          value: 'ACCOUNT',
                                          label: localization.depositToBankAccount,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentMethodType'] =
                                                  'SELF';
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentMethodType'],
                                          value: 'SELF',
                                          label: localization.directPayment,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentCycleType'] =
                                                  'MONTH';
                                              contractValidator[
                                                  'paymentCycleMonth'] = true;
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentCycleType'],
                                          value: 'MONTH',
                                          label: localization.monthly,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentCycleType'] =
                                                  'WEEK';
                                              contractValidator[
                                                  'paymentCycleMonth'] = true;
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentCycleType'],
                                          value: 'WEEK',
                                          label: localization.weekly,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CommonRadioTextButton(
                                          onChanged: (value) {
                                            setState(() {
                                              params['ccdPaymentCycleType'] =
                                                  'EVERY';
                                              contractValidator[
                                                  'paymentCycleMonth'] = true;
                                            });
                                          },
                                          groupValue:
                                              params['ccdPaymentCycleType'],
                                          value: 'EVERY',
                                          label: localization.daily,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (params['ccdPaymentCycleType'] == 'MONTH')
                                    Column(
                                      children: [
                                        SizedBox(height: 8.w),
                                        TextFormField(
                                          controller: paymentCycleController,
                                          maxLength: 2,
                                          keyboardType: TextInputType.number,
                                          maxLines: null,
                                          autocorrect: false,
                                          cursorColor: Colors.black,
                                          textAlign: TextAlign.end,
                                          onChanged: (value) {
                                            params['ccdPaymentCycleMonth'] =
                                                paymentCycleController.text;
                                          },
                                          style: commonInputText(),
                                          decoration: suffixInput(
                                              suffixText: localization.day,
                                              suffixSize: 14.sp,
                                              suffixColor:
                                                  CommonColors.black2b),
                                        ),
                                      ],
                                    ),
                                  SizedBox(
                                      height: 25.w,
                                      child: !contractValidator[
                                              'paymentCycleMonth']
                                          ? Text(
                                              '* ${localization.checkPaymentDate}',
                                              style: commonErrorAuth(),
                                            )
                                          : const Text('')),
                                  Container(
                                    width: CommonSize.vw,
                                    height: 1.w,
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.socialInsurance,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CommonRadioTextButton(
                                              onChanged: (value) {
                                                setState(() {
                                                  if (params[
                                                          'ccdEmploymentInsuranceStatus'] ==
                                                      0) {
                                                    params['ccdEmploymentInsuranceStatus'] =
                                                        1;
                                                  } else {
                                                    params['ccdEmploymentInsuranceStatus'] =
                                                        0;
                                                  }
                                                });
                                              },
                                              groupValue: params[
                                                  'ccdEmploymentInsuranceStatus'],
                                              value: 1,
                                              label: localization.employmentInsurance,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: CommonRadioTextButton(
                                              onChanged: (value) {
                                                setState(() {
                                                  if (params[
                                                          'ccdWorkersCompensationStatus'] ==
                                                      0) {
                                                    params['ccdWorkersCompensationStatus'] =
                                                        1;
                                                  } else {
                                                    params['ccdWorkersCompensationStatus'] =
                                                        0;
                                                  }
                                                });
                                              },
                                              groupValue: params[
                                                  'ccdWorkersCompensationStatus'],
                                              value: 1,
                                              label: localization.industrialInsurance,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.w),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CommonRadioTextButton(
                                              onChanged: (value) {
                                                setState(() {
                                                  if (params[
                                                          'ccdNationalPensionStatus'] ==
                                                      0) {
                                                    params['ccdNationalPensionStatus'] =
                                                        1;
                                                  } else {
                                                    params['ccdNationalPensionStatus'] =
                                                        0;
                                                  }
                                                });
                                              },
                                              groupValue: params[
                                                  'ccdNationalPensionStatus'],
                                              value: 1,
                                              label: localization.nationalPension,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: CommonRadioTextButton(
                                              onChanged: (value) {
                                                setState(() {
                                                  if (params[
                                                          'ccdHealthInsuranceStatus'] ==
                                                      0) {
                                                    params['ccdHealthInsuranceStatus'] =
                                                        1;
                                                  } else {
                                                    params['ccdHealthInsuranceStatus'] =
                                                        0;
                                                  }
                                                });
                                              },
                                              groupValue: params[
                                                  'ccdHealthInsuranceStatus'],
                                              value: 1,
                                              label: localization.healthInsurance,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.w),
                                  !contractValidator['insurance']
                                      ? Text(
                                          '* ${localization.selectSocialInsurance}',
                                          style: commonErrorAuth(),
                                        )
                                      : const Text(''),
                                  SizedBox(height: 20.w),
                                  Text(
                                    localization.requiredDocuments,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DocumentRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              if (params[
                                                      'ccdFamilyRelationCertificate'] ==
                                                  0) {
                                                params['ccdFamilyRelationCertificate'] =
                                                    1;
                                              } else {
                                                params['ccdFamilyRelationCertificate'] =
                                                    0;
                                              }
                                            });
                                          },
                                          groupValue: params[
                                              'ccdFamilyRelationCertificate'],
                                          value: 1,
                                          label: localization.familyRelationCertificate,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: DocumentRadio(
                                          onChanged: (value) {
                                            setState(() {
                                              if (params[
                                                      'ccdParentalConsent'] ==
                                                  0) {
                                                params['ccdParentalConsent'] =
                                                    1;
                                              } else {
                                                params['ccdParentalConsent'] =
                                                    0;
                                              }
                                            });
                                          },
                                          groupValue:
                                              params['ccdParentalConsent'],
                                          value: 1,
                                          label: localization.guardianConsentForm,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.w),
                                  !contractValidator['insurance']
                                      ? Text(
                                          '* ${localization.selectRequiredDocuments}',
                                          style: commonErrorAuth(),
                                        )
                                      : const Text('')
                                ],
                              ),
                            if (step == 3)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    localization.workerInfo,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  TextFormField(
                                    readOnly: true,
                                    controller: employeeNameController,
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    cursorColor: CommonColors.black,
                                    style: commonInputText(),
                                    maxLength: 100,
                                    decoration: suffixInput(),
                                    minLines: 1,
                                    maxLines: 1,
                                    onChanged: (value) {
                                      params['ccdEmployeeName'] =
                                          employeeNameController.text;
                                    },
                                  ),
                                  SizedBox(height: 12.w),
                                  TextFormField(
                                    readOnly: true,
                                    controller: employeeContactController,
                                    keyboardType: TextInputType.text,
                                    autocorrect: false,
                                    cursorColor: CommonColors.black,
                                    style: commonInputText(),
                                    maxLength: 100,
                                    decoration: suffixInput(),
                                    minLines: 1,
                                    maxLines: 1,
                                    onChanged: (value) {
                                      params['ccdEmployeeContact'] =
                                          employeeContactController.text;
                                    },
                                  ),
                                  SizedBox(height: 52.w),
                                  Text(
                                    localization.workerAddress,
                                    style: commonTitleAuth(),
                                  ),
                                  SizedBox(height: 20.w),
                                  TextFormField(
                                    readOnly: true,
                                    enabled: false,
                                    controller: employeeAddressController,
                                    autocorrect: false,
                                    style: commonInputText(),
                                    maxLength: null,
                                    minLines: 1,
                                    maxLines: 1,
                                    decoration: commonInput(
                                      disable: true,
                                    ),
                                  ),
                                  SizedBox(height: 12.w),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          readOnly: true,
                                          controller:
                                              employeeAddressDetailController,
                                          keyboardType: TextInputType.text,
                                          autocorrect: false,
                                          cursorColor: CommonColors.black,
                                          style: commonInputText(),
                                          maxLength: 100,
                                          decoration: suffixInput(),
                                          minLines: 1,
                                          maxLines: 1,
                                          onChanged: (value) {
                                            params['ccdEmployeeAddressDetail'] =
                                                employeeAddressDetailController
                                                    .text;
                                          },
                                        ),
                                      ),
                                      /*SizedBox(width: 4.w),
                                      CommonButton(
                                        width: 90.w,
                                        height: 48.w,
                                        confirm: true,
                                        onPressed: showPost,
                                        text: '주소검색',
                                      ),*/
                                    ],
                                  ),
                                  SizedBox(height: 66.w),
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
                                      GestureDetector(
                                        onTap: () {
                                          context.push('/terms/27');
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              '(${localization.required})',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: CommonColors.red,
                                              ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              localization.privacyConsentNotice,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/icon/iconArrowRight.png',
                                              width: 14.w,
                                              height: 14.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            SizedBox(height: 20.w),
                            if (!isLoading)
                              CommonButton(
                                fontSize: 15,
                                onPressed: onNextStep,
                                confirm: isConfirmEnabled(),
                                text: step == 3
                                    ? (widget.msgKey != null
                                        ? localization.contractModificationCompleted
                                        : localization.contractCreationCompleted)
                                    : localization.next,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isConfirmLoading)
          Positioned(
              left: 20.w,
              right: 20.w,
              top: 20.w,
              bottom: 20.w,
              child: const Loader()),
      ],
    );
  }
}
