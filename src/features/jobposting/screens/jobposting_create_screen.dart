import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/input_step_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_manage_tap_enum.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingCreateScreen extends ConsumerStatefulWidget {
  const JobpostingCreateScreen({super.key});

  @override
  ConsumerState<JobpostingCreateScreen> createState() =>
      _JobpostingCreateScreenState();
}

class _JobpostingCreateScreenState extends ConsumerState<JobpostingCreateScreen>
    with SingleTickerProviderStateMixin, Files {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  int jobpostingPageIndex = 0;

  late Future<void> _allAsyncTasks;
  bool isLoading = true;

  final jobpostingTitleController = TextEditingController();

  List<Map<String, dynamic>> selectedJobpostingPhoto = [];

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
      'jpSalary': null,
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
      'workHour': <Map<String, dynamic>>[],
      //근무 시간 협의 가능 0 불가능 1: 가능
      'jpWorkHourChangeable': 0,
      //휴게시간
      'restHour': 0,
      // 휴게시간 협의 가능 0 불가능 1: 가능
      'jpRestHourChangeable': 0,

      // 소정 근무 시간
      'jpContractualWorkHour': null,

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
      'jpRecruitedCount': null,
      // //성별 0무관 1여자 2남자
      'jpSex': 0,
      // //최소 나이  연력무관이면 Null이거나 보내지 말것
      'jpAgeMin': null,
      // //최대 나이  연력무관이면 Null이거나 보내지 말것
      'jpAgeMax': null,
      // //중장년층 채용 여부 1채용 0미채용
      'jpMiddleAge': 0,
      // //학력
      'stIdx': null,
      'jpEduStatus': null,

      'jpCareerType': 0,

      'jpCareerMin': null,
      'jpCareerMax': null,
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
              alertTitle: localization.notification,
            );
          },
        );
      }
    }
  }

  bool isRunning = false;

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

  createJobposting() async {
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
    if (jobpostingData['workCondition']['workHour'][0]['jphEndTime'] ==
        '24:00') {
      setState(() {
        jobpostingData['workCondition']['workHour'][0]['jphEndTime'] = '23:59';
      });
    }
    if (jobpostingData['workCondition']['workHour'][0]['jphStartTime'] ==
        '24:00') {
      setState(() {
        jobpostingData['workCondition']['workHour'][0]['jphStartTime'] =
            '23:59';
      });
    }
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .createJobposting(jobpostingData);
    if (result.status == 200) {
      if (result.type == 1) {
        if (selectedJobpostingPhoto.isNotEmpty) {
          List<Future<void>> saveFileFutures = [];
          for (Map<String, dynamic> item in selectedJobpostingPhoto) {
            saveFileFutures.add(saveFile(item, result.data));
          }

          // 모든 saveFile 호출이 완료될 때까지 기다립니다.
          await Future.wait(saveFileFutures);
        }
        ApiResultModel openSearchResult = await ref
            .read(jobpostingControllerProvider.notifier)
            .createJobpostingOpenSearch(result.data);
        showBottomCreateJobposting();
      } else {
        showDefaultToast(localization.jobPostRegistrationFailed);
      }
    } else if (result.status != 200) {
      if (result.status == 401 && result.type == -2001) {
        showForbiddenAlert(result.data);
      } else if (result.type == -609) {
        showBlockAlert();
      } else {
        showDefaultToast(localization.jobPostRegistrationFailed);
      }
    }
    setState(() {
      isRunning = false;
    });
  }

  showForbiddenAlert(keyword) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: localization.jobPostRegistrationBlockedByKeyword(keyword),
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
        });
  }

  showBlockAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: localization.accountRestrictedByAdministrator,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
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

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
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
        UserModel? userProfileInfo = ref.read(userProfileProvider);
        if (userProfileInfo != null) {
          jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerName'] =
              userProfileInfo.companyInfo!.managerName;
          jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerEmail'] =
              userProfileInfo.companyInfo!.managerEmail;
          jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerHp'] =
              userProfileInfo.companyInfo!.managerPhoneNumber;
        }
        isLoading = false;
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
          jobpostingData['jpType'] == JobpostingTypeEnum.normal.param &&
              // 2)공고 제목
              jobpostingData['jpTitle'] != '' &&
              // 3) 공고 사진
              // selectedJobpostingPhoto.isNotEmpty &&
              // workCondition 1-1) 급여 형태

              ConvertService.isNotEmptyValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpSalaryType']) &&
              // workCondition 1-2) 급여
              // TODO : case 1
              jobpostingData[InputDepthEnum.workCondition.key]['jpSalary'] !=
                  null &&
              // TODO : case 2
              // ConvertService.negotiableValueValidate(jobpostingData[InputDepthEnum.workCondition.key]['jpSalary'],ConvertService.convertIntToBool(jobpostingData[InputDepthEnum.workCondition.key]
              // ['jpSalaryNegotiable'])) &&
              // workCondition1-3) 급여 협의
              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpSalaryNegotiable']) &&
              // workCondition 2) 근무 형태
              jobpostingData[InputDepthEnum.workCondition.key]['wtIdx'] !=
                  null &&

              // workCondition 3) 근무 기간

              // TODO : case 1
              // jobpostingData[InputDepthEnum.workCondition.key]['wpIdx'] !=
              //     null &&

              // TODO : case 2
              // ConvertService.negotiableValueValidate(jobpostingData[InputDepthEnum.workCondition.key]['wpIdx'], ConvertService.convertIntToBool(jobpostingData[InputDepthEnum.workCondition.key]['jpPeriodChangeable'])) &&
              // workCondition 4-1) 근무 요일

              // TODO : case 1
              // jobpostingData[InputDepthEnum.workCondition.key]['wdIdx'] !=
              //     null &&

              // TODO : case 2
              // ConvertService.negotiableListValidate(jobpostingData[InputDepthEnum.workCondition.key]['wdIdx'], ConvertService.convertIntToBool(jobpostingData[InputDepthEnum.workCondition.key]['jpDaysChangeable'])) &&

              // workCondition 4-2) 근무 요일 협의 가능

              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpDaysChangeable']) &&

              // workCondition 5-1) 근무시간

              // TODO : case 1

              // workCondition 5-2) 근무시간 협의가능
              ConvertService.intTypeBoolValidate(
                  jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpWorkHourChangeable']) &&


              // workCondition 7) 소정 근무 시간
              jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpContractualWorkHour'] !=
                  null &&

              // workCondition 8-1) 근무지 별도 근무지
              jobpostingData[InputDepthEnum.workCondition.key]['jpAddressType'] ==
                  1 &&

              // workCondition 8-1) 회사 주소
              jobpostingData[InputDepthEnum.workCondition.key]['jpAddress'] !=
                  '' &&

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
          stringList.add('${item['keyword']}: ${localization.private}');
        }
      }
    }
    return stringList;
  }

  //수습기간

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
            stepController: workConditionStep);
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
      useSafeArea: false,
      barrierDismissible: false,
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
          stepController: recruitInfoStep,
        );
      },
    ).then((value) => {confirm()});
  }

  showJobpostingPhotoAlert() {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return JobpostingPhotoWidget(
          initialPhotoList: selectedJobpostingPhoto,
          setSelectedJobpostingPhoto: setSelectedJobpostingPhoto,
        );
      },
    ).then((value) => {confirm()});
  }

  showDialogCancelCreateJobposing() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
          type: JobpostingEditEnum.create.path,
          matchData: matchData!,
          areaTopData: areaTopData!,
        );
      },
    ).whenComplete(() {
      context.pushReplacement(
          '/jobpostingmanage?tab=${JobpostingManageTapEnum.waitingPermission.tabIndex}');
    });
  }

  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  SwiperController swiperController = SwiperController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            showDialogCancelCreateJobposing();
          }
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 15;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            // Right Swipe
            showDialogCancelCreateJobposing();
          }
        },
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: CommonAppbar(
                title: localization.newJobPostRegistration,
                backFunc: showDialogCancelCreateJobposing,
              ),
              body: !isLoading
                  ? CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              height: 48.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
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
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: selectedJobpostingPhoto.isNotEmpty
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                        height:
                                            (CommonSize.vw * 0.9166 - 10.w) /
                                                    360 *
                                                    244 +
                                                20.w,
                                        child: Swiper(
                                          scrollDirection: Axis.horizontal,
                                          itemCount:
                                              selectedJobpostingPhoto.length,
                                          viewportFraction: 0.9166,
                                          scale: 1,
                                          loop: false,
                                          outer: true,
                                          onIndexChanged: (value) {
                                            setSwiper(value);
                                          },
                                          itemBuilder: (context, index) {
                                            var item =
                                                selectedJobpostingPhoto[index];
                                            return Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  5.w, 0, 5.w, 16.w),
                                              child: GestureDetector(
                                                  onTap: () {
                                                    showJobpostingPhotoAlert();
                                                    confirm();
                                                  },
                                                  child: Container(
                                                    height: (CommonSize.vw *
                                                                0.9166 -
                                                            10.w) /
                                                        4 *
                                                        3,
                                                    clipBehavior: Clip.hardEdge,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    12.w)),
                                                    child: Image.file(
                                                      File(
                                                        item['url'],
                                                      ),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )),
                                            );
                                          },
                                        )),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        for (var i = 0;
                                            i < selectedJobpostingPhoto.length;
                                            i++)
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            margin: EdgeInsets.fromLTRB(
                                                2.w, 0, 2.w, 0),
                                            width:
                                                activeIndex == i ? 20.w : 6.w,
                                            height: 6.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(500.w),
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
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.w),
                                        color: CommonColors.white,
                                        border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.red02,
                                        ),
                                      ),
                                      child: AspectRatio(
                                        aspectRatio: 360 / 244,
                                        child:  Column(
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
                                      )

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
                                      onTap: () {
                                        ScrollCenter(textAreaKey);
                                      },
                                      key: textAreaKey,
                                      focusNode: textAreaNode,
                                      textInputAction: TextInputAction.newline,
                                      keyboardType: TextInputType.multiline,


                                      controller: jobpostingTitleController,
                                      autocorrect: false,
                                      cursorColor: CommonColors.black,
                                      style: commonInputText(),
                                      maxLength: 40,
                                      decoration: areaInput(
                                        hintText: localization.createAttractiveJobTitle,
                                      ),

                                      textAlignVertical: TextAlignVertical.top,
                                      minLines: 2,
                                      maxLines: 2,
                                      onChanged: (dynamic value) {
                                        setState(() {
                                          jobpostingData['jpTitle'] =
                                              jobpostingTitleController.text;
                                          confirm();
                                        });
                                      },
                                    )),
                                Positioned(
                                    right: 10.w,
                                    bottom: 10.w,
                                    // TODO: 이곳은 언어팩 적용 어떤식으로 해야할지 물어보기 (이건호)
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
                          content: workConditionStep.currentStep ==
                                  InputStepEnum.init
                              ? localization.enterWorkingConditionsForTheCandidate
                              : null,
                          isRequire: true,
                        ),
                        if (workConditionStep.currentStep != InputStepEnum.init)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                            sliver: SliverToBoxAdapter(
                              child: Wrap(
                                spacing: 8.w,
                                runSpacing: 8.w,
                                children: [
                                  ProfileBox(
                                      text: workConditionStep.currentStep.msg),
                                ],
                              ),
                            ),
                          ),
                        ProfileListItemWidget(
                          onTap: () => showRecruitConditionDataAlert(),
                          title: localization.recruitmentRequirements2,
                          content: recruitConditionStep.currentStep ==
                                  InputStepEnum.init
                              ? localization.enterJobResponsibilitiesForTheCandidate
                              : null,
                          isRequire: true,
                        ),
                        if (recruitConditionStep.currentStep !=
                            InputStepEnum.init)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                            sliver: SliverToBoxAdapter(
                              child: Wrap(
                                spacing: 8.w,
                                runSpacing: 8.w,
                                children: [
                                  ProfileBox(
                                      text:
                                          recruitConditionStep.currentStep.msg),
                                ],
                              ),
                            ),
                          ),
                        ProfileListItemWidget(
                          onTap: () => showRecruitInfoDataAlert(),
                          title: localization.jobDescription3,
                          content:
                              recruitInfoStep.currentStep == InputStepEnum.init
                                  ? localization.enterJobResponsibilitiesForTheCandidate
                                  : null,
                          isRequire: true,
                        ),
                        if (recruitInfoStep.currentStep != InputStepEnum.init)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                            sliver: SliverToBoxAdapter(
                              child: Wrap(
                                spacing: 8.w,
                                runSpacing: 8.w,
                                children: [
                                  ProfileBox(
                                      text: recruitInfoStep.currentStep.msg),
                                ],
                              ),
                            ),
                          ),
                        ProfileListItemWidget(
                          onTap: () => showManagerDataAlert(),
                          title: localization.contactPersonInfo,
                          content: mergeManagerInfoContent().isEmpty
                              ? localization.checkRecruiterContactInfo
                              : null,
                          isRequire: true,
                        ),
                        if (mergeManagerInfoContent().isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
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
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 12.w,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                            decoration: BoxDecoration(
                              color: CommonColors.grayF2,
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12.w),
                            child: Text(
                              localization.jobPostDisplayPeriod30Days,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: CommonColors.gray80,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 50.w,
                          ),
                        ),
                        if (!isConfirm)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                localization.pleaseEnterRequiredInformation,
                                style: commonErrorAuth(),
                              ),
                            ),
                          ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                              20.w, 8.w, 20.w, CommonSize.commonBoard(context)),
                          sliver: SliverToBoxAdapter(
                            child: CommonButton(
                              onPressed: () {
                                if (isConfirm) {
                                  createJobposting();
                                }
                              },
                              fontSize: 15,
                              confirm: isConfirm,
                              text: localization.register,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Loader(),
            ),
          ],
        ),
      ),
    );
  }
}
