import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  List<ProfileModel> userProfileList = [];
  bool isLoading = true;

  String formatOfferStatus(int offerValue, int? offerScope) {
    if (offerValue == 1) {
      return offerScope == 1 ? localization.acceptAllProposals : '희망 업무만 받음';
    } else {
      return localization.declineAllProposals;
    }
  }

  showProfileDeleteAlert(BuildContext context, int profileKey) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.deleteProfile,
            alertContent: localization.confirmProfileDeletion,
            alertConfirm: localization.delete,
            alertCancel: localization.close,
            onConfirm: () {
              deleteProfile(profileKey);
              getApplyOrProposedJobpostKey();
              context.pop(context);
            },
            onCancel: () {
              context.pop(context);
            },
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

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getProfileList(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getProfileList() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getProfileList(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          List<ProfileModel> resultData = result.data;
          setState(() {
            userProfileList = [...resultData];
          });
        }
      }
    }
  }

  deleteProfile(int profileKey) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .deleteProfile(userInfo.key, profileKey);
      if (result.status == 200 && result.type == 1) {
        getProfileList();
      }
    }
  }

  openBottomSheet(userProfileData) {
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
        return ContentBottomSheet(
          contents: [
            if (userProfileData.profileDisplay != 0)
              BottomSheetButton(
                  onTap: () {
                    context.pop();
                    context
                        .push('/my/profile/update/${userProfileData.key}')
                        .then((_) async {
                      await getProfileList();
                    });
                  },
                  text: localization.editProfile),
            BottomSheetButton(
                onTap: () {
                  context.pop();
                  showProfileDeleteAlert(context, userProfileData.key);
                },
                text: localization.delete,
                last: true,
                isRed: true),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.profileManagement,
      ),
      body: !isLoading
          ? Stack(
              children: [
                userProfileList.isNotEmpty
                    ? CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: userProfileList.length,
                                (context, index) {
                                  var userProfileData = userProfileList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      context
                                          .push(
                                              '/my/profile/${userProfileData.key}')
                                          .then((_) async {
                                        await getProfileList();
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                          10.w, 20.w, 10.w, 20.w),
                                      margin: EdgeInsets.only(top: 10.w),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(20.w),
                                        color: CommonColors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 16.w,
                                            color: const Color.fromRGBO(
                                                0, 0, 0, 0.06),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              if (userProfileData.mainProfile ==
                                                      1 &&
                                                  userProfileData
                                                          .profileDisplay ==
                                                      1) // 대표 O, 노출 O
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 7.w),
                                                  height: 22.w,
                                                  padding: EdgeInsets.fromLTRB(
                                                      8.w, 0, 8.w, 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color:
                                                            CommonColors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            500.w),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    localization.representative,
                                                    style: TextStyle(
                                                        color: CommonColors.red,
                                                        fontSize: 11.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              if (userProfileData
                                                          .mainProfile ==
                                                      0 &&
                                                  userProfileData
                                                          .profileDisplay ==
                                                      1) // 대표 X, 노출 O
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 7.w),
                                                  height: 22.w,
                                                  padding: EdgeInsets.fromLTRB(
                                                      8.w, 0, 8.w, 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color:
                                                            CommonColors.red),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            500.w),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    localization.visible,
                                                    style: TextStyle(
                                                        color: CommonColors.red,
                                                        fontSize: 11.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              if (userProfileData
                                                  .mainProfile ==
                                                  0 && userProfileData
                                                          .profileDisplay ==
                                                      0) // 미노출
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 7.w),
                                                  height: 22.w,
                                                  padding: EdgeInsets.fromLTRB(
                                                      8.w, 0, 8.w, 0),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color:
                                                            CommonColors.gray),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            500.w),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    localization.hidden,
                                                    style: TextStyle(
                                                        color:
                                                            CommonColors.gray,
                                                        fontSize: 11.sp,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  userProfileData.profileTitle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          CommonColors.black2b,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              
                                              GestureDetector(
                                                onTap: () {
                                                  openBottomSheet(
                                                      userProfileData);
                                                },
                                                child:Container(
                                                  padding: EdgeInsets.only(left: 10.w),
                                                  color: Colors.transparent,
                                                  child:  Image.asset(
                                                    'assets/images/appbar/iconSetting.png',
                                                    width: 20.w,
                                                    height: 20.w,
                                                  ),
                                                ),

                                              ),

                                            ],
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                14.w, 23.w, 0, 0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 84.w,
                                                      child: Text(
                                                        localization.desiredRegion,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .gray80,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        userProfileData
                                                            .profileAreas
                                                            .map((job) => job
                                                                .areaInfo
                                                                .dongName)
                                                            .join(','),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .black2b,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                      width: 84.w,
                                                      child: Text(
                                                        localization.desiredWork,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .gray80,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        userProfileData
                                                            .profileJobs
                                                            .map((job) =>
                                                                job.name)
                                                            .join(','),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
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
                                                      width: 84.w,
                                                      child: Text(
                                                        localization.positionProposal,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        formatOfferStatus(
                                                            userProfileData
                                                                .offerValue,
                                                            userProfileData
                                                                .offerScope),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
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
                                                      width: 84.w,
                                                      child: Text(
                                                        localization.lastModifiedDate,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        DateFormat(
                                                                'yyyy-MM-dd HH:mm')
                                                            .format(DateTime.parse(
                                                                userProfileData
                                                                    .updateAt)),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const BottomPadding(
                            extra: 100,
                          ),
                        ],
                      )
                    : Padding(
                        padding: EdgeInsets.only(bottom: 100.w),
                        child: const CommonEmpty(text: localization.noRegisteredProfiles),
                      ),
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: CommonSize.commonBottom,
                  child: userProfileList.length < 3
                      ? CommonButton(
                          onPressed: () {
                            context.push('/my/profile/create').then((_) async {
                              await getProfileList();
                            });
                          },
                          text: localization.addNewProfile,
                          fontSize: 15,
                          confirm: true,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            border: Border.all(
                              width: 1.w,
                              color: CommonColors.grayD9,
                            ),
                            color: CommonColors.grayF2,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                localization.addNewProfile,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: CommonColors.gray80,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                localization.maxThreeProfilesAllowed,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: CommonColors.grayB2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            )
          : const Loader(),
    );
  }
}
