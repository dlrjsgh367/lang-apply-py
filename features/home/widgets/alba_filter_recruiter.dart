import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/commute/service/commute_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/home/service/filter_service.dart';
import 'package:chodan_flutter_app/features/home/widgets/home_search_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/filter_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

class AlbaFilterRecruiter extends ConsumerStatefulWidget {
  AlbaFilterRecruiter({
    super.key,
    required this.bodyType,
    required this.showOccu,
    required this.addFilterParam,
    required this.removeFilterParam,
    required this.resultLength,
    required this.currentPosition,
    required this.originPosition,
  });

  Function showOccu;

  String bodyType;

  final Function addFilterParam;
  final Function removeFilterParam;

  final int resultLength;

  final Map<String, dynamic> currentPosition;
  final Map<String, dynamic> originPosition;

  @override
  ConsumerState<AlbaFilterRecruiter> createState() => _AlbaFilterState();
}

class _AlbaFilterState extends ConsumerState<AlbaFilterRecruiter> {
  int maxLength = 10;

  List<Map<String, dynamic>> genderFilterList = [];

  List<Map<String, dynamic>> workTypeFilterList = [];

  List<Map<String, dynamic>> workPeriodFilterList = [];

  static const String JO_IDX = 'joIdx';

  static const String ME_SEX = 'meSex';

  static const String WT_IDX = 'wtIdx';

  static const String WP_IDX = 'wpIdx';

  static const String ME_AGE_MIN = 'meAgeMin';

  static const String ME_AGE_MAX = 'meAgeMax';

  static const String MP_HAVE_CAREER = 'mpHaveCareer';

  static const String DESIRE_AD_IDX = 'mpAdIdx';

