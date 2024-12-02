import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/branch_dynamiclink.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/like_hide_tap_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_manage_tap_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/screens/recruit/setting_recriuter.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/recruiter_block_jobposting_bottomsheet.dart';
import 'package:chodan_flutter_app/features/premium/screens/premium_match_screen.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/choco_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/move_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/company_img_widget.dart';

class RecruiterMypageScreen extends ConsumerStatefulWidget {
  RecruiterMypageScreen({super.key, required this.setSilver});

  final Function setSilver;

  @override
  ConsumerState<RecruiterMypageScreen> createState() =>
      _RecruiterMypageScreenState();
}

class _RecruiterMypageScreenState extends ConsumerState<RecruiterMypageScreen>
    with Alerts, BackButtonEvent {
  BranchDynamicLink dynamicLink = BranchDynamicLink();

  late UserModel userProfileInfo;
  bool isLoading = true;
  bool silverLoad = false;

  UserModel? companyData;
  List<ChocoModel> chocoList = [];

  int totalPoint = 0;

  var totalChoco = 0;

  int publishingJobpostingTotal = 0;

  int likesWorkerTotal = 0;

  int hidesWorkerTotal = 0;

  int recentProfile = 0;

  updateHiringStatus() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .updateStatus(4, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          getUserData();
        }
      }
    }
  }

  getJobpostingListData(int page, Map<String, dynamic> params) async {
    UserModel? userInfo = ref.read(userProvider);
    Map<String, dynamic> ownerIdxParam = {'ownerIdx': userInfo!.key};
    params = {...params, ...ownerIdxParam};
    params.addAll(ownerIdxParam);
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingListData(page, params);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          publishingJobpostingTotal = result.page['total'];
        });
        if (publishingJobpostingTotal > 0 && userInfo.memberStatus == '미채용') {
          updateHiringStatus();
        }
      }
    }
  }

  getWorkerLikesListData(int page) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerLikesListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          likesWorkerTotal = result.page['total'];
        });
      }
    }
  }

  getWorkerHidesListData(int page) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerHidesListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          hidesWorkerTotal = result.page['total'];
        });
      }
    }
  }

  getLatestWorkerListData(int page) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getLatestWorkerListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          recentProfile = result.page['total'];
        });
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getUserData(),
      getRecruiterProfileData(),
      getMyTotalPoint(),
      getJobpostingListData(
          1, JobpostingManageTapEnum.publishing.listApiParams),
      getWorkerLikesListData(1),
      getWorkerHidesListData(1),
      getLatestWorkerListData(1)
    ]);
  }

  pushAfterFunc() {
    getUserData();
    getMyTotalPoint();
    getJobpostingListData(1, JobpostingManageTapEnum.publishing.listApiParams);
    getWorkerLikesListData(1);
    getWorkerHidesListData(1);
    getLatestWorkerListData(1);
  }

  getMyTotalPoint() async {
    ApiResultModel result =
        await ref.read(mypageControllerProvider.notifier).getMyTotalPoint();
    if (result.status == 200) {
      if (result.type == 1) {
        if (result.data != null) {
          setState(() {
            totalPoint = result.data;
          });
        }
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
          companyData = result.data;
          ref.read(userProfileProvider.notifier).update((state) => companyData);
        }
      }
    }
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

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
        });
      }
    }
  }

  showBottomBlckJobposting() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const SizedBox(
            height: 200, child: RecruiterBlockJobpostingBottomsheet());
      },
      context: context,
    );
  }

  int activeTab = 0;

  setTab(data) {
    setState(() {
      savePageLog();
      activeTab = data;
    });
  }

  showPremiumMatchSAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PremiumMatchScreen();
      },
    ).then((_) {
      pushAfterFunc();
    });
  }

  void openShare(String url) async {
    showDefaultToast('복사되었습니다.');
    final result = await Share.share(
        await dynamicLink.generateLink(context, url),
        subject: '초단알바');
    if (result.status == ShareResultStatus.success) {
      showDefaultToast("공유가 완료되었습니다.");
    }
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  saveInviteLog() async {
    await ref.read(logControllerProvider.notifier).saveInviteLog();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    UserModel? company = ref.watch(userProfileProvider);
    return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) {
            backPress();
          }
        },
        child: Scaffold(
          appBar: RedAppbar(
            actionFunc: () {
              context.push('/menu');
            },
            setTab: setTab,
            activeTab: activeTab,
            tabTitleArr: const ['마이페이지', '설정'],
          ),
          bottomNavigationBar: CommonBottomAppbar(type: 'mypage'),
          body: !isLoading
              ? activeTab == 0
                  ? CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const RedBack(extraHeight: 80),
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(12.w, 4.w, 12.w, 16.w),
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: CommonColors.white,
                                    borderRadius: BorderRadius.circular(20.w),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 16.w,
                                        offset: Offset(0, 2.w),
                                        color:
                                            const Color.fromRGBO(0, 0, 0, 0.06),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [

                                      CompanyImgWidget(
                                        text: company!.companyInfo!.name,
                                        imgUrl:
                                            company.companyInfo!.files[0].url,
                                        imgWidth: CommonSize.vw,
                                        color: Color(
                                          ConvertService.returnBgColor(
                                              companyData!.companyInfo!.color),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16.w,
                                      ),
                                      Center(
                                        child: Container(
                                          height: 28.w,
                                          decoration: BoxDecoration(
                                            color: CommonColors.red,
                                            borderRadius:
                                                BorderRadius.circular(500.w),
                                          ),
                                          padding: EdgeInsets.fromLTRB(
                                              12.w, 0.w, 12.w, 0.w),
                                          // alignment: Alignment.center,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                // companyData!.memberStatus,
                                                userInfo!.memberStatus,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: CommonColors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.w,
                                      ),
                                      Text(
                                        company.companyInfo!.name,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.gray4d),
                                      ),
                                      SizedBox(
                                        height: 8.w,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  companyData!.evaluateAvg
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.gray80),
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                RatingBar.builder(
                                                  itemSize: 12.w,
                                                  initialRating:
                                                      companyData!.evaluateAvg /
                                                          2,
                                                  minRating: 0,
                                                  direction: Axis.horizontal,
                                                  allowHalfRating: true,
                                                  itemCount: 5,
                                                  itemPadding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 1.0),
                                                  itemBuilder: (context, _) =>
                                                      Image.asset(
                                                    'assets/images/icon/IconFullStarActive.png',
                                                    width: 12.w,
                                                    height: 12.w,
                                                  ),
                                                  ignoreGestures: true,
                                                  onRatingUpdate: (rating) {},
                                                ),
                                                SizedBox(
                                                  width: 24.w,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            width: 1.w,
                                            height: 16.w,
                                            color: CommonColors.grayF2,
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 24.w,
                                                ),
                                                Text(
                                                  '포인트',
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.gray80),
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                Text(
                                                  ConvertService
                                                      .returnStringWithCommaFormat(
                                                          totalPoint),
                                                  style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color: CommonColors.red,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 24.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 18.w, 0, 18.w),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 16.w,
                                      offset: Offset(0, 2.w),
                                      color:
                                          const Color.fromRGBO(0, 0, 0, 0.06),
                                    )
                                  ],
                                  color: CommonColors.white,
                                  borderRadius: BorderRadius.circular(20.w)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .push(
                                                '/jobpostingmanage?tab=${JobpostingManageTapEnum.publishing.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$publishingJobpostingTotal',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: CommonColors.red),
                                            ),
                                            SizedBox(
                                              height: 8.w,
                                            ),
                                            // iconRedBlock.png
                                            // iconRedHeart.png
                                            // iconRedClock.png

                                            Text(
                                              '게재 중 공고',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .push(
                                                '/my/worker?tab${LikeHideTapEnum.likes.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$likesWorkerTotal',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: CommonColors.red),
                                            ),
                                            SizedBox(
                                              height: 8.w,
                                            ),
                                            // iconRedBlock.png
                                            // iconRedHeart.png
                                            // iconRedClock.png

                                            Text(
                                              '관심인재',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .push(
                                                '/my/worker?tab=${LikeHideTapEnum.hides.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$hidesWorkerTotal',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: CommonColors.red),
                                            ),
                                            SizedBox(
                                              height: 8.w,
                                            ),
                                            // iconRedBlock.png
                                            // iconRedHeart.png
                                            // iconRedClock.png

                                            Text(
                                              '차단인재',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        context
                                            .push('/worker/recent')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$recentProfile',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: CommonColors.red),
                                            ),
                                            SizedBox(
                                              height: 8.w,
                                            ),
                                            Text(
                                              '최근 본 인재',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CommonButton(
                                    backColor: CommonColors.red02,
                                    onPressed: () {
                                      UserModel? userProfile =
                                          ref.read(userProfileProvider);
                                      if (userProfile != null) {
                                        if (userProfile.companyInfo!
                                                .registrationNumber !=
                                            '') {
                                          context
                                              .push('/mypage/jobposting/create')
                                              .then((_) {
                                            pushAfterFunc();
                                          });
                                        } else {
                                          showBottomBlckJobposting();
                                        }
                                      }
                                    },
                                    text: '',
                                    confirm: true,
                                    childWidget: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/icon/iconPlusRed.png',
                                          width: 18.w,
                                          height: 18.w,
                                        ),
                                        SizedBox(
                                          width: 6.w,
                                        ),
                                        Text(
                                          '신규 공고 등록',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                              color: CommonColors.red),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                Expanded(
                                  child: CommonButton(
                                    onPressed: () {
                                      showPremiumMatchSAlert();
                                    },
                                    text: '',
                                    childWidget: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '긴급구인',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: CommonColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 4.w,
                                        ),
                                        Image.asset(
                                          'assets/images/default/imgCrazy.png',
                                          width: 74.w,
                                          height: 22.w,
                                        ),
                                      ],
                                    ),
                                    confirm: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () {
                                context.push('/my/choco');
                              },
                              child: Container(
                                height: 48.w,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      width: 1.w,
                                      color: CommonColors.grayF7,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/default/imgChoco.png',
                                      width: 32.w,
                                      height: 32.w,
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                      child: Text(
                                        '보유 초단코인',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: CommonColors.brown,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${ConvertService.returnStringWithCommaFormat(userInfo.choco)} 초코',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: CommonColors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/jobpostingmanage');
                            },
                            text: '공고 관리',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/my/premium').then((_) {
                                pushAfterFunc();
                              });
                            },
                            text: '프리미엄 서비스',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/my/consult');
                            },
                            text: '노무 상담 하기',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/my/document');
                            },
                            text: '계약서/사직서',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/review');
                            },
                            text: '별점 관리',
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/point');
                            },
                            text: '활동 포인트 관리',
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 40.w, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              children: [
                                CommonButton(
                                  onPressed: () {
                                    // savePageLog();
                                    saveInviteLog();
                                    openShare('?id=${userInfo.id}');
                                  },
                                  text: '친구 초대하기',
                                  confirm: true,
                                  childWidget: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/icon/iconShareWhite.png',
                                        width: 20.w,
                                        height: 20.w,
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Text(
                                        '사장님 초대하기 (10,000초코 지급)',
                                        style: TextStyles.commonButton(
                                            color: CommonColors.white,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  '※ 초대를 받은 분이 사장님(구인)회원으로 가입한 이후 초코가 지급됩니다.',
                                  style: TextStyles.commonButton(
                                      color: CommonColors.gray4d, fontSize: 10),
                                ),
                                Text(
                                  '(가입 30일 이후 지급, 단 초대 받은 회원이 탈퇴, 재가입 할 경우 지급 안됨)',
                                  style: TextStyles.commonButton(
                                      color: CommonColors.red, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const FooterBottomPadding(),
                      ],
                    )
                  : SettingRecruiter(setSilver: widget.setSilver)
              : const Loader(),
        ));
  }
}
