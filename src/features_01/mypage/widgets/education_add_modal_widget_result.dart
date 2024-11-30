import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_constants.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/date_picker_dropdown_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/edu_finish_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/edu_last_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EducationAddModalWidget extends StatefulWidget {
  const EducationAddModalWidget({
    super.key,
    required this.schoolTypes,
  });

  final List<ProfileModel> schoolTypes;

  @override
  State<EducationAddModalWidget> createState() =>
      _EducationAddModalWidgetState();
}

class _EducationAddModalWidgetState extends State<EducationAddModalWidget> {
  final _schoolNameController = TextEditingController();

  String educationTypeErrorMessage = '';
  String educationStatusErrorMessage = '';
  String educationDateErrorMessage = '';

  int? selectedEducationTypeKey;
  String? selectedEducationStatus;

  Map<String, dynamic> educationData = {
    'stIdx': 0, // 학력 키
    'mpeStatus': '', // 졸업 여부
    'mpeDate': null, // 졸업 연월
    'mpeName': '', // 학교명
  };

  Map<String, dynamic> educationDateInfo = {
    'endYear': '',
    'endMonth': '',
  };

  setEducationData(String key, dynamic value) {
    educationData[key] = value;
  }

  updateEducationDateInfo(String key, dynamic value) {
    educationDateInfo[key] = value;
    checkEducationDateErrorText();
  }

