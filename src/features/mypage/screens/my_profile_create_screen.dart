import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_constants.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/about_me_widget..dart';
import 'package:chodan_flutter_app/features/mypage/widgets/add_file_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/add_job_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/add_profile_photo_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/add_work_area_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/input_career_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/input_education_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_box.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_list_item_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_list_title_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/select_profile_title_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/select_work_condition_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/select_work_schedule_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MyProfileCreateScreen extends ConsumerStatefulWidget {
  const MyProfileCreateScreen({super.key});

  @override
  ConsumerState<MyProfileCreateScreen> createState() =>
      _MyProfileCreateScreenState();
}

class _MyProfileCreateScreenState extends ConsumerState<MyProfileCreateScreen>
    with Files {
  Map<String, dynamic> profileData = {
    'type': 'all',
    'mpGetOffer': 1, // 제안 수신
    'mpOfferScope': 1, // 제안 수신 범위
    'mpTitle': '', // 프로필 제목
    'adIdx': [], // 희망 근무 지역
    'joIdx': [], // 희망 직종 키 값
    'wdIdx': [], // 희망 근무 요일
    'whIdx': [], // 희망 근무 시간
    'wtIdx': [], // 희망 근무 형태
    'wpIdx': [], // 희망 근무 기간
    'educationList': [], // 학력
    'careerList': [], // 경력
    'mpIntroduce': '', // 자기소개
    'keyword': [], // 자기소개 키워드
    'mpBasic': 0, // 기본 프로필
    'mpHaveCareer': 0, // 경력이면 1
    'fileList': [],
  };

  int totalCareerMonths = 0;
  bool isBasicProfile = false;
  bool basicReadOnly = false;
  bool isLoading = true;
  bool isRunning = false;
  List<ProfileModel> userProfileList = [];
  List<ProfileModel> schoolTypes = [];

  List<AddressModel> selectedAreaList = [];
  List<DefineModel> selectedJobList = [];
  List<dynamic> fileList = [];

  Map<String, dynamic> selectedDirectInputData = {
    'index': 0,
  };

  Map<String, dynamic> keywordStringData = {
    'keywordName': [],
  };

  Map<String, dynamic> profilePhotoData = {
    'file': null,
  };

  Map<String, dynamic> fileData = {
    'file': null,
  };

  setProfileData(String key, dynamic value) {
    profileData[key] = value;
  }

  setAreaData(List<AddressModel> data) {
    selectedAreaList = data;
  }

  setJobData(List<DefineModel> data) {
    selectedJobList = data;
  }

  setProfilePhotoData(String key, dynamic value) {
    profilePhotoData[key] = value;
  }

  setFileData(List file, List fileInfoList, List deleteList) {
    setState(() {
      fileData['file'] = file;
      fileList = fileInfoList;
      profileData['fileList'] = fileList;
    });
  }

  setTotalCareerMonths(int totalValue) {
    totalCareerMonths = totalValue;
  }

  setKeywordStringData(String key, dynamic keywordValue) {
    keywordStringData[key] = keywordValue;
  }

  void saveFile(dynamic profilePhoto, dynamic file, int key) async {
    List fileInfo = [
      {
        'fileType': 'PROFILE_IMAGE',
        'files': [profilePhoto]
      },
      {'fileType': 'PROFILE_FILES', 'files': file},
    ];
    var result = await runS3FileUpload(fileInfo, key);

    if (result == true) {
      setState(() {
        profilePhotoData['file'] = null;
        fileData['file'] = null;

        if (mounted) {
          context.pop();
          showDefaultToast(localization.283);
        }
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.fileUploadFailedRetry,
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
  }

  // 프로필 사진
  showProfilePhotoAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddProfilePhotoWidget(
          profilePhotoData: profilePhotoData,
          isCreate: true,
        );
      },
    ).then((value) => {
          setState(() {
            setProfilePhotoData('file', value);
          })
        });
  }

  // 희망 근무 지역
  showWorkAreaAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddWorkAreaWidget(
          profileData: profileData,
          areaList: selectedAreaList,
          setProfileData: setProfileData,
          setAreaData: setAreaData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 희망 직종
  showJobAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (BuildContext context) {
        return AddJobWidget(
          profileData: profileData,
          jobList: selectedJobList,
          setProfileData: setProfileData,
          setJobData: setJobData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 프로필 제목
  showProfileTitleSelection(BuildContext context) {
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
        return SelectProfileTitleWidget(
          profileData: profileData,
          selectedDirectInputData: selectedDirectInputData,
          setProfileData: setProfileData,
          isWrite: true,
        );
      },
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                if (value == ProfileConstants.profileTitleList.length - 1) {
                  // 직접 입력 선택
                  selectedDirectInputData['index'] = value;
                } else {
                  // 직접 입력 선택 X
                  selectedDirectInputData['index'] = value;
                  setProfileData(
                      'mpTitle', ProfileConstants.profileTitleList[value]);
                }
              }),
            }
        });
  }

  // 희망 근무 스케줄
  showWorkScheduleAlert() {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SelectWorkScheduleWidget(
          profileData: profileData,
          setProfileData: setProfileData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 희망 근무 조건
  showWorkConditionAlert() {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SelectWorkConditionWidget(
          profileData: profileData,
          setProfileData: setProfileData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 학력
  showEducationAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InputEducationWidget(
          profileData: profileData,
          setProfileData: setProfileData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 경력
  showCareerAlert() {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return InputCareerWidget(
          profileData: profileData,
          setProfileData: setProfileData,
          totalCareerMonths: totalCareerMonths,
          setTotalCareerMonths: setTotalCareerMonths,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 자기소개
  showAboutMeAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AboutMeWidget(
          profileData: profileData,
          keywordStringData: keywordStringData,
          setProfileData: setProfileData,
          setKeywordStringData: setKeywordStringData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  // 첨부
  showFileAlert() {
    showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddFileWidget(
          fileData: fileData,
          fileList: fileList,
          setFileData: setFileData,
        );
      },
    ).then((value) => {setState(() {})});
  }

  String mergeStrings(String leftKey, String rightKey, Function leftConvertFunc,
      Function rightConvertFunc) {
    String leftString = ProfileService.accumulateToString(
        profileData[leftKey], leftConvertFunc);
    String rightString = ProfileService.accumulateToString(
        profileData[rightKey], rightConvertFunc);

    String result = '';

    if (leftString.isNotEmpty && rightString.isNotEmpty) {
      result = '$leftString / $rightString';
    } else if (leftString.isNotEmpty) {
      result = leftString;
    } else if (rightString.isNotEmpty) {
      result = rightString;
    } else {
      result = localization.284;
    }
    return result;
  }

  // 프로필이 0개인 경우 체크된 상태로 read only
  setProfileCheck() {
    setState(() {
      if (userProfileList.isEmpty) {
        isBasicProfile = true;
        basicReadOnly = true;
        setProfileData('mpBasic', 1);
      }
    });
  }

  showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.cancelWriting,
          alertContent: '페이지를 이동하시겠어요?\n이동 시 작성된 내용은 저장되지 않아요.',
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  showBasicProfileAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.285,
            alertContent: '대표 프로필은 1개만 설정 가능해요.\n기존 대표 프로필을 현재 프로필로 변경 하시겠어요?',
            alertConfirm: localization.287,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop(context);
              createProfile();
            },
            onCancel: () {
              context.pop(context);
            },
          );
        });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>(
        [getUserData(ref), getProfileList(), getSchoolType()]);
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      setProfileCheck();
      isLoading = false;
    });
  }

  getUserData(WidgetRef ref) async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.type == 1) {
      if (result.status == 200) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
        });
      }
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
          setState(() {
            userProfileList = [...result.data];
          });
        }
      }
    }
  }

  getSchoolType() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getSchoolType();
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          schoolTypes = [...resultData];
        });
      }
    }
  }

  createProfile() async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });

    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .createProfile(profileData);

    if (result.status == 200 && result.type == 1) {
      if (profilePhotoData['file'] != null || fileData['file'] != null) {
        saveFile(profilePhotoData['file'], fileData['file'], result.data);
      } else {
        if (mounted) {
          context.pop();
          showDefaultToast(localization.283);
        }
      }
    } else {
      setState(() {
        isRunning = false;
      });

      if (mounted) {
        if (result.status == 401) {
          showDefaultToast(localization.78);
        } else if (result.status == 412) {
          showDefaultToast(localization.288);
        } else {
          showDefaultToast(localization.289);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.read(userProvider);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          showCancelDialog();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            showCancelDialog();
          }
        },
        child: Scaffold(
          appBar: CommonAppbar(
            title: localization.290,
            backFunc: () {
              showCancelDialog();
            },
          ),
          body: !isLoading
              ? CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () => showProfilePhotoAlert(),
                          child: ColoredBox(
                            color: Colors.transparent,
                            child: Row(
                              children: [
                                Container(
                                  width: 72.w,
                                  height: 72.w,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: CommonColors.grayF2,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: profilePhotoData['file'] != null
                                      ? null
                                      : Alignment.center,
                                  child: profilePhotoData['file'] != null
                                      ? Image.file(
                                          File(profilePhotoData['file']['url']),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/icon/iconCamera.png',
                                          width: 24.w,
                                          height: 24.w,
                                        ),
                                ),
                                SizedBox(
                                  width: 16.w,
                                ),
                                Expanded(
                                  child: Text(
                                    userInfo!.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/icon/iconArrowRightThin.png',
                                  width: 20.w,
                                  height: 20.w,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ProfileListTitleWidget(
                      onTap: () => showProfileTitleSelection(context),
                      title: localization.291,
                      data: profileData,
                      required: true,
                    ),
                    ProfileListItemWidget(
                      isRequire: true,
                      onTap: () => showWorkAreaAlert(),
                      title: localization.292,
                      content: selectedAreaList.isNotEmpty
                          ? null
                          : localization.293,
                    ),
                    if (selectedAreaList.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.w,
                            children: [
                              for (int i = 0; i < selectedAreaList.length; i++)
                                ProfileBox(
                                    text: selectedAreaList[i].selectionName),
                            ],
                          ),
                        ),
                      ),
                    ProfileListItemWidget(
                      isRequire: true,
                      onTap: () => showJobAlert(),
                      title: localization.294,
                      content: selectedJobList.isNotEmpty
                          ? null
                          : localization.295,
                    ),
                    if (selectedJobList.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Wrap(
                            spacing: 8.w,
                            runSpacing: 8.w,
                            children: [
                              for (int i = 0; i < selectedJobList.length; i++)
                                ProfileBox(
                                  text: selectedJobList[i].name,
                                  isRed: true,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ProfileListItemWidget(
                      onTap: () => showWorkScheduleAlert(),
                      title: localization.296,
                      isRequire: true,
                      content: profileData['wdIdx'].isNotEmpty ||
                              profileData['whIdx'].isNotEmpty
                          ? null
                          : localization.284,
                    ),
                    if (profileData['wdIdx'].isNotEmpty ||
                        profileData['whIdx'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (profileData['wdIdx'].isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.w),
                                  child: Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.w,
                                    children: [
                                      for (var i = 0;
                                          i < profileData['wdIdx'].length;
                                          i++)
                                        ProfileBox(
                                            text: ProfileService.convertWorkDay(
                                                profileData['wdIdx'][i])),
                                    ],
                                  ),
                                ),
                              if (profileData['whIdx'].isNotEmpty)
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    for (var i = 0;
                                        i < profileData['whIdx'].length;
                                        i++)
                                      ProfileBox(
                                          text: ProfileService.convertWorkTime(
                                              profileData['whIdx'][i])),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ProfileListItemWidget(
                      onTap: () => showWorkConditionAlert(),
                      title: localization.297,
                      isRequire: true,
                      content: profileData['wtIdx'].isNotEmpty ||
                              profileData['wpIdx'].isNotEmpty
                          ? null
                          : localization.284,
                    ),
                    if (profileData['wtIdx'].isNotEmpty ||
                        profileData['wpIdx'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (profileData['wtIdx'].isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.w),
                                  child: Wrap(
                                    spacing: 8.w,
                                    runSpacing: 8.w,
                                    children: [
                                      for (var i = 0;
                                          i < profileData['wtIdx'].length;
                                          i++)
                                        ProfileBox(
                                            text:
                                                ProfileService.convertWorkType(
                                                    profileData['wtIdx'][i])),
                                    ],
                                  ),
                                ),
                              if (profileData['wpIdx'].isNotEmpty)
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    for (var i = 0;
                                        i < profileData['wpIdx'].length;
                                        i++)
                                      ProfileBox(
                                          text:
                                              ProfileService.convertWorkPeriod(
                                                  profileData['wpIdx'][i])),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ProfileListItemWidget(
                      isRequire: true,
                      onTap: () => showEducationAlert(),
                      title: localization.educationLevel,
                      content: profileData['educationList'].isNotEmpty
                          ? null
                          : localization.298,
                    ),
                    if (profileData['educationList'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                            child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6.w),
                              color: CommonColors.grayF7),
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0;
                                  i < profileData['educationList'].length;
                                  i++)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: i == 0 ? 0 : 12.w),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (profileData['educationList'][i]
                                              ['mpeName']
                                          .isNotEmpty)
                                        Flexible(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(right: 8.w),
                                            child: Text(
                                              '${profileData['educationList'][i]['mpeName']}',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      Text(
                                        '${ProfileService.educationTypeKeyToString(schoolTypes, profileData['educationList'][i]['stIdx'])} ${profileData['educationList'][i]['mpeStatus']}',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray80,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      if (profileData['educationList'][i]
                                              ['mpeDate'] !=
                                          null)
                                        Column(
                                          children: [
                                            SizedBox(
                                              width: 4.w,
                                            ),
                                            Text(
                                              '(${ProfileService.formatDate(profileData['educationList'][i]['mpeDate'])})',
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.gray80,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        )),
                      ),
                    ProfileListItemWidget(
                      onTap: () => showCareerAlert(),
                      title: localization.experienced,
                      content: profileData['careerList'].isNotEmpty
                          ? null
                          : localization.299,
                    ),
                    if (profileData['careerList'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0;
                                  i < profileData['careerList'].length;
                                  i++)
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.w),
                                    color: CommonColors.grayF7,
                                  ),
                                  child: Text(
                                    '총 ${totalCareerMonths ~/ 12}년 ${totalCareerMonths % 12}개월',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.black2b,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ProfileListItemWidget(
                      isRequire: true,
                      onTap: () => showAboutMeAlert(),
                      title: localization.300,
                      // isAboutMe: profileData['mpIntroduce'].isNotEmpty ||
                      //     profileData['keyword'].isNotEmpty,
                      // data: profileData,
                      // stringData: keywordStringData,
                      content: profileData['mpIntroduce'].isNotEmpty ||
                              keywordStringData['keywordName'].isNotEmpty
                          ? null
                          : localization.301,
                    ),
                    if (profileData['mpIntroduce'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.w),
                                  color: CommonColors.grayF7,
                                ),
                                child: Text(
                                  profileData['mpIntroduce'],
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (keywordStringData['keywordName'].isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Wrap(
                                spacing: 8.w,
                                runSpacing: 8.w,
                                children: [
                                  for (int i = 0;
                                      i <
                                          keywordStringData['keywordName']
                                              .length;
                                      i++)
                                    ProfileBox(
                                      isRed: true,
                                      text:
                                          '${keywordStringData['keywordName'][i]}',
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (keywordStringData['keywordName'].isNotEmpty ||
                        profileData['mpIntroduce'].isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 24.w,
                        ),
                      ),
                    ProfileListItemWidget(
                      onTap: () => showFileAlert(),
                      title: localization.302,
                      content: fileData['file'] != null &&
                              fileData['file'].length > 0
                          ? null
                          : localization.303,
                    ),
                    if (fileData['file'] != null && fileData['file'].length > 0)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < fileData['file'].length; i++)
                                Container(
                                  margin:
                                      EdgeInsets.only(top: i == 0 ? 0 : 12.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.w),
                                    color: CommonColors.grayF7,
                                  ),
                                  padding: EdgeInsets.all(20.w),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        'assets/images/icon/iconFileBlack.png',
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          '${fileData['file'][i]['name']}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray4d,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        ProfileService.formatFileSize(
                                            fileData['file'][i]['size']),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.gray60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                        child: Text(
                          localization.304,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CommonColors.black2b,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 10.w),
                      sliver: SliverToBoxAdapter(
                        child: ProfileRadio(
                          onChanged: (value) {
                            setState(() {
                              setProfileData('mpGetOffer', 1);
                              setProfileData('mpOfferScope', 1);
                            });
                          },
                          groupValue: true,
                          value: profileData['mpGetOffer'] == 1 &&
                              profileData['mpOfferScope'] == 1,
                          label: localization.305,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 10.w),
                      sliver: SliverToBoxAdapter(
                        child: ProfileRadio(
                          onChanged: (value) {
                            setState(() {
                              setProfileData('mpGetOffer', 1);
                              setProfileData('mpOfferScope', 2);
                            });
                          },
                          groupValue: true,
                          value: profileData['mpGetOffer'] == 1 &&
                              profileData['mpOfferScope'] == 2,
                          label: localization.306,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 10.w),
                      sliver: SliverToBoxAdapter(
                        child: ProfileRadio(
                          onChanged: (value) {
                            setState(() {
                              setProfileData('mpGetOffer', 0);
                              setProfileData('mpOfferScope', null);
                            });
                          },
                          groupValue: true,
                          value: profileData['mpGetOffer'] == 0,
                          label: localization.307,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(24.w, 48.w, 0.w, 48.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                            onTap: () {
                              if (!basicReadOnly) {
                                setState(() {
                                  isBasicProfile = !isBasicProfile;

                                  if (isBasicProfile) {
                                    setProfileData('mpBasic', 1);
                                  } else {
                                    setProfileData('mpBasic', 0);
                                  }
                                });
                              }
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.transparent),
                              child: Row(
                                children: [
                                  CircleCheck(
                                    readOnly: basicReadOnly,
                                    value: isBasicProfile,
                                    size: 24,
                                    onChanged: (value) {
                                      setState(() {
                                        isBasicProfile = !isBasicProfile;

                                        if (isBasicProfile) {
                                          setProfileData('mpBasic', 1);
                                        } else {
                                          setProfileData('mpBasic', 0);
                                        }
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  Expanded(
                                    child: Text(
                                      localization.308,
                                      style: TextStyle(
                                        color: isBasicProfile
                                            ? CommonColors.red
                                            : CommonColors.grayE6,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                          20.w, 0, 20.w, CommonSize.commonBottom),
                      sliver: SliverToBoxAdapter(
                        child: CommonButton(
                          fontSize: 15,
                          confirm: profileData['mpTitle']
                                  .isNotEmpty && // 프로필 제목
                              profileData['adIdx'].isNotEmpty && // 희망 근무 지역
                              profileData['joIdx'].isNotEmpty && // 희망 직종
                              profileData['wdIdx'].isNotEmpty && // 희망 근무 요일
                              profileData['whIdx'].isNotEmpty && // 희망 근무 시간
                              profileData['wtIdx'].isNotEmpty && // 희망 근무 형태
                              profileData['wpIdx'].isNotEmpty && // 희망 근무 기간
                              profileData['educationList'].isNotEmpty && // 학력
                              (profileData['mpIntroduce'].isNotEmpty || // 자기소개
                                  profileData['keyword'].isNotEmpty),
                          onPressed: () {
                            if (profileData['mpTitle'].isNotEmpty && // 프로필 제목
                                profileData['adIdx'].isNotEmpty && // 희망 근무 지역
                                profileData['joIdx'].isNotEmpty && // 희망 직종
                                profileData['wdIdx'].isNotEmpty && // 희망 근무 요일
                                profileData['whIdx'].isNotEmpty && // 희망 근무 시간
                                profileData['wtIdx'].isNotEmpty && // 희망 근무 형태
                                profileData['wpIdx'].isNotEmpty && // 희망 근무 기간
                                profileData['educationList'].isNotEmpty && // 학력
                                (profileData['mpIntroduce']
                                        .isNotEmpty || // 자기소개
                                    profileData['keyword'].isNotEmpty)) {
                              if (userProfileList.length > 1 &&
                                  profileData['mpBasic'] == 1) {
                                showBasicProfileAlert(context);
                              } else {
                                createProfile();
                              }
                            }
                          },
                          text: localization.register,
                        ),
                      ),
                    ),
                    const BottomPadding(),
                  ],
                )
              : const Loader(),
        ),
      ),
    );
  }
}
