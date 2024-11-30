import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/condition_career_enum.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/input_step_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_check.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_constants.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_box.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/preferential_condition_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/edu_finish_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/edu_last_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/preference_condition_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_radio_button_text.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/sliver_divider.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingRecruitConditionWidget extends ConsumerStatefulWidget {
  const JobpostingRecruitConditionWidget(
      {required this.jobpostingData,
      required this.setData,
      required this.preferentialConditionGroup,
      required this.preferentialConditionList,
      required this.schoolTypes,
      required this.stepController,
      super.key});

  final Map<String, dynamic> jobpostingData;

  final Function setData;

  final List<PreferentialConditionModel> preferentialConditionGroup;

  final List<PreferentialConditionModel> preferentialConditionList;

  // final Function setSelectedPreferentialList;

  final List<ProfileModel> schoolTypes;

  final InputStepController stepController;

  @override
  ConsumerState<JobpostingRecruitConditionWidget> createState() =>
      _JobpostingRecruitConditionWidgetState();
}

class _JobpostingRecruitConditionWidgetState
    extends ConsumerState<JobpostingRecruitConditionWidget> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  bool isConfirm = false;

  bool isRecruitmentNumberDetermined = false;

  bool isCanApplyAnyAge = false;

  bool isMiddleAgeHiring = false;

  ConditionGenderEnum conditionGenderType = ConditionGenderEnum.anyGender;

  ConditionCareerEnum conditionCareerType = ConditionCareerEnum.anyCareer;

  String? selectedSchoolType;

  int? selectedSchoolTypeKey;

  List<dynamic> selectedPreferenceConditionKeyList = [];

  List<PreferentialConditionModel> selectedPreferentialItemList = [];

  List<Map<String, dynamic>> selectedPreferentialParam = [];

  final jobPositionController = TextEditingController();

  final recruitmentNumberController = TextEditingController();

  final minAgeController = TextEditingController();

  final maxAgeController = TextEditingController();

  final minCareerController = TextEditingController();

  final maxCareerController = TextEditingController();

  final applyEligibilityController = TextEditingController();

  List<dynamic> selectedPreference = [];
  String? selectedEducationStatus;
  String educationStatusErrorMessage = '';

  @override
  void initState() {
    Future(() {
      savePageLog();
    });

    jobPositionController.text =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpJobPosition'];
    if (widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpRecruitedCount'] !=
        null) {
      recruitmentNumberController.text = widget
          .jobpostingData[InputDepthEnum.recruitmentCondition.key]
              ['jpRecruitedCount']
          .toString();
    }
    isRecruitmentNumberDetermined =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
                        ['jpRecruitedCount'] ==
                    0 ||
                widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
                        ['jpRecruitedCount'] ==
                    null
            ? false
            : true;
    conditionGenderType = setConditionGenderEnumFromInt(widget
        .jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpSex']);
    if (widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpAgeMin'] !=
        null) {
      minAgeController.text = widget
          .jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpAgeMin']
          .toString();
    }
    if (widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpAgeMax'] !=
        null) {
      maxAgeController.text = widget
          .jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpAgeMax']
          .toString();
    }
    isCanApplyAnyAge =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
                        ['jpAgeMin'] ==
                    null &&
                widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
                        ['jpAgeMax'] ==
                    null
            ? true
            : false;
    isMiddleAgeHiring = ConvertService.convertIntToBool(
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpMiddleAge']);
    conditionCareerType = setConditionCareerEnumFromInt(
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpCareerType']);

    if (widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpCareerMin'] !=
        null) {
      minCareerController.text = widget
          .jobpostingData[InputDepthEnum.recruitmentCondition.key]
              ['jpCareerMin']
          .toString();
    }

    if (widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpCareerMax'] !=
        null) {
      maxCareerController.text = widget
          .jobpostingData[InputDepthEnum.recruitmentCondition.key]
              ['jpCareerMax']
          .toString();
    }

    applyEligibilityController.text =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['jpApplyEligibility'];

    selectedSchoolTypeKey =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]['stIdx'];
    selectedEducationStatus = widget
        .jobpostingData[InputDepthEnum.recruitmentCondition.key]['jpEduStatus'];

    selectedPreference =
        widget.jobpostingData[InputDepthEnum.recruitmentCondition.key]
            ['preferentialConditions'];

    widget.stepController.changeStep(InputStepEnum.ongoing);
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  apply(List<dynamic> selectItem) {
    setState(() {
      selectedPreference = [...selectItem];
    });
  }

  deletePreferenceConditionItem(Map<String, dynamic> item) {
    item['jppcType'] == 'key' ? removeTypeKey(item) : removeTypeString(item);
  }

  removeTypeKey(Map<String, dynamic> item) {
    setState(() {
      selectedPreference
          .removeWhere((element) => element['pcName'] == item['pcName']);
    });
  }

  removeTypeString(Map<String, dynamic> item) {
    setState(() {
      selectedPreference.removeWhere(
          (element) => element['jppcString'] == item['jppcString']);
    });
  }

  // selectPreferenceCondition(int preferenceConditionKey){
  //   setState(() {
  //     if(selectedPreferenceConditionItem.contains(preferenceConditionKey)){
  //       selectedPreferenceConditionItem.remove(preferenceConditionKey);
  //     }else{
  //       // selectedPreferenceConditionItem.add(preferenceConditionKey);
  //     }
  //   });
  // }

  setConditionGenderTypeEnum(ConditionGenderEnum conditionGenderTypeEnum) {
    setState(() {
      conditionGenderType = conditionGenderTypeEnum;
    });
  }

  setConditionCareerTypeEnum(ConditionCareerEnum conditionCareerTypeEnum) {
    setState(() {
      conditionCareerType = conditionCareerTypeEnum;
    });
  }

  bool ageValidate() {
    if (isCanApplyAnyAge) {
      return true;
    } else {
      if (ageErrorMsg == null &&
          minAgeController.text.isNotEmpty &&
          maxAgeController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool careerValidate() {
    if (conditionCareerType != ConditionCareerEnum.experienced) {
      return true;
    } else {
      if (careerErrorMsg == null &&
          minCareerController.text.isNotEmpty &&
          maxCareerController.text.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  bool confirm() {
    //필수 1) 모집분야, 모집인원 2) 모집인원(항상 값이 있음)
    if (jobPositionController.text.isNotEmpty &&
        applyEligibilityController.text.isNotEmpty &&
        ageValidate() &&
        careerValidate()) {
      return true;
    } else {
      return false;
    }
  }

  showPreference() {
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
        return PreferenceConditionBottomSheet(
            itemGroupList: widget.preferentialConditionGroup,
            selectedItemKey: selectedPreferenceConditionKeyList,
            selectedPreference: selectedPreference,
            preferentialConditionList: widget.preferentialConditionList,
            apply: apply);
      },
    );
  }

  showEducationLast() {
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
      builder: (BuildContext context) {
        return EduLastBottomSheet(
          dataArr: widget.schoolTypes,
          initItem: selectedSchoolTypeKey ?? 15245,
          title: '학력',
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedSchoolTypeKey = value;
        });
      }
    });
  }

  clearAgeInfo() {
    minAgeController.clear();
    maxAgeController.clear();
    ageErrorMsg = null;
  }

  clearCareerInfo() {
    minCareerController.clear();
    maxCareerController.clear();
    careerErrorMsg = null;
  }

  String? ageErrorMsg;

  String? careerErrorMsg;

  String? minMaxValidate(TextEditingController minController,
      TextEditingController maxController, String type) {
    return ValidateService.minMaxValidate(minController, maxController, type);
  }

  void saveRecruitmentConditionData() {
    void setRecruitmentConditionData(String key, dynamic value) {
      widget.setData(key, value, depth: InputDepthEnum.recruitmentCondition);
    }

    setRecruitmentConditionData('jpJobPosition', jobPositionController.text);

    setRecruitmentConditionData(
      'jpRecruitedCount',
      isRecruitmentNumberDetermined
          ? ConvertService.convertStringToInt(recruitmentNumberController.text)
          : 0,
    );

    setRecruitmentConditionData('jpSex', conditionGenderType.param);

    setRecruitmentConditionData(
      'jpAgeMin',
      isCanApplyAnyAge
          ? null
          : ConvertService.convertStringToInt(minAgeController.text),
    );

    setRecruitmentConditionData(
      'jpAgeMax',
      isCanApplyAnyAge
          ? null
          : ConvertService.convertStringToInt(maxAgeController.text),
    );

    setRecruitmentConditionData(
      'jpMiddleAge',
      ConvertService.convertBoolToInt(isMiddleAgeHiring),
    );

    setRecruitmentConditionData('jpCareerType', conditionCareerType.param);

    setRecruitmentConditionData(
      'jpCareerMin',
      conditionCareerType == ConditionCareerEnum.experienced
          ? ConvertService.convertStringToInt(minCareerController.text)
          : 0,
    );

    setRecruitmentConditionData(
      'jpCareerMax',
      conditionCareerType == ConditionCareerEnum.experienced
          ? ConvertService.convertStringToInt(maxCareerController.text)
          : 0,
    );

    setRecruitmentConditionData(
        'jpApplyEligibility', applyEligibilityController.text);

    setRecruitmentConditionData(
      'preferentialConditions',
      [...selectedPreference],
    );

    setRecruitmentConditionData('stIdx', selectedSchoolTypeKey);

    setRecruitmentConditionData('jpEduStatus', selectedEducationStatus);

    widget.stepController.changeStep(InputStepEnum.complete);
    context.pop();
  }

  showEducationFinish() {
    showModalBottomSheet(
      isScrollControlled: true,
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
      builder: (BuildContext context) {
        return EduFinishBottomSheet(
          dataArr: ProfileConstants.educationStatusList,
          initItem: selectedEducationStatus ?? '',
          title: '졸업 여부',
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedEducationStatus = value;
          checkEducationStatusErrorText();
        });
      }
    });
  }

  checkEducationStatusErrorText() {
    setState(() {
      if (selectedEducationStatus == null) {
        educationStatusErrorMessage = ProfileMsgService.educationStatusEmpty;
      } else {
        educationStatusErrorMessage = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 15;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            // Right Swipe
            context.pop();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: '모집 조건',
              ),
              body: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        ProfileTitle(
                          title: '모집분야',
                          required: true,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: TextFormField(
                              key: const Key('jobposting_job_position'),
                              controller: jobPositionController,
                              autocorrect: false,
                              cursorColor: CommonColors.black,
                              style: commonInputText(),
                              maxLength: 50,
                              decoration: suffixInput(
                                hintText: ProfileMsgService.jobPositionEnter,
                              ),
                              onChanged: (value) {},
                              onEditingComplete: () {
                                // if (textController.text.isNotEmpty) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                // }
                              },
                            ),
                          ),
                        ),
                        ProfileTitle(
                          title: '모집인원',
                          required: true,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ProfileRadio(
                                    onChanged: (value) {
                                      setState(() {
                                        isRecruitmentNumberDetermined = value;
                                      });
                                    },
                                    groupValue: isRecruitmentNumberDetermined,
                                    value: false,
                                    label: '인원 미정',
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: ProfileRadio(
                                    onChanged: (value) {
                                      setState(() {
                                        isRecruitmentNumberDetermined = value;
                                      });
                                    },
                                    groupValue: isRecruitmentNumberDetermined,
                                    value: true,
                                    label: '직접 입력',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        if (isRecruitmentNumberDetermined)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                            sliver: SliverToBoxAdapter(
                              child: TextFormField(
                                controller: recruitmentNumberController,
                                key: const Key('jobposting_probation_period'),
                                keyboardType: TextInputType.number,
                                autocorrect: false,
                                cursorColor: CommonColors.black,
                                style: commonInputText(),
                                textAlign: TextAlign.end,
                                maxLength: 2,
                                decoration: suffixInput(
                                  suffixText: '명',
                                  suffixColor: CommonColors.grayB2,
                                  suffixSize: 14.sp,
                                  hintText: '모집인원을 입력해주세요.',
                                ),
                                minLines: 1,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        const SliverDivider(
                          big: true,
                        ),

                        ProfileTitle(
                          title: '성별',
                          required: false,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setConditionGenderTypeEnum(value);
                                    },
                                    groupValue: conditionGenderType,
                                    value: ConditionGenderEnum.anyGender,
                                    label: ConditionGenderEnum.anyGender.label,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setConditionGenderTypeEnum(value);
                                    },
                                    groupValue: conditionGenderType,
                                    value: ConditionGenderEnum.male,
                                    label: ConditionGenderEnum.male.label,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setConditionGenderTypeEnum(value);
                                    },
                                    groupValue: conditionGenderType,
                                    value: ConditionGenderEnum.female,
                                    label: ConditionGenderEnum.female.label,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverDivider(),
                        ProfileTitle(
                          title: '연령',
                          required: false,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: ProfileRadio(
                                    onChanged: (value) {
                                      setState(() {
                                        isCanApplyAnyAge = value;
                                        clearAgeInfo();
                                      });
                                    },
                                    groupValue: isCanApplyAnyAge,
                                    value: true,
                                    label: '연령 무관',
                                  ),
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Expanded(
                                  child: ProfileRadio(
                                    onChanged: (value) {
                                      setState(() {
                                        isCanApplyAnyAge = value;
                                      });
                                    },
                                    groupValue: isCanApplyAnyAge,
                                    value: false,
                                    label: '직접 입력',
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),

                        if (!isCanApplyAnyAge)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: minAgeController,
                                      key: const Key('jobposting_min_age'),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      cursorColor: CommonColors.black,
                                      style: commonInputText(),
                                      maxLength: 2,
                                      textAlign: TextAlign.center,
                                      decoration: suffixInput(
                                        suffixText: '세 이상',
                                        suffixColor: CommonColors.black2b,
                                        suffixSize: 14.sp,
                                        // hintText: ProfileMsgService.minAgeEnter,
                                      ),
                                      minLines: 1,
                                      maxLines: 1,
                                      onChanged: (value) {
                                        setState(() {
                                          ageErrorMsg = minMaxValidate(
                                              minAgeController,
                                              maxAgeController,
                                              'age');
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                    child: Text(
                                      '~',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      controller: maxAgeController,
                                      key: const Key('jobposting_max_age'),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      cursorColor: CommonColors.black,
                                      style: commonInputText(),
                                      maxLength: 2,
                                      decoration: suffixInput(
                                        suffixText: '세 이하',
                                        suffixColor: CommonColors.black2b,
                                        suffixSize: 14.sp,
                                        // hintText: ProfileMsgService.maxAgeEnter,
                                      ),
                                      minLines: 1,
                                      maxLines: 1,
                                      onChanged: (value) {
                                        setState(() {
                                          ageErrorMsg = minMaxValidate(
                                              minAgeController,
                                              maxAgeController,
                                              'age');
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (ConvertService.isNotEmptyValidate(ageErrorMsg))
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 8.w),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                ageErrorMsg!,
                                style: TextStyles.error,
                              ),
                            ),
                          ),
                        PostingCheck(
                          onChanged: (value) {
                            setState(() {
                              isMiddleAgeHiring = !isMiddleAgeHiring;
                            });
                          },
                          groupValue: isMiddleAgeHiring,
                          value: true,
                          label: '중장년층 채용',
                        ),
                        const SliverDivider(),

                        ProfileTitle(
                          title: '학력',
                          required: false,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                          sliver: SliverToBoxAdapter(
                            child: SelectButton(
                              onTap: () {
                                showEducationLast();
                              },
                              text: selectedSchoolTypeKey != null
                                  ? widget.schoolTypes
                                      .where((e) =>
                                          e.schoolKey == selectedSchoolTypeKey)
                                      .map((e) => e.schoolType)
                                      .join('')
                                  : '',
                              hintText: '학력을 선택해주세요.',
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: SelectButton(
                              onTap: () {
                                showEducationFinish();
                              },
                              text: selectedEducationStatus ?? '',
                              hintText: '졸업 여부를 선택해 주세요.',
                            ),
                          ),
                        ),
                        ProfileTitle(
                          title: '경력',
                          required: false,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setState(() {
                                        setConditionCareerTypeEnum(value);
                                        clearCareerInfo();
                                      });
                                    },
                                    groupValue: conditionCareerType,
                                    value: ConditionCareerEnum.anyCareer,
                                    label: ConditionCareerEnum.anyCareer.label,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setState(() {
                                        setConditionCareerTypeEnum(value);
                                        clearCareerInfo();
                                      });
                                    },
                                    groupValue: conditionCareerType,
                                    value: ConditionCareerEnum.entry,
                                    label: ConditionCareerEnum.entry.label,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Expanded(
                                  child: CommonRadioTextButton(
                                    onChanged: (value) {
                                      setConditionCareerTypeEnum(value);
                                    },
                                    groupValue: conditionCareerType,
                                    value: ConditionCareerEnum.experienced,
                                    label:
                                        ConditionCareerEnum.experienced.label,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (conditionCareerType ==
                            ConditionCareerEnum.experienced)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: minCareerController,
                                      key: const Key('jobposting_min_career'),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      cursorColor: CommonColors.black,
                                      style: commonInputText(),
                                      maxLength: 2,
                                      textAlign: TextAlign.center,
                                      decoration: suffixInput(
                                        suffixText: '년 이상',
                                        suffixColor: CommonColors.black2b,
                                        suffixSize: 14.sp,
                                        hintText:
                                            ProfileMsgService.minCareerEnter,
                                      ),
                                      minLines: 1,
                                      maxLines: 1,
                                      onChanged: (value) {
                                        setState(() {
                                          careerErrorMsg = minMaxValidate(
                                              minCareerController,
                                              maxCareerController,
                                              'career');
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 24.w,
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: maxCareerController,
                                      key: const Key('jobposting_max_career'),
                                      keyboardType: TextInputType.number,
                                      autocorrect: false,
                                      cursorColor: CommonColors.black,
                                      style: commonInputText(),
                                      maxLength: 2,
                                      textAlign: TextAlign.center,
                                      decoration: suffixInput(
                                        suffixText: '년 이하',
                                        suffixColor: CommonColors.black2b,
                                        suffixSize: 14.sp,
                                        hintText:
                                            ProfileMsgService.maxCareerEnter,
                                      ),
                                      minLines: 1,
                                      maxLines: 1,
                                      onChanged: (value) {
                                        setState(() {
                                          careerErrorMsg = minMaxValidate(
                                              minCareerController,
                                              maxCareerController,
                                              'career');
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (conditionCareerType ==
                                ConditionCareerEnum.experienced &&
                            ConvertService.isNotEmptyValidate(careerErrorMsg))
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 8.w),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                careerErrorMsg!,
                                style: TextStyles.error,
                              ),
                            ),
                          ),
                        SliverDivider(
                          big: true,
                        ),

                        //TODO : 우대 조건
                        ProfileTitle(
                          title: '우대조건',
                          required: false,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.w,
                              children: [
                                for (Map<String, dynamic> item
                                    in selectedPreference)
                                  GestureDetector(
                                    onTap: () {
                                      deletePreferenceConditionItem(item);
                                    },
                                    child: ProfileBox(
                                      hasClose: true,
                                      text: item['jppcType'] == 'key'
                                          ? item['pcName']
                                          : item['jppcString'],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 20.w),
                          sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () {
                                showPreference();
                              },
                              child: Container(
                                height: 50.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.w),
                                    color: CommonColors.red02),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      '우대조건 추가하기',
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
                          ),
                        ),
                        const SliverDivider(),
                        ProfileTitle(
                          title: '지원자격',
                          required: true,
                          text: '',
                          onTap: () {},
                          hasArrow: false,
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
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
                                    controller: applyEligibilityController,
                                    autocorrect: false,
                                    cursorColor: CommonColors.black,
                                    style: areaInputText(),
                                    maxLength: 5000,
                                    decoration: areaInput(
                                      hintText: ProfileMsgService.contentEnter,
                                    ),
                                    textAlignVertical: TextAlignVertical.top,
                                    minLines: 3,
                                    maxLines: 10,
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                    onEditingComplete: () {},
                                  ),
                                ),
                                Positioned(
                                  right: 10.w,
                                  bottom: 10.w,
                                  child: Text(
                                    '${applyEligibilityController.text.length} / 5000',
                                    style: TextStyles.counter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BottomPadding(extra: 100),
                      ],
                    ),
                  ),
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
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBottom,
              child: CommonButton(
                onPressed: () {
                  if (confirm()) {
                    saveRecruitmentConditionData();
                  }
                },
                confirm: confirm(),
                text: '입력하기',
                width: CommonSize.vw,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
