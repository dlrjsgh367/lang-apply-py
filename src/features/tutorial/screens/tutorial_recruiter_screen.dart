import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_company_additional_info_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_company_info_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_company_introduce_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_company_manager_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_company_photo_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/tutorial_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TutorialRecruiterScreen extends ConsumerStatefulWidget {
  const TutorialRecruiterScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<TutorialRecruiterScreen> createState() =>
      _TutorialRecruiterScreenState();
}

class _TutorialRecruiterScreenState
    extends ConsumerState<TutorialRecruiterScreen> with Files, Alerts {
  late PageController _pageController;
  late List<Widget> tutorialPageList;
  late int tutorialPageIndex;

  bool isLoading = true;
  String industryName = '';
  int companyKey = 0;
  int percent = 0;

  bool isInitialEntry = false;
  bool isRunning = false;

  Map<String, dynamic> companyData = {
    'mcName': '',
    'mcAddress': '', // 기업 주소
    'mcAddressDetail': '', // 기업 상세 주소
    'inIdx': 0, // 업종 키 값
    'mcEmployees': 0, // 직원 수
    'mcIntroduce': '', // 소개글
    'mcManagerName': '', // 담당자명
    'mcManagerNameDisplay': 1, // 담당자명 공개 여부
    'mcManagerHp': '', // 담당자 연락처
    'mcManagerHpDisplay': 1, // 담당자 연락처 공개 여부
    'mcManagerEmail': '', // 담당자 이메일
    'mcManagerEmailDisplay': 1, // 담당자 이메일 공개 여부
  };

  Map<String, dynamic> companyPhotoData = {
    'file': null,
  };

  List<String> titleList = [
    localization.750,
    localization.751,
    localization.752,
    localization.753,
    localization.754,
  ];

  int returnFirstVisiblePageIndex() {
    if (companyPhotoData['file'][0].key == 0) return 0;
    if (companyData['mcAddress'].isEmpty) return 1;
    if (companyData['mcEmployees'] == 0) return 2;
    if (companyData['mcIntroduce'].isEmpty) return 3;
    if (companyData['mcManagerName'].isEmpty &&
        companyData['mcManagerHp'].isEmpty &&
        companyData['mcManagerEmail'].isEmpty) return 4;

    return -1;
  }

  setCompanyData(String key, dynamic value) {
    companyData[key] = value;
  }

  setCompanyPhotoData(String key, dynamic value) {
    companyPhotoData[key] = value;
  }

  setIndustryName(String name) {
    industryName = name;
  }

  void movePage(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    isInitialEntry = false;
    savePageLog(); // 페이지 로그 쌓기

    _pageController
        .animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    )
        .whenComplete(() {
      setState(() {
        tutorialPageIndex = index;
      });
    });
  }

  void saveFile(dynamic file) async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });

    List fileInfo = [
      {
        'fileType': 'COMPANY_IMAGES',
        'files': [file]
      },
    ];

    var result = await runS3FileUpload(fileInfo, companyKey);
    setState(() {
      isRunning = false;
    });
    if (result == true) {
      setState(() {
        checkRecruiterPercent();
        movePage(1);
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.fileUploadFailedRetry,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
              }, alertTitle: localization.notification,
            );
          },
        );
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getCompanyInfo(), checkRecruiterPercent()]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .getCompanyInfo(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          setState(() {
            companyKey = result.data.companyInfo.key;
            industryName = result.data.industryName;
            companyData['mcAddress'] = result.data.companyInfo.address;
            companyData['mcAddressDetail'] =
                result.data.companyInfo.addressDetail;
            companyData['inIdx'] = result.data.companyInfo.industryKey;
            companyData['mcEmployees'] =
                result.data.companyInfo.numberOfEmployees;
            companyData['mcIntroduce'] =
                result.data.companyInfo.companyIntroduce;
            companyData['mcManagerName'] = result.data.companyInfo.managerName;
            companyData['mcManagerHp'] =
                result.data.companyInfo.managerPhoneNumber;
            companyData['mcManagerEmail'] =
                result.data.companyInfo.managerEmail;
            companyData['mcManagerNameDisplay'] =
                result.data.companyInfo.managerNameDisplay;
            companyData['mcManagerHpDisplay'] =
                result.data.companyInfo.managerHpDisplay;
            companyData['mcManagerEmailDisplay'] =
                result.data.companyInfo.managerEmailDisplay;
            companyPhotoData['file'] = result.data.companyInfo.files;
          });
        }
      }
    }
  }

  checkRecruiterPercent() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .checkRecruiterPercent();
    if (result.status == 200) {
      setState(() {
        if (result.data.percent != 100) {
          percent = result.data.percent;
        }
      });
    }
  }

  writeCompanyItem() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .updateCompanyInfo(companyData, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          checkRecruiterPercent();
        }
      } else if (result.status == 500) {
        showNetworkErrorAlert(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    isInitialEntry = true;

    _getAllAsyncTasks().then((_) {
      isLoading = false;

      _pageController =
          PageController(initialPage: returnFirstVisiblePageIndex());
      tutorialPageIndex = returnFirstVisiblePageIndex();

      tutorialPageList = [
        TutorialCompanyPhotoWidget(
          data: companyPhotoData,
          setData: setCompanyPhotoData,
          writeFunc: saveFile,
          onPress: () {
            movePage(1);
          },
        ),
        TutorialCompanyInfoWidget(
          data: companyData,
          setData: setCompanyData,
          writeFunc: writeCompanyItem,
          onPress: () {
            movePage(2);
          },
        ),
        TutorialCompanyAdditionalInfoWidget(
          data: companyData,
          industryName: industryName,
          setData: setCompanyData,
          writeFunc: writeCompanyItem,
          onPress: () {
            movePage(3);
          },
        ),
        TutorialCompanyIntroduceWidget(
          data: companyData,
          setData: setCompanyData,
          writeFunc: writeCompanyItem,
          onPress: () {
            movePage(4);
          },
        ),
        TutorialCompanyManagerWidget(
          data: companyData,
          setData: setCompanyData,
          writeFunc: writeCompanyItem,
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else if (tutorialPageIndex == 0) {
          if (isInitialEntry) {
            savePageLog();
          }
          context.pop();
        } else {
          movePage(tutorialPageIndex - 1);
        }
      },
      child: GestureDetector(
          onHorizontalDragUpdate: (details) async {
            int sensitivity = 15;
            if (details.globalPosition.dx - details.delta.dx < 60 &&
                details.delta.dx > sensitivity) {
              // Right Swipe
              if (tutorialPageIndex == 0) {
                if (isInitialEntry) {
                  savePageLog();
                }
                context.pop();
              } else {
                movePage(tutorialPageIndex - 1);
              }
            }
          },
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Stack(
            children: [
              Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: !isLoading
                    ? TutorialAppbar(
                        titleList: titleList,
                        movePage: movePage,
                        index: tutorialPageIndex,
                        percent: percent,
                      )
                    : null,
                body: !isLoading
                    ? PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        itemCount: tutorialPageList.length,
                        itemBuilder: (context, index) {
                          return tutorialPageList[index];
                        },
                      )
                    : const Loader(),
              ),
              if (isRunning) const Loader(),
            ],
          )),
    );
  }
}
