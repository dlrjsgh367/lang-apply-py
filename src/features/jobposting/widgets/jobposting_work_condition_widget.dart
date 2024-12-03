import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/input_step_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/negotiable_enum.dart';
import 'package:chodan_flutter_app/enum/salary_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/service/address_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_msg_service.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_service.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_check.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/day_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/work_period_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/work_time_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/work_type_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_radio_button_text.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/etc/sliver_divider.dart';
import 'package:chodan_flutter_app/widgets/input/TimeInput.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingWorkConditionWidget extends ConsumerStatefulWidget {
  const JobpostingWorkConditionWidget(
      {required this.dayList,
      required this.workPeriodList,
      required this.workTypeList,
      required this.jobpostingData,
      required this.setData,
      required this.stepController,
      super.key});

  final List<DayModel> dayList;
  final List<ProfileModel> workPeriodList;
  final List<ProfileModel> workTypeList;

  final Map<String, dynamic> jobpostingData;

  final Function setData;

  final InputStepController stepController;

  @override
  ConsumerState<JobpostingWorkConditionWidget> createState() =>
      _JobpostingWorkConditionWidgetState();
}

class _JobpostingWorkConditionWidgetState
    extends ConsumerState<JobpostingWorkConditionWidget> {
  final probationPeriodTextController = TextEditingController();
  final salaryTextController = TextEditingController();
  final restHourTextController = TextEditingController();
  final contractualWorkHourTextController = TextEditingController();

  final companyAddressController = TextEditingController();

  final companyAddressDetailController = TextEditingController();

  List<int> selectedWorkTypes = [];

  List<int> selectedWorkPeriodList = [];

  String? selectedWorkType;

  String? selectedWorkPeriod;

  int? selectedWorkTypeKey;

  int? selectedWorkPeriodKey;

  List<int> initialSelectedDayItem = [];

  bool isConfirm = false;

  List workHour = [];

  int restHour = 0;

  //급여 협의 가능
  NegotiableEnum isSalaryNegotiable = NegotiableEnum.impossible;

  //근무 기간 협의 가능
  NegotiableEnum isWorkPeriodNegotiable = NegotiableEnum.impossible;

  //근무 요일 협의 가능
  NegotiableEnum isWorkDayNegotiable = NegotiableEnum.impossible;

  //근무 시간 협의 가능
  NegotiableEnum isWorkTimeNegotiable = NegotiableEnum.impossible;

  //휴게 시간 협의 가능
  NegotiableEnum isRestTimeNegotiable = NegotiableEnum.impossible;

  //급여 타입

  SalaryTypeEnum salaryType = SalaryTypeEnum.time;

  bool hasProbation = false;

  String? si;
  String? gu;
  String? dong;

  bool confirm() {
    //필수 값, 1) 급여@ 2)근무형태@ 3) 근무기간@ 4)근무요일@ 5) 근무시간@  6) 소정근무시간@ 7)근무지 주소@ /주소 상세는 선택

    if (salaryTextController.text.isNotEmpty &&
        selectedWorkTypeKey != null &&
        (selectedWorkPeriodKey != null ||
            isWorkPeriodNegotiable == NegotiableEnum.possible) &&
        isWorkTimeValidator(workHour) &&
        (restHour > 0 || isRestTimeNegotiable == NegotiableEnum.possible) &&
        (initialSelectedDayItem.isNotEmpty ||
            isWorkDayNegotiable == NegotiableEnum.possible) &&
        contractualWorkHourTextController.text.isNotEmpty &&
        companyAddressController.text != '') {
      return true;
    } else {
      return false;
    }
  }

  selectDay(int dayKey) {
    setState(() {
      if (initialSelectedDayItem.contains(dayKey)) {
        initialSelectedDayItem.remove(dayKey);
      } else {
        if (initialSelectedDayItem.length < 6) {
          initialSelectedDayItem.add(dayKey);
        }
      }
    });
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        companyAddressController.text = data.address;

        int siIndex = AddressService.siNameDefine
            .indexWhere((el) => el['daumName'] == data.sido);
        if (siIndex > -1) {
          si = AddressService.siNameDefine[siIndex]['dbName'];
        } else {
          si = data.sido;
        }
        gu = data.sigungu;
        dong = data.bname;
        companyAddressController.text = data.address;
      });
    }
  }

  void toggleSalaryNegotiable(NegotiableEnum negotiableType) {
    setState(() {
      isSalaryNegotiable = negotiableType == NegotiableEnum.possible
          ? NegotiableEnum.impossible
          : NegotiableEnum.possible;
    });
  }

  void toggleWorkPeriodNegotiable(NegotiableEnum negotiableType) {
    setState(() {
      isWorkPeriodNegotiable = negotiableType == NegotiableEnum.possible
          ? NegotiableEnum.impossible
          : NegotiableEnum.possible;
    });
  }

  void toggleWorkDayNegotiable(NegotiableEnum negotiableType) {
    setState(() {
      isWorkDayNegotiable = negotiableType == NegotiableEnum.possible
          ? NegotiableEnum.impossible
          : NegotiableEnum.possible;
    });
  }

  void toggleWorkTimeNegotiable(NegotiableEnum negotiableType) {
    setState(() {
      isWorkTimeNegotiable = negotiableType == NegotiableEnum.possible
          ? NegotiableEnum.impossible
          : NegotiableEnum.possible;
    });
  }

  void toggleRestTimeNegotiable(NegotiableEnum negotiableType) {
    setState(() {
      isRestTimeNegotiable = negotiableType == NegotiableEnum.possible
          ? NegotiableEnum.impossible
          : NegotiableEnum.possible;
    });
  }

  setSalaryTypeEnum(SalaryTypeEnum salaryTypeEnum) {
    setState(() {
      salaryType = salaryTypeEnum;
    });
  }

  @override
  void initState() {
    Future(() {
      savePageLog();
    });

    initialSelectedDayItem = [
      ...widget.jobpostingData[InputDepthEnum.workCondition.key]['wdIdx']
    ];

    //급여 협의 가능
    isSalaryNegotiable = setNegotiableEnumFromInt(
        widget.jobpostingData[InputDepthEnum.workCondition.key]
            ['jpSalaryNegotiable']);

    //근무 기간
    isWorkPeriodNegotiable = setNegotiableEnumFromInt(
        widget.jobpostingData[InputDepthEnum.workCondition.key]
            ['jpPeriodChangeable']);

    //근무 요일 협의 가능
    isWorkDayNegotiable = setNegotiableEnumFromInt(widget
        .jobpostingData[InputDepthEnum.workCondition.key]['jpDaysChangeable']);

    //근무 시간 협의 가능
    isWorkTimeNegotiable = setNegotiableEnumFromInt(
        widget.jobpostingData[InputDepthEnum.workCondition.key]
            ['jpWorkHourChangeable']);

    //휴게 시간 협의 가능
    isRestTimeNegotiable = setNegotiableEnumFromInt(
        widget.jobpostingData[InputDepthEnum.workCondition.key]
            ['jpRestHourChangeable']);

    probationPeriodTextController.text = widget
            .jobpostingData[InputDepthEnum.workCondition.key]
                ['jpProbationPeriod']
            .toString() ??
        '';
    hasProbation = widget.jobpostingData[InputDepthEnum.workCondition.key]
                ['jpProbationPeriod'] ==
            0
        ? false
        : true;

    salaryType = setSalaryTypeEnumFromString(widget
        .jobpostingData[InputDepthEnum.workCondition.key]['jpSalaryType']);

    if (widget.jobpostingData[InputDepthEnum.workCondition.key]['jpSalary'] !=
        null) {
      salaryTextController.text = ConvertService.formatWithComma(
          widget.jobpostingData[InputDepthEnum.workCondition.key]['jpSalary']);
    }

    workHour = [
      ...widget.jobpostingData[InputDepthEnum.workCondition.key]['workHour']
    ];
    if (workHour.isEmpty) {
      workHour.add({
        //근무시간
        'jphType': 'WORK',
        // 근무시작시간
        'jphStartTime': "",
        // 근무종료시간
        'jphEndTime': "",
      });
    }

    if (widget.jobpostingData[InputDepthEnum.workCondition.key]['jpRestHour'] !=
            null &&
        widget.jobpostingData[InputDepthEnum.workCondition.key]['jpRestHour'] !=
            '') {
      restHour = widget
                  .jobpostingData[InputDepthEnum.workCondition.key]
                      ['jpRestHour']
                  .runtimeType ==
              String
          ? int.parse(widget.jobpostingData[InputDepthEnum.workCondition.key]
              ['jpRestHour'])
          : widget.jobpostingData[InputDepthEnum.workCondition.key]
              ['jpRestHour'];
    }

    setState(() {
      restHourTextController.text = restHour == 0 ? '' : restHour.toString();
    });

    if (widget.jobpostingData[InputDepthEnum.workCondition.key]
            ['jpContractualWorkHour'] !=
        null) {
      contractualWorkHourTextController.text = ConvertService.formatWithComma(
          widget.jobpostingData[InputDepthEnum.workCondition.key]
              ['jpContractualWorkHour']);
    }

    companyAddressController.text =
        widget.jobpostingData[InputDepthEnum.workCondition.key]['jpAddress'] ??
            '';
    companyAddressDetailController.text =
        widget.jobpostingData[InputDepthEnum.workCondition.key]
                ['jpAddressDetail'] ??
            '';
    si = widget.jobpostingData[InputDepthEnum.workCondition.key]['adSi'] ?? '';
    gu = widget.jobpostingData[InputDepthEnum.workCondition.key]['adGu'] ?? '';
    dong =
        widget.jobpostingData[InputDepthEnum.workCondition.key]['adDong'] ?? '';

    selectedWorkTypeKey =
        widget.jobpostingData[InputDepthEnum.workCondition.key]['wtIdx'];

    selectedWorkPeriodKey =
        widget.jobpostingData[InputDepthEnum.workCondition.key]['wpIdx'];
    widget.stepController.changeStep(InputStepEnum.ongoing);
    salaryTextController.addListener(_removeLeadingZeros);
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    salaryTextController.removeListener(_removeLeadingZeros);
    probationPeriodTextController.dispose();
    restHourTextController.dispose();
    salaryTextController.dispose();
    contractualWorkHourTextController.dispose();
    companyAddressController.dispose();
    companyAddressDetailController.dispose();
    super.dispose();
  }

  void _removeLeadingZeros() {
    String text = salaryTextController.text;
    if (text.isNotEmpty && text != '0') {
      String newText = text.replaceAll(RegExp(r'^0+'), '');
      if (newText.isEmpty) {
        newText = '0';
      }
      if (newText != text) {
        salaryTextController.value = TextEditingValue(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: newText.length),
          ),
        );
      }
    }
  }

  showWorkType(BuildContext context) {
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
        return WorkTypeBottomSheet(
          dataArr: widget.workTypeList,
          title: localization.83,
          initItem: selectedWorkTypeKey.toString(),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedWorkTypeKey = value;
        });
      }
    });
  }

  showWorkPeriod(BuildContext context) {
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
        return WorkPeriodBottomSheet(
          // CheckList: const ['하루 (1일)',localization.481,localization.482,localization.483,localization.484,localization.485,localization.486],
          // selected: 1,
          title: localization.84, dataArr: widget.workPeriodList,
          initItem: selectedWorkPeriodKey.toString(),
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          if (value != '') {
            selectedWorkPeriodKey = value;
          } else {
            selectedWorkPeriodKey = null;
          }
        });
      }
    });
  }

  showWorkTime(
    BuildContext context,
    int i,
    String type,
  ) {
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
        return WorkTimeBottomSheet(
          // CheckList: const ['하루 (1일)',localization.481,localization.482,localization.483,localization.484,localization.485,localization.486],
          // selected: 1,

          initItem: type == 'start'
              ? workHour[i]['jphStartTime']
              : workHour[i]['jphEndTime'],
          title: type == 'start' ? localization.startTime : localization.endTime,
          dataArr: ContractService.workTimeList,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          if (type == 'start') {
            workHour[i]['jphStartTime'] = value;
          }
          if (type == 'end') {
            workHour[i]['jphEndTime'] = value;
          }
        });
      }
    });
  }

  isWorkTimeValidator(List hourList) {
    bool isValid = true;

    final timePattern = RegExp(r'^\d{2}:\d{2}$');

    for (dynamic hour in hourList) {
      String startTime = hour['jphStartTime'];
      String endTime = hour['jphEndTime'];

      if ((startTime.isEmpty && endTime.isNotEmpty) ||
          (startTime.isNotEmpty && endTime.isEmpty)) {
        isValid = false;
      }

      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        if (startTime == ':' && endTime == ':') {
          return true;
        }
        if (!timePattern.hasMatch(startTime) ||
            !timePattern.hasMatch(endTime)) {
          isValid = false;
        }

        if (startTime == endTime) {
          isValid = false;
        }
      }
    }

    return isValid;
  }

  void saveWorkConditionData() {
    initialSelectedDayItem.sort();
    final Map<String, dynamic> workConditionData = {
      'wdIdx': initialSelectedDayItem,
      'jpPeriodChangeable': isWorkPeriodNegotiable.param,
      'jpDaysChangeable': isWorkDayNegotiable.param,
      'jpWorkHourChangeable': isWorkTimeNegotiable.param,
      'jpRestHourChangeable': isRestTimeNegotiable.param,
      'jpSalaryNegotiable': isSalaryNegotiable.param,
      'jpProbationPeriod': hasProbation
          ? ConvertService.convertStringToInt(
              probationPeriodTextController.text)
          : 0,
      'jpSalaryType': salaryType.param,
      'jpSalary': ConvertService.convertStringToInt(
          ConvertService.removeAllComma(salaryTextController.text)),
      'workHour': setWorkHour(),
      'jpRestHour': restHourTextController.text,
      'jpContractualWorkHour': ConvertService.convertStringToInt(
          ConvertService.removeAllComma(
              contractualWorkHourTextController.text)),
      'jpAddress': companyAddressController.text,
      'jpAddressDetail': companyAddressDetailController.text,
      'adSi': si,
      'adGu': gu,
      'adDong': dong,
      'wtIdx': selectedWorkTypeKey,
      'wpIdx': selectedWorkPeriodKey,
    };

    workConditionData.forEach((key, value) {
      widget.setData(key, value, depth: InputDepthEnum.workCondition);
    });

    widget.stepController.changeStep(InputStepEnum.ongoing, isComplete: true);
    context.pop();
  }

  setWorkHour() {
    List<Map<String, dynamic>> list = [];
    final timePattern = RegExp(r'^\d{2}:\d{2}$');
    for (var time in workHour) {
      String startTime =
          time['jphStartTime'] == ':' ? "" : time['jphStartTime'];
      String endTime = time['jphEndTime'] == ':' ? "" : time['jphEndTime'];

      if (!timePattern.hasMatch(startTime)) {
        startTime = "";
      }
      if (!timePattern.hasMatch(endTime)) {
        endTime = "";
      }

      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        list.add({
          'jphType': 'WORK',
          'jphStartTime': startTime,
          'jphEndTime': endTime,
        });
      }
    }

    return list;
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
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 15;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            context.pop();
          }
        },
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: localization.workingConditions2,
              ),
              body: CustomScrollView(
                slivers: [
                  ProfileTitle(
                    title: localization.salary,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: CommonRadioTextButton(
                              onChanged: (value) {
                                setSalaryTypeEnum(value);
                              },
                              groupValue: salaryType,
                              value: SalaryTypeEnum.time,
                              label: localization.hourlyRate,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Expanded(
                            child: CommonRadioTextButton(
                              onChanged: (value) {
                                setSalaryTypeEnum(value);
                              },
                              groupValue: salaryType,
                              value: SalaryTypeEnum.day,
                              label: localization.dailyRate,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Expanded(
                            child: CommonRadioTextButton(
                              onChanged: (value) {
                                setSalaryTypeEnum(value);
                              },
                              groupValue: salaryType,
                              value: SalaryTypeEnum.month,
                              label: localization.monthlySalary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: salaryTextController,
                        key: const Key('jobposting_salary'),
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: 11,
                        textAlign: TextAlign.end,
                        onTapOutside: (value) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: commonInput(
                          hintText: localization.92,
                        ),
                        onChanged: (value) {},
                        inputFormatters: [
                          CurrencyTextInputFormatter.currency(
                              locale: 'ko', decimalDigits: 0, symbol: ''),
                        ],
                        minLines: 1,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleSalaryNegotiable(isSalaryNegotiable);
                    },
                    groupValue: isSalaryNegotiable,
                    value: NegotiableEnum.possible,
                    label: localization.93,
                  ),
                  const SliverDivider(),
                  ProfileTitle(
                    title: localization.employmentType,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: SelectButton(
                        text: widget.workTypeList
                            .where((e) => e.workTypeKey == selectedWorkTypeKey)
                            .map((e) => e.workTypeName)
                            .join(),
                        onTap: () {
                          showWorkType(context);
                        },
                        hintText: localization.95,
                      ),
                    ),
                  ),
                  const SliverDivider(
                    big: true,
                  ),
                  ProfileTitle(
                    title: localization.96,
                    required: false,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileRadio(
                              onChanged: (value) {
                                setState(() {
                                  hasProbation = value;
                                });
                              },
                              groupValue: hasProbation,
                              value: false,
                              label: localization.97,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ProfileRadio(
                              onChanged: (value) {
                                setState(() {
                                  hasProbation = value;
                                });
                              },
                              groupValue: hasProbation,
                              value: true,
                              label: localization.manualInput,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasProbation)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: TextFormField(
                          controller: probationPeriodTextController,
                          key: const Key('jobposting_probation_period'),
                          keyboardType: TextInputType.number,
                          autocorrect: false,
                          cursorColor: CommonColors.black,
                          style: commonInputText(),
                          maxLength: 3,
                          textAlign: TextAlign.right,
                          decoration: suffixInput(
                            suffixSize: 14.sp,
                            suffixColor: CommonColors.grayB2,
                            suffixText: localization.98,
                            hintText: localization.99,
                          ),
                          minLines: 1,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.only(top: 20.w),
                    sliver: const SliverDivider(),
                  ),
                  ProfileTitle(
                    title: localization.workDuration,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleWorkPeriodNegotiable(isWorkPeriodNegotiable);
                    },
                    groupValue: isWorkPeriodNegotiable,
                    value: NegotiableEnum.possible,
                    label: localization.101,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                      child: SelectButton(
                        text: widget.workPeriodList
                            .where(
                                (e) => e.workPeriodKey == selectedWorkPeriodKey)
                            .map((e) => e.workPeriodName)
                            .join(),
                        onTap: () {
                          showWorkPeriod(context);
                        },
                        hintText: localization.102,
                      ),
                    ),
                  ),
                  const SliverDivider(),
                  ProfileTitle(
                    extraText: '${initialSelectedDayItem.length} / 6',
                    title: localization.workingDays,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleWorkDayNegotiable(isWorkDayNegotiable);
                    },
                    groupValue: isWorkDayNegotiable,
                    value: NegotiableEnum.possible,
                    label: localization.104,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.dayList.length; i++)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                child: CommonRadioTextButton(
                                  onChanged: (value) {
                                    selectDay(widget.dayList[i].key);
                                  },
                                  groupValue: true,
                                  value: initialSelectedDayItem
                                      .contains(widget.dayList[i].key),
                                  label: widget.dayList[i].name,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SliverDivider(),
                  ProfileTitle(
                    title: localization.workingHours2,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleWorkTimeNegotiable(isWorkTimeNegotiable);
                    },
                    groupValue: isWorkTimeNegotiable,
                    value: NegotiableEnum.possible,
                    label: localization.106,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TimeInput(
                                  titleHint: localization.workStartTime,
                                  setFunc: (value) {
                                    workHour[0]['jphStartTime'] = value;
                                  },
                                  initTime: workHour[0]['jphStartTime'],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
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
                                  titleHint: localization.workEndTime,
                                  setFunc: (value) {
                                    workHour[0]['jphEndTime'] = value;
                                  },
                                  initTime: workHour[0]['jphEndTime'],
                                ),
                              ),
                            ],
                          ),
                          for (int i = 1; i < workHour.length; i++)
                            Padding(
                              padding: EdgeInsets.only(top: 8.w),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TimeInput(
                                      titleHint: localization.workStartTime,
                                      setFunc: (value) {
                                        workHour[i]['jphStartTime'] = value;
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
                                    child: TimeInput(
                                      titleHint: localization.workEndTime,
                                      setFunc: (value) {
                                        workHour[i]['jphEndTime'] = value;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(3.w, 0, 0, 0),
                                    child: BorderButton(
                                      color: CommonColors.grayF2,
                                      width: 36.w,
                                      onPressed: () {
                                        setState(() {
                                          workHour.removeAt(i);
                                        });
                                      },
                                      text: '',
                                      child: Image.asset(
                                        'assets/images/icon/iconX.png',
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 0.w, 8.w),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '※ 시간은 24시간 단위로 입력해주세요.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: CommonColors.grayB2,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 0.w, 8.w),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        '근로자의 건강과 안전을 위해 법정 최대 근로시간을 준수해 주세요.\n주 52시간을 초과하지 않도록 유의해 주시기 바랍니다.',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                          color: CommonColors.grayB2,
                        ),
                      ),
                    ),
                  ),
                  if (workHour.length < 5)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 24.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              workHour.add({
                                //근무시간
                                'jphType': 'WORK',
                                // 근무시작시간
                                'jphStartTime': "",
                                // 근무종료시간
                                'jphEndTime': "",
                              });
                            });
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
                                  localization.addField,
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
                  if (!isWorkTimeValidator(workHour))
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          localization.112,
                          style: TextStyles.error,
                        ),
                      ),
                    ),
                  const SliverDivider(),
                  ProfileTitle(
                    title: localization.breakTime2,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleRestTimeNegotiable(isRestTimeNegotiable);
                    },
                    groupValue: isRestTimeNegotiable,
                    value: NegotiableEnum.possible,
                    label: localization.114,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                        child: Row(
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
                              restHour = int.parse(value);
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
                    )),
                  ),
                  const SliverDivider(),
                  ProfileTitle(
                    title: localization.117,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: contractualWorkHourTextController,
                        key: const Key('jobposting_contractual_workhour'),
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: 3,
                        textAlign: TextAlign.end,
                        decoration: prefixInput(
                          prefixText: localization.118,
                          prefixColor: CommonColors.grayB2,
                          prefixSize: 14.sp,
                          hintText: localization.119,
                          suffixText: localization.time,
                        ),
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
                      ),
                    ),
                  ),
                  const SliverDivider(
                    big: true,
                  ),
                  ProfileTitle(
                    title: localization.121,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.w),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: showPost,
                        child: TextFormField(
                          enabled: false,
                          controller: companyAddressController,
                          key: const Key('sign-up-company-address-input'),
                          autocorrect: false,
                          style: commonInputText(),
                          maxLength: null,
                          decoration: commonInput(
                              hintText: AuthMsgService.addressEnter,
                              disable: true),
                          minLines: 1,
                          maxLines: 1,
                          onChanged: (value) {},
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: companyAddressDetailController,
                              key: const Key(
                                  'sign-up-company-address-detail-input'),
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              cursorColor: CommonColors.black,
                              style: commonInputText(),
                              maxLength: 100,
                              decoration: suffixInput(
                                hintText: AuthMsgService.addressDetailEnter,
                              ),
                              minLines: 1,
                              maxLines: 1,
                              onChanged: (value) {},
                              onEditingComplete: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 0, 20.w, CommonSize.commonBottom),
                    sliver: SliverToBoxAdapter(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 20.w,
                        ),
                        CommonButton(
                          onPressed: () {
                            if (confirm()) {
                              saveWorkConditionData();
                            }
                          },
                          confirm: confirm(),
                          text: localization.32,
                          fontSize: 15,
                        ),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
