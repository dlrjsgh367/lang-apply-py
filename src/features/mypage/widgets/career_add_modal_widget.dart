import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/date_picker_dropdown_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/career_job_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/work_type_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CareerAddModalWidget extends ConsumerStatefulWidget {
  const CareerAddModalWidget({
    super.key,
    required this.workTypes,
    this.setJobData,
  });

  final List<ProfileModel> workTypes;
  final Function? setJobData;

  @override
  ConsumerState<CareerAddModalWidget> createState() =>
      _CareerAddModalWidgetState();
}

class _CareerAddModalWidgetState extends ConsumerState<CareerAddModalWidget> {
  final _companyNameController = TextEditingController();
  final jobDescriptionController = TextEditingController();
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();

  String companyNameErrorMessage = '';
  String workTypeErrorMessage = '';
  String jobErrorMessage = '';
  String workDateErrorMessage = '';
  String jobDescriptionErrorMessage = '';

  String? selectedWorkType;
  int? selectedWorkKey;

  int _jobDescriptionTextLength = 0;

  List<DefineModel> selectedJobList = [];
  int selectedJobKey = -1;

  late CareerJobModel jobData;

  int jobMaxLength = 1;

  Map<String, dynamic> careerData = {
    'mpcName': '', // 업체명
    'wtIdx': 0, // 근무형태 키 값
    'mpcStartDate': '', // 근무기간 시작일
    'mpcEndDate': '', // 근무기간 종료일
    'joIdx': -1, // 직종 키 값
    'mpcWork': '', // 담당 업무
  };

  Map<String, dynamic> workDateInfo = {
    'startYear': '',
    'startMonth': '',
    'endYear': '',
    'endMonth': '',
  };

  Map<String, dynamic> initialJobData = {
    'name': '',
    'formattedDepthName': '',
  };

  setCareerData(String key, dynamic value) {
    careerData[key] = value;
  }

  setJobData(String key, dynamic value) {
    initialJobData[key] = value;
  }

  updateWorkDateInfo(String key, dynamic value) {
    workDateInfo[key] = value;
    checkWorkDateErrorText();
  }

  addWorkJob(List<DefineModel> jobItem, List<int> apply) {
    setState(() {
      selectedJobList = [...jobItem];
      selectedJobKey = apply[0];
      careerData['joIdx'] = selectedJobKey;

      jobData = CareerJobModel(
        name: jobItem[0].name,
        formattedDepthName: initialJobData['formattedDepthName'],
      );

      if (widget.setJobData != null) {
        widget.setJobData!(jobData);
      }
    });
  }

  checkCompanyNameErrorText() {
    setState(() {
      if (_companyNameController.text.isEmpty) {
        companyNameErrorMessage = ProfileMsgService.companyNameEmpty;
      } else {
        companyNameErrorMessage = '';
      }
    });
  }

  checkWorkTypeErrorText() {
    setState(() {
      if (selectedWorkKey == null) {
        workTypeErrorMessage = ProfileMsgService.workTypeEmpty;
      } else {
        workTypeErrorMessage = '';
      }
    });
  }

  checkJobErrorText() {
    setState(() {
      if (selectedJobList.isEmpty) {
        jobErrorMessage = ProfileMsgService.jobEmpty;
      } else {
        jobErrorMessage = '';
      }
    });
  }

  int getWorkYear(String key) {
    return int.parse(workDateInfo[key]);
  }

  int getWorkMonth(String key) {
    return int.parse(workDateInfo[key]);
  }

  bool isEndBeforeStart() {
    return getWorkYear('startYear') > getWorkYear('endYear') ||
        (getWorkYear('startYear') == getWorkYear('endYear') &&
            getWorkMonth('startMonth') > getWorkMonth('endMonth'));
  }

  checkWorkDateErrorText() {
    setState(() {
      if (!checkWorkDate()) {
        workDateErrorMessage = ProfileMsgService.workDateEmpty;
      } else if (isEndBeforeStart()) {
        workDateErrorMessage = ProfileMsgService.contentFormat;
      } else {
        workDateErrorMessage = '';
      }
    });
  }

  checkJobDescriptionErrorText() {
    setState(() {
      if (jobDescriptionController.text.isEmpty) {
        jobDescriptionErrorMessage = ProfileMsgService.jobDescriptionEmpty;
      } else {
        jobDescriptionErrorMessage = '';
      }
    });
  }