  checkEducationTypeErrorText() {
    setState(() {
      if (selectedEducationTypeKey == null) {
        educationTypeErrorMessage = ProfileMsgService.workTypeEmpty;
      } else {
        educationTypeErrorMessage = '';
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

  void checkEducationDateErrorText() {
    setState(() {
      if (!checkWorkDate()) {
        educationDateErrorMessage = ProfileMsgService.contentFormat;
      } else {
        educationDateErrorMessage = '';
      }
    });
  }

  checkWorkDate() {
    for (var value in educationDateInfo.values) {
      if (value.isEmpty) {
        return false;
      }
    }
    return true;
  }

  checkEducationValidate() {
    setState(() {
      if (selectedEducationTypeKey == null) {
        educationTypeErrorMessage = ProfileMsgService.educationEmpty;
      }
      if (selectedEducationStatus == null) {
        educationStatusErrorMessage = ProfileMsgService.educationStatusEmpty;
      }
      if ((educationDateInfo['endYear'].isNotEmpty &&
              educationDateInfo['endMonth'].isEmpty) ||
          (educationDateInfo['endYear'].isEmpty &&
              educationDateInfo['endMonth'].isNotEmpty)) {
        educationDateErrorMessage = ProfileMsgService.contentFormat;
      }
    });
  }

  calculateEndDateAndFormat() {
    int endYear = int.parse(educationDateInfo['endYear']);
    int endMonth = int.parse(educationDateInfo['endMonth']);

    DateTime date = DateTime(endYear, endMonth, 1);

    setEducationData('mpeDate', DateFormat('yyyy-MM-dd').format(date));
  }

  showEducationLast() {
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
        return EduLastBottomSheet(
          dataArr: widget.schoolTypes,
          initItem: selectedEducationTypeKey ?? 15245,
          title: localization.education,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedEducationTypeKey = value;
          checkEducationTypeErrorText();
          setEducationData('stIdx', value);
        });
      }
    });
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
          title: localization.graduationStatus,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedEducationStatus = value;
          checkEducationStatusErrorText();
          setEducationData('mpeStatus', selectedEducationStatus);
        });
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
        child: Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: localization.addEducation,
              ),
              body: CustomScrollView(
                slivers: [
                  ProfileTitle(
                    onTap: () {},
                    hasArrow: false,
                    title: localization.education,
                    required: true,
                    text: '',
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: SelectButton(
                        onTap: () {
                          showEducationLast();
                        },
                        text: selectedEducationTypeKey != null
                            ? widget.schoolTypes
                                .where((e) =>
                                    e.schoolKey == selectedEducationTypeKey)
                                .map((e) => e.schoolType)
                                .join('')
                            : '',
                        hintText: localization.selectEducationLevel,
                      ),
                    ),

                    // DropdownButtonHideUnderline(
                    //   child: DropdownButton2(
                    //     isExpanded: true,
                    //     hint: Text(
                    //       '선택',
                    //       style: TextStyle(
                    //         fontSize: 14,
                    //         color: Theme.of(context).hintColor,
                    //       ),
                    //     ),
                    //     buttonStyleData: const ButtonStyleData(
                    //       padding: EdgeInsets.symmetric(horizontal: 16),
                    //       height: 40,
                    //     ),
                    //     menuItemStyleData: const MenuItemStyleData(
                    //       height: 40,
                    //     ),
                    //     items: widget.schoolTypes.map((education) {
                    //       return DropdownMenuItem(
                    //         value: education.schoolKey,
                    //         child: Text(education.schoolType),
                    //       );
                    //     }).toList(),
                    //     value: selectedEducationTypeKey,
                    //     onChanged: (int? value) {
                    //       setState(() {
                    //         selectedEducationTypeKey = value;
                    //         checkEducationTypeErrorText();
                    //         setEducationData('stIdx', value);
                    //       });
                    //     },
                    //   ),
                    // ),
                  ),
                  // SliverToBoxAdapter(
                  //   child:    SizedBox(
                  //     height: 20,
                  //     child: Center(
                  //       child: Text(educationTypeErrorMessage,
                  //           style: TextStyle(color: CommonColors.red)),
                  //     ),
                  //   ),
                  // ),

                  ProfileTitle(
                    onTap: () {},
                    hasArrow: false,
                    title: localization.graduationStatus,
                    required: true,
                    text: '',
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: SelectButton(
                        onTap: () {
                          showEducationFinish();
                        },
                        text: selectedEducationStatus ?? '',
                        hintText: localization.selectGraduationStatus,
                      ),
                    ),
                  ),

                  if (selectedEducationStatus == localization.graduated)
                    ProfileTitle(
                      onTap: () {},
                      hasArrow: false,
                      title: localization.graduationMonthAndYear,
                      required: false,
                      text: '',
                    ),
                  if (selectedEducationStatus == localization.graduated)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                      sliver: SliverToBoxAdapter(
                        child: DatePickerDropdownWidget(
                          initialYear: DateTime.now().year,
                          startYear: 1900,
                          endYear: DateTime.now().year,
                          currentYear: DateTime.now().year,
                          month: DateTime.now().month,
                          setData: updateEducationDateInfo,
                          workDateInfo: educationDateInfo,
                          isStart: false,
                        ),
                      ),
                    ),

                  ProfileTitle(
                    onTap: () {},
                    hasArrow: false,
                    title: localization.school,
                    required: false,
                    text: '',
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: _schoolNameController,
                        key: const Key('career-add-input'),
                        keyboardType: TextInputType.text,
                        autocorrect: false,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: suffixInput(
                          hintText: ProfileMsgService.schoolNameEnter,
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            if (_schoolNameController.text.isNotEmpty) {
                              setEducationData(
                                  'mpeName', _schoolNameController.text);
                            }
                          });
                        },
                        onEditingComplete: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                      ),
                    ),
                  ),
                  const BottomPadding(
                    extra: 100,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBoard(context) + CommonSize.keyboardHeight,
              child: Row(
                children: [
                  BorderButton(
                    onPressed: () {
                      context.pop();
                    },
                    text: localization.close,
                    width: 96.w,
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: CommonButton(
                      fontSize: 15,
                      confirm: selectedEducationTypeKey != null &&
                          selectedEducationStatus != null &&
                          ((educationDateInfo['endYear'].isNotEmpty &&
                                  educationDateInfo['endMonth'].isNotEmpty) ||
                              (educationDateInfo['endYear'].isEmpty &&
                                  educationDateInfo['endMonth'].isEmpty)),
                      onPressed: () {
                        checkEducationValidate();

                        if (selectedEducationTypeKey != null &&
                            selectedEducationStatus != null &&
                            ((educationDateInfo['endYear'].isNotEmpty &&
                                    educationDateInfo['endMonth'].isNotEmpty) ||
                                (educationDateInfo['endYear'].isEmpty &&
                                    educationDateInfo['endMonth'].isEmpty))) {
                          if (educationDateInfo['endYear'].isNotEmpty &&
                              educationDateInfo['endMonth'].isNotEmpty) {
                            calculateEndDateAndFormat();
                            context.pop(educationData);
                          } else {
                            context.pop(educationData);
                          }
                        }
                      },
                      text: localization.add,
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
