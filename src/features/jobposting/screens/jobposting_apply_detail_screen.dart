import 'dart:async';
import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/branch_dynamiclink.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_career_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_type_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/negotiable_enum.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_constants.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_service.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_swiper_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/map/widgets/google_map_widget.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/posting_model.dart';
import 'package:chodan_flutter_app/models/preferential_condition_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/report_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/report_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class JobpostingApplyDetailScreen extends ConsumerStatefulWidget {
  const JobpostingApplyDetailScreen(
      {required this.idx, required this.type, super.key});

  final String idx;
  final String type;

  @override
  ConsumerState<JobpostingApplyDetailScreen> createState() =>
      _JobpostingApplyDetailScreenState();
}

class _JobpostingApplyDetailScreenState
    extends ConsumerState<JobpostingApplyDetailScreen> with Alerts {
  late Future<void> _allAsyncTasks;

  bool isLoading = true;

  JobpostModel? jobpostData;
  PostingModel? applyData;

  EvaluateModel? companyEvaluate;

  bool isRunning = false;

  Timer? runningTimer;

  final TextEditingController jobpostReportReasonController =
      TextEditingController();

  List<ReportModel> reportList = [];

  List<ProfileModel> userProfileList = [];

  Map<String, dynamic> currentPosition = MapService.currentPosition;

  BranchDynamicLink dynamicLink = BranchDynamicLink();

  void openShare(String url) async {
    Share.share(
      await dynamicLink.generateLink(context, url),
    );
    runningTimer = Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        isRunning = false;
      });
    });
  }

  getReportReasonList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getReportReasonList();
    if (result.status == 200) {
      if (result.type == 1) {
        reportList = result.data;
      }
    }
  }

  isDoneDay(String date) {
    String endDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(date));
    var toDay = DateTime.now();
    return !DateTime.parse(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(endDate)))
        .isAfter(toDay);
  }

  getJobpostingDetail(int jobpostingKey) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingDetail(jobpostingKey);
    if (result.status == 200 && result.type == 1) {
      setState(() {
        jobpostData = result.data;
      });
      if (jobpostData == null) {
        if (!mounted) return null;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertTitle: localization.guide,
              alertContent: localization.nonexistentJobPost,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
                context.pop();
              },
            );
          },
        );
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
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

  getApplyPostDetail(int idx, int type) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getApplyPostDetail(idx, type);
    if (result.type == 1) {
      setState(() {
        applyData = result.data[0];
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  Future<void> _getAllAsyncTasks() async {
    setState(() {
      isLoading = true;
    });
    await getJobpostingDetail(int.parse(widget.idx));
    if (widget.type == 'apply') {
      await getApplyPostDetail(int.parse(widget.idx), 1);
    } else {
      await getApplyPostDetail(int.parse(widget.idx), 2);
    }

    if (jobpostData != null) {
      await Future.wait<void>([
        savePageLog(),
        getCompanyEvaluate(jobpostData!.owner.key),
        getReportReasonList(),
        getCurrentLocation(),
        getProfileList(),
      ]);
    }
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
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  final GlobalKey _widgetKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  ReportModel? reportReason;

  setReportReason(ReportModel reason) {
    setState(() {
      reportReason = reason;
    });
  }

  String reportDetail = '';

  setReportDetail(String stringValue) {
    setState(() {
      reportDetail = stringValue;
    });
  }

  showReport([Function? afterFunc]) {
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
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomState) {
          return ReportBottomSheet(
            title: localization.reportJobPost,
            text: localization.reportInappropriateJobInfo,
            afterFunc: afterFunc != null
                ? () {
                    afterFunc();
                  }
                : null,
            setData: (ReportModel value) {
              bottomState(() {
                setReportReason(value);
              });
            },
            groupValue: reportReason,
            selectedValue: reportReason,
            textController: jobpostReportReasonController,
            reportList: reportList,
            setReportDetail: (String value) {
              bottomState(() {
                setReportDetail(value);
              });
            },
          );
        });
      },
    ).whenComplete(() {
      jobpostReportReasonController.text = '';
      setReportReason(reportList[0]);
    });
  }

  TextEditingController reportTextController = TextEditingController();

  String returnAgeCondition(int minAge, int maxAge) {
    if (minAge == 0 && maxAge == 0) {
      return JobpostingConstants.anyAge;
    }
    if (minAge == 0) {
      return '${JobpostingConstants.maxAge} ${localization.ageValue(maxAge)}';
    } else if (maxAge == 0) {
      return '${JobpostingConstants.minAge} ${localization.ageValue(minAge)}';
    } else {
      return '${localization.ageGreaterThanOrEqualToMinAge(minAge)} ~ ${localization.ageLessThanOrEqualToMaxAge(maxAge)}';
    }
  }

  String returnSchoolCondition(
      int schoolKey, String schoolType, String schoolStatus) {
    if (schoolKey == 0 && schoolType == '') {
      return JobpostingConstants.noMatter;
    } else {
      return schoolType;
    }
  }

  String returnCareerCondition(
      ConditionCareerEnum conditionCareerEnum, int minCareer, int maxCareer) {
    String result = JobpostingConstants.noMatter;
    if (conditionCareerEnum == ConditionCareerEnum.anyCareer) {
      result = JobpostingConstants.noMatter;
    } else if (conditionCareerEnum == ConditionCareerEnum.entry) {
      result = '${ConditionCareerEnum.entry.label} $minCareer ~ $maxCareer 년';
    } else {
      result =
          '${ConditionCareerEnum.experienced.label} $minCareer ~ $maxCareer 년';
    }
    return result;
  }

  reportJobposting(JobpostModel jobpostItem) async {
    if (isRunning) {
      return;
    } else {
      isRunning = true;
    }
    if (reportReason == null) {
      isRunning = false;
      showDefaultToast(localization.selectReportReason);
      return;
    } else if (reportReason?.key == 5 && reportDetail == '') {
      isRunning = false;
      showDefaultToast(localization.enterReportReason);
      return;
    }
    if (jobpostItem.owner.key == 0) {
      isRunning = false;
      showDefaultToast(localization.cannotReportJobPost);
      return;
    }
    Map<String, dynamic> params = {
      'reCategory': 3,
      'reOriginal': jobpostItem.key,
      'reTitle': jobpostItem.title,
      'reAccused': jobpostItem.owner.key,
      'reReason': reportReason!.key,
      'reDetail': reportDetail
    };

    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .reportEventComment(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.reportSubmitted);
        if (mounted) {
          context.pop();
        }
      }
    } else if (result.status == 401) {
      showDefaultToast(localization.cannotReportYourOwnPost);
    } else if (result.status == 409) {
      showDefaultToast(localization.duplicateReportLimitReached);
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
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

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;

    return double.parse(distance.toStringAsFixed(1));
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
          userProfileList = [...result.data];
        }
      }
    }
  }

  getUserClipAnnouncementList() async {
    ApiResultModel result = await ref
        .read(userControllerProvider.notifier)
        .getUserClipAnnouncementList();
    if (result.type == 1) {
      setState(() {
        ref
            .read(userClipAnnouncementListProvider.notifier)
            .update((state) => [...result.data]);
      });
    }
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

  getLatestJobposting() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getLatestJobpost(1);
    if (result.status == 200) {
      if (result.type == 1) {
        List<JobpostModel> data = result.data;
        ref.read(lastJobpostProvider.notifier).update((state) => data);
      }
    }
  }

  saveShareLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .saveShareLog(int.parse(widget.idx));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    getLatestJobposting();
    if (runningTimer != null && runningTimer!.isActive) {
      runningTimer!.cancel();
    }
    super.dispose();
  }

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
          _showTitle = true; // 스크롤이 위젯 아래로 이동한 경우
        } else {
          _showTitle = false; // 스크롤이 위젯 위로 이동한 경우
        }
      });
    }
  }

  returnHour() {
    var data = '';
    for (int i = 0; i < jobpostData!.workCondition.workHour.length; i++) {
      data = data + jobpostData!.workCondition.workHour[i].mergeTime;
    }
    return data;
  }

  cancelJobPosting(int key) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(key, 0);
    if (result.type == 1) {
      _getAllAsyncTasks().then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.applicationCancelSuccess,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
              getApplyOrProposedJobpostKey();
            },
            alertTitle: localization.notification,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.applicationCancelFailure,
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

  getApplyOrProposedJobpostKey() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getApplyOrProposedJobpostKey();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref.read(applyOrProposedJobpostKeyListProvider.notifier).update(
              (state) =>
                  [...result.data['jpIdx'], ...result.data['jpIdxApproved']]);
        });
      }
    }
  }

  blockCompany(int key) async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).createHide(key, 1);
    if (result.type == 1) {
      Future(() {
        showDefaultToast(localization.savedAsBlockedCompany);
      });
      context.pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.blockFailure,
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

  deAcceptJobPosting(int key) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(key, 3);
    if (result.type == 1) {
      context.pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.proposalRejectionFailed,
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

  acceptJobPosting(dynamic item) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(item.key, 2);
    if (result.type == 1) {
      Future(() {
        List<int> list = ref.watch(applyOrProposedJobpostKeyListProvider);
        list.add(item.postKey);
        ref
            .read(applyOrProposedJobpostKeyListProvider.notifier)
            .update((state) => list);
      });
      context.pop();
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
        useSafeArea: true,
        builder: (BuildContext context) {
          return ContentBottomSheet(
            contents: [
              SizedBox(
                height: 20.w,
              ),
              Center(
                child: Image.asset(
                  'assets/images/icon/iconCheckRec.png',
                  width: CommonSize.vw / 3,
                  height: CommonSize.vw / 3,
                ),
              ),
              SizedBox(
                height: 20.w,
              ),
              Text(
                localization.matchedSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.black2b,
                ),
              ),
              SizedBox(
                height: 10.w,
              ),
              Text(
                localization.chatWindowOpeningSoonContactFromEmployer,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.grayB2,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                child: CommonButton(
                  onPressed: () {
                    context.pop();
                  },
                  text: localization.confirm,
                  confirm: true,
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.proposalAcceptanceFailed,
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

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    List<int> companyLikesKeyList = ref.watch(companyLikesKeyListProvider);
    List scrapList = ref.watch(userClipAnnouncementListProvider);
    List<int> applyOrProposedJobpostKeyList =
        ref.watch(applyOrProposedJobpostKeyListProvider);
    List hideCompanyKeyList = ref.watch(companyHidesKeyListProvider);

    return Scaffold(
      appBar: CommonAppbar(
        title: jobpostData != null && jobpostData?.owner.key != userInfo?.key
            ? _showTitle && !isLoading
                ? jobpostData!.title
                : localization.jobInformation
            : localization.viewMyJobPosts,
        actions: [
          if (jobpostData != null && jobpostData?.owner.key != userInfo?.key)
            AppbarButton(
              onPressed: () {
                if (!isLoading) {
                  showReport(() {
                    FocusManager.instance.primaryFocus?.unfocus();
                    reportJobposting(jobpostData!);
                  });
                }
              },
              imgUrl: 'iconReport.png',
              plural: true,
            ),
          if (jobpostData != null && jobpostData?.owner.key != userInfo?.key)
            AppbarButton(
              onPressed: () {
                if (!isRunning) {
                  setState(() {
                    isRunning = true;
                  });
                  // 활동 로그 쌓기
                  saveShareLog();
                  openShare('jobpost/${widget.idx}');
                }
              },
              imgUrl: 'iconShare.png',
              plural: true,
            ),
          SizedBox(
            width: 15.w,
          ),
        ],
      ),
      body: !isLoading && jobpostData != null
          ? Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: jobpostData!.files.isNotEmpty
                          ? PostingSwiperWidget(
                              key: _widgetKey,
                              data: jobpostData!.files,
                            )
                          : AspectRatio(
                              key: _widgetKey,
                              aspectRatio: 360 / 244,
                              child: Container(
                                color: CommonColors.grayF2,
                                alignment: Alignment.center,
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    Color(
                                      ConvertService.returnBgColor(
                                          jobpostData!.color),
                                    ),
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    'assets/images/default/iconNoCompany.png',
                                    width: 52.w,
                                    height: 52.w,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${jobpostData!.dongName} ${distanceBetween(jobpostData!.lat, jobpostData!.long)}km',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                ),
                                Text(
                                  ConvertService.convertDateISOtoString(
                                      jobpostData!.createdAt,
                                      ConvertService.YYYY_MM_DD_HH_MM_dot),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: CommonColors.grayB2,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Text(
                              jobpostData!.title,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d,
                              ),
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Divider(
                              height: 1.w,
                              color: CommonColors.grayF7,
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            if (jobpostData!.companyInfo.key != 0)
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.w,
                                children: [
                                  Container(
                                    height: 24.w,
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color: CommonColors.grayF7),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          jobpostData!.companyInfo.name,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(
                              height: 4.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/icon/iconSalaryNew.png',
                                              width: 18.w,
                                              height: 18.w,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              jobpostData!.workCondition
                                                  .salaryType.label,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray80,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                        Wrap(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4.w),
                                              child: Text(
                                                '${ConvertService.returnStringWithCommaFormat(jobpostData!.workCondition.salary)}원',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                            ),
                                            if (jobpostData!.workCondition
                                                    .salaryNegotiable ==
                                                NegotiableEnum.possible)
                                              Text(
                                                '(${ConvertService.returnNegotiable(jobpostData!.workCondition.salaryNegotiable)})',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/icon/iconBagNew.png',
                                              width: 18.w,
                                              height: 18.w,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              localization.employmentType,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray80,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                        Wrap(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4.w),
                                              child: Text(
                                                jobpostData!
                                                    .workCondition.workTypeName,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '(${JobpostingService.returnProbationPeriod(jobpostData!.workCondition.probationPeriod)})',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.black2b,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/icon/iconCalendarNew.png',
                                              width: 18.w,
                                              height: 18.w,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              localization.dayOfWeek,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray80,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                        Wrap(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4.w),
                                              child: Text(
                                                ConvertService
                                                    .returnSortedWorkDays(
                                                        jobpostData!
                                                            .workCondition
                                                            .workDays),
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                            ),
                                            if (jobpostData!.workCondition
                                                    .workDayNegotiable ==
                                                NegotiableEnum.possible)
                                              Text(
                                                '(${ConvertService.returnNegotiable(jobpostData!.workCondition.workDayNegotiable)})',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/icon/iconClockNew.png',
                                              width: 18.w,
                                              height: 18.w,
                                            ),
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              localization.time,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray80,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                        Wrap(
                                          children: [
                                            for (int i = 0;
                                                i <
                                                    jobpostData!.workCondition
                                                        .workHour.length;
                                                i++)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  right: 4.w,
                                                ),
                                                child: Text(
                                                  jobpostData!.workCondition
                                                      .workHour[i].mergeTime,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: CommonColors.black2b,
                                                  ),
                                                ),
                                              ),
                                            if (jobpostData!.workCondition
                                                    .workHourNegotiable ==
                                                NegotiableEnum.possible)
                                              Text(
                                                '(${ConvertService.returnNegotiable(jobpostData!.workCondition.workHourNegotiable)})',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            Divider(
                              height: 1.w,
                              color: CommonColors.grayF7,
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            Text(
                              localization.workingConditions,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.salary,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.workCondition
                                                .salaryNegotiable ==
                                            NegotiableEnum.possible
                                        ? '${jobpostData!.workCondition.salaryType.label} ${localization.amount(ConvertService.returnStringWithCommaFormat(jobpostData!.workCondition.salary))} / ${ConvertService.returnNegotiable(jobpostData!.workCondition.salaryNegotiable)}'
                                        : '${jobpostData!.workCondition.salaryType.label} ${localization.amount(ConvertService.returnStringWithCommaFormat(jobpostData!.workCondition.salary))}',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.employmentType,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '${jobpostData!.workCondition.workTypeName} (${JobpostingService.returnProbationPeriod(jobpostData!.workCondition.probationPeriod)})',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.workDuration,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.workCondition.workPeriodName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.workingDays,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.workCondition
                                                .workDayNegotiable ==
                                            NegotiableEnum.possible
                                        ? '${ConvertService.returnSortedWorkDays(jobpostData!.workCondition.workDays)} / ${ConvertService.returnNegotiable(jobpostData!.workCondition.workDayNegotiable)}'
                                        : ConvertService.returnSortedWorkDays(
                                            jobpostData!
                                                .workCondition.workDays),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.workingHours2,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (int i = 0;
                                          i <
                                              jobpostData!.workCondition
                                                  .workHour.length;
                                          i++)
                                        Text(
                                          i == 0
                                              ? jobpostData!.workCondition
                                                          .workHourNegotiable ==
                                                      NegotiableEnum.possible
                                                  ? '${jobpostData!.workCondition.workHour[i].mergeTime} / ${ConvertService.returnNegotiable(jobpostData!.workCondition.workHourNegotiable)}'
                                                  : jobpostData!.workCondition
                                                      .workHour[i].mergeTime
                                              : jobpostData!.workCondition
                                                  .workHour[i].mergeTime,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      if (jobpostData!
                                          .workCondition.workHour.isEmpty)
                                        Text(
                                          JobpostingConstants.noWorkHour,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.breakTime2,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (jobpostData!.workCondition.restHour >
                                          0)
                                        Text(
                                          jobpostData!.workCondition
                                                      .restHourNegotiable ==
                                                  NegotiableEnum.possible
                                              ? '${jobpostData!.workCondition.restHour}분 / ${ConvertService.returnNegotiable(jobpostData!.workCondition.restHourNegotiable)}'
                                              : '${jobpostData!.workCondition.restHour}분',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      // if (jobpostData!
                                      //     .workCondition.restHour.isEmpty)
                                      //   Text(
                                      //     JobpostingConstants.noRestHour,
                                      //     style: TextStyle(
                                      //       fontSize: 14.sp,
                                      //     ),
                                      //   ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.regularWorkingHours,
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    localization.workingHoursPerWeek(
                                        jobpostData!
                                            .workCondition.contractualWorkHour),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 16.w,
                                ),
                                Positioned(
                                  left: -16.w,
                                  right: -16.w,
                                  child: Container(
                                    width: 20,
                                    height: 16.w,
                                    color: CommonColors.grayF7,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            Text(
                              localization.jobDescription2,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.companyName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          jobpostData!.companyName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.jobCategory,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (int i = 0;
                                                i <
                                                    jobpostData!.workInfo
                                                        .jobList.length;
                                                i++)
                                              Text(
                                                jobpostData!
                                                    .workInfo.jobList[i].name,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization
                                              .detailedJobResponsibilities,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          jobpostData!.workInfo.workDetail,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40.w,
                            ),
                            Text(
                              localization.recruitmentRequirements,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            Container(
                              padding: EdgeInsets.all(20.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.recruitmentField,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          jobpostData!
                                              .recruitmentCondition.jobPosition,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.numberOfPositions,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${jobpostData!.recruitmentCondition.recruitCount}명',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.age,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          returnAgeCondition(
                                              jobpostData!
                                                  .recruitmentCondition.minAge,
                                              jobpostData!
                                                  .recruitmentCondition.maxAge),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.gender,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          jobpostData!.recruitmentCondition
                                              .gender.labelTwo,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.educationLevel,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          returnSchoolCondition(
                                              jobpostData!.recruitmentCondition
                                                  .schoolKey,
                                              jobpostData!.recruitmentCondition
                                                  .schoolType,
                                              jobpostData!.recruitmentCondition
                                                  .schoolStatus),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.experienced,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          returnCareerCondition(
                                              jobpostData!.recruitmentCondition
                                                  .careerType,
                                              jobpostData!.recruitmentCondition
                                                  .minCareer,
                                              jobpostData!.recruitmentCondition
                                                  .maxCareer),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.preferredQualifications,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      jobpostData!
                                              .recruitmentCondition
                                              .preferentialConditionList
                                              .isNotEmpty
                                          ? Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  for (int i = 0;
                                                      i <
                                                          jobpostData!
                                                              .recruitmentCondition
                                                              .preferentialConditionList
                                                              .length;
                                                      i++)
                                                    Text(
                                                      jobpostData!
                                                                  .recruitmentCondition
                                                                  .preferentialConditionList[
                                                                      i]
                                                                  .type ==
                                                              PreferentialInputType
                                                                  .key
                                                          ? jobpostData!
                                                                  .recruitmentCondition
                                                                  .preferentialConditionList[
                                                                      i]
                                                                  .name ??
                                                              '-'
                                                          : jobpostData!
                                                                  .recruitmentCondition
                                                                  .preferentialConditionList[
                                                                      i]
                                                                  .inputName ??
                                                              '-',
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            )
                                          : Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '-',
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization
                                              .applicationQualifications,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          jobpostData!.recruitmentCondition
                                              .applyEligibility,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40.w,
                            ),
                            Text(
                              localization.workLocation,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            GoogleMapWidget(
                                mapWidth: CommonSize.vw,
                                mapHeight: 210.w,
                                data: [
                                  MapService.makeMarker(
                                      name: jobpostData!.companyInfo.name,
                                      lat: jobpostData!.lat,
                                      long: jobpostData!.long)
                                ],
                                targetLat: jobpostData!.lat,
                                targetLong: jobpostData!.long),
                            SizedBox(
                              height: 8.w,
                            ),
                            if (jobpostData!.addressType == 1)
                              Text(
                                '${jobpostData!.address} ${jobpostData!.addressDetail}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: CommonColors.gray80,
                                ),
                              ),
                            if (jobpostData!.addressType == 0)
                              Text(
                                '${jobpostData!.companyInfo.address} ${jobpostData!.companyInfo.addressDetail}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                  color: CommonColors.gray80,
                                ),
                              ),
                            SizedBox(
                              height: 32.w,
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                SizedBox(
                                  height: 16.w,
                                ),
                                Positioned(
                                  left: -16.w,
                                  right: -16.w,
                                  child: Container(
                                    width: 20,
                                    height: 16.w,
                                    color: CommonColors.grayF7,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.w,
                            ),
                            Text(
                              localization.contactPersonInfo,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: 16.w,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.contactPersonName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.managerInfo.nameDisplayType
                                            .isVisible
                                        ? jobpostData!.managerInfo.name ?? '-'
                                        : jobpostData!
                                            .managerInfo.nameDisplayType.label,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.contactNumber,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.managerInfo
                                            .phoneNumberDisplayType.isVisible
                                        ? jobpostData!.managerInfo.phoneNumber
                                                .contains('-')
                                            ? jobpostData!
                                                    .managerInfo.phoneNumber ??
                                                '-'
                                            : ConvertService.formatPhoneNumber(
                                                    jobpostData!.managerInfo
                                                        .phoneNumber) ??
                                                '-'
                                        : jobpostData!.managerInfo
                                            .phoneNumberDisplayType.label,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100.w,
                                  child: Text(
                                    localization.email,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray80,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    jobpostData!.managerInfo.emailDisplayType
                                            .isVisible
                                        ? jobpostData!.managerInfo.email ?? '-'
                                        : jobpostData!
                                            .managerInfo.emailDisplayType.label,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 28.w,
                            ),
                            if (jobpostData!.companyInfo.key != 0 &&
                                jobpostData!.type != JobpostingTypeEnum.self)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    height: 1,
                                    color: CommonColors.grayF2,
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  Text(
                                    localization.companyInfo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.numberOfEmployees2,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          localization.numberOfEmployees2Count(
                                              jobpostData!.companyInfo
                                                  .numberOfEmployees),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.companyAddress,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${jobpostData!.companyInfo.address} ${jobpostData!.companyInfo.addressDetail}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100.w,
                                        child: Text(
                                          localization.industry,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ConvertService.removeParentheses(
                                              jobpostData!
                                                  .companyInfo.industryName),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (userInfo!.key !=
                                          jobpostData!.owner.key) {
                                        context.push(
                                            '/company/${jobpostData!.owner.key}');
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                          12.w, 16.w, 12.w, 16.w),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4.w),
                                          color: CommonColors.grayF7),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              child: jobpostData!.companyInfo
                                                          .files.isNotEmpty &&
                                                      jobpostData!.companyInfo
                                                              .files[0].key >
                                                          0 &&
                                                      jobpostData!.companyInfo
                                                              .files[0].key !=
                                                          null
                                                  ? ExtendedImgWidget(
                                                      imgUrl: jobpostData!
                                                          .companyInfo
                                                          .files[0]
                                                          .url,
                                                      imgFit: BoxFit.cover,
                                                      imgWidth: 56.w,
                                                      imgHeight: 56.w,
                                                    )
                                                  : Container(
                                                      width: 56.w,
                                                      height: 56.w,
                                                      color: Color(ConvertService
                                                          .returnBgColor(
                                                              jobpostData!
                                                                  .companyInfo
                                                                  .color)),
                                                      child: Center(
                                                        child: Text(
                                                          jobpostData!
                                                              .companyInfo.name,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 18.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: CommonColors
                                                                .gray4d,
                                                          ),
                                                        ),
                                                      ),
                                                    )),
                                          SizedBox(
                                            width: 16.w,
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Text(
                                                  jobpostData!.companyInfo.name,
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          CommonColors.gray4d,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                SizedBox(
                                                  height: 4.w,
                                                ),
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/icon/iconStarS.png',
                                                      width: 14.w,
                                                      height: 14.w,
                                                    ),
                                                    SizedBox(
                                                      width: 8.w,
                                                    ),
                                                    Text(
                                                      companyEvaluate!.totalAvg
                                                          .toStringAsFixed(2),
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color:
                                                            CommonColors.gray80,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              if (userInfo!.key !=
                                                  jobpostData!.owner.key) {
                                                toggleLikeCompany(
                                                    companyLikesKeyList,
                                                    jobpostData!
                                                        .companyInfo.key);
                                              } else {
                                                showDefaultToast(localization
                                                    .employerCannotAddInterestedCompanies);
                                              }
                                            },
                                            child: Container(
                                              color: Colors.transparent,
                                              padding: EdgeInsets.fromLTRB(
                                                  8.w, 8.w, 0, 8.w),
                                              child: Image.asset(
                                                companyLikesKeyList.contains(
                                                        jobpostData!
                                                            .companyInfo.key)
                                                    ? 'assets/images/icon/iconHeartActive.png'
                                                    : 'assets/images/icon/iconHeart.png',
                                                width: 24.w,
                                                height: 24.w,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const BottomPadding(
                      extra: 100,
                    ),
                  ],
                ),
                if (!isLoading)
                  Positioned(
                      left: 20.w,
                      bottom: CommonSize.commonBottom,
                      right: 20.w,
                      child: userInfo != null &&
                              userInfo.key != jobpostData!.owner.key
                          ? widget.type == 'apply'
                              ? CommonButton(
                                  onPressed: () {
                                    if (!isDoneDay(applyData!.postingPeriod) &&
                                        applyData!.postingRequiredStatus == 1) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertTwoButtonDialog(
                                              alertTitle: localization
                                                  .cancelApplication,
                                              alertContent: localization
                                                  .confirmCancelJobApplication,
                                              alertConfirm: localization
                                                  .cancelApplication,
                                              alertCancel: localization.closed,
                                              onConfirm: () {
                                                cancelJobPosting(
                                                    applyData!.key);
                                                context.pop(context);
                                              },
                                            );
                                          });
                                    }
                                  },
                                  text: localization.cancelApplication,
                                  confirm:
                                      !isDoneDay(applyData!.postingPeriod) &&
                                          applyData!.postingRequiredStatus == 1)
                              : Row(
                                  children: [
                                    BorderButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertTwoButtonDialog(
                                                alertTitle:
                                                    localization.blockCompany,
                                                alertContent: localization
                                                    .confirmBlockSelectedCompany,
                                                alertConfirm:
                                                    localization.blockUser,
                                                alertCancel:
                                                    localization.cancel,
                                                onConfirm: () {
                                                  blockCompany(
                                                      applyData!.postKey);
                                                  context.pop(context);
                                                },
                                              );
                                            });
                                      },
                                      text: 'text',
                                      width:
                                          applyData!.postingRequiredStatus == 2
                                              ? 115.w
                                              : 55.w,
                                      child: Text(
                                        localization.blockUser,
                                        style: TextStyle(
                                            fontSize: 15.w,
                                            color: CommonColors.gray4d,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    if (applyData!.postingRequiredStatus != 2 &&
                                        applyData!.postingRequiredStatus != 3)
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 5.w,
                                          ),
                                          BorderButton(
                                            onPressed: () {
                                              if (!isDoneDay(
                                                  applyData!.postingPeriod)) {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return AlertTwoButtonDialog(
                                                        alertTitle: localization
                                                            .rejectProposal,
                                                        alertContent: localization
                                                            .confirmRejectSelectedProposal,
                                                        alertConfirm:
                                                            localization.reject,
                                                        alertCancel:
                                                            localization.cancel,
                                                        onConfirm: () {
                                                          deAcceptJobPosting(
                                                              applyData!.key);
                                                          context.pop(context);
                                                        },
                                                      );
                                                    });
                                              }
                                            },
                                            text: 'text',
                                            width: 55.w,
                                            color: isDoneDay(
                                                    applyData!.postingPeriod)
                                                ? CommonColors.grayE6
                                                : const Color(0xffD8DCE4),
                                            backColor: isDoneDay(
                                                    applyData!.postingPeriod)
                                                ? CommonColors.grayE6
                                                : const Color(0xffffffff),
                                            child: Text(
                                              localization.reject,
                                              style: TextStyle(
                                                  fontSize: 15.w,
                                                  color: isDoneDay(applyData!
                                                          .postingPeriod)
                                                      ? Colors.white
                                                      : CommonColors.gray4d,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Expanded(
                                      child: CommonButton(
                                        fontSize: 15,
                                        onPressed: () {
                                          if ((applyData!.postingRequiredStatus ==
                                                      1 ||
                                                  applyData!
                                                          .postingRequiredStatus ==
                                                      4) &&
                                              !isDoneDay(
                                                  applyData!.postingPeriod)) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertTwoButtonDialog(
                                                    alertTitle: localization
                                                        .acceptProposal,
                                                    alertContent: localization
                                                        .confirmAcceptSelectedProposal,
                                                    alertConfirm: localization
                                                        .confirmAcceptance,
                                                    alertCancel:
                                                        localization.cancel,
                                                    onConfirm: () {
                                                      acceptJobPosting(
                                                          applyData);
                                                      context.pop(context);
                                                    },
                                                  );
                                                });
                                          }
                                        },
                                        text: applyData!
                                                    .postingRequiredStatus ==
                                                2
                                            ? localization.proposalAccepted
                                            : applyData!.postingRequiredStatus ==
                                                    3
                                                ? localization.proposalRejected
                                                : localization.acceptProposal2,
                                        confirm: (applyData!
                                                        .postingRequiredStatus ==
                                                    1 ||
                                                applyData!
                                                        .postingRequiredStatus ==
                                                    4) &&
                                            !isDoneDay(
                                                applyData!.postingPeriod),
                                      ),
                                    ),
                                  ],
                                )
                          : jobpostData!.postState == 'UNEXPOSED'
                              ? CommonButton(
                                  onPressed: () {
                                    context
                                        .push(
                                            '/mypage/jobposting/${JobpostingEditEnum.update.path}/${widget.idx}')
                                        .then((_) {
                                      getJobpostingDetail(
                                          int.parse(widget.idx));
                                    });
                                  },
                                  confirm: true,
                                  text: localization.edit,
                                  width: CommonSize.vw,
                                )
                              : const SizedBox()),
              ],
            )
          : const Loader(),
    );
  }
}