  checkCareerValidate() {
    setState(() {
      if (_companyNameController.text.isEmpty) {
        companyNameErrorMessage = ProfileMsgService.companyNameEmpty;
      }
      if (selectedWorkKey == null) {
        workTypeErrorMessage = ProfileMsgService.workTypeEmpty;
      }
      if (selectedJobList.isEmpty) {
        jobErrorMessage = ProfileMsgService.jobEmpty;
      }
      if (!checkWorkDate()) {
        workDateErrorMessage = ProfileMsgService.workDateEmpty;
      }
      if (jobDescriptionController.text.isEmpty) {
        jobDescriptionErrorMessage = ProfileMsgService.jobDescriptionEmpty;
      }
    });
  }

  checkWorkDate() {
    for (var value in workDateInfo.values) {
      if (value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  calculateEndDateAndFormat() {
    int startYear = int.parse(workDateInfo['startYear']);
    int startMonth = int.parse(workDateInfo['startMonth']);
    int endYear = int.parse(workDateInfo['endYear']);
    int endMonth = int.parse(workDateInfo['endMonth']);

    // 근무 시작일
    DateTime startDate = DateTime(startYear, startMonth, 1);
    // 근무 종료일
    DateTime endDate =
        DateTime(endYear, endMonth + 1, 1).subtract(const Duration(days: 1));

    setCareerData('mpcStartDate', DateFormat('yyyy-MM-dd').format(startDate));
    setCareerData('mpcEndDate', DateFormat('yyyy-MM-dd').format(endDate));
  }

  showWorkType() {
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
        return WorkTypeBottomSheet(
          dataArr: widget.workTypes,
          initItem: selectedWorkKey.toString(),
          title: localization.83,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedWorkKey = value;
          checkWorkTypeErrorText();
          setCareerData('wtIdx', value);
        });
      }
    });
  }

  reset() {
    setState(() {
      _companyNameController.text = '';
      jobDescriptionController.text = '';
      selectedWorkKey = null;
      selectedJobList = [];
      workDateInfo = {
        'startYear': '',
        'startMonth': '',
        'endYear': '',
        'endMonth': '',
      };

      careerData = {
        'mpcName': '', // 업체명
        'wtIdx': 0, // 근무형태 키 값
        'mpcStartDate': '', // 근무기간 시작일
        'mpcEndDate': '', // 근무기간 종료일
        'joIdx': -1, // 직종 키 값
        'mpcWork': '', // 담당 업무
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
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
        child: Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: localization.513,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        ProfileTitle(
                          onTap: () {},
                          hasArrow: false,
                          title: localization.514,
                          required: true,
                          text: '',
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: TextFormField(
                              controller: _companyNameController,
                              key: const Key('career-add-input'),
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              cursorColor: CommonColors.black,
                              style: commonInputText(),
                              maxLength: 50,
                              decoration: commonInput(
                                hintText: ProfileMsgService.companyNameEnter,
                              ),
                              minLines: 1,
                              maxLines: 1,
                              onChanged: (value) {
                                setState(() {
                                  checkCompanyNameErrorText();

                                  if (_companyNameController.text.isNotEmpty) {
                                    setCareerData(
                                        'mpcName', _companyNameController.text);
                                  }
                                });
                              },
                              onEditingComplete: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                          ),
                        ),
                        if (companyNameErrorMessage.isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                                child: Text(
                              companyNameErrorMessage,
                              style: TextStyles.error,
                            )),
                          ),
                        ProfileTitle(
                          onTap: () {},
                          hasArrow: false,
                          title: localization.83,
                          required: true,
                          text: '',
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: SelectButton(
                              onTap: () {
                                showWorkType();
                              },
                              text: widget.workTypes
                                  .where(
                                      (e) => e.workTypeKey == selectedWorkKey)
                                  .map((e) => e.workTypeName)
                                  .join(),
                              hintText: localization.95,
                            ),
                          ),
                        ),
                        if (workTypeErrorMessage.isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                                child: Text(
                              workTypeErrorMessage,
                              style: TextStyles.error,
                            )),
                          ),
                        ProfileTitle(
                          onTap: () {},
                          hasArrow: false,
                          title: localization.jobCategory,
                          required: true,
                          text: '',
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () async {
                                await DefineDialog.showOnlyOneJobBottom(
                                  context,
                                  localization.jobCategory,
                                  jobList,
                                  addWorkJob,
                                  selectedJobList,
                                  jobMaxLength,
                                  setJobData,
                                  DefineEnum.job,
                                );
                                await checkJobErrorText();
                              },
                              child: Container(
                                height: 48.w,
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
                                      localization.515,
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
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Wrap(
                              spacing: 8.w,
                              runSpacing: 8.w,
                              children: [
                                for (var i = 0; i < selectedJobList.length; i++)
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedJobList.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color: CommonColors.grayF7,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            selectedJobList[i].name,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 4.w,
                                          ),
                                          Image.asset(
                                            'assets/images/icon/iconX.png',
                                            width: 16.w,
                                            height: 16.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (jobErrorMessage.isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                                child: Text(
                              jobErrorMessage,
                              style: TextStyles.error,
                            )),
                          ),
                        ProfileTitle(
                          onTap: () {},
                          hasArrow: false,
                          title: localization.84,
                          required: true,
                          text: '',
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                          sliver: SliverToBoxAdapter(
                            child: DatePickerDropdownWidget(
                              extraText: localization.516,
                              initialYear: DateTime.now().year,
                              startYear: 1900,
                              endYear: DateTime.now().year,
                              currentYear: DateTime.now().year,
                              month: DateTime.now().month,
                              isStart: true,
                              setData: updateWorkDateInfo,
                              workDateInfo: workDateInfo,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: DatePickerDropdownWidget(
                              extraText: localization.517,
                              initialYear: DateTime.now().year,
                              startYear: 1900,
                              endYear: DateTime.now().year,
                              currentYear: DateTime.now().year,
                              month: DateTime.now().month,
                              setData: updateWorkDateInfo,
                              workDateInfo: workDateInfo,
                            ),
                          ),
                        ),
                        if (workDateErrorMessage.isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                                child: Text(
                              workDateErrorMessage,
                              style: TextStyles.error,
                            )),
                          ),
                        ProfileTitle(
                          onTap: () {},
                          hasArrow: false,
                          title: localization.518,
                          required: true,
                          text: '',
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                CommonKeyboardAction(
                                  focusNode: textAreaNode,
                                  child: TextFormField(
                                    controller: jobDescriptionController,
                                    onTap: () {
                                      ScrollCenter(textAreaKey);
                                    },
                                    key: textAreaKey,
                                    focusNode: textAreaNode,
                                    autocorrect: false,
                                    cursorColor: CommonColors.black,
                                    style: areaInputText(),
                                    maxLength: 500,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: areaInput(
                                      hintText:
                                          ProfileMsgService.jobDescriptionEnter,
                                    ),
                                    minLines: 3,
                                    maxLines: 3,
                                    onChanged: (value) {
                                      setState(() {
                                        checkJobDescriptionErrorText();
                                        _jobDescriptionTextLength =
                                            value.length;

                                        if (jobDescriptionController
                                            .text.isNotEmpty) {
                                          jobDescriptionErrorMessage = '';
                                          setCareerData('mpcWork', value);
                                        }
                                      });
                                    },
                                    onEditingComplete: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 10.w,
                                  bottom: 10.w,
                                  child: Text(
                                    '$_jobDescriptionTextLength/500',
                                    style: TextStyles.counter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (jobDescriptionErrorMessage.isNotEmpty)
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                                child: Text(
                              jobDescriptionErrorMessage,
                              style: TextStyles.error,
                            )),
                          ),
                        const BottomPadding(
                          extra: 100,
                        ),
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
              child: Row(
                children: [
                  BorderButton(
                    onPressed: () {
                      reset();
                    },
                    text: localization.reset,
                    width: 96.w,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: CommonButton(
                      fontSize: 15,
                      confirm: _companyNameController.text.isNotEmpty &&
                          selectedWorkKey != null &&
                          checkWorkDate() &&
                          !isEndBeforeStart() &&
                          careerData['joIdx'] != -1 &&
                          jobDescriptionController.text.isNotEmpty,
                      onPressed: () {
                        checkCareerValidate();

                        if (_companyNameController.text.isNotEmpty &&
                            selectedWorkKey != null &&
                            checkWorkDate() &&
                            !isEndBeforeStart() &&
                            careerData['joIdx'] != -1 &&
                            jobDescriptionController.text.isNotEmpty) {
                          calculateEndDateAndFormat();
                          context.pop(careerData);
                        }
                      },
                      text: localization.520,
                    ),
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
