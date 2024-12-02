import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/features/premium/screens/premium_area_top_screen.dart';
import 'package:chodan_flutter_app/features/premium/screens/premium_match_screen.dart';
import 'package:chodan_flutter_app/features/premium/widgets/premium_swiper.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/preminm_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  late Future<void> _allAsyncTasks;

  bool isLoading = true;

  List<PremiumModel> premiumServiceList = [];

  PremiumModel? matchData;

  PremiumModel? areaTopData;

  PremiumModel? companyThemeData;

  getPremiumServiceList() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumServiceList();
    if (result.status == 200) {
      if (result.type == 1) {
        premiumServiceList = [...result.data];
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getPremiumServiceMatch(),
      getPremiumServiceAreaTop(),
      getPremiumServiceCompanyTheme()
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  @override
  void initState() {
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          setState(() {
            isLoading = false;
          });
        });
      }
    });
    super.initState();
  }

  showPremiumMatchSAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PremiumMatchScreen();
      },
    );
  }

  showPremiumAreaTopAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PremiumAreaTopScreen();
      },
    );
  }

  getPremiumServiceMatch() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(PremiumServiceEnum.match.code);
    if (result.status == 200) {
      if (result.type == 1) {
        matchData = result.data;
      }
    }
  }

  getPremiumServiceAreaTop() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(PremiumServiceEnum.areaTop.code);
    if (result.status == 200) {
      if (result.type == 1) {
        areaTopData = result.data;
      }
    }
  }

  getPremiumServiceCompanyTheme() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(PremiumServiceEnum.theme.code);
    if (result.status == 200) {
      if (result.type == 1) {
        companyThemeData = result.data;
      }
    }
  }

  showInfo(String title, String content, String imgUrl){
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      enableDrag: false,
      builder: (BuildContext context) {
        return PremiumBottomSheet(
          title: title,
          content: content,
          imgUrl: imgUrl,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xfffff8eb),
                  CommonColors.white,
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const CommonAppbar(
            backColor: Colors.transparent,
            title: '프리미엄 서비스',
          ),
          body: Stack(
            children: [
              !isLoading
                  ? CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(
                          child: PremiumSwiper(),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16.w, 14.w, 16.w, 4.w),
                          sliver: SliverToBoxAdapter(
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                height: 56.w,
                                padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '서비스 목록',
                                        style: TextStyle(
                                            color: CommonColors.black2b,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        context.push('/my/premium/history');
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            '나의 신청 내역',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray66,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            width: 4.w,
                                          ),
                                          Image.asset(
                                            'assets/images/icon/iconArrowRightThin.png',
                                            width: 20.w,
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16.w, 0.w, 16.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '미친매칭',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          showInfo(
                                              matchData!.name,
                                                  matchData!.content,
                                                  matchData!.files[0].url
                                          );
                                        },
                                        child:  Image.asset(
                                          'assets/images/icon/iconQuestionInner.png',
                                          width: 20.w,
                                        ),
                                      ),

                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Text(
                                    '채용공고 등록&인재검색 및 추천을 모두 대신 하는 미친듯 편한 인재 매칭!',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                  Text(
                                    '이제 초저가로 HR컨설팅을 경험하세요.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CommonButton(
                                          width: 116,
                                          onPressed: () {
                                            showPremiumMatchSAlert();
                                          },
                                          height: 32,
                                          text: '신청 바로가기',
                                          confirm: true)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16.w, 0.w, 16.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                              decoration: BoxDecoration(
                                color: CommonColors.white,
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '지역별 상위 노출',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          showInfo(
                                            areaTopData!.name,
                                            areaTopData!.content,
                                              areaTopData!.files[0].url
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/icon/iconQuestionInner.png',
                                          width: 20.w,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Text(
                                    '지역별 채용공고목록 상단에 회원님의 공고를 배치해서',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                  Text(
                                    '더 많은 구직자에게 채용 공고를 노출하고 관심을 높이세요.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CommonButton(
                                          width: 116,
                                          onPressed: () {
                                            showPremiumAreaTopAlert();
                                          },
                                          height: 32,
                                          text: '신청 바로가기',
                                          confirm: true)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16.w, 0.w, 16.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                              decoration: BoxDecoration(
                                color: CommonColors.white,
                                borderRadius: BorderRadius.circular(12.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '브랜드 테마관',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (){
                                          showInfo(
                                              companyThemeData!.name,
                                              companyThemeData!.content,
                                              companyThemeData!.files[0].url
                                          );
                                        },
                                        child: Image.asset(
                                          'assets/images/icon/iconQuestionInner.png',
                                          width: 20.w,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Text(
                                    '앱 내 배너링크 제공! 기업정보 및 채용소식을 웹진처럼 제공하는 스페셜 채용관 페이지 생성!',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                  Text(
                                    '지금 즉시 문의 주세요.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CommonButton(
                                          width: 116,
                                          onPressed: () {
                                            context.push('/my/theme/create');
                                          },
                                          height: 32,
                                          text: '신청 바로가기',
                                          confirm: true)
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const BottomPadding(),
                      ],
                    )
                  : const Loader()
            ],
          ),
        ),
      ],
    );
  }
}
