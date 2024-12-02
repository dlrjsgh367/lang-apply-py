import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/commute/service/commute_service.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/home/service/filter_service.dart';
import 'package:chodan_flutter_app/features/home/widgets/home_search_jobseeker_widget.dart';
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

class AlbaFilterJobseeker extends ConsumerStatefulWidget {
  AlbaFilterJobseeker({
    super.key,
    required this.bodyType,
    required this.getPostList,
    required this.setSelectedGenderKey,
    required this.setSelectedAgeKey,
    required this.setSelectedWorkTypeKey,
    required this.setSelectedAreaKey,
    required this.setSelectedWorkPeriodKey,
    required this.setSelectedCareerKey,
    required this.setSelectedDesireArea,
    required this.setSelectedSalaryType,
    required this.listLength,
    required this.isSearch,
    required this.setSelectPosition,
    required this.moveSelectLocation,
    required this.userProfileList,
    required this.currentPosition,
    required this.searchJobPostList,
    required this.isFirstGet,
    required this.setSelectedSalary,
    required this.selectedJobList,
    required this.selectedJobKeyList,
    required this.addWorkJob,
    required this.setSelectPositionKey,
    required this.originPosition,
  });

  String bodyType;
  Function getPostList;
  Function setSelectedGenderKey;
  Function setSelectedAgeKey;
  Function setSelectedWorkTypeKey;
  Function setSelectedAreaKey;
  Function setSelectedWorkPeriodKey;
  Function setSelectedCareerKey;
  Function setSelectedDesireArea;
  Function setSelectedSalaryType;
  int listLength;
  bool isSearch;
  Function setSelectPosition;
  Function moveSelectLocation;
  List<ProfileModel> userProfileList;
  Map<String, dynamic> currentPosition;
  Function searchJobPostList;
  bool isFirstGet;
  Function setSelectedSalary;

  List selectedJobList;
  List selectedJobKeyList;
  Function addWorkJob;
  Function setSelectPositionKey;
  Map<String, dynamic> originPosition;

  @override
  ConsumerState<AlbaFilterJobseeker> createState() => _AlbaFilterState();
}

