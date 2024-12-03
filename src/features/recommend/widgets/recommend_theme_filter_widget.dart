import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/home/service/filter_service.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/filter_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecommendThemeFilterWidget extends ConsumerStatefulWidget {
  RecommendThemeFilterWidget(
      {super.key,
      required this.totalCount,
      required this.openedFilter,
      required this.addFilterParam,
      required this.removeFilterParam,
      required this.changeFilter});

  final int totalCount;
  final bool openedFilter;
  final Function changeFilter;
  final Function addFilterParam;
  final Function removeFilterParam;

  @override
  ConsumerState<RecommendThemeFilterWidget> createState() => _AlbaFilterState();
}

class _AlbaFilterState extends ConsumerState<RecommendThemeFilterWidget> {
  int maxLength = 10;
  List<Map<String, dynamic>> genderFilterList = [];
  List<Map<String, dynamic>> workTypeFilterList = [];
  List<Map<String, dynamic>> careerFilterList = [];
  List<Map<String, dynamic>> workPeriodFilterList = [];

  static const String JO_IDX = 'joIdxs';

  static const String ME_SEX = 'jpSexes';

  static const String WT_IDX = 'wtIdxes';

  static const String AD_IDX = 'adIdxs';

  static const String WP_IDX = 'wpIdxes';

  static const String AGE = 'ages';

  static const String HAVE_CAREER = 'jpCareerTypes';

  @override
  void initState() {
    List<ProfileModel> workTypeData = ref.read(workTypeListProvider);
    List<ProfileModel> workPeriodData = ref.read(workPeriodListProvider);
    for (ConditionGenderEnum item in genderList) {
      genderFilterList.add({'key': item.param, 'label': item.label});
    }

    for (ProfileModel item in workTypeData) {
      workTypeFilterList.add({
        'key': item.workTypeKey,
        'label': item.workTypeName,
      });
    }

    for (ProfileModel item in workPeriodData) {
      workPeriodFilterList.add({
        'key': item.workPeriodKey,
        'label': item.workPeriodName,
      });
    }

    super.initState();
  }

