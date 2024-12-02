
import 'dart:math';
import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/scrap_toast_utils.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_constants.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_profile_bottomsheet.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AlbaList extends ConsumerStatefulWidget {
  AlbaList(
      {
      required this.jobpostItem,
      required this.jobList,
      required this.currentPosition,
      required this.getProfile,
      this.isHome = true,
      super.key});


  final dynamic jobpostItem;
  final List jobList;
  final Map<String, dynamic> currentPosition;
  final Function getProfile;
  final bool isHome;

  @override
  ConsumerState<AlbaList> createState() => _AlbaListState();
}

class _AlbaListState extends ConsumerState<AlbaList> with Alerts {
  bool isRunning = false;

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - widget.currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - widget.currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(widget.currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
  }

  Future<void> scrapJobseeker(String type, int idx) async {
    ApiResultModel result;
    Map<String, dynamic> params = {"jpIdx": idx};
    if (type == JobpostingConstants.ADD) {
      result = await ref
          .read(jobpostingControllerProvider.notifier)
          .createScrapJobseeker(params);
    } else {
      result = await ref
          .read(jobpostingControllerProvider.notifier)
          .deleteScrapJobseeker(params);
    }

    if (result.status == 200) {
      if (result.type == 1) {
        String msg =
            type == JobpostingConstants.ADD ? localization.scrapedPost : localization.removedFromScrapedList;
        await getUserClipAnnouncementList();
        showScrapToast(msg, type);
      } else {
        String msg = type == JobpostingConstants.ADD
            ? localization.failedToScrapePost
            : localization.failedToRemoveScrapedPost;
        showScrapToast(msg, type);
      }
    } else if (result.status == 401) {
      showStartDialog(context);
    } else {
      String msg = type == JobpostingConstants.ADD
          ? localization.failedToScrapePost
          : localization.failedToRemoveScrapedPost;
      showScrapToast(msg, type);
    }
  }