class _AlbaFilterState extends ConsumerState<AlbaFilterJobseeker> {
  bool openedFilter = false;
  int maxLength = 10;
  List<Map<String, dynamic>> genderFilterList = [];
  List<Map<String, dynamic>> workTypeFilterList = [];
  List<Map<String, dynamic>> careerFilterList = [];
  List<Map<String, dynamic>> workPeriodFilterList = [];
  int areaParentKey = 0;
  String titleArea = '';
  String? searchKeyword;
  AddressModel? defaultArea;
  bool isLoading = true;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() async {
        await setDefaultArea();
      });
      List<ProfileModel> workTypeData = ref.watch(workTypeListProvider);
      List<ProfileModel> workPeriodData = ref.watch(workPeriodListProvider);

      setState(() {
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

        careerFilterList = FilterService.careerFilter;
      });
      // 나머지 코드
    });

    super.initState();
  }

  searchApply(String keyword) async {
    setState(() {
      searchKeyword = keyword;
    });

    await widget.searchJobPostList(searchKeyword);

    context.pop();
  }

  resetSearch() async {
    setState(() {
      searchKeyword = '';
    });

    await widget.searchJobPostList(searchKeyword);
  }

  showSearchModal() {
    showModalSideSheet(
      width: CommonSize.vw,
      useRootNavigator: false,
      withCloseControll: false,
      ignoreAppBar: true,
      context: context,
      transitionDuration: const Duration(milliseconds: 200),
      body: HomeSearchJobseekerWidget(
        searchFunc: searchApply,
        searchKeyword: searchKeyword,
        searchPlaceHolder: localization.findPartTimeJobBySearch,
        resetJobPost: resetSearch,
      ),
    );
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
      widget.setSelectedGenderKey(selectedGenderKey);
    });

    widget.getPostList(1);
  }

  //연령
  List<Map<String, dynamic>> initialSelectedAge = [];
  List<int> selectedAgeKey = [];

  applyAge(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedAge = [...itemList];
      selectedAgeKey = [...apply];
      widget.setSelectedAgeKey(selectedAgeKey);
    });

    widget.getPostList(1);
  }

  //근무형태
  List<Map<String, dynamic>> initialSelectedWorkType = [];
  List<int> selectedWorkTypeKey = [];

  applyWorkType(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedWorkType = [...itemList];
      selectedWorkTypeKey = [...apply];
      widget.setSelectedWorkTypeKey(selectedWorkTypeKey);
    });

    widget.getPostList(1);
  }

  // 지역
  List<AddressModel> initialSelectedArea = [];
  List<Map<String, dynamic>> selectedAreaItemList = [];
  List<int> selectedAreaKey = [];

  applyArea(
      List<AddressModel> addressItem, List<int> apply, int adParent) async {
    if (addressItem.isEmpty) {
      showDefaultToast(localization.selectRegionPrompt);
    }

    initialSelectedArea = [...addressItem];
    selectedAreaItemList = [
      {
        'key': addressItem[0].key,
        'lat': addressItem[0].lat,
        'lng': addressItem[0].lng,
      }
    ];

    selectedAreaKey = apply;
    widget.setSelectedAreaKey(selectedAreaItemList);
    areaParentKey = adParent;

    if (selectedAreaItemList.length == 1) {
      titleArea = addressItem[0].dongName;
      widget.setSelectPosition(
          addressItem[0].lat, addressItem[0].lng, addressItem[0].key);
      widget.moveSelectLocation();
    }
    widget.getPostList(1);
  }

  // 희망근무지
  List<AreaInfoModel> initialSelectedDesireArea = [];
  List<int> selectedDesireAreaKey = [];

  applyDesireArea(List<AreaInfoModel> addressItem, List<int> apply) {
    setState(() {
      initialSelectedDesireArea = [...addressItem];
      selectedDesireAreaKey = [...apply];
    });
    widget.setSelectedDesireArea(
        initialSelectedDesireArea, selectedDesireAreaKey);
  }

  //근무기간

  List<Map<String, dynamic>> initialSelectedWorkPeriod = [];
  List<int> selectedWorkPeriodKey = [];

  applyWorkPeriod(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedWorkPeriod = [...itemList];
      selectedWorkPeriodKey = [...apply];
      widget.setSelectedWorkPeriodKey(selectedWorkPeriodKey);
    });

    widget.getPostList(1);
  }

  //경력
  List<Map<String, dynamic>> initialSelectedCareer = [];
  List<int> selectedCareerKey = [];

  applyCareer(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedCareer = [...itemList];
      selectedCareerKey = [...apply];
      widget.setSelectedCareerKey(selectedCareerKey);
    });

    widget.getPostList(1);
  }

  //급여
  String initialSelectedSalaryType = '';
  String selectedSalaryType = '';

  applySalaryType(String apply) {
    setState(() {
      initialSelectedSalaryType = apply;
      selectedSalaryType = apply;
      widget.setSelectedSalaryType(selectedSalaryType);
    });
  }

  //급여
  int initialSelectedSalary = 0;
  int selectedSalary = 0;

  applySalary(int apply) {
    setState(() {
      initialSelectedSalary = apply;
      selectedSalary = apply;
      widget.setSelectedSalary(selectedSalary);
    });
  }

  // 직종

  addWorkJob(List jobItem, List apply) {
    widget.addWorkJob(jobItem, apply);
    savePageLog();
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

  getAreaCode(code) async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getAreaCode(code);
    if (result.status == 200) {
      if (result.type == 1) {
        return result.data;
      }
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

  setAreaName(int adIdx, bool isDefault) async {
    var areaList = await getAreaChildList();
    if (areaList.isNotEmpty) {
      for (var data in areaList) {
        if (data.key == adIdx) {
          setState(() {
            titleArea = data.dongName;
            if (!isDefault) {
              widget.setSelectPosition(data.lat, data.lng, data.key);
              widget.moveSelectLocation();
            } else {
              widget.setSelectPositionKey(data.key);
            }
          });
        }
      }
    }
  }

  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return false; // 위치 권한이 거부됨
    } else {
      return true; // 위치 권한이 허용됨
    }
  }

  setDefaultArea() async {
    setState(() {
      isLoading = true;
    });

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

    widget.setSelectedAreaKey(selectedAreaItemList);
    widget.getPostList(1);
    setState(() {
      isLoading = false;
    });
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
      defaultArea = dong;
      selectedAreaKey = [dong.key];
      initialSelectedArea = [dong];
      setAreaName(selectedAreaItemList[0]['key'], true);
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.jobPosting.type);
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
    List<AddressModel> areaList = ref.watch(areaListProvider);

    return !isLoading
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        child: ColoredBox(
                          color: Colors.transparent,
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
                                  selectedAreaItemList.isEmpty && !isLoading
                                      ? localization.setRegion
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
                    ),

                    Row(
                      children: [
                        if (widget.bodyType == 'list')
                          GestureDetector(
                            onTap: () {
                              showSearchModal();
                            },
                            child: Image.asset(
                              widget.isSearch && searchKeyword != null
                                  ? 'assets/images/icon/iconSearchRed.png'
                                  : 'assets/images/icon/iconSearch.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                          ),
                        SizedBox(
                          width: 8.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              openedFilter = !openedFilter;
                            });
                          },
                          child: Image.asset(
                            openedFilter
                                ? 'assets/images/icon/iconFilterRed.png'
                                : 'assets/images/icon/iconFilter.png',
                            width: 24.w,
                            height: 24.w,
                          ),
                        ),
                      ],
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
                      //직종
                      GestureDetector(
                        onTap: () {
                          savePageLog();
                          DefineDialog.showJobBottom(
                              context,
                              localization.jobCategory,
                              jobList,
                              addWorkJob,
                              widget.selectedJobList,
                              10,
                              DefineEnum.job);
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
                            color: widget.selectedJobList.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.jobCategory,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: widget.selectedJobList.isNotEmpty
                                      ? CommonColors.white
                                      : CommonColors.black,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                widget.selectedJobList.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
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
                          DefineDialog.showFilter(
                              context,
                              localization.gender,
                              genderFilterList,
                              applyGender,
                              initialSelectedGender,
                              3);
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
                            color: selectedGenderKey.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.gender,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedGenderKey.isNotEmpty
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedGenderKey.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
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
                              FilterService.ageElasticFilter,
                              applyAge,
                              initialSelectedAge,
                              FilterService.ageElasticFilter.length);
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
                            color: selectedAgeKey.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.age,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedAgeKey.isNotEmpty
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedAgeKey.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
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
                            color: selectedWorkTypeKey.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.employmentType,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedWorkTypeKey.isNotEmpty
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedWorkTypeKey.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
                                width: 16.w,
                                height: 16.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.userProfileList.isNotEmpty)
                        //희망근무지
                        GestureDetector(
                          onTap: () {
                            savePageLog();
                            DefineDialog.showMemberAreaFilter(
                                context,
                                localization.desiredWorkLocation,
                                widget.userProfileList[0].profileAreas,
                                applyDesireArea,
                                initialSelectedDesireArea,
                                10);
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
                              color: selectedDesireAreaKey.isNotEmpty
                                  ? CommonColors.red
                                  : CommonColors.grayFc,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  localization.desiredWorkLocation,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: selectedDesireAreaKey.isNotEmpty
                                        ? Colors.white
                                        : CommonColors.black2b,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Image.asset(
                                  selectedDesireAreaKey.isNotEmpty
                                      ? 'assets/images/icon/iconArrowDownWhite.png'
                                      : 'assets/images/icon/iconArrowDown.png',
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
                            color: selectedWorkPeriodKey.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.workDuration,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedWorkPeriodKey.isNotEmpty
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedWorkPeriodKey.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
                                width: 16.w,
                                height: 16.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                      //급여
                      GestureDetector(
                        onTap: () {
                          savePageLog();
                          DefineDialog.showSalaryFilter(
                              context,
                              widget.getPostList,
                              applySalaryType,
                              applySalary,
                              initialSelectedSalaryType,
                              initialSelectedSalary);
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
                            color: selectedSalaryType.isNotEmpty ||
                                    selectedSalary > 0
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.salary,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedSalaryType.isNotEmpty ||
                                          selectedSalary > 0
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedSalaryType.isNotEmpty ||
                                        selectedSalary > 0
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
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
                              careerFilterList,
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
                              color: CommonColors.grayF2,
                            ),
                            borderRadius: BorderRadius.circular(8.w),
                            color: selectedCareerKey.isNotEmpty
                                ? CommonColors.red
                                : CommonColors.grayFc,
                          ),
                          child: Row(
                            children: [
                              Text(
                                localization.experienced,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: selectedCareerKey.isNotEmpty
                                      ? Colors.white
                                      : CommonColors.black2b,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Image.asset(
                                selectedCareerKey.isNotEmpty
                                    ? 'assets/images/icon/iconArrowDownWhite.png'
                                    : 'assets/images/icon/iconArrowDown.png',
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
              if (widget.bodyType == 'list' &&
                  widget.isSearch &&
                  searchKeyword != null &&
                  searchKeyword != '')
                SizedBox(
                  height: 40.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            '‘$searchKeyword’',
                            style: TextStyle(
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                              color: CommonColors.red,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                        ],
                      ),
                      Text(
                        localization.searchResults,
                        style: TextStyle(
                            fontSize: 14.w,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.black2b),
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Text(
                        localization.resultCount(widget.listLength),
                        style: TextStyle(
                            fontSize: 14.w,
                            fontWeight: FontWeight.w600,
                            color: CommonColors.black2b),
                      ),
                      SizedBox(
                        width: 16.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          widget.getPostList(1);
                        },
                        child: Image.asset(
                          'assets/images/icon/iconReload.png',
                          width: 20.w,
                          height: 20.w,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          )
        : const SizedBox();
  }
}
