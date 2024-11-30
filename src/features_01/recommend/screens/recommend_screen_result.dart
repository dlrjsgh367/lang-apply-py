import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/apply_toast_utils.dart';
import 'package:chodan_flutter_app/core/utils/scrap_toast_utils.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_profile_bottomsheet.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_today_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_list_widget.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendScreen extends ConsumerStatefulWidget {
  const RecommendScreen({super.key});

  @override
  ConsumerState<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends ConsumerState<RecommendScreen>
    with BackButtonEvent {
  int activeTab = 0;

  // bool isLoader = false;

  List<ProfileModel> userProfileList = [];
  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(LogTypeEnum.recommendedAlba.type),
      getUserClipAnnouncementList(),
      getUserData(),
    ]);
  }

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token != null) {
      ApiResultModel result =
      await ref.read(authControllerProvider.notifier).getUserData();
      if (result.type == 1) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
          ref.read(userAuthProvider.notifier).update((state) => result.data);
        });
      }
    }
  }
  savePageLog(int logType) async {
    await ref.read(logControllerProvider.notifier).savePageLog(logType);
  }

  void setTab(data) {
    setState(() {
      if (activeTab != data && data == 0) {
        savePageLog(LogTypeEnum.recommendedAlba.type);
      }

      if (activeTab != data && data == 1) {
        savePageLog(LogTypeEnum.theme.type);
      }
      activeTab = data;
    });

  }

  getProfileList() async {
    UserModel? userInfo = ref.read(userProvider);
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
            .update((state) => result.data);
      });
    }
  }

  void scrapJobseeker(String type, int idx) async {
    ApiResultModel result;
    Map<String, dynamic> params = {"jpIdx": idx};
    if (type == 'add') {
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
        setState(() {
          String msg = type == 'add' ? '공고를 스크랩했어요!' : '스크랩 목록에서 삭제했어요!';
          showScrapToast(msg, type);
          getUserClipAnnouncementList();
        });
      } else {
        setState(() {
          String msg =
              type == 'add' ? '공고 스크랩에 실패하였습니다.' : '공고 스크랩 삭제에 실패하였습니다.';
          showScrapToast(msg, type);
        });
      }
    } else {
      setState(() {
        String msg = type == 'add' ? '공고 스크랩에 실패하였습니다.' : '공고 스크랩 삭제에 실패하였습니다.';
        showScrapToast(msg, type);
      });
    }
  }

  showApply(int jobpostKey) async {
    await getProfileList();

    if (userProfileList.isEmpty) {
      showDefaultToast(localization.completeProfileBeforeApplying);
    } else {
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
                builder: (BuildContext context, StateSetter bottomSate) {
              return JobpostingProfileBottomSheet(
                  apply: applyJobposting,
                  jobpostKey: jobpostKey,
                  getProfile: () {
                    bottomSate(() {
                      getProfileList();
                    });
                  });
            });
          });
    }
  }

  getApplyOrProposedJobpostKey() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getApplyOrProposedJobpostKey();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref
              .read(applyOrProposedJobpostKeyListProvider.notifier)
              .update((state) => [...result.data['jpIdx'], ...result.data['jpIdxApproved']]);
        });
      }
    }
  }

  applyJobposting(int idx, int mpIdx) async {
    if (mpIdx == 0) {
      showApplyToast(localization.jobPostApplicationFailed, 'delete');
      return null;
    }
    Map<String, dynamic> params = {"mpIdx": mpIdx, "jpIdx": idx};
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .applyJobposting(params);

    if (result.status == 200) {
      if (result.type == 1) {
        getApplyOrProposedJobpostKey();
        setState(() {
          showApplyToast(localization.jobPostApplicationSuccessful, 'add');
        });
      }
    } else {
      showApplyToast(localization.jobPostApplicationFailed, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            backPress();
          }
        },
        child: Scaffold(
            appBar: RedAppbar(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: const ['추천 알바', '테마별 찾기'],
            ),
            bottomNavigationBar: CommonBottomAppbar(
              type: 'recommend',
            ),
            body: !isLoading
                ? activeTab == 0
                    ? RecommendTodayWidget(
                        scrapJobseeker: scrapJobseeker,
                        applyJobposting: showApply)
                    : const ThemeListWidget()
                : const Loader()));
  }
}