  @override
  void initState() {
    Future(() async {
      await setDefaultArea();
    });
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

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.worker.type);
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return FilterBottomSheet(
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
          if (key == 0) {
            widget.removeFilterParam([ME_AGE_MIN, ME_AGE_MAX]);
            return;
          } else {
            paramData.add(FilterService.returnAgeFilterParam(key));
          }
        }
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([ME_AGE_MIN, ME_AGE_MAX]);
      }
    });
  }

  //근무형태
  List<Map<String, dynamic>> initialSelectedWorkType = [];
  List<int> selectedWorkTypeKey = [];

  int areaParentKey = 0;

  String titleArea = '';

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
  List<AddressModel> initialSelectedDesireArea = [];
  List<int> selectedDesireAreaKey = [];

  List<Map<String, dynamic>> selectedAreaItemList = [];

  setAreaName(int adIdx) async {
    List<AddressModel> areaList = await getAreaChildList();
    if (areaList.isNotEmpty) {
      for (AddressModel data in areaList) {
        if (data.key == adIdx) {
          setState(() {
            titleArea = data.dongName;
            List<Map<String, dynamic>> paramData = [
              {"disLat": data.lat},
              {"disLong": data.lng},
            ];
            widget.addFilterParam(paramData);
          });
        }
      }
    }
  }

  applyArea(List<AddressModel> addressItem, List<int> apply, int adParent) {
    if (addressItem.isEmpty) {
      initialSelectedArea.clear();
      selectedAreaItemList.clear();
      selectedAreaKey.clear();
      widget.removeFilterParam(["meAdString"]);
      return;
    }

    setState(() {
      initialSelectedArea = [...addressItem];
      selectedAreaItemList = [
        {
          'key': addressItem[0].key,
          'lat': addressItem[0].lat,
          'lng': addressItem[0].lng
        }
      ];
      selectedAreaKey = apply;
      areaParentKey = adParent;

      if (selectedAreaItemList.length == 1) {
        setAreaName(selectedAreaItemList[0]['key']);
      } else {
        widget.removeFilterParam(["meAdString"]);
      }
    });
  }

  applyDesireArea(
      List<AddressModel> addressItem, List<int> apply, int adParent) async {
    setState(() {
      initialSelectedDesireArea = [...addressItem];
      selectedDesireAreaKey = apply;
    });

    if (selectedDesireAreaKey.isNotEmpty) {
      List<Map<String, dynamic>> paramData = [
        {DESIRE_AD_IDX: selectedDesireAreaKey}
      ];
      setState(() {
        widget.addFilterParam(paramData);
      });
    } else {
      setState(() {
        widget.removeFilterParam([DESIRE_AD_IDX]);
      });
    }
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

  List<AddressModel> initialSelectedArea = [];

  applyCareer(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedCareer = [...itemList];
      selectedCareerKey = [...apply];
      if (selectedCareerKey.isNotEmpty) {
        List<Map<String, dynamic>> paramData = [];
        for (int key in selectedCareerKey) {
          if (key == 0) {
            widget.removeFilterParam([MP_HAVE_CAREER]);
            break;
          } else {
            paramData.add(FilterService.returnCareerFilterParam(key));
          }
        }
        widget.addFilterParam(paramData);
      } else {
        widget.removeFilterParam([MP_HAVE_CAREER]);
      }
    });
  }

  List<DefineModel> selectedJobList = [];
  List<int> selectedJobKey = [];

  List<int> selectedAreaKey = [];

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
    if (initialSelectedDesireArea.isNotEmpty) {
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

  bool openedFilter = false;

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return false;
    } else {
      return true;
    }
  }

  getAreaGuList() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getAreaGuList(DefineEnum.area);
    if (result.status == 200) {
      if (result.type == 1) {
        return result.data;
      }
    }
  }

  getAreaChildList() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getAreaChildList(DefineEnum.area, areaParentKey);
    if (result.status == 200) {
      if (result.type == 1) {
        return result.data;
      }
    }
  }

  AddressModel? defaultArea;

  setDefaultArea() async {
    bool hasLocationPermission = await checkLocationPermission();
    var areaGuList = await getAreaGuList();
    Map<String, dynamic> currentPosition = _getCurrentPosition();
    var address = await CommuteService.coord2RegionCode(
        currentPosition['lat'], currentPosition['lng']);
    if (hasLocationPermission && address != null) {
      await _processAreaGuList(address, currentPosition);
    } else {
      await _setDefaultAreaIfPermissionDenied(areaGuList);
    }
  }

  Map<String, dynamic> _getCurrentPosition() {
    if (widget.currentPosition == {} ||
        widget.currentPosition['lat'] == null ||
        widget.currentPosition['lng'] == null) {
      return {'lat': 37.489082, 'lng': 127.008046};
    }
    return widget.currentPosition;
  }

  Future<void> _processAreaGuList(Map<String, dynamic> address,
      Map<String, dynamic> currentPosition) async {
    var area = await getAreaCode(address);

    if (area != null) {
      _updateSelectedArea(area, currentPosition);
    }
  }

  getAreaCode(code) async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getAreaCode(code);
    if (result.status == 200) {
      if (result.type == 1) {
        return result.data;
      }
    }
  }

  void _updateSelectedArea(var dong, Map<String, dynamic> currentPosition) {
    setState(() {
      titleArea = dong.dongName;
      selectedAreaItemList = [
        {
          'key': dong.key,
          'lat': currentPosition['lat'],
          "lng": currentPosition['lng']
        }
      ];
      areaParentKey = dong.key;
      defaultArea = dong;
      selectedAreaKey = [dong.key];
      initialSelectedArea = [dong];

      List<Map<String, dynamic>> paramData = [
        {"disLat": dong.lat},
        {"disLong": dong.lng},
      ];
      widget.addFilterParam(paramData);
    });
  }

  Future<void> _setDefaultAreaIfPermissionDenied(List areaGuList) async {
    if (areaGuList.isEmpty) return;

    for (var data in areaGuList) {
      var district = _getDistrictFromGu(data.gu);

      if (district == localization.seochoGu) {
        setState(() {
          areaParentKey = data.key;
        });

        var areaList = await getAreaChildList();
        var matchedDong;
        for (var dong in areaList) {
          if (dong.dongName == localization.seochoDong) {
            matchedDong = dong;
            break;
          }
        }

        if (matchedDong != null) {
          _updateSelectedArea(
              matchedDong, {'lat': matchedDong.lat, 'lng': matchedDong.lng});
        }
        return;
      }
    }
  }

  String _getDistrictFromGu(String gu) {
    List<String> parts = gu.split(' ');
    return parts.last;
  }

  resetFilter() async {
    //직종
    selectedJobList = [];
    selectedJobKey = [];

    //성별
    initialSelectedGender = [];
    selectedGenderKey = [];
    //연령
    initialSelectedAge = [];
    selectedAgeKey = [];
    //근무형태
    initialSelectedWorkType = [];
    selectedWorkTypeKey = [];

    //희망근무지
    initialSelectedDesireArea = [];
    selectedDesireAreaKey = [];

    //근무기간

    initialSelectedWorkPeriod = [];
    selectedWorkPeriodKey = [];

    //경력
    initialSelectedCareer = [];
    selectedCareerKey = [];

    widget.removeFilterParam([
      JO_IDX,
      ME_SEX,
      WT_IDX,
      WP_IDX,
      ME_AGE_MIN,
      ME_AGE_MAX,
      MP_HAVE_CAREER,
      DESIRE_AD_IDX
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
    List<AddressModel> areaList = ref.watch(areaListProvider);
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      DefineDialog.showAreaBottomHome(
                          context,
                          localization.selectRegion,
                          areaList,
                          applyArea,
                          initialSelectedArea,
                          defaultArea!,
                          widget.originPosition,
                          1);
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/icon/iconPin.png',
                          width: 20.w,
                          height: 20.w,
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Flexible(
                          child: Text(
                            selectedAreaItemList.isEmpty
                                ? localization.selectRegionPrompt
                                : titleArea,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4.w,
                        ),
                        Image.asset(
                          'assets/images/icon/iconArrowDown.png',
                          width: 16.w,
                          height: 16.w,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      openedFilter = !openedFilter;
                    });
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        openedFilter
                            ? 'assets/images/icon/iconSearchRed.png'
                            : 'assets/images/icon/iconSearch.png',
                        width: 38.w,
                        height: 24.w,
                      ),
                      if (countFilter() != 0)
                        Positioned(
                            right: -10.w,
                            bottom: 10.w,
                            child: Container(
                              width: 20.w,
                              height: 20.w,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red, // 배경색을 빨간색으로 설정
                              ),
                              child: Text(
                                '${countFilter()}',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.white,
                                    height: 1.0),
                              ),
                            ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (openedFilter)
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 8.w),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        resetFilter();
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0.w, 0, 10.w, 0),
                      child: Image.asset(
                        'assets/images/icon/iconReload.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                    ),
                  ),
                  //직종
                  GestureDetector(
                    onTap: () {
                      savePageLog();
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
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: selectedJobList.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          selectedJobList.isEmpty
                              ? Text(
                                  localization.jobCategory,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: selectedJobList.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.jobCategoryCount(selectedJobList.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: selectedJobList.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
                      savePageLog();
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
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedGender.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedGender.isEmpty
                              ? Text(
                                  localization.gender,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedGender.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.genderCount(initialSelectedGender.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedGender.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
                      savePageLog();
                      DefineDialog.showFilter(
                          context,
                          localization.age,
                          FilterService.ageFilter,
                          applyAge,
                          initialSelectedAge,
                          1);
                    },
                    child: Container(
                      height: 28.w,
                      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedAge.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedAge.isEmpty
                              ? Text(
                                  localization.age,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedAge.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  // '연령 ${initialSelectedAge.length}',
                                  localization.ageCount(initialSelectedAge.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedAge.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
                      savePageLog();
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
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedWorkType.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedWorkType.isEmpty
                              ? Text(
                                  localization.employmentType,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedWorkType.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.employmentTypeCount(initialSelectedWorkType.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedWorkType.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
                      savePageLog();
                      DefineDialog.showAreaBottom(
                          context,
                          localization.selectRegion,
                          areaList,
                          applyDesireArea,
                          initialSelectedDesireArea,
                          maxLength);
                    },
                    child: Container(
                      height: 28.w,
                      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedDesireArea.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedDesireArea.isEmpty
                              ? Text(
                                  localization.desiredWorkLocation2,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedWorkType.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.desiredWorkLocation2Count(initialSelectedDesireArea.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedDesireArea.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Image.asset(
                            initialSelectedDesireArea.isEmpty
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
                      savePageLog();
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
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedWorkPeriod.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedWorkPeriod.isEmpty
                              ? Text(
                                  localization.workDuration,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedWorkPeriod.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.workDurationCount(initialSelectedWorkPeriod.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedWorkPeriod.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
                      savePageLog();
                      DefineDialog.showFilter(
                          context,
                          localization.experienced,
                          FilterService.careerFilter,
                          applyCareer,
                          initialSelectedCareer,
                          1);
                    },
                    child: Container(
                      height: 28.w,
                      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                        color: initialSelectedCareer.isEmpty
                            ? CommonColors.grayFc
                            : CommonColors.red,
                      ),
                      child: Row(
                        children: [
                          initialSelectedCareer.isEmpty
                              ? Text(
                                  localization.experienced,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedCareer.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                )
                              : Text(
                                  localization.experiencedCount(initialSelectedCareer.length),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: initialSelectedCareer.isEmpty
                                        ? CommonColors.black2b
                                        : CommonColors.white,
                                  ),
                                ),
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
      ),
    );
  }
}
