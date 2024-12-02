import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_profile_bottomsheet.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/dialog/start_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
// import 'transformer_page_view/transformer_page_view.dart';

class AlbaMapSwiper extends ConsumerStatefulWidget {
  const AlbaMapSwiper(
      {required this.data,
      required this.currentPosition,
      required this.userProfileList,
      required this.getProfile,
      super.key});

  final List data;
  final Map<String, dynamic> currentPosition;
  final List<ProfileModel> userProfileList;
  final Function getProfile;

  @override
  ConsumerState<AlbaMapSwiper> createState() => _AlbaMapSwiperState();
}

class _AlbaMapSwiperState extends ConsumerState<AlbaMapSwiper> with Alerts {
  bool isRunning = false;

  SwiperController swiperController = SwiperController();

  initIndex() {
    setState(() {

      swiperController.move(0, animation: true);
    });
  }

  @override
  void didUpdateWidget(AlbaMapSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 필요한 값이 변경되었는지 확인
    if (widget.data != oldWidget.data) {
      initIndex();
    }
  }

  double distanceBetween(
      {required double endLatitude, required double endLongitude}) {
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

  showStartDialog(BuildContext context) {
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
      isScrollControlled: true,
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      builder: (BuildContext context) {
        return const StartDialogWidget();
      },
    );
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
      showDefaultToast(localization.incompleteProfileCannotApply);
    } else if (result.status == 409) {
      showDefaultToast(localization.alreadyAppliedPost);
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
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

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    List<int> applyOrProposedJobpostKeyList =
        ref.watch(applyOrProposedJobpostKeyListProvider);
    List hideCompanyKeyList = ref.watch(companyHidesKeyListProvider);

    return SizedBox(
      height: 102.w,
      child: Swiper(
        controller: swiperController,
        scrollDirection: Axis.horizontal,
        axisDirection: AxisDirection.left,
        itemCount: widget.data.length,
        viewportFraction: 0.85,
        duration: 10,
        loop: false,
        itemBuilder: (context, index) {
          dynamic item = widget.data[index];
          return Padding(
            padding: EdgeInsets.fromLTRB(6.w, 0, 6.w, 0),
            child: GestureDetector(
              onTap: () {
                context.push('/jobpost/${item.key}');
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: CommonColors.white,
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    width: 1.w,
                    color: CommonColors.red,
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.w),
                      child: SizedBox(
                        width: 86.w,
                        height: 86.w,
                        child: ExtendedImgWidget(
                          imgFit: BoxFit.cover,
                          imgUrl: item.files[0].url,
                          imgHeight: 86.w,
                          imgWidth: 86.w,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.companyName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.black2b,
                            ),
                          ),
                          Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                              fontWeight: FontWeight.w600,
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
                                '${distanceBetween(endLatitude: item.lat, endLongitude: item.long)}km',
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
                                  '${item.dongName}',
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
                          SizedBox(
                            height: 3.w,
                          ),
                          Row(
                            children: [
                              Text(
                                item.salaryType.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.red,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Expanded(
                                child: Text(
                                  '${ConvertService.returnStringWithCommaFormat(item.salary)} 원',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (hideCompanyKeyList.contains(item.mcIdx)) {
                                    showDefaultToast(localization.blockedCompany);
                                  } else if (userInfo == null) {
                                    showStartDialog(context);
                                  } else {
                                    if (!applyOrProposedJobpostKeyList
                                        .contains(item.key)) {
                                      showApply(item.key);
                                    } else {
                                      showDefaultToast(localization.alreadyAppliedPost);
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.w),
                                  ),
                                  fixedSize: Size.fromHeight(22.w),
                                  backgroundColor:
                                      !applyOrProposedJobpostKeyList
                                              .contains(item.key)
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
                                  localization.applyForJob,
                                  style: TextStyle(
                                    color: CommonColors.white,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
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
            ),
          );
        },
      ),
    );
  }
}
