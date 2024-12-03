import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/jobposting_recruiter_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecommendSeekerBottom extends ConsumerStatefulWidget {
  const RecommendSeekerBottom({required this.workerItem, super.key});

  final ProfileModel workerItem;

  @override
  ConsumerState<RecommendSeekerBottom> createState() =>
      _RecommendSeekerBottomState();
}

class _RecommendSeekerBottomState extends ConsumerState<RecommendSeekerBottom>
    with Alerts {
  bool isRunning = false;

  showBottomSuggestJobposting(int profileKey) {
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
        return JobpostingRecruiterBottomSheet(
          apply: proposeJobpost,
          profileKey: profileKey,
        );
      },
    );
  }

  proposeJobpost(int profileKey, int jobpostKey) async {
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
        .proposeJobpost(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.387);
      } else {
        showDefaultToast(localization.388);
      }
    } else if (result.status == 409) {
      showDefaultToast(localization.389);
    } else if (result.status == 401) {
      if(result.type == -2504){
        showDefaultToast(localization.390);
      }else{
        showDefaultToast(localization.391);
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.388);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  String returnString(List<ProfileWorkDayModel> itemList) {
    String result = '';

    for (int i = 0; i < itemList.length; i++) {
      if (i != itemList.length - 1) {
        result += '${itemList[i].workDayName}, ';
      } else {
        result += itemList[i].workDayName;
      }
    }
    return result;
  }

  addLikesWorker(int idx) async {
    var result =
        await ref.read(workerControllerProvider.notifier).addLikesWorker(idx);
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

  deleteLikesWorker(int idx) async {
    var result = await ref
        .read(workerControllerProvider.notifier)
        .deleteLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      if (mounted) {
        showDefaultToast(localization.dataCommunicationFailed);
      }
    }
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(workerLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.392);
    } else {
      likeList.add(key);
      showDefaultToast(localization.393);
    }
    setState(() {
      ref
          .read(workerLikesKeyListProvider.notifier)
          .update((state) => [...likeList]);
    });
  }

  toggleLikesWorker(List list, int profileKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(profileKey)) {
      await deleteLikesWorker(profileKey);
    } else {
      await addLikesWorker(profileKey);
    }
    isRunning = false;
  }

  returnTimeText() {
    var returnText = '';
    for (var i = 0; i < widget.workerItem.profileWorkTimes.length; i++) {
      returnText +=
          '${i == 0 ? '' : ','} ${ConvertService.setWorkHourRecommend(widget.workerItem.profileWorkTimes[i].workTimeStartTime, widget.workerItem.profileWorkTimes[i].workTimeEndTime)}';
    }

    // '${ConvertService.setWorkHourRecommend(widget.workerItem.profileWorkTimes[0].workTimeStartTime, widget.workerItem.profileWorkTimes[0].workTimeEndTime)}',

    return returnText;
  }

  @override
  Widget build(BuildContext context) {
    List<int> workerLikesKeyList = ref.watch(workerLikesKeyListProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0.w, 15.w, 0.w, 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/icon/IconEducationSeeker.png',
                                width: 18.w,
                                height: 18.w,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                localization.educationLevel,
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
                          Text(
                            widget.workerItem.finalEducation.schoolName.isEmpty
                                ? localization.206
                                : '${widget.workerItem.finalEducation.schoolType} ${widget.workerItem.finalEducation.status}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/icon/IconCareerSeeker.png',
                                width: 18.w,
                                height: 18.w,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                localization.experienced,
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
                          Text(
                            ConvertService.formatWorkingDays(
                                widget.workerItem.careerDays),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            Image.asset(
                              'assets/images/icon/IconDateSeeker.png',
                              width: 18.w,
                              height: 16.w,
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
                          ]),
                          SizedBox(
                            height: 8.w,
                          ),
                          widget.workerItem.profileWorkDays.isNotEmpty
                              ? Wrap(
                                  children: [
                                    for (int i = 0;
                                        i <
                                            widget.workerItem.profileWorkDays
                                                .length;
                                        i++)
                                      Padding(
                                        padding: EdgeInsets.only(right: 4.w),
                                        child: Text(
                                          widget.workerItem.profileWorkDays[i]
                                              .workDayName,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Text(
                                  localization.206,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/icon/IconTimeSeeker.png',
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
                          widget.workerItem.profileWorkTimes.isNotEmpty
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                      Text(
                                        '${widget.workerItem.profileWorkTimes[0].workTimeName} ${ConvertService.setWorkHour(widget.workerItem.profileWorkTimes[0].workTimeStartTime, widget.workerItem.profileWorkTimes[0].workTimeEndTime)}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                  ],
                                )
                              : Text(
                                  '-',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.black2b,
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
        Row(
          children: [
            BorderButton(
              onPressed: () {
                toggleLikesWorker(workerLikesKeyList, widget.workerItem.key);
              },
              text: '',
              width: 108.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    workerLikesKeyList.contains(widget.workerItem.key)
                        ? 'assets/images/icon/iconHeartActive.png'
                        : 'assets/images/icon/iconHeart.png',
                    width: 16.w,
                    height: 16.w,
                  ),
                  SizedBox(
                    width: 4.w,
                  ),
                  Text(
                    localization.interestedTalents,
                    style: TextStyle(
                        fontSize: 15.w,
                        color: CommonColors.gray4d,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: CommonButton(
                fontSize: 15,
                confirm: true,
                onPressed: () {
                  showBottomSuggestJobposting(widget.workerItem.key);
                },
                text: localization.819,
              ),
            ),
          ],
        )
      ],
    );
  }
}
