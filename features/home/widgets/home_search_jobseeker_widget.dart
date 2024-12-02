import 'dart:math';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/banner_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/search_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/search_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeSearchJobseekerWidget extends ConsumerStatefulWidget {
  const HomeSearchJobseekerWidget(
      {required this.searchFunc,
      this.searchKeyword,
      required this.searchPlaceHolder,
      required this.resetJobPost,
      super.key});

  final Function searchFunc;
  final String? searchKeyword;
  final String searchPlaceHolder;
  final Function resetJobPost;

  @override
  ConsumerState<HomeSearchJobseekerWidget> createState() =>
      _HomeSearchJobseekerWidgetState();
}

class _HomeSearchJobseekerWidgetState
    extends ConsumerState<HomeSearchJobseekerWidget> {
  List<SearchModel> searchList = [];
  bool isActive = false;

  bool isLoading = true;

  getSearchHistory() async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getSearchHistory(generateUniqueString());
    if (result.type == 1) {
      setState(() {
        List<SearchModel> data = result.data;
        searchList = [...data];
        isActive = false;
      });
    }
  }

  deleteSearchHistory(idx) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .deleteSearchHistory(idx);
    if (result.type == 1) {
      getSearchHistory();
    }
  }

  String generateRandomString(int length) {
    const charset =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String generateUniqueString() {
    final randomString = generateRandomString(6);
    final now = DateTime.now();
    final formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return '$randomString-$formattedDate';
  }

  Future<ApiResultModel> addSearchHistory(text) async {
    UserModel? userInfo = ref.watch(userProvider);

    if (userInfo == null) {
      return await ref
          .read(applyControllerProvider.notifier)
          .addSearchHistory(text, generateUniqueString());
    } else {
      return await ref
          .read(applyControllerProvider.notifier)
          .addSearchHistory(text, null);
    }
  }

  String filterHangul(String input) {
    // 한글 초성과 모음에 대한 정규 표현식
    RegExp hangulPattern = RegExp(r'[ㄱ-ㅎㅏ-ㅣㆍᆞᆢ]+');

    // 입력된 문자열에서 한글 초성과 모음을 제외한 나머지 문자를 모두 제거
    String filteredString = input.replaceAll(hangulPattern, '');

    return filteredString;
  }

  searchFunc(String text) async {
    String data = text.trim();
    if (data != '') {
      if (ValidateService.isValidSingleKorean(data)) {
        await addSearchHistory(data);
      }
    }
    widget.searchFunc(data);
    isActive = false;
  }

  @override
  void initState() {
    Future(() {
      UserModel? userInfo = ref.read(userProvider);

      savePageLog();
      getSearchHistory();
    }).then((_) {
      isLoading = false;
    });
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.jobPosting.type);
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

  @override
  Widget build(BuildContext context) {
    List<BannerModel> menuBannerList = ref.watch(menuBannerListProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            context.pop();
          }
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            context.pop();
          }
        },
        child: Scaffold(
          appBar: SearchAppbar(
            afterFunc: (String keyword) {
              searchFunc(keyword);
              savePageLog();
            },
            searchValue: widget.searchKeyword,
            searchPlaceHolder: widget.searchPlaceHolder,
            isPop: true,
            hasSingleValidate: false,
            resetJobPost: widget.resetJobPost,
          ),
          body: isLoading
              ? const Loader()
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.only(bottom: 16.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: CommonColors.grayD9,
                              ),
                            ),
                          ),
                          child: Text(
                            '최근검색어',
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.black2b,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 0),
                        child: Row(
                          children: [
                            for (int i = 0; i < searchList.length; i++)
                              GestureDetector(
                                onTap: () {
                                  if (!isActive) {
                                    isActive = true;
                                    searchFunc(searchList[i].word);
                                    savePageLog();
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
                                  height: 28.w,
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      width: 1.w,
                                      color: CommonColors.red02,
                                    ),
                                    borderRadius: BorderRadius.circular(100.w),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        searchList[i].word,
                                        style: TextStyle(
                                          fontSize: 14.w,
                                          color: CommonColors.red,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          if (!isActive) {
                                            isActive = true;
                                            deleteSearchHistory(
                                                searchList[i].key);
                                          }
                                        },
                                        child: Image.asset(
                                          'assets/images/icon/iconX.png',
                                          width: 12.w,
                                          height: 12.w,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (menuBannerList.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 8.w, top: 48.w),
                        sliver: SliverToBoxAdapter(
                          child: BannerMenuSwiperWidget(
                              bannerList: menuBannerList),
                        ),
                      ),
                    const BottomPadding(),
                  ],
                ),
        ),
      ),
    );
  }
}
