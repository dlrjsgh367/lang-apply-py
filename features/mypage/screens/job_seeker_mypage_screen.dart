import 'package:chodan_flutter_app/core/back_listener.dart';
import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/service/branch_dynamiclink.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/like_hide_tap_enum.dart';
import 'package:chodan_flutter_app/enum/jobpost_tap_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/setting/screens/setting_seeker_screen.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
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

class JobSeekerMypageScreen extends ConsumerStatefulWidget {
  JobSeekerMypageScreen({super.key, required this.setSilver});

  final Function setSilver;

  @override
  ConsumerState<JobSeekerMypageScreen> createState() =>
      _JobSeekerMypageScreenState();
}

class _JobSeekerMypageScreenState extends ConsumerState<JobSeekerMypageScreen>
    with Alerts, BackButtonEvent {
  BranchDynamicLink dynamicLink = BranchDynamicLink();
  bool isLoading = true;
  bool silverLoad = false;
  int totalPoint = 0;

  int scrapTotal = 0;
  int postTotal = 0;
  int likeCompanyTotal = 0;
  int blockCompanyTotal = 0;

  void openShare(String url) async {
    Share.share(
      await dynamicLink.generateLink(context, url),
    );
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getUserData(),
      getMyTotalPoint(),
      getScrappedJobposting(),
      getLatestJobposting(),
      getCompanyLikesListData(),
      getCompanyHidesListData(),
    ]);
  }

  pushAfterFunc() {
    getUserData();
    getMyTotalPoint();
    getScrappedJobposting();
    getLatestJobposting();
    getCompanyLikesListData();
    getCompanyHidesListData();
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
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  getMyTotalPoint() async {
    ApiResultModel result =
        await ref.read(mypageControllerProvider.notifier).getMyTotalPoint();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          totalPoint = result.data ?? 0;
        });
      }
    }
  }

  int activeTab = 0;

  setTab(data) {
    setState(() {
      if (activeTab != data && data == 1) {
        savePageLog(); // 설정 진입시 페이지 로그 쌓기
      }
      activeTab = data;
    });
  }

  String addCommasToNumber(int number) {
    String formattedNumber = number.toString();
    RegExp regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return formattedNumber.replaceAllMapped(regex, (match) => '${match[1]},');
  }

  getScrappedJobposting() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getScrappedJobpost(1);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          scrapTotal = result.page['total'];
        });
      }
    }
  }

  getLatestJobposting() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getLatestJobpost(1);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          postTotal = result.page['total'];
        });
      }
    }
  }

  getCompanyLikesListData() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getCompanyLikesListData(1);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          likeCompanyTotal = result.page['total'];
        });
      }
    }
  }

  getCompanyHidesListData() async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getCompanyHidesListData(1);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          blockCompanyTotal = result.page['total'];
        });
      }
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
            tabTitleArr: ['마이페이지', '설정'],
          ),
          bottomNavigationBar: CommonBottomAppbar(type: 'mypage'),
          body: activeTab == 0
              ? !isLoading
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
                                      Stack(
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            child: AspectRatio(
                                              aspectRatio: 1 / 1,
                                              child: userInfo!.userProfile ==
                                                          null ||
                                                      userInfo.userProfile!
                                                              .profileIdx ==
                                                          0
                                                  ? Container(
                                                      color: Color(
                                                        ConvertService
                                                            .returnBgColor(
                                                          userInfo.color!,
                                                        ),
                                                      ),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Image.asset(
                                                        'assets/images/icon/imgProfileSeeker.png',
                                                        width: 100.w,
                                                        height: 100.w,
                                                      ),
                                                    )
                                                  : ExtendedImgWidget(
                                                      imgUrl: userInfo
                                                          .userProfile!
                                                          .profileImg,
                                                      imgFit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 12.w,
                                            right: 12.w,
                                            child: Container(
                                              height: 28.w,
                                              decoration: BoxDecoration(
                                                color: CommonColors.red,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        500.w),
                                              ),
                                              padding: EdgeInsets.fromLTRB(
                                                  12.w, 0.w, 12.w, 0.w),
                                              alignment: Alignment.center,
                                              child: Text(
                                                userInfo.memberStatus,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: CommonColors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16.w,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            userInfo.name,
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: CommonColors.gray4d),
                                          ),
                                          SizedBox(
                                            width: 12.w,
                                          ),
                                          Text(
                                            '(${ConvertService.calculateAge(userInfo.birth)}세, ${ProfileService.identifyGender(userInfo.gender)})',
                                            style: TextStyle(
                                                fontSize: 18.sp,
                                                fontWeight: FontWeight.w600,
                                                color: CommonColors.gray4d),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 24.w,
                                      ),
                                      if (userInfo.userProfile != null &&
                                          userInfo
                                              .userProfile!.title.isNotEmpty)
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              8.w, 0, 8.w, 16.w),
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                25.w, 16.w, 25.w, 16.w),
                                            decoration: BoxDecoration(
                                              color: CommonColors.grayF7,
                                              borderRadius:
                                                  BorderRadius.circular(12.w),
                                            ),
                                            child: Text(
                                              userInfo.userProfile!.title,
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  color: CommonColors.gray66),
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${userInfo.evaluateAvg}0',
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
                                                      userInfo.evaluateAvg / 2,
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
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 24.w,
                                          ),
                                          Container(
                                            width: 1.w,
                                            height: 16.w,
                                            color: CommonColors.grayF2,
                                          ),
                                          SizedBox(
                                            width: 24.w,
                                          ),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Text(
                                                '포인트',
                                                style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: CommonColors.gray80),
                                              ),
                                              SizedBox(
                                                width: 8.w,
                                              ),
                                              Text(
                                                addCommasToNumber(totalPoint),
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: CommonColors.red,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ))
                                        ],
                                      ),
                                      SizedBox(
                                        height: 24.w,
                                      ),
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            context
                                                .push('/my/profile')
                                                .then((_) => getUserData());
                                          },
                                          child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                12.w, 6.w, 12.w, 6.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(500.w),
                                              color: CommonColors.grayF7,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/icon/iconWrite.png',
                                                  width: 16.w,
                                                  height: 16.w,
                                                ),
                                                SizedBox(
                                                  width: 12.w,
                                                ),
                                                Text(
                                                  '프로필 관리',
                                                  style: TextStyle(
                                                      fontSize: 11.sp,
                                                      color:
                                                          CommonColors.gray66,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
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
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(0, 24.w, 0, 24.w),
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
                                                '/my/recruit?tab=${JobpostTapEnum.scrap.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                        ;
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            /*Image.asset(
                                          'assets/images/icon/iconRedStar.png',
                                          width: 20.w,
                                          height: 20.w,
                                        ),*/
                                            Text(
                                              '$scrapTotal',
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
                                              '스크랩',
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
                                                '/my/recruit?tab=${JobpostTapEnum.recentWatched.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                        ;
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            /*Image.asset(
                                          'assets/images/icon/iconRedClock.png',
                                          width: 20.w,
                                          height: 20.w,
                                        ),*/
                                            Text(
                                              '$postTotal',
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
                                              '최근본공고',
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
                                                '/my/enterprise?tab=${LikeHideTapEnum.likes.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                        ;
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$likeCompanyTotal',
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
                                              '관심기업',
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
                                                '/my/enterprise?tab=${LikeHideTapEnum.hides.tabIndex}')
                                            .then((_) {
                                          pushAfterFunc();
                                        });
                                        ;
                                      },
                                      child: ColoredBox(
                                        color: Colors.transparent,
                                        child: Column(
                                          children: [
                                            Text(
                                              '$blockCompanyTotal',
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: CommonColors.red),
                                            ),
                                            SizedBox(
                                              height: 8.w,
                                            ),
                                            Text(
                                              '차단기업',
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
                        SliverToBoxAdapter(
                          child: MoveButton(
                            onTap: () {
                              context.push('/my/certificate');
                            },
                            text: '취업활동증명서 발급',
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
                              context.push('/point').then((_) {
                                pushAfterFunc();
                              });
                            },
                            text: '활동 포인트 관리',
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 40.w, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: CommonButton(
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
                                      '친구 초대하기',
                                      style: TextStyles.commonButton(
                                          color: CommonColors.white,
                                          fontSize: 15),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        const FooterBottomPadding(),
                      ],
                    )
                  : const Loader()
              : SettingSeekerScreen(setSilver: widget.setSilver),
        ));
  }
}