  void showArea() {
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
        return const FilterBottomSheet(
          type: localization.region,
        );
      },
    );
  }

  //성별
  List<Map<String, dynamic>> initialSelectedGender = [];
  List<int> selectedGenderKey = [];

  applyGender(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedGender = [...itemList];
      selectedGenderKey = [...apply];
      if (selectedGenderKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {ME_SEX: selectedGenderKey}
        ];
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([ME_SEX]);
      }
    });
  }

  //연령
  List<Map<String, dynamic>> initialSelectedAge = [];
  List<int> selectedAgeKey = [];

  applyAge(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedAge = [...itemList];
      selectedAgeKey = [...apply];
      if (selectedAgeKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [];
        for (int key in selectedAgeKey) {
          paramData.add({AGE: selectedAgeKey});
        }
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([AGE]);
      }
    });
  }

  //근무형태
  List<Map<String, dynamic>> initialSelectedWorkType = [];
  List<int> selectedWorkTypeKey = [];

  applyWorkType(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedWorkType = [...itemList];
      selectedWorkTypeKey = [...apply];
      if (selectedWorkTypeKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {WT_IDX: selectedWorkTypeKey}
        ];
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([WT_IDX]);
      }
    });
  }

  //희망근무지
  List<AddressModel> initialSelectedArea = [];
  List<int> selectedAreaKey = [];

  applyArea(List<AddressModel> addressItem, List<int> apply, int adParent) {
    setState(() {
      initialSelectedArea = [...addressItem];
      selectedAreaKey = apply;
      if (selectedAreaKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {AD_IDX: selectedAreaKey}
        ];
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([AD_IDX]);
      }
    });
  }

  //근무기간

  List<Map<String, dynamic>> initialSelectedWorkPeriod = [];
  List<int> selectedWorkPeriodKey = [];

  applyWorkPeriod(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedWorkPeriod = [...itemList];
      selectedWorkPeriodKey = [...apply];
      if (selectedWorkPeriodKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {WP_IDX: selectedWorkPeriodKey}
        ];
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([WP_IDX]);
      }
    });
  }

  //경력
  List<Map<String, dynamic>> initialSelectedCareer = [];
  List<int> selectedCareerKey = [];

  applyCareer(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedCareer = [...itemList];
      selectedCareerKey = [...apply];
      if (selectedCareerKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {HAVE_CAREER: selectedCareerKey}
        ];
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([HAVE_CAREER]);
      }
    });
  }

  List<DefineModel> selectedJobList = [];
  List<int> selectedJobKey = [];

  addWorkJob(List<DefineModel> jobItem, List<int> apply) {
    setState(() {
      selectedJobList = [...jobItem];
      selectedJobKey = [...apply];
      if (selectedJobKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [
          {JO_IDX: selectedJobKey}
        ];

        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([JO_IDX]);
      }
    });
  }

  int countFilter() {
    int result = 0;
    if (initialSelectedArea.isNotEmpty) {
      result++;
    }
    if (selectedJobList.isNotEmpty) {
      result++;
    }
    if (initialSelectedGender.isNotEmpty) {
      result++;
    }
    if (initialSelectedAge.isNotEmpty) {
      result++;
    }
    if (initialSelectedWorkType.isNotEmpty) {
      result++;
    }
    if (initialSelectedWorkPeriod.isNotEmpty) {
      result++;
    }
    if (initialSelectedCareer.isNotEmpty) {
      result++;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
    List<AddressModel> areaList = ref.watch(areaListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 0),
            child: Row(
              children: [
                Text(
                  '총 ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: CommonColors.gray4d,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${ConvertService.returnStringWithCommaFormat(widget.totalCount)}건',
                    style: TextStyle(
                        color: CommonColors.red, fontWeight: FontWeight.w600),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    widget.changeFilter();
                  },
                  child: Image.asset(
                    widget.openedFilter
                        ? 'assets/images/icon/iconFilterRed.png'
                        : 'assets/images/icon/iconFilter.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                ),
              ],
            )),
        // if (widget.openedFilter)
        if (widget.openedFilter)
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 8.w),
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                //직종
                GestureDetector(
                  onTap: () {
                    DefineDialog.showJobBottom(context, localization.jobCategory, jobList,
                        addWorkJob, selectedJobList, 10, DefineEnum.job);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color:
                        selectedJobList.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: selectedJobList.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.jobCategory,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: selectedJobList.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (selectedJobList.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${selectedJobList.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: selectedJobList.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          selectedJobList.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //성별
                GestureDetector(
                  onTap: () {
                    DefineDialog.showFilter(context, localization.gender, genderFilterList,
                        applyGender, initialSelectedGender, 1);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color:
                        initialSelectedGender.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedGender.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.gender,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedGender.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedGender.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedGender.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedGender.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedGender.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //연령
                GestureDetector(
                  onTap: () {
                    DefineDialog.showFilter(
                        context,
                        localization.age,
                        FilterService.ageFilter,
                        applyAge,
                        initialSelectedAge,
                        8);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color:
                        initialSelectedAge.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedAge.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.age,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedAge.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedAge.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedAge.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedAge.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedAge.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //근무형태
                GestureDetector(
                  onTap: () {
                    DefineDialog.showFilter(
                        context,
                        localization.employmentType,
                        workTypeFilterList,
                        applyWorkType,
                        initialSelectedWorkType,
                        workTypeFilterList.length);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color:
                        initialSelectedWorkType.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedWorkType.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.employmentType,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedWorkType.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedWorkType.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedWorkType.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedWorkType.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedWorkType.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //희망근무지
                GestureDetector(
                  onTap: () {
                    DefineDialog.showAreaBottom(context, localization.selectRegion, areaList,
                        applyArea, initialSelectedArea, 10);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color:
                        initialSelectedArea.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedArea.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.desiredWorkLocation,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedArea.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedArea.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedArea.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedArea.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedArea.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //근무기간
                GestureDetector(
                  onTap: () {
                    DefineDialog.showFilter(
                        context,
                        localization.workDuration,
                        workPeriodFilterList,
                        applyWorkPeriod,
                        initialSelectedWorkPeriod,
                        workPeriodFilterList.length);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color: initialSelectedWorkPeriod.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedWorkPeriod.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.workDuration,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedWorkPeriod.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedWorkPeriod.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedWorkPeriod.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedWorkPeriod.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedWorkPeriod.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                //경력
                GestureDetector(
                  onTap: () {
                    DefineDialog.showFilter(
                        context,
                        localization.experienced,
                        FilterService.careerFilter,
                        applyCareer,
                        initialSelectedCareer,
                        3);
                  },
                  child: Container(
                    height: 28.w,
                    margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                    padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.w,
                        color: initialSelectedCareer.isEmpty?
                        CommonColors.grayF2:CommonColors.red,
                      ),
                      borderRadius: BorderRadius.circular(8.w),
                      color: initialSelectedCareer.isEmpty
                          ? CommonColors.grayFc
                          : CommonColors.red,
                    ),
                    child: Row(
                      children: [
                        Text(
                          localization.experienced,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: initialSelectedCareer.isEmpty
                                ? CommonColors.black2b
                                : CommonColors.white,
                          ),
                        ),
                        // if (initialSelectedCareer.isNotEmpty)
                        //   Padding(
                        //     padding: EdgeInsets.only(left: 4.w),
                        //     child: Text(
                        //       '${initialSelectedCareer.length}',
                        //       style: TextStyle(
                        //         fontSize: 14.sp,
                        //         color: initialSelectedCareer.isEmpty
                        //             ? CommonColors.black2b
                        //             : CommonColors.white,
                        //       ),
                        //     ),
                        //   ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          initialSelectedCareer.isEmpty
                              ? 'assets/images/icon/iconArrowDown.png'
                              : 'assets/images/icon/iconArrowDownWhite.png',
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
      ],
    );
  }
}