  showApply(int jobpostKey) {
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
          return JobpostingProfileBottomSheet(
            apply: applyJobposting,
            jobpostKey: jobpostKey,
            getProfile: widget.getProfile,
          );
        });
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

  applyJobposting(int jobpostKey, int profileKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    Map<String, dynamic> params = {
      "mpIdx": profileKey,
      "jpIdx": jobpostKey,
    };

    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .applyJobposting(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        getApplyOrProposedJobpostKey();
        showDefaultToast(localization.applicationCompleted);
      } else if (result.type == -2201) {
        showDefaultToast(localization.alreadyAppliedPost);
      } else {
        showDefaultToast(localization.jobApplicationFailed);
      }
    } else if (result.status == 401) {
      showDefaultToast(localization.alreadyReceivedProposal);
    } else if (result.status == 406) {
      showDefaultToast(localization.closedJobPost);
    } else if (result.status == 409) {
      showDefaultToast(localization.alreadyAppliedPost);
    } else if (result.status != 200) {
      showDefaultToast(localization.jobApplicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
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
            .update((state) => result.data);
      });
    }
  }

  toggleScrap(List list, int jobpostkey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(jobpostkey)) {
      await scrapJobseeker(JobpostingConstants.DELETE, jobpostkey);
    } else {
      await scrapJobseeker(JobpostingConstants.ADD, jobpostkey);
    }
    isRunning = false;
  }

  @override
  void initState() {
    super.initState();
  }

  returnJobName(DefineModel item) {
    String name = item.name;
    if (item.parent != null && item.parent!.key != 0) {
      name = '${item.name} ( ${setJobParentName('', item.parent)} )';
    }
    return name;
  }

  setJobParentName(String name, DefineModel? item) {
    String jobName = name;
    if (item != null) {
      if (jobName != '') {
        jobName = '$name < ${item.name}';
      } else {
        jobName = item.name;
      }
      if (item.parent != null && item.parent!.key != 0) {
        jobName = setJobParentName(jobName, item.parent);
      }
    }
    return jobName;
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    List scrapList = ref.watch(userClipAnnouncementListProvider);
    List<int> applyOrProposedJobpostKeyList =
        ref.watch(applyOrProposedJobpostKeyListProvider);
    List hideCompanyKeyList = ref.watch(companyHidesKeyListProvider);

    return GestureDetector(
      onTap: () {
        context.push('/jobpost/${widget.jobpostItem.key}');
      },
      child: Container(
        margin: EdgeInsets.only(top: 10.w),
        padding: widget.isHome
            ? EdgeInsets.fromLTRB(12.w, 10.w, 12.w, 20.w)
            : EdgeInsets.fromLTRB(0.w, 10.w, 0.w, 24.w),
        decoration: BoxDecoration(
          color: CommonColors.white,
          borderRadius: BorderRadius.circular(12.w),
          border: widget.isHome
              ? Border.all(
                  width: widget.jobpostItem.adStatus != null &&
                          widget.jobpostItem.adStatus == 1
                      ? 2.w
                      : 1.w,
                  color: widget.jobpostItem.adStatus != null &&
                          widget.jobpostItem.adStatus == 1
                      ? CommonColors.red
                      : CommonColors.grayF2,
                )
              : Border(
                  bottom: BorderSide(
                  width: 1.w,
                  color: widget.jobpostItem.adStatus != null &&
                          widget.jobpostItem.adStatus == 1
                      ? CommonColors.red
                      : CommonColors.grayF2,
                )),
          boxShadow: [
            if (widget.isHome)
              BoxShadow(
                blurRadius: 4.w,
                color: const Color.fromRGBO(150, 150, 150, 0.25),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 4.w,
                ),
                if (widget.jobpostItem.adStatus != null &&
                    widget.jobpostItem.adStatus == 1)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.w),
                    decoration: BoxDecoration(
                      color: CommonColors.red02,
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    child: Text(
                      'AD',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.w,
                        color: CommonColors.red,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 4.w,
                ),
                Expanded(
                  child: Text.rich(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: widget.jobpostItem.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (userInfo == null) {
                      showStartDialog(context);
                    } else {
                      toggleScrap(scrapList, widget.jobpostItem.key);
                    }
                  },
                  style: ButtonStyles.childBtn,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(4.w, 4.w, 0, 4.w),
                    child: Image.asset(
                      scrapList.contains(widget.jobpostItem.key)
                          ? 'assets/images/icon/iconTagActive.png'
                          : 'assets/images/icon/iconTag.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 12.w,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                          width: 140.w,
                          height: 140.w / 360 * 244,
                          child: Swiper(
                            scrollDirection: Axis.horizontal,
                            axisDirection: AxisDirection.left,
                            itemCount: widget.jobpostItem.files.length,
                            viewportFraction: 1,
                            scale: 1,
                            loop: false,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(10.w),
                                child: ExtendedImgWidget(
                                  imgFit: BoxFit.cover,
                                  imgUrl: widget.jobpostItem.files[index].url,
                                  imgWidth: 140.w,
                                ),
                              );
                            },
                          )),
                      if (widget.jobpostItem.postPeriod.isNotEmpty)
                        Positioned(
                          top: 8.w,
                          left: 8.w,
                          child: Container(
                            height: 24.w,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.w, color: CommonColors.red),
                              color: const Color.fromRGBO(255, 255, 255, 0.7),
                              borderRadius: BorderRadius.circular(300.w),
                            ),
                            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                            alignment: Alignment.center,
                            child: Text(
                              ConvertService.isNotEmptyValidate(
                                      widget.jobpostItem.postPeriod)
                                  ? ConvertService.returnDiffDate(
                                      widget.jobpostItem.postPeriod)
                                  : 'D',
                              style: TextStyle(
                                fontSize: 12.w,
                                color: CommonColors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(
                    width: 8.w,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.jobpostItem.companyName,
                          style: TextStyle(
                            fontSize: 12.w,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/icon/iconPinGray.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              '${distanceBetween(widget.jobpostItem.lat, widget.jobpostItem.long)}km',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Expanded(
                              child: Text(
                                widget.jobpostItem.dongName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: CommonColors.gray80,
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              widget.jobpostItem.salaryType.label,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: CommonColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Expanded(
                              child: Text(
                                '${ConvertService.returnStringWithCommaFormat(widget.jobpostItem.salary)} 원',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            if (hideCompanyKeyList
                                .contains(widget.jobpostItem.mcIdx)) {
                              showDefaultToast(localization.blockedCompany);
                            } else if (userInfo == null) {
                              showStartDialog(context);
                            } else {
                              if (ConvertService.returnDiffDate(
                                      widget.jobpostItem.postPeriod) ==
                                  localization.closed) {
                                showDefaultToast(localization.closedJobPost);
                              } else if (!applyOrProposedJobpostKeyList
                                  .contains(widget.jobpostItem.key)) {
                                showApply(widget.jobpostItem.key);
                              } else {
                                showDefaultToast(localization.alreadyAppliedPost);
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            fixedSize: Size.fromHeight(34.w),
                            backgroundColor: ConvertService.returnDiffDate(
                                        widget.jobpostItem.postPeriod) == localization.closed
                                ? CommonColors.grayE6
                                : !applyOrProposedJobpostKeyList
                                        .contains(widget.jobpostItem.key)
                                    ? CommonColors.red
                                    : CommonColors.grayE6,
                            side: const BorderSide(
                              width: 0,
                              color: Colors.transparent,
                            ),
                          ).copyWith(
                            overlayColor: ButtonStyles.overlayNone,
                          ),
                          child: Text(
                            ConvertService.returnDiffDate(
                                        widget.jobpostItem.postPeriod) == localization.closed
                                ? localization.jobPostClosed
                                : applyOrProposedJobpostKeyList
                                        .contains(widget.jobpostItem.key)
                                    ? localization.applicationSubmitted
                                    : localization.applyForJob,
                            style: TextStyle(
                              color: CommonColors.white,
                              fontSize: 14.w,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (widget.jobList.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 12.w),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 4.w,
                  runAlignment: WrapAlignment.start,
                  children: [
                    for (var i = 0; i < widget.jobList.length; i++)
                      SizedBox(
                        height: 26.w,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    4.w,
                                  ),
                                  color: CommonColors.grayF7,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                              child: Text(
                                widget.jobList[i].name,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: CommonColors.gray66,
                                ),
                              ),
                            ),
                          ],
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
