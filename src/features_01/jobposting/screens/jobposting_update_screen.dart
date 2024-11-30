import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/input_step_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_type_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/enum/display_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_complete_create_bottomsheet.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_manager_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_photo_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_recruit_condition_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_recruit_info_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_work_condition_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_box.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_list_item_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/day_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/preferential_condition_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingUpdateScreen extends ConsumerStatefulWidget {
  const JobpostingUpdateScreen(
      {required this.feature, required this.idx, super.key});

  final String feature;
  final String idx;

  @override
  ConsumerState<JobpostingUpdateScreen> createState() =>
      _JobpostingUpdateScreenState();
}

class _JobpostingUpdateScreenState extends ConsumerState<JobpostingUpdateScreen>
    with SingleTickerProviderStateMixin, Files, Alerts {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  int jobpostingPageIndex = 0;

  late Future<void> _allAsyncTasks;
  bool isLoading = true;

  final jobpostingTitleController = TextEditingController();

  List<dynamic> selectedJobpostingPhoto = [];

  setSelectedJobpostingPhoto(List<Map<String, dynamic>> photoList) {
    setState(() {
      selectedJobpostingPhoto = [...photoList];
    });
  }

  Map<String, dynamic> jobpostingData = {
    //공고타입
    'jpType': JobpostingTypeEnum.normal.param,

    //공고제목
    'jpTitle': '',

    'workInfo': <String, dynamic>{
      'jpWork': '',
      'joIdx': [],
    },

    //공고 상태

    'workCondition': <String, dynamic>{
      //급여 타입
      'jpSalaryType': 'TIME',
      //금여액
      'jpSalary': 0,
      //급여 협의 가능 0 협의 불가능 1: 협의 가능
      'jpSalaryNegotiable': 0,

      //근무 형태 키 값
      'wtIdx': null,
      // 수습 기간 선택
      'jpProbationPeriod': 0,

      // 근무 기간 키 값
      'wpIdx': null,

      //근무 기간 협의 가능  0 불가능 1: 가능
      'jpPeriodChangeable': 0,
      // 근무 요일
      'wdIdx': <int>[],
      // 근무 요일 협의 가능 0 불가능 1: 가능
      'jpDaysChangeable': 0,

      //근무 시간 Work, Rest
      'workHour': <Map<String, dynamic>>[
        // {
        //   //근무시간
        //   'jphType': 'WORK',
        //   // 근무시작시간
        //   'jphStartTime': "",
        //   // 근무종료시간
        //   'jphEndTime': "",
        // }
      ],
      //근무 시간 협의 가능 0 불가능 1: 가능
      'jpWorkHourChangeable': 0,
      //휴게시간
      'jpRestHour': 0,
      // 휴게시간 협의 가능 0 불가능 1: 가능
      'jpRestHourChangeable': 0,

      // 소정 근무 시간
      'jpContractualWorkHour': 0,

      //회사주소와 동일한지 0회사 주소와 동일, 1별도 근무지
      'jpAddressType': 1,

      //근무지 주소 선택
      'jpAddress': '',

      //근무지 상세주소 선택
      'jpAddressDetail': '',
      //시 선택
      'adSi': '',

      //구 선택
      'adGu': '',
      //동 선택
      'adDong': '',
    },

    'recruitmentCondition': <String, dynamic>{
      //모집 분야
      'jpJobPosition': '',
      //모집 인원 인원 미정이면 0
      'jpRecruitedCount': 0,
      // //성별 0무관 1여자 2남자
      'jpSex': 0,
      // //최소 나이  연력무관이면 Null이거나 보내지 말것
      'jpAgeMin': null,
      // //최대 나이  연력무관이면 Null이거나 보내지 말것
      'jpAgeMax': null,
      // //중장년층 채용 여부 1채용 0미채용
      'jpMiddleAge': 1,
      // //학력
      'stIdx': null,

      'jpCareerType': 0,

      'jpCareerMin': 0,
      'jpCareerMax': 0,
      'jpApplyEligibility': '',
      'preferentialConditions': []
    },

    'managerInfoDto': <String, dynamic>{
      //담당자 이름
      'jpManagerName': '',
      //담당자 연락처
      'jpManagerHp': '',
      //담당자 이메일
      'jpManagerEmail': '',
      'jpManagerNameDisplay': DisplayTypeEnum.display.param,
      'jpManagerHpDisplay': DisplayTypeEnum.display.param,
      'jpManagerEmailDisplay': DisplayTypeEnum.display.param,
    },
    //승인 여부
    'jpIsPermission': 0,
  };

  List<ProfileModel> workPeriodList = [];

  List<ProfileModel> workTypeList = [];

  List<DayModel> dayList = [];

  List<DefineModel> selectedJobList = [];

  List<PreferentialConditionModel> selectedPreferenceConditionList = [];

  // 1) 근무 조건
  InputStepController workConditionStep = InputStepController();

  // 2) 모집 조건
  InputStepController recruitConditionStep = InputStepController();

  // 3) 업무 정보
  InputStepController recruitInfoStep = InputStepController();

  // 4) 담당자 정보
  InputStepController managerInfoStep = InputStepController();

  bool isConfirm = false;

  List<PreferentialConditionModel> preferentialConditionGroup = [];
  List<PreferentialConditionModel> preferentialConditionList = [];

  List<PreferentialConditionModel> selectedPreferentialList = [];

  List<ProfileModel> schoolTypes = [];

  PremiumModel? matchData;

  PremiumModel? areaTopData;

  List<dynamic> deleteFiles = [];

  void addDeleteFiles(dynamic deleteItem) {
    deleteFiles.add(deleteItem);
  }

  getWorkDayJobpostingList() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getWorkDayJobpostingList();
    if (result.status == 200) {
      if (result.type == 1) {
        dayList = [...result.data];
      }
    }
  }

  getWorkTypes() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkTypes();
    if (result.status == 200) {
      if (result.type == 1) {
        workTypeList = [...result.data];
      }
    }
  }

  getWorkPeriodList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkPeriodList();
    if (result.status == 200) {
      if (result.type == 1) {
        workPeriodList = [...result.data];
      }
    }
  }

  getPreferentialConditionGroup() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getPreferentialConditionGroup();
    if (result.status == 200) {
      if (result.type == 1) {
        preferentialConditionGroup = [...result.data];
      }
    }
  }

  getPreferentialConditionList() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getPreferentialConditionList();
    if (result.status == 200) {
      if (result.type == 1) {
        preferentialConditionList = [...result.data];
      }
    }
  }

  getSchoolType() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getSchoolType();
    if (result.status == 200) {
      if (result.type == 1) {
        schoolTypes = [...result.data];
      }
    }
  }

  saveFile(dynamic file, int key) async {
    List fileInfo = [
      {
        'fileType': 'JOB_POSTING_IMAGES',
        'files': [file]
      },
    ];
    var result = await runS3FileUpload(fileInfo, key);

    if (result == true) {
      await ref
          .read(jobpostingControllerProvider.notifier)
          .indexingOpenSearch(key);
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
              alertTitle: localization.failure,
            );
          },
        );
      }
    }
  }

  bool isManagerDateChanged() {
    UserModel? userProfileInfo = ref.read(userProfileProvider);
    if (userProfileInfo != null) {
      if (jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerName'] !=
          userProfileInfo.companyInfo!.managerName) {
        return true;
      }
      if (jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerEmail'] !=
          userProfileInfo.companyInfo!.managerEmail) {
        return true;
      }

      if (jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerHp'] !=
          userProfileInfo.companyInfo!.managerPhoneNumber) {
        return true;
      }
      return false;
    }
    return false;
  }

  updateJobposting() async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });

    if (isManagerDateChanged()) {
      jobpostingData[InputDepthEnum.managerInfoDto.key]['jpCompanyNameType'] =
          1;
    }
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .updateJobposting(jobpostingData);
    if (result.status == 200) {
      if (result.type == 1) {
        if (selectedJobpostingPhoto.isNotEmpty) {
          for (Map<String, dynamic> item in selectedJobpostingPhoto) {
            if (!item.containsKey('atIdx')) {
              await saveFile(item, result.data);
            }
          }
          if (deleteFiles.isNotEmpty) {
            await runS3ApiDeleteFiles(deleteFiles);
          }
        }
        ApiResultModel openSearchResult = await ref
            .read(jobpostingControllerProvider.notifier)
            .createJobpostingOpenSearch(result.data);

        showBottomCreateJobposting();
      } else {
        showDefaultToast(localization.jobPostRegistrationFailed);
      }
    } else if (result.status == 401) {
      if (result.type == -2001) {
        showForbiddenAlert(localization.jobPostEditBlockedByProhibitedKeyword);
      }
    } else {
      showDefaultToast(localization.jobPostRegistrationFailed);
    }

    setState(() {
      isRunning = false;
    });
  }

  showForbiddenAlert(msg) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: msg,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
        });
  }

  bool isRunning = false;

  createJobposting() async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .createJobposting(jobpostingData);
    if (result.status == 200) {
      if (result.type == 1) {
        if (selectedJobpostingPhoto.isNotEmpty) {
          for (Map<String, dynamic> item in selectedJobpostingPhoto) {
            await saveFile(item, result.data);
          }
        }
        ApiResultModel openSearchResult = await ref
            .read(jobpostingControllerProvider.notifier)
            .createJobpostingOpenSearch(result.data);

        showBottomCreateJobposting();
      } else {
        showDefaultToast(localization.jobPostRegistrationFailed);
      }
    } else if (result.status == 200) {
      if (result.type == -2001) {
        showForbiddenAlert(localization.jobPostRepostBlockedByProhibitedKeyword);
      }
    }
    setState(() {
      isRunning = false;
    });
  }

  getPremiumServiceMatch() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(PremiumServiceEnum.match.code);
    if (result.status == 200) {
      if (result.type == 1) {
        matchData = result.data;
      }
    }
  }

  getPremiumServiceAreaTop() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(PremiumServiceEnum.areaTop.code);
    if (result.status == 200) {
      if (result.type == 1) {
        areaTopData = result.data;
      }
    }
  }

  List<Map<String, String>> convertListFormat(List<dynamic> inputList) {
    List<Map<String, String>> resultList = [];

    // 주어진 리스트 순회
    for (var item in inputList) {
      // 각 요소의 "jphStartTime" 및 "jphEndTime" 값을 변환
      String startTime = ConvertService.convertTimeFormat(item['jphStartTime']);
      String endTime = ConvertService.convertTimeFormat(item['jphEndTime']);

      // 변환된 값을 포함하는 새로운 맵 생성
      Map<String, String> newItem = {
        'jphType': item['jphType'],
        'jphStartTime': startTime,
        'jphEndTime': endTime,
      };

      // 결과 리스트에 추가
      resultList.add(newItem);
    }

    return resultList;
  }

  getJobpostingDetailForUpdate(int jobpostingKey) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingDetailForUpdate(jobpostingKey);
    if (result.status == 200 && result.type == 1) {
      Map<String, dynamic> jobData = result.data;

      // jobpostingData['jpPostPeriod'] = jobData['jpPostPeriod'];
      jobpostingData['jpTitle'] = jobData['jpTitle'];
      jobpostingTitleController.text = jobData['jpTitle'];
      jobpostingData['jpIdx'] = jobData['jpIdx'];
      //
      // jobpostingData['jpPostPeriod'] = jobData['jpPostPeriod'];
      jobpostingData['jpPostState'] = jobData['jpPostState'];
      jobpostingData['jpOwnerIdx'] = jobData['jpOwner']['meIdx'];
      // jobpostingData['jpIdx'] = jobData['jpIdx'];
      //
      jobpostingData[InputDepthEnum.workInfo.key]['joIdx'] =
          jobData[InputDepthEnum.workInfo.key]['jobList']
              .map((job) => job['joIdx'])
              .toList();

      List<DefineModel> tempt = [];
      for (var item in jobData[InputDepthEnum.workInfo.key]['jobList']) {
        tempt.add(DefineModel.fromApiJobJson(item));
      }
      selectedJobList = tempt;
      jobpostingData[InputDepthEnum.workInfo.key]['jpWork'] =
          jobData[InputDepthEnum.workInfo.key]['jpWork'];
      //
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerName'] =
          jobData["managerInfo"]['jpManagerName'];

      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerHp'] =
          jobData["managerInfo"]['jpManagerHp'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerName'] =
          jobData["managerInfo"]['jpManagerName'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerEmail'] =
          jobData["managerInfo"]['jpManagerEmail'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]
              ['jpManagerNameDisplay'] =
          jobData["managerInfo"]['jpManagerNameDisplay'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerHpDisplay'] =
          jobData["managerInfo"]['jpManagerHpDisplay'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]
              ['jpManagerEmailDisplay'] =
          jobData["managerInfo"]['jpManagerEmailDisplay'];

      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpCompanyNameType'] =
          jobData['jpCompanyNameType'];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpCompanyName'] =
          jobData["jpCompanyName"];
      jobpostingData[InputDepthEnum.managerInfoDto.key!]['jpManagerIdx'] =
          jobData["jpManager"]['meIdx'];

      //
      jobpostingData[InputDepthEnum.workCondition.key!]['jpSalaryType'] =
          jobData[InputDepthEnum.workCondition.key]['jpSalaryType'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpSalary'] =
          jobData[InputDepthEnum.workCondition.key]['jpSalary'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpSalaryNegotiable'] =
          jobData[InputDepthEnum.workCondition.key]['jpSalaryNegotiable'];
      jobpostingData[InputDepthEnum.workCondition.key!]['wtIdx'] =
          jobData[InputDepthEnum.workCondition.key]['wtIdx'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpProbationPeriod'] =
          jobData[InputDepthEnum.workCondition.key]['jpProbationPeriod'];
      jobpostingData[InputDepthEnum.workCondition.key!]['wpIdx'] =
          jobData[InputDepthEnum.workCondition.key]['wpIdx'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpPeriodChangeable'] =
          jobData[InputDepthEnum.workCondition.key]['jpPeriodChangeable'];
      jobpostingData[InputDepthEnum.workCondition.key!]['wdIdx'] =
          jobData[InputDepthEnum.workCondition.key]['workDays']
              .map((job) => job['wdIdx'])
              .toList();
      jobpostingData[InputDepthEnum.workCondition.key!]['wdIdx'].sort();
      jobpostingData[InputDepthEnum.workCondition.key!]['jpDaysChangeable'] =
          jobData[InputDepthEnum.workCondition.key]['jpDaysChangeable'];
      jobpostingData[InputDepthEnum.workCondition.key!]['workHour'] =
          convertListFormat(
              jobData[InputDepthEnum.workCondition.key]['workHour']);
      jobpostingData[InputDepthEnum.workCondition.key!]
              ['jpWorkHourChangeable'] =
          jobData[InputDepthEnum.workCondition.key]['jpWorkHourChangeable'];
      jobpostingData[InputDepthEnum.workCondition.key!]
          ['jpRestHour'] = jobData[InputDepthEnum.workCondition.key]
                      ['jpRestHour']
                  .runtimeType ==
              String
          ? int.parse(jobData[InputDepthEnum.workCondition.key]['jpRestHour'])
          : jobData[InputDepthEnum.workCondition.key]['jpRestHour'];
      jobpostingData[InputDepthEnum.workCondition.key!]
              ['jpRestHourChangeable'] =
          jobData[InputDepthEnum.workCondition.key]['jpRestHourChangeable'];
      jobpostingData[InputDepthEnum.workCondition.key!]
              ['jpContractualWorkHour'] =
          jobData[InputDepthEnum.workCondition.key]['jpContractualWorkHour'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpAddressType'] = 1;
      jobpostingData[InputDepthEnum.workCondition.key!]
              ['jpContractualWorkHour'] =
          jobData[InputDepthEnum.workCondition.key]['jpContractualWorkHour'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpAddress'] =
          jobData['jpAddress'];
      jobpostingData[InputDepthEnum.workCondition.key!]['jpAddressDetail'] =
          jobData['jpAddressDetail'];

      jobpostingData[InputDepthEnum.workCondition.key!]['adSi'] =
          jobData['jpAdSi'];
      jobpostingData[InputDepthEnum.workCondition.key!]['adGu'] =
          jobData['jpAdGu'];
      jobpostingData[InputDepthEnum.workCondition.key!]['adDong'] =
          jobData['jpAdDongName'];

      //
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]
              ['jpJobPosition'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpJobPosition'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]
              ['jpRecruitedCount'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpRecruitedCount'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpSex'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpSex'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpAgeMin'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpAgeMin'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpAgeMax'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpAgeMax'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpMiddleAge'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpMiddleAge'];

      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['stIdx'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['stIdx'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpCareerType'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpCareerType'];

      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpCareerMin'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpCareerMin'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]['jpCareerMax'] =
          jobData[InputDepthEnum.recruitmentCondition.key]['jpCareerMax'];

      jobpostingData[InputDepthEnum.recruitmentCondition.key!]
              ['preferentialConditions'] =
          jobData[InputDepthEnum.recruitmentCondition.key]
              ['preferentialConditions'];
      jobpostingData[InputDepthEnum.recruitmentCondition.key!]
              ['jpApplyEligibility'] =
          jobData[InputDepthEnum.recruitmentCondition.key]
              ['jpApplyEligibility'];

      if (widget.feature == JobpostingEditEnum.update.path) {
        selectedJobpostingPhoto = jobData['jobPostingImages'];
      }
      confirm();
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getJobpostingDetailForUpdate(int.parse(widget.idx)),
      getWorkDayJobpostingList(),
      getWorkTypes(),
      getWorkPeriodList(),
      getPreferentialConditionGroup(),
      getPreferentialConditionList(),
      getSchoolType(),
      getPremiumServiceMatch(),
      getPremiumServiceAreaTop(),
    ]).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  void initState() {
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  confirm() {
    // 1)공고 타입 2) 공고 제목 / 3) 공고사진 1장이상,
    // workCondition 1) 급여 형태, 급여, 급여 협의가능 2)근무형태 3) 근무 기간 4)근무 요일, 근무 요일 협의 가능  5) 근무시간, 근무시간 협의가능 6)휴게시간 협의가능  7) 소정근무시간 8) 근무지 주소타입, 근무지 주소@ /주소 상세는 선택
    // recruitmentCondition 1) 모집 분야 2) 모집인원
    // workInfo 1) 직종키 2)담당업무상
    // managerInfoDto 1) 담당자 이름 2) 담당자 연락처 3) 담당자 이메일 4)담당자 이름 공개 여부 5)담당자 연락처 공개 여부 6) 담당자 이메일 공개 여부

    setState(() {
      if (
          // 1)공고 타입
          // jobpostingData['jpType'] == JobpostingTypeEnum.normal.param &&
          // 2)공고 제목
          jobpostingData['jpTitle'] != '' &&
              // 3) 공고 사진
              // selectedJobpostingPhoto.isNotEmpty &&
              // workCondition 1-1) 급여 형태

              ConvertService.isNotEmptyValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpSalaryType']) &&
              // workCondition 1-2) 급여
              jobpostingData[InputDepthEnum.workCondition.key]['jpSalary'] !=
                  null &&

              // workCondition1-3) 급여 협의
              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpSalaryNegotiable']) &&
              // workCondition 2) 근무 형태
              jobpostingData[InputDepthEnum.workCondition.key]['wtIdx'] !=
                  null &&

              // workCondition 3) 근무 기간
              // jobpostingData[InputDepthEnum.workCondition.key]['wpIdx'] !=
              //     null &&

              // workCondition 4-1) 근무 요일
              // jobpostingData[InputDepthEnum.workCondition.key]['wdIdx'] !=
              //     null &&

              // workCondition 4-2) 근무 요일 협의 가능

              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpDaysChangeable']) &&

              // workCondition 5-1) 근무시간
              // jobpostingData[InputDepthEnum.workCondition.key]['workHour']
              //     .isNotEmpty &&

              // workCondition 5-2) 근무시간 협의가능
              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpWorkHourChangeable']) &&

              // workCondition 6) 휴게시간 협의가능
              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpRestHourChangeable']) &&

              // workCondition 7) 소정 근무 시간
              jobpostingData[InputDepthEnum.workCondition.key]['jpContractualWorkHour'] != null &&

              // workCondition 8-1) 근무지 별도 근무지
              jobpostingData[InputDepthEnum.workCondition.key]['jpAddressType'] == 1 &&

              // workCondition 8-1) 회사 주소
              jobpostingData[InputDepthEnum.workCondition.key]['jpAddress'] != '' &&

              // recruitmentCondition 1) 모집분야
              jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpJobPosition'] != '' &&
              // recruitmentCondition 2) 모집인원
              jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpRecruitedCount'] != null &&

              // workInfo 1) 직종 키

              jobpostingData[InputDepthEnum.workInfo.key]['joIdx'].isNotEmpty &&

              // workInfo 2) 담당 업무 상세
              jobpostingData[InputDepthEnum.workInfo.key]['jpWork'] != '' &&

              // managerInfoDto 1) 담당자 이름
              jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerName'] != '' &&
              // managerInfoDto 2) 담당자 연락처
              jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerHp'] != '' &&
              // managerInfoDto 3) 담당자 이메일
              jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerEmail'] != '' &&
              // managerInfoDto 4) 담당자 이름 공개여부
              ConvertService.intTypeBoolValidate(jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerNameDisplay']) &&

              // managerInfoDto 5) 담당자 연락처 공개여부
              ConvertService.intTypeBoolValidate(jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerHpDisplay']) &&

              // managerInfoDto 6) 담당자 이메일 공개여부
              ConvertService.intTypeBoolValidate(jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerEmailDisplay'])) {
        isConfirm = true;
      } else {
        isConfirm = false;
      }
    });
  }

  List<String> mergeManagerInfoContent() {
    // if (!isManagerInfoDtoEverSaved) {
    //   return '채용 담당자 정보를 확인해주세요!';
    // }
    List<String> stringList = [];
    bool managerNameDisplay = ConvertService.convertIntToBool(
        jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerNameDisplay']);
    bool managerPhoneNumberDisplay = ConvertService.convertIntToBool(
        jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerHpDisplay']);
    bool managerEmailDisplay = ConvertService.convertIntToBool(
        jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerEmailDisplay']);

    List<Map<String, dynamic>> managerSetData = [
      {
        'isVisible': managerNameDisplay,
        'key': 'jpManagerName',
        'keyword': localization.contactPersonName
      },
      {
        'isVisible': managerPhoneNumberDisplay,
        'key': 'jpManagerHp',
        'keyword': localization.contactPersonPhone
      },
      {
        'isVisible': managerEmailDisplay,
        'key': 'jpManagerEmail',
        'keyword': localization.contactPersonEmail
      },
    ];

    if (!managerNameDisplay &&
        !managerPhoneNumberDisplay &&
        !managerEmailDisplay) {
      stringList.add(localization.contactPersonInfoHidden);
    } else {
      for (var item in managerSetData) {
        if (item['isVisible']) {
          if (ConvertService.isNotEmptyValidate(
              jobpostingData[InputDepthEnum.managerInfoDto.key][item['key']])) {
            stringList.add(
                '${item['keyword']}: ${jobpostingData[InputDepthEnum.managerInfoDto.key][item['key']]}');
          }
        } else {
          stringList.add('${item['keyword']}: ${ localization.private}');
        }
      }
    }
    return stringList;
  }

  setSelectedPreferentialList(List<PreferentialConditionModel> itemList) {
    setState(() {
      selectedPreferentialList = [...itemList];
    });
  }

  setSelectedJobList(List<DefineModel> itemList) {
    selectedJobList = [...itemList];
  }

  setSelectedPreferenceConditionList(
      List<PreferentialConditionModel> itemList) {
    selectedPreferenceConditionList = [...itemList];
  }

  setJobpostingData(String key, dynamic value,
      {InputDepthEnum depth = InputDepthEnum.none}) {
    if (depth == InputDepthEnum.none) {
      jobpostingData[key] = value;
    } else {
      jobpostingData[depth.key][key] = value;
    }
  }

  showWorkConditionDataAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return JobpostingWorkConditionWidget(
          dayList: dayList,
          workPeriodList: workPeriodList,
          workTypeList: workTypeList,
          jobpostingData: jobpostingData,
          setData: setJobpostingData,
          stepController: workConditionStep,
        );
      },
    ).then((value) => {confirm()});
  }

  showManagerDataAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return JobpostingManagerWidget(
          jobpostingData: jobpostingData,
          setData: setJobpostingData,
        );
      },
    ).then((value) => {confirm()});
  }

  showRecruitConditionDataAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return JobpostingRecruitConditionWidget(
            jobpostingData: jobpostingData,
            setData: setJobpostingData,
            preferentialConditionGroup: preferentialConditionGroup,
            preferentialConditionList: preferentialConditionList,
            schoolTypes: schoolTypes,
            stepController: recruitConditionStep);
      },
    ).then((value) => {confirm()});
  }

  showRecruitInfoDataAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return JobpostingRecruitInfoWidget(
            jobpostingData: jobpostingData,
            setData: setJobpostingData,
            initSelectedList: selectedJobList,
            setInitSelectedList: setSelectedJobList,
            stepController: recruitInfoStep);
      },
    ).then((value) => {confirm()});
  }

  showJobpostingPhotoAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return JobpostingPhotoWidget(
          initialPhotoList: selectedJobpostingPhoto,
          setSelectedJobpostingPhoto: setSelectedJobpostingPhoto,
          addDeleteFiles: addDeleteFiles,
        );
      },
    ).then((value) => {confirm()});
  }

  showDialogCancelUpdateJobposing() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.cancelWriting,
          alertContent: localization.confirmPageNavigationUnsavedChanges,
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            context.pop();
            context.pop();
          },
        );
      },
    );
  }

  showBottomCreateJobposting() {
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
        return JobpostingCompleteCreateBottomsheet(
          type: widget.feature == JobpostingEditEnum.update.path
              ? JobpostingEditEnum.update.path
              : JobpostingEditEnum.reregister.path,
          matchData: matchData!,
          areaTopData: areaTopData!,
        );
      },
    ).whenComplete(() {
      context.pop();
      context.pop();
    });
  }

  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              appBar: CommonAppbar(
                title: widget.feature == JobpostingEditEnum.update.path
                    ? localization.editJobPost
                    : localization.repostJobPost,
                backFunc: showDialogCancelUpdateJobposing,
              ),
              body: !isLoading
                  ? Stack(
                      children: [
                        CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                        color: CommonColors.red02,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        localization.photoBoostsJobApplications,
                                        style: TextStyle(
                                          color: CommonColors.red,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: selectedJobpostingPhoto.isNotEmpty &&
                                      selectedJobpostingPhoto[0]['atIdx'] !=
                                          null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                            height: (CommonSize.vw * 0.9166 -
                                                        10.w) /
                                                    4 *
                                                    3 +
                                                20.w,
                                            child: Swiper(
                                              scrollDirection: Axis.horizontal,
                                              onIndexChanged: (value) {
                                                setSwiper(value);
                                              },
                                              itemCount: selectedJobpostingPhoto
                                                  .length,
                                              viewportFraction: 0.9166,
                                              scale: 1,
                                              loop: false,
                                              outer: true,
                                              itemBuilder: (context, index) {
                                                var item =
                                                    selectedJobpostingPhoto[
                                                        index];
                                                return Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      5.w, 0, 5.w, 16.w),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        showJobpostingPhotoAlert();
                                                        confirm();
                                                      },
                                                      child: item['atIdx'] !=
                                                              null
                                                          ? Container(
                                                              height: (CommonSize.vw *
                                                                          0.9166 -
                                                                      10.w) /
                                                                  4 *
                                                                  3,
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(
                                                                      12.w)),
                                                              child:
                                                                  Image.network(
                                                                item['url'],
                                                                fit: BoxFit
                                                                    .cover,
                                                              ))
                                                          : Container(
                                                              height: (CommonSize
                                                                              .vw *
                                                                          0.9166 -
                                                                      10.w) /
                                                                  4 *
                                                                  3,
                                                              clipBehavior:
                                                                  Clip.hardEdge,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(12.w)),
                                                              child: Image.file(
                                                                File(item[
                                                                    'url']),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ))),
                                                );
                                              },
                                            )),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            for (var i = 0;
                                                i <
                                                    selectedJobpostingPhoto
                                                        .length;
                                                i++)
                                              AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                margin: EdgeInsets.fromLTRB(
                                                    2.w, 0, 2.w, 0),
                                                width: activeIndex == i
                                                    ? 20.w
                                                    : 6.w,
                                                height: 6.w,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          500.w),
                                                  color: activeIndex == i
                                                      ? CommonColors.black2b
                                                      : CommonColors.grayF2,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                      child: GestureDetector(
                                        onTap: () {
                                          showJobpostingPhotoAlert();
                                        },
                                        child: Container(
                                          clipBehavior: Clip.hardEdge,
                                          height:
                                              (CommonSize.vw - 40.w) / 360 * 244,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                            color: CommonColors.white,
                                            border: Border.all(
                                              width: 1.w,
                                              color: CommonColors.red02,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/icon/iconCamera.png',
                                                width: 36.w,
                                                height: 36.w,
                                              ),
                                              SizedBox(
                                                height: 4.w,
                                              ),
                                              Text(
                                                localization.registerPhoto,
                                                style: TextStyle(
                                                  color: CommonColors.grayD9,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 24.w,
                              ),
                            ),
                            ProfileTitle(
                              title: localization.jobPostTitle,
                              required: true,
                              text: '',
                              onTap: () {},
                              hasArrow: false,
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                              sliver: SliverToBoxAdapter(
                                child: Stack(
                                  children: [
                                    CommonKeyboardAction(
                                      focusNode: textAreaNode,
                                      child: TextFormField(
                                        focusNode: textAreaNode,
                                        controller: jobpostingTitleController,
                                        key: textAreaKey,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        autocorrect: false,
                                        cursorColor: CommonColors.black,
                                        style: commonInputText(),
                                        maxLength: 40,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        decoration: areaInput(
                                          hintText: localization.createAttractiveJobTitle,
                                        ),
                                        onTap: () {
                                          ScrollCenter(textAreaKey);
                                        },
                                        minLines: 2,
                                        maxLines: 2,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            jobpostingData['jpTitle'] =
                                                jobpostingTitleController.text;
                                            confirm();
                                          });
                                        },
                                      ),
                                    ),
                                    Positioned(
                                        right: 10.w,
                                        bottom: 10.w,
                                        child: Text(
                                          '${jobpostingTitleController.text.length} / 40',
                                          style: TextStyles.counter,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                            ProfileListItemWidget(
                              onTap: () => showWorkConditionDataAlert(),
                              title: localization.workingConditions2,
                              content: null,
                              isRequire: true,
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                              sliver: SliverToBoxAdapter(
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    ProfileBox(
                                        text: InputStepEnum.complete.msg),
                                  ],
                                ),
                              ),
                            ),
                            ProfileListItemWidget(
                              onTap: () => showRecruitConditionDataAlert(),
                              title: localization.recruitmentRequirements2,
                              content: null,
                              isRequire: true,
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                              sliver: SliverToBoxAdapter(
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    ProfileBox(
                                        text: InputStepEnum.complete.msg),
                                  ],
                                ),
                              ),
                            ),
                            ProfileListItemWidget(
                              onTap: () => showRecruitInfoDataAlert(),
                              title: localization.jobDescription3,
                              content: null,
                              isRequire: true,
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                              sliver: SliverToBoxAdapter(
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    ProfileBox(
                                        text: InputStepEnum.complete.msg),
                                  ],
                                ),
                              ),
                            ),
                            ProfileListItemWidget(
                              onTap: () {},
                              title: localization.contactPersonInfo,
                              content: mergeManagerInfoContent().isEmpty
                                  ? localization.checkRecruiterContactInfo
                                  : null,
                              isRequire: true,
                              isEditable: false,
                            ),
                            if (mergeManagerInfoContent().isNotEmpty)
                              SliverPadding(
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                                sliver: SliverToBoxAdapter(
                                  child: Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.w,
                                    children: [
                                      for (int i = 0;
                                          i < mergeManagerInfoContent().length;
                                          i++)
                                        ProfileBox(
                                            text: mergeManagerInfoContent()[i]),
                                    ],
                                  ),
                                ),
                              ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                              sliver: SliverToBoxAdapter(
                                child: CommonButton(
                                  fontSize: 15,
                                  onPressed: () {
                                    if (isConfirm) {
                                      if (widget.feature ==
                                          JobpostingEditEnum.update.path) {
                                        updateJobposting();
                                      } else {
                                        //재등록
                                        createJobposting();
                                      }
                                    }
                                  },
                                  confirm: isConfirm,
                                  text: widget.feature ==
                                          JobpostingEditEnum.update.path
                                      ? localization.edit
                                      : localization.repostJobPost,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isRunning) const Loader(),
                      ],
                    )
                  : const Loader()),
        ),
      ],
    );
  }
}
