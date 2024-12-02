import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/banner_enum.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/token_service.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/tutorial/widgets/tutorial_modal_widget.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/router_notifier.dart';
import 'package:chodan_flutter_app/screens/job_seeker_home_screen.dart';
import 'package:chodan_flutter_app/screens/recruiter_home_screen.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/popup_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeCheckUser extends ConsumerStatefulWidget {
  const HomeCheckUser({
    super.key,
    this.id,
  });

  final String? id;

  @override
  ConsumerState<HomeCheckUser> createState() => _HomeCheckUserState();
}

class _HomeCheckUserState extends ConsumerState<HomeCheckUser>
    with Alerts, BackButtonEvent {
  bool isLoading = true;
  Timer? runningTimer;

  bool isCheckedUnSeenForOneDay = false;


  Future<void> _getAllAsyncTasks() async {
    await getUserData();
    await getCommonData();
    await getDefineAppMenu();
    await getAreaList(DefineEnum.area);
  }

  Future<void> getCommonData() async {
    final prefs = await SharedPreferences.getInstance();
    chatUserService = ChatUserService(ref: ref);
    var token = prefs.getString('token');
    UserModel? userInfo = ref.read(userProvider);

    List<Future<void>> data = [
      getPopupBanner(),
      getPopupBeltBanner(),
      getBanner(BannerEnum.promotionMenu),
      getBanner(BannerEnum.theme),
      //직군, 지역
      getDefineList(DefineEnum.industry),
      getDefineList(DefineEnum.job),
      getWorkTypes(),
      getWorkPeriodList()
    ];

    if (token != null) {
      if (userInfo != null) {
        if (userInfo.memberType == MemberTypeEnum.jobSeeker) {
          data.add(getBanner(BannerEnum.promotionJobPosting));
          data.add(getCompanyLikesKeyList());
          data.add(getCompanyHidesKeyList());
          data.add(getUserClipAnnouncementList());
        } else {
          data.add(getBanner(BannerEnum.promotionJobSeekerList));
          data.add(getRecruiterProfileData());
          data.add(getWorkerLikesKeyList());
          data.add(getWorkerHidesKeyList());
          data.add(matchingKeyProfileList());
        }

        await Future.wait<void>(data);
      }
    }
  }

  getDefineAppMenu() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getDefineAppMenuList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(appMenuListProvider.notifier).update((state) => result.data);
      }
    }
  }

  getWorkPeriodList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkPeriodList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(workPeriodListProvider.notifier)
            .update((state) => result.data);
      }
    }
  }

  getWorkTypes() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkTypes();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(workTypeListProvider.notifier).update((state) => result.data);
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
            .update((state) => result.data);
      });
    }
  }

  getCompanyLikesKeyList() async {
    ApiResultModel result = await ref
        .read(companyControllerProvider.notifier)
        .getCompanyLikesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(companyLikesKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  getCompanyHidesKeyList() async {
    ApiResultModel result = await ref
        .read(companyControllerProvider.notifier)
        .getCompanyHidesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(companyHidesKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  getWorkerLikesKeyList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerLikesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(workerLikesKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  getWorkerHidesKeyList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerHidesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(workerHidesKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  matchingKeyProfileList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .matchingKeyProfileList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(matchingKeyListProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  getRecruiterProfileData() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(authControllerProvider.notifier)
          .getRecruiterProfileData(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          UserModel userProfileInfo = result.data;
          ref
              .read(userProfileProvider.notifier)
              .update((state) => userProfileInfo);
        }
      }
    }
  }

  Future<void> getDefineList(DefineEnum defineTypeEnum) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getDefineList(defineTypeEnum);
    StateProvider<List<DefineModel>> provider =
        setDefineProvider(defineTypeEnum);
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(provider.notifier).update((state) => result.data);
      }
    }
  }

  Future<void> getAreaList(DefineEnum defineTypeEnum) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getAreaList(defineTypeEnum);
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(areaListProvider.notifier).update((state) => result.data);
      }
    }
  }

  getPopupBanner() async {
    List<BannerModel> popupBannerList = ref.read(popupBannerListProvider);
    ApiResultModel result =
        await ref.read(bannerControllerProvider.notifier).getPopupBanner(1);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref
              .read(popupBannerListProvider.notifier)
              .update((state) => [...result.data]);
        });
      }
    }
  }

  getPopupBeltBanner() async {
    List<BannerModel> popupBeltBannerList =
        ref.read(popupBeltBannerListProvider);
    ApiResultModel result =
        await ref.read(bannerControllerProvider.notifier).getPopupBanner(2);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref
              .read(popupBeltBannerListProvider.notifier)
              .update((state) => [...result.data]);
        });
      }
    }
  }

  StateProvider<List<BannerModel>> setBannerProvider(
      BannerEnum bannerTypeEnum) {
    switch (bannerTypeEnum) {
      case BannerEnum.promotionMenu:
        return menuBannerListProvider;
      case BannerEnum.promotionJobPosting:
        return jobPostingBannerListProvider;
      case BannerEnum.promotionJobSeekerList:
        return jobSeekerBannerListProvider;
      case BannerEnum.theme:
        return themeBannerListProvider;
    }
  }

  StateProvider<List<DefineModel>> setDefineProvider(
      DefineEnum defineTypeEnum) {
    switch (defineTypeEnum) {
      case DefineEnum.industry:
        return industryListProvider;
      case DefineEnum.job:
        return jobListProvider;
      default:
        return defineListProvider;
    }
  }

  getBanner(BannerEnum bannerType) async {
    StateProvider<List<BannerModel>> bannerStateProvider =
        setBannerProvider(bannerType);
    List<BannerModel> bannerList = ref.read(bannerStateProvider);
    ApiResultModel result = await ref
        .read(bannerControllerProvider.notifier)
        .getBanner(bannerType.value);
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(bannerStateProvider.notifier)
            .update((state) => [...result.data]);
      }
    }
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    chatUserService = ChatUserService(ref: ref);
    var token = prefs.getString('token');
    if (token != null) {
      ApiResultModel result =
          await ref.read(authControllerProvider.notifier).getUserData();
      if (result.type == 1) {
        TokenService tokenService = TokenService(user: result.data);
        ref.read(userProvider.notifier).update((state) => result.data);
        ref.read(userAuthProvider.notifier).update((state) => result.data);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          chatUserService = ChatUserService(ref: ref);
          initChatService(result.data, chatUserService);
        });
        setState(() {
          String deviceType;
          if (Platform.isIOS) {
            deviceType = ApiConstants.ios;
          } else {
            deviceType = ApiConstants.aos;
          }
          tokenService.writeToken(deviceType);
        });
      } else if(result.status == 502){} else{
        ref.read(goRouterNotifierProvider).isLoggedIn = false;
        if (mounted) {
          showStartDialog(context);
        }
      }
    } else {
      if (mounted) {
        showStartDialog(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      Future(() {
        ref.read(inviteProvider.notifier).update((state) => widget.id!);
        ref.read(userSingFinishProvider.notifier).update((state) => {});
      });
    }
    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
        showPopupBanner();
        var user = ref.watch(userProvider);
        runningTimer = Timer(const Duration(milliseconds: 2000), () {
          if (user != null) {
            if (user.memberType == MemberTypeEnum.jobSeeker) {
              checkJobSeekerPercent();
            } else {
              checkRecruiterPercent();
            }
          }
        });

      });
    });
  }

  void showPopup(BuildContext context, List<BannerModel> bannerList,
      String formattedDate) {
    if (bannerList.isNotEmpty) {
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
            return PopupBottomSheet(
              bannerList: bannerList,
              formattedDate: formattedDate,
            );
          });
    }
  }

  showPopupBanner() async {
    List<BannerModel> popupBanner = ref.read(popupBannerListProvider);
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final prefs = await SharedPreferences.getInstance();
    dynamic popupBannerData = prefs.getString('popupBanner');
    if (popupBannerData == null) {
      return showPopup(context, popupBanner, formattedDate);
    }
    dynamic decodedBannerData = jsonDecode(popupBannerData);
    String bannedBannedData = decodedBannerData['notShowData'];
    DateTime bannedDate = DateFormat('yyyy-MM-dd').parse(bannedBannedData);
    bool oneDaysAfterToday =
        today.isAfter(bannedDate.add(const Duration(days: 1)));
    if (!oneDaysAfterToday) {
      return;
    } else if (oneDaysAfterToday) {
      return showPopup(context, popupBanner, formattedDate);
    } else {
      return showPopup(context, popupBanner, formattedDate);
    }
  }

  Future<String> getProfilePhoto(WidgetRef ref) async {
    UserModel? userInfo = ref.read(userProvider);
    String profilePhotoUrl = '';
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getMainProfileData(userInfo.key);
      if (result.type == 1) {
        if (result.status == 200) {
          setState(() {
            if (result.data.isNotEmpty) {
              profilePhotoUrl = result.data[0].profileImg.url;
            }
          });
        }
      }
    }
    return profilePhotoUrl;
  }

  Future<String> getCompanyPhoto(WidgetRef ref) async {
    UserModel? userInfo = ref.read(userProvider);
    String profilePhotoUrl = '';
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .getCompanyInfo(userInfo.key);
      if (result.type == 1) {
        if (result.status == 200) {
          setState(() {
            if (result.data != null) {
              profilePhotoUrl = result.data.companyInfo.files[0].url;
            }
          });
        }
      }
    }
    return profilePhotoUrl;
  }

  showTutorialModalBottom(String memberType, int percent, String message,
      int idx, String? profilePhotoUrl) {
    showModalBottomSheet<void>(
      isDismissible: false,
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
        return Builder(builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {},
            child: TutorialModalWidget(
              type: memberType,
              idx: idx,
              percent: percent,
              message: message,
              photoUrl: profilePhotoUrl,
            ),
          );
        });
      },
    ).whenComplete(() {
      context.pop();
    });
  }

  showTutorialDialog(String memberType, int percent, String message, int idx,
      String? profilePhotoUrl) async {
    UserModel? userInfo = ref.read(userProvider);
    DateTime today = DateTime.now();
    // String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    final prefs = await SharedPreferences.getInstance();
    dynamic popupTutorialData =
        prefs.getString('popupTutorial${userInfo!.key}');
    if (popupTutorialData == null) {
      showTutorialModalBottom(
          memberType, percent, message, idx, profilePhotoUrl);
    } else {
      dynamic decodedBannerData = jsonDecode(popupTutorialData);
      String bannedBannedData = decodedBannerData['notShowData'];
      DateTime bannedDate = DateFormat('yyyy-MM-dd').parse(bannedBannedData);

      bool oneDaysAfterToday =
          today.isAfter(bannedDate.add(const Duration(days: 1)));
      if (!oneDaysAfterToday) {
        return;
      } else if (oneDaysAfterToday) {
        return showTutorialModalBottom(
            memberType, percent, message, idx, profilePhotoUrl);
      } else {
        return showTutorialModalBottom(
            memberType, percent, message, idx, profilePhotoUrl);
      }
    }
  }

  checkJobSeekerPercent() async {
    String profilePhotoUrl = await getProfilePhoto(ref);
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .checkJobSeekerPercent(userInfo.key);
      if (result.status == 200) {
        setState(() {
          // 튜토리얼 미완료일 경우에만 튜토리얼 띄우기  // 학력(6), 경력(7), 첨부(9) 제외
          if (!result.data.incompleteStep
              .every((step) => step == 6 || step == 7 || step == 9)) {
            if (mounted) {
              showTutorialDialog('jobSeeker', result.data.percent,
                  result.data.message, result.data.key, profilePhotoUrl);
            }
          }
        });
      }
    }
  }

  checkRecruiterPercent() async {
    String profilePhotoUrl = await getCompanyPhoto(ref);
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .checkRecruiterPercent();
    if (result.status == 200) {
      setState(() {
        if (result.data.percent != 100) {
          if (mounted) {
            showTutorialDialog('recruiter', result.data.percent,
                result.data.message, result.data.key, profilePhotoUrl);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    disposeChatService();
    if (runningTimer != null && runningTimer!.isActive) {
      runningTimer!.cancel();
    }
    super.dispose();
  }

  Widget checkUser(MemberTypeEnum type) {
    switch (type) {
      // 구직자
      case MemberTypeEnum.jobSeeker:
        return const JobSeekerHomeScreen();
      // 구인자
      case MemberTypeEnum.recruiter:
        return const RecruiterHomeScreen();
      default:
        return const JobSeekerHomeScreen();
    }
  }

  finishSing(Map<String, dynamic> loginData) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          ref.read(userSingFinishProvider.notifier).update((state) => {});
        });
        UserModel? userInfo = ref.watch(userProvider);
        if (userInfo != null) {
          setState(() {
            checkJobSeekerPercent();
          });
        } else {
          setState(() {
            // login(loginData);
            showStartDialog(context);
          });
        }
      } else {
        setState(() {
          ref.read(userSingFinishProvider.notifier).update((state) => {});
        });
      }
    });
  }

  void login(Map<String, dynamic> loginData) async {
    if (loginData['type'] == 'email') {
      ApiResultModel result = await ref
          .read(authControllerProvider.notifier)
          .login(loginData['email'], loginData['password']);
      if (result.status == 200) {
        if (result.data['accessToken'] != null) {
          String token = result.data['accessToken'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          ref.read(goRouterNotifierProvider).isLoggedIn = true;

          ApiResultModel userDataResult =
              await ref.read(authControllerProvider.notifier).getUserData();
          if (userDataResult.type == 1) {
            ApiResultModel user =
                await ref.read(authControllerProvider.notifier).getUserData();
            ref.read(userProvider.notifier).update((state) => user.data);
            ref.read(userAuthProvider.notifier).update((state) => user.data);

            TokenService tokenService = TokenService(user: user.data);

            chatUserService = ChatUserService(ref: ref);
            initChatService(userDataResult.data, chatUserService);
            ref
                .read(authControllerProvider.notifier)
                .saveUserDataToFirebase(userDataResult.data);
            String deviceType;
            if (Platform.isIOS) {
              deviceType = ApiConstants.ios;
            } else {
              deviceType = ApiConstants.aos;
            }
            var token = await tokenService.writeToken(deviceType);
            if (token != null) {
              chatUserService.updateUserDeviceToken(token);
            }

            await getProfileList();
          }
        }
      } else {
        showStartDialog(context);
        showDefaultToast(localization.unapprovedRecruitmentMember);
      }
    }
  }

  getProfileList() async {
    UserModel? userInfo = ref.watch(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getCompleteProfileList(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          int filteredIndex = result.data
              .indexOf((ProfileModel element) => element.mainProfile == 1);
          if (filteredIndex != -1) {
            ProfileModel data = result.data.removeAt(filteredIndex);
            result.data.insert(0, data);
          }
          setState(() {
            ref
                .read(userProfileListProvider.notifier)
                .update((state) => result.data);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    Map<String, dynamic> loginData = ref.watch(userSingFinishProvider);
    if (loginData.isNotEmpty) {
      finishSing(loginData);
    }
    if (userInfo == null) {
      return checkUser(MemberTypeEnum.jobSeeker);
    } else {
      // 멤버 타입에 따라 Background Screen 다름
      return checkUser(userInfo.memberType);
    }
  }
}
