import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/company/widgets/company_evaluate_widget.dart';
import 'package:chodan_flutter_app/features/home/widgets/alba_list.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/company_img_widget.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class CompanyDetailScreen extends ConsumerStatefulWidget {
  const CompanyDetailScreen({required this.idx, super.key});

  final String idx;

  @override
  ConsumerState<CompanyDetailScreen> createState() =>
      _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends ConsumerState<CompanyDetailScreen>
    with Alerts {
  late Future<void> _allAsyncTasks;

  bool isLoading = true;

  UserModel? managerData;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  List<JobpostModel> jobpostList = [];

  EvaluateModel? companyEvaluate;

  List<ProfileModel> userProfileList = [];

  Map<String, dynamic> currentPosition = MapService.currentPosition;
  bool isRunning = false;

  getRecruiterProfileData() async {
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .getRecruiterProfile(int.parse(widget.idx));
    if (result.status == 200) {
      if (result.type == 1) {
        managerData = result.data;
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await getRecruiterProfileData();
    if (managerData != null) {
      await Future.wait<void>([
        savePageLog(),
        getCompanyJobpostingList(managerData!.companyInfo!.key, page),
        getCompanyEvaluate(managerData!.companyInfo!.key),
        getCurrentLocation(),
        getProfileList(),
        getUserClipAnnouncementList()
      ]);
    }
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getUserClipAnnouncementList() async {
    ApiResultModel result = await ref
        .read(userControllerProvider.notifier)
        .getUserClipAnnouncementList();
    if (result.type == 1) {
      setState(() {
        ref
            .read(userClipAnnouncementListProvider.notifier)
            .update((state) => result.data);
      });
    }
  }

  getProfileList() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getProfileList(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          int filteredIndex = result.data
              .indexOf((ProfileModel element) => element.mainProfile == 1);
          if (filteredIndex != -1) {
            ProfileModel data = result.data.removeAt(filteredIndex);
            result.data.insert(0, data);
          }
          setState(() {
            userProfileList = [...result.data];
          });
        }
      }
    }
  }

  getCompanyJobpostingList(int key, int page) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getCompanyJobpostingList(key, page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<JobpostModel> data = result.data;
        if (page == 1) {
          jobpostList = [...data];
        } else {
          jobpostList = [...jobpostList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  _loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      isLazeLoading = true;
      page = page + 1;
      getCompanyJobpostingList(managerData!.companyInfo!.key, page);
    }
  }

  void showBottomEvaluate(EvaluateModel data) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      isScrollControlled: true,
      // isDismissible:false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return CompanyEvaluateWidget(
          title: localization.companyRating,
          evaluateData: data,
        );
      },
    );
  }

  getCompanyEvaluate(int key) async {
    ApiResultModel result = await ref
        .read(companyControllerProvider.notifier)
        .getCompanyEvaluate(key);
    if (result.status == 200) {
      if (result.type == 1) {
        companyEvaluate = result.data;
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  String returnVerifyInfo(int isVerify, String verifyDate) {
    String result = '';
    if (ConvertService.convertIntToBool(isVerify)) {
      result =
          '${localization.certificationCompleted} (${ConvertService.convertDateISOtoString(verifyDate, ConvertService.YYYY_MM_DD_HH_MM_dot)})';
    } else {
      result = localization.certificationIncomplete;
    }
    return result;
  }

  getCurrentLocation() async {
    UserModel? userInfo = ref.read(userProvider);
    LocationService? locationService;
    if (userInfo != null) {
      locationService = LocationService(user: userInfo);
    } else {
      locationService = LocationService(user: userInfo);
    }
    Position? location = await locationService.returnCurrentLocation();
    if (location != null) {
      setState(() {
        currentPosition['lat'] = location.latitude;
        currentPosition['lng'] = location.longitude;
      });
    }
  }


  toggleLikeCompany(List list, int companyKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(companyKey)) {
      await deleteLikesCompany(companyKey);
    } else {
      await addLikesCompany(companyKey);
    }
    isRunning = false;
  }

  addLikesCompany(int idx) async {
    var result =
        await ref.read(companyControllerProvider.notifier).addLikesCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
        return result.data;
      }
    } else {
      if (result.type == -2801) {
        showDefaultToast(localization.alreadySavedAsInterestedCompany);
      } else if (mounted) {
        showDefaultToast(localization.dataCommunicationFailed);
      }
    }
  }

  deleteLikesCompany(int idx) async {
    var result = await ref
        .read(companyControllerProvider.notifier)
        .deleteLikesCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(companyLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.removedFromInterestedCompanies);
    } else {
      likeList.add(key);
      showDefaultToast(localization.savedAsInterestedCompany);
    }
    setState(() {
      ref
          .read(companyLikesKeyListProvider.notifier)
          .update((state) => [...likeList]);
    });
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
    _scrollController.addListener(_scrollListener);
    super.initState();
  }
  final GlobalKey _widgetKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  bool _showProfileTitle = false;

  void _scrollListener() {
    final RenderObject? renderObject =
    _widgetKey.currentContext!.findRenderObject();
    if (renderObject is RenderBox) {
      final double widgetPosition = renderObject.localToGlobal(Offset.zero).dy;
      final double scrollPosition = _scrollController.position.pixels;
      setState(() {
        if (scrollPosition >
            widgetPosition -
                CommonSize.safePaddingTop +
                200.w +
                renderObject.size.height) {
          _showProfileTitle = true; // 스크롤이 위젯 아래로 이동한 경우
        } else {
          _showProfileTitle = false; // 스크롤이 위젯 위로 이동한 경우
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> companyLikesKeyList = ref.watch(companyLikesKeyListProvider);
    UserModel? userInfo = ref.read(userProvider);
    
    return Scaffold(
      appBar: CommonAppbar(
        title:

        _showProfileTitle && !isLoading ?
        managerData!
            .companyInfo!.name:
        localization.companyInformation,
        actions: [
          if (!isLoading && userInfo!.key != managerData!.companyInfo!.key)
            AppbarButton(
              onPressed: () {
                toggleLikeCompany(
                    companyLikesKeyList, managerData!.companyInfo!.key);
              },
              childWidget: Image.asset(
                companyLikesKeyList.contains(managerData!.companyInfo!.key)
                    ? 'assets/images/icon/iconHeartActive.png'
                    : 'assets/images/icon/iconHeart.png',
                width: 24.w,
                height: 24.w,
              ),
              imgUrl: '',
              plural: true,
            ),
          SizedBox(
            width: 15.w,
          ),
        ],
      ),
      body: !isLoading
          ? Stack(
              children: [
                LazyLoadScrollView(
                  onEndOfPage: () => _loadMore(),
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: 16.w),
                            Padding(
                              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20.0.w),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: CommonColors.grayF2,
                                          offset: Offset(0, 2.w),
                                          blurRadius: 16.w,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        CompanyImgWidget(
                                          key:_widgetKey,
                                          imgUrl: managerData!
                                              .companyInfo!.files[0].url,
                                          color: Color(
                                              ConvertService.returnBgColor(
                                                  managerData!
                                                      .companyInfo!.color)),
                                          text: managerData!.companyInfo!.name,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              20.w, 0, 20.w, 0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              SizedBox(
                                                height: 16.w,
                                              ),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      managerData!
                                                          .companyInfo!.name,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.3.sp,
                                                        color:
                                                            CommonColors.gray4d,
                                                      ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      showBottomEvaluate(
                                                          companyEvaluate!);
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/icon/IconRoundStarActive.png',
                                                          width: 20.w,
                                                          height: 20.w,
                                                        ),
                                                        SizedBox(width: 8.w),
                                                        Column(
                                                          children: [
                                                            SizedBox(
                                                                height: 1.w),
                                                            Text(
                                                              '${companyEvaluate!.totalAvg}',
                                                              style: TextStyle(
                                                                fontSize: 13.sp,
                                                                height: 1.3.sp,
                                                                color:
                                                                    CommonColors
                                                                        .gray80,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20.w),
                                              Text(
                                                managerData!.companyInfo!
                                                    .companyIntroduce,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  height: 1.4.sp,
                                                  color: CommonColors.gray80,
                                                ),
                                              ),
                                              SizedBox(height: 20.w),
                                              DecoratedBox(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        color: CommonColors
                                                            .gray100,
                                                        width: 1.w),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20.w),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/icon/IconAddress.png',
                                                    fit: BoxFit.cover,
                                                    width: 20.w,
                                                    height: 20.w,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  SizedBox(
                                                    width: 60.w,
                                                    child: Text(
                                                      localization.industryName,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        height: 1.4.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            CommonColors.gray80,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16.w),
                                                  Expanded(
                                                    child: Text(
                                                      managerData!.industryName,
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        height: 1.4.sp,
                                                        color: CommonColors
                                                            .black2b,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 14.w),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/icon/IconPeople.png',
                                                    fit: BoxFit.cover,
                                                    width: 20.w,
                                                    height: 20.w,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  SizedBox(
                                                    width: 60.w,
                                                    child: Text(
                                                      localization.numberOfEmployees,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        height: 1.4.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            CommonColors.gray80,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16.w),
                                                  Expanded(
                                                    child: Text(
                                                      '${managerData!.companyInfo!.numberOfEmployees}명',
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        height: 1.4.sp,
                                                        color: CommonColors
                                                            .black2b,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 14.w),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/icon/IconLocation.png',
                                                    fit: BoxFit.cover,
                                                    width: 20.w,
                                                    height: 20.w,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  SizedBox(
                                                    width: 60.w,
                                                    child: Text(
                                                      localization.address,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        height: 1.4.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            CommonColors.gray80,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 16.w),
                                                  Expanded(
                                                    child: Text(
                                                      '${managerData!.companyInfo!.address} ${managerData!.companyInfo!.addressDetail}',
                                                      style: TextStyle(
                                                        fontSize: 15.sp,
                                                        height: 1.4.sp,
                                                        color: CommonColors
                                                            .black2b,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(height: 32.w),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.w),
                                  Container(
                                    padding:
                                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20.0.w),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: CommonColors.grayF2,
                                          offset: Offset(0, 2.w),
                                          blurRadius: 16.w,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 28.w),
                                        Text(
                                          localization.recruitmentContact,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5.sp,
                                            color: CommonColors.black,
                                          ),
                                        ),
                                        SizedBox(height: 16.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 80.w,
                                                  child: Text(
                                                    localization.contactPersonName,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.gray80,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Text(
                                                    managerData!.companyInfo!
                                                        .managerName.isEmpty ? '-' : managerData!.companyInfo!
                                                        .managerName,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.black2b,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.w),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 80.w,
                                                  child: Text(
                                                    localization.contactNumber,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.gray80,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Text(
                                                    managerData!.companyInfo!
                                                            .managerPhoneNumber
                                                            .contains('-')
                                                        ? managerData!
                                                            .companyInfo!
                                                            .managerPhoneNumber.isEmpty ? '-' : managerData!
                                                        .companyInfo!
                                                        .managerPhoneNumber
                                                        : managerData!
                                                          .companyInfo!
                                                          .managerPhoneNumber.isEmpty ? '-' : ConvertService
                                                            .formatPhoneNumber(
                                                                managerData!
                                                                    .companyInfo!
                                                                    .managerPhoneNumber),
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.black2b,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 16.w),
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 80.w,
                                                  child: Text(
                                                    localization.email,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.gray80,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                Expanded(
                                                  child: Text(
                                                    managerData!.companyInfo!
                                                        .managerEmail.isEmpty ? '-' : managerData!.companyInfo!
                                                        .managerEmail,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      height: 1.4.sp,
                                                      color:
                                                          CommonColors.black2b,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 36.w),
                                        Text(
                                          localization.businessCertification,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5.sp,
                                            color: CommonColors.black,
                                          ),
                                        ),
                                        SizedBox(height: 16.w),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0.w),
                                            color: CommonColors.gray100,
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              16.w, 20.w, 16.w, 20.w),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 80.w,
                                                child: Text(
                                                  localization.certificationStatus,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    height: 1.4.sp,
                                                    color: CommonColors.gray80,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  returnVerifyInfo(
                                                      managerData!.companyInfo!
                                                          .isCompanyVerify,
                                                      managerData!.companyInfo!
                                                          .companyVerifyDate),
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    height: 1.4.sp,
                                                    color: CommonColors.black2b,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 28.w),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 16.w),
                                  if(jobpostList.isNotEmpty)
                                  Container(
                                    padding:
                                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20.0.w),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: CommonColors.grayF2,
                                          offset: Offset(0, 2.w),
                                          blurRadius: 16.w,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 28.w),
                                        Text(
                                          localization.currentJobPostings,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w600,
                                            height: 1.5.sp,
                                            color: CommonColors.black,
                                          ),
                                        ),
                                        CustomScrollView(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          slivers: [
                                            SliverList(
                                              delegate:
                                                  SliverChildBuilderDelegate(
                                                childCount: jobpostList.length,
                                                (context, index) {
                                                  JobpostModel jobpostItem =
                                                      jobpostList[index];
                                                  return AlbaList(
                                                      jobpostItem: jobpostItem,
                                                      jobList: jobpostItem
                                                          .workInfo.jobList,
                                                      currentPosition:
                                                          currentPosition,
                                                      getProfile:
                                                          getProfileList,
                                                      isHome: false);
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const BottomPadding(),
                    ],
                  ),
                ),
                if (isLazeLoading) const Positioned(child: Loader())
              ],
            )
          : const Loader(),
    );
  }
}
