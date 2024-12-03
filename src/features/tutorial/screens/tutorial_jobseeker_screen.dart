import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_about_me_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_career_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_education_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_file_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_job_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_profile_photo_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_profile_title.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_work_area_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_work_condition_widget.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_work_schedule_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/career_job_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/tutorial_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TutorialJobSeekerScreen extends ConsumerStatefulWidget {
  const TutorialJobSeekerScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<TutorialJobSeekerScreen> createState() =>
      _TutorialJobSeekerScreenState();
}

class _TutorialJobSeekerScreenState
    extends ConsumerState<TutorialJobSeekerScreen> with Files {
  late PageController _pageController;
  late List<Widget> tutorialPageList;
  late int tutorialPageIndex;
  bool isInitialEntry = false;

  Map<String, dynamic> profileData = {
    'mpGetOffer': 1, // 제안 수신
    'mpOfferScope': 1, // 제안 수신 범위
    'mpTitle': '', // 프로필 제목
    'adIdx': [], // 희망 근무 지역
    'joIdx': [], // 희망 직종 키 값
    'wdIdx': [], // 희망 근무 요일
    'whIdx': [], // 희망 근무 시간
    'wtIdx': [], // 희망 근무 형태
    'wpIdx': [], // 희망 근무 기간
    'educationList': [], // 학력
    'careerList': [], // 경력
    'mpIntroduce': '', // 자기소개
    'keyword': [], // 자기소개 키워드
    'mpBasic': 0, // 기본 프로필
    'mpHaveCareer': 0, // 경력이면 1
    'fileList': [],
  };

  List<String> titleList = [
    localization.749,
    localization.292,
    localization.294,
    localization.296,
    localization.297,
    localization.educationLevel,
    localization.experienced,
    localization.300,
    localization.302,
    localization.291,
  ];

  Map<String, dynamic> profilePhotoData = {
    'file': null,
  };

  Map<String, dynamic> fileData = {
    'file': null,
  };

  List<AddressModel> selectedAreaList = [];
  List<AddressModel> initialSelectedAreaList = [];

  List<DefineModel> selectedJobList = [];
  List<DefineModel> initialSelectedJobList = [];

  List<CareerJobModel> jobDepthDataList = [];
  List initialJobDepthDataList = [];

  bool isLoading = true;
  int profileKey = 0;
  int percent = 0;

  int areaMaxLength = 10;
  int jobMaxLength = 5;

  int totalCareerMonths = 0;
  bool isRunning = false;
  List<dynamic> fileList = [];

  setProfileData(String key, dynamic value) {
    profileData[key] = value;
  }

  setProfilePhotoData(String key, dynamic value) {
    profilePhotoData[key] = value;
  }

  setTotalCareerMonths(int totalValue) {
    totalCareerMonths = totalValue;
  }

  setFileData(List file, List fileInfoList, List deleteList) async {
    setState(() {
      fileData['file'] = file;
      fileList = fileInfoList;
      profileData['fileList'] = fileList;
    });
    await writeProfileItem('file');
  }

  int returnFirstVisiblePageIndex() {
    if (profilePhotoData['file'] == null) return 0;
    if (profileData['adIdx'].isEmpty) return 1;
    if (profileData['joIdx'].isEmpty) return 2;
    if (profileData['wdIdx'].isEmpty && profileData['whIdx'].isEmpty) return 3;
    if (profileData['wtIdx'].isEmpty && profileData['wpIdx'].isEmpty) return 4;
    if (profileData['educationList'].isEmpty) return 5;
    if (profileData['careerList'].isEmpty) return 6;
    if (profileData['mpIntroduce'] == null && profileData['keyword'].isEmpty)
      return 7;
    if (fileData['file'] == null) return 8;
    if (profileData['mpTitle'].isEmpty) return 9;

    return -1;
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

  void saveFile(Object? profilePhoto, Object? file) async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });

    List fileInfo = [
      {
        'fileType': 'PROFILE_IMAGE',
        'files': profilePhoto != null ? [profilePhoto] : [],
      },
      {'fileType': 'PROFILE_FILES', 'files': file ?? []},
    ];
    var result = await runS3FileUpload(fileInfo, profileKey);
    setState(() {
      isRunning = false;
    });
    if (result == true) {
      setState(() {
        checkJobSeekerPercent();
        if (tutorialPageIndex == 0) {
          movePage(1); // 프로필 사진
        } else {
          movePage(9); // 파일 첨부
        }
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
              },
              alertTitle: localization.notification,
            );
          },
        );
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getProfileInfo(),
      checkJobSeekerPercent(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getProfileInfo() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getProfileInfo(int.parse(widget.idx));
    if (result.status == 200) {
      setState(() {
        if (result.data != null) {
          profileData['mpGetOffer'] = result.data['mpGetOffer'];
          profileData['mpOfferScope'] = result.data['mpOfferScope'];
          profileData['mpTitle'] = result.data['mpTitle'] ?? '';
          profileData['adIdx'] = result.data['memberProfileArea']
                  .map((area) => area['areaDefine']['adIdx'])
                  .toList() ??
              [];
          profileData['joIdx'] = result.data['memberProfileJob']
                  .map((job) => job['joIdx'])
                  .toList() ??
              [];
          profileData['wdIdx'] = result.data['memberProfileWorkDays']
                  .map((workday) => workday['wdIdx'])
                  .toList() ??
              [];
          profileData['whIdx'] = result.data['memberProfileWorkHour']
                  .map((workTime) => workTime['whIdx'])
                  .toList() ??
              [];
          profileData['wtIdx'] = result.data['memberProfileWorkType']
                  .map((workType) => workType['wtIdx'])
                  .toList() ??
              [];
          profileData['wpIdx'] = result.data['memberProfileWorkPeriod']
                  .map((workPeriod) => workPeriod['wpIdx'])
                  .toList() ??
              [];
          profileData['educationList'] =
              result.data['memberProfileEducation'] ?? [];
          profileData['careerList'] = result.data['memberProfileCareer'] ?? [];
          profileData['mpIntroduce'] = result.data['mpIntroduce'];
          profileData['keyword'] = result.data['memberProfileKeyword']
                  .map((keyword) => keyword['pkdIdx'])
                  .toList() ??
              [];
          profileData['mpBasic'] = result.data['mpBasic'];
          profileData['mpHaveCareer'] = result.data['mpHaveCareer'];
          profilePhotoData['file'] = result.data['profileImg']['atIdx'] != null
              ? setFilesFromMap(result.data['profileImg'])[0]
              : null;
          fileData['file'] = result.data['files'][0]['atIdx'] != null
              ? setFiles(result.data['files'])
              : null;
          fileList = result.data['memberProfileFiles'] ?? [];
          // 총 경력
          if (profileData['careerList'].isNotEmpty) {
            totalCareerMonths = profileData['careerList']
                .map((career) => ProfileService.calculateTotalCareerMonths(
                    career['mpcStartDate'], career['mpcEndDate']))
                .toList()
                .reduce((value, element) => value + element);
          }

          // 희망 근무 지역 상세 데이터
          result.data['memberProfileArea'].forEach((area) {
            AddressModel address = AddressModel(
              key: area['areaDefine']['adIdx'] ?? 0,
              parentKey: area['areaDefine']['adParent'] ?? 0,
              administCode: area['areaDefine']['adAdministCode'] ?? '',
              si: area['areaDefine']['adSi'] ?? '',
              gu: area['areaDefine']['adGu'] ?? '',
              dong: area['areaDefine']['adDong'] ?? '',
              legalCode: area['areaDefine']['adLegalCode'] ?? '',
              dongName: area['areaDefine']['adDongName'] ?? '',
              child: [],
              selectionName: '',
              lat: area['areaDefine']['adLat'] ?? 0,
              lng: area['areaDefine']['adLong'] ?? 0,
            );

            initialSelectedAreaList.add(address);
          });

          // 희망 직종 상세 데이터
          result.data['memberProfileJob'].forEach((job) {
            DefineModel jobModel = DefineModel(
              key: job['joIdx'] ?? 0,
              depth: job['joDepth'] ?? 0,
              name: job['joName'] ?? '',
              child: [],
              isInput: 0,
              parent: null,
              parentKey: 0,
            );

            initialSelectedJobList.add(jobModel);
          });

          runSecondaryTask(profileData['joIdx']);
        }
      });
    } else {
      if (result.status == 406) {
        // 프로필 관리에 프로필 아예 없는 경우
        setState(() {});
      }
    }
  }

  runSecondaryTask(List jobKeyList) {
    getJobDepthDetailData(jobKeyList);
  }

  getJobDepthDetailData(List jobKeyList) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getJobDepthDetailData(jobKeyList);
    if (result.status == 200) {
      if (result.type == 1) {
        List resultData = result.data;
        setState(() {
          initialJobDepthDataList = [...resultData];

          if (initialJobDepthDataList.isNotEmpty) {
            for (var item in initialJobDepthDataList) {
              late CareerJobModel jobData;
              if (item['joDepth'] == 1) {
                // 1Depth
                jobData = CareerJobModel(
                  name: item['joName'],
                  formattedDepthName: item['joName'],
                );
                jobDepthDataList.add(jobData);
              } else {
                if (item['joDepth'] == 2) {
                  // 2Depth
                  if (item['joChild'] != null) {
                    // ${2Depth} 전체
                    jobData = CareerJobModel(
                      name: item['joName'],
                      formattedDepthName:
                          '${item['joParent']['joName']} > ${item['joName']} 전체',
                    );
                    jobDepthDataList.add(jobData);
                  } else {
                    // ${2Depth}
                    jobData = CareerJobModel(
                      name: item['joName'],
                      formattedDepthName:
                          '${item['joParent']['joName']} > ${item['joName']}',
                    );
                    jobDepthDataList.add(jobData);
                  }
                } else {
                  if (item['joDepth'] == 3) {
                    // 3Depth
                    jobData = CareerJobModel(
                      name: item['joName'],
                      formattedDepthName:
                          '${item['joParent']['joParent']['joName']} > ${item['joParent']['joName']} > ${item['joName']}',
                    );
                    jobDepthDataList.add(jobData);
                  }
                }
              }
            }
          }
        });
      }
    }
  }

  checkJobSeekerPercent() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .checkJobSeekerPercent(userInfo.key);
      if (result.status == 200) {
        setState(() {
          if (result.data.percent != 100) {
            percent = result.data.percent;
          } else {
            // 만약 100%라면 프로필 등록 포인트 지급
            giveJobSeekerPoint();
          }
        });
      }
    }
  }

  giveJobSeekerPoint() async {
    await ref.read(mypageControllerProvider.notifier).giveJobSeekerPoint();
  }

  writeProfileItem(String type) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .writeProfileItem(profileData, type, userInfo.key, profileKey);
      if (result.status == 200) {
        checkJobSeekerPercent();
        if (type == 'file') {
          saveFile(null, fileData['file']);
          await getProfileInfo();
        }
      }
    }
  }

  selectionName(String origin, bool isAll) {
    if (isAll) {
      return '$origin 전체';
    } else {
      return origin;
    }
  }

  void addSelectedAreaList(AddressModel addressData, int depth, bool isAll) {
    AddressModel addressDataCopy = AddressModel.copy(addressData);

    if (depth == 1) {
      addressDataCopy.selectionName = selectionName(addressDataCopy.si, isAll);
    } else if (depth == 2) {
      addressDataCopy.selectionName = selectionName(addressDataCopy.gu, isAll);
    } else {
      addressDataCopy.selectionName =
          selectionName(addressDataCopy.dongName, isAll);
    }
    selectedAreaList.add(addressDataCopy);
  }

  selectAreaItem(AddressModel item, {int depth = -1, bool isAll = false}) {
    setState(() {
      if (initialSelectedAreaList.length <= areaMaxLength) {
        addSelectedAreaList(item, depth, isAll);
      }
    });
  }

  void addSelectedJobList(DefineModel defineData, bool isAll) {
    DefineModel defineDataCopy = DefineModel.copy(defineData);
    if (isAll) {
      defineDataCopy.name =
          ConvertService.removeParentheses('${defineData.name} 전체');
    }
    selectedJobList.add(defineDataCopy);
  }

  selectJobItem(DefineModel item, {bool isAll = false}) {
    setState(() {
      if (initialSelectedJobList.length <= jobMaxLength) {
        addSelectedJobList(item, isAll);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    profileKey = int.parse(widget.idx);
    isInitialEntry = true;

    _getAllAsyncTasks().then((_) {
      isLoading = false;

      // 희망 근무 지역
      for (AddressModel item in initialSelectedAreaList) {
        if (item.dongName.isEmpty) {
          if (item.gu.isEmpty) {
            selectAreaItem(item, depth: 1);
          } else {
            selectAreaItem(item, depth: 2, isAll: true);
          }
        } else {
          selectAreaItem(item, depth: 3);
        }
      }

      // 희망 직종
      for (DefineModel item in initialSelectedJobList) {
        selectJobItem(item);
      }

      _pageController =
          PageController(initialPage: returnFirstVisiblePageIndex());
      tutorialPageIndex = returnFirstVisiblePageIndex();

      tutorialPageList = [
        TutorialProfilePhotoWidget(
          data: profilePhotoData,
          setData: setProfilePhotoData,
          writeFunc: saveFile,
          onPress: () {
            movePage(1);
          },
        ),
        TutorialWorkAreaWidget(
          data: profileData,
          areaList: selectedAreaList,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(2);
          },
        ),
        TutorialJobWidget(
          data: profileData,
          jobList: selectedJobList,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(3);
          },
        ),
        TutorialWorkScheduleWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(4);
          },
        ),
        TutorialWorkConditionWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(5);
          },
        ),
        TutorialEducationWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(6);
          },
        ),
        TutorialCareerWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          jobDepthDataList: jobDepthDataList,
          totalCareerMonths: totalCareerMonths,
          setTotalCareerMonths: setTotalCareerMonths,
          onPress: () {
            movePage(7);
          },
        ),
        TutorialAboutMeWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
          onPress: () {
            movePage(8);
          },
        ),
        TutorialFileWidget(
          fileData: fileData,
          fileList: fileList,
          setData: setFileData,
          writeFunc: saveFile,
          onPress: () {
            movePage(9);
          },
        ),
        TutorialProfileTitleWidget(
          data: profileData,
          setData: setProfileData,
          writeFunc: writeProfileItem,
        ),
      ];
    });

    /*if (tutorialPageIndex < 0) {
      setState(() {
        tutorialPageIndex = 0;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (tutorialPageIndex <= 0) {
            if (isInitialEntry) {
              savePageLog();
            }
            context.pop();
          } else {
            movePage(tutorialPageIndex - 1);
          }
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
              if (isRunning) const Loader()
            ],
          )),
    );
  }
}
