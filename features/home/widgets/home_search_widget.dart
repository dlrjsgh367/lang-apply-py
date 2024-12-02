import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/banner/controller/banner_controller.dart';
import 'package:chodan_flutter_app/features/banner/widgets/banner_menu_swiper_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:chodan_flutter_app/models/search_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/search_appbar.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSearchWidget extends ConsumerStatefulWidget {
  const HomeSearchWidget(
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
  ConsumerState<HomeSearchWidget> createState() => _HomeSearchWidgetState();
}

class _HomeSearchWidgetState extends ConsumerState<HomeSearchWidget> {
  List<SearchModel> searchList = [];

  bool isActive = false;

  bool isLoading = true;

  getSearchHistory() async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).getSearchHistory(null);
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

  Future<ApiResultModel> addSearchHistory(text) async {
    return await ref
        .read(applyControllerProvider.notifier)
        .addSearchHistory(text, null);
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
      getSearchHistory();
    }).then((_) {
      isLoading = false;
    });
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.worker.type);
  }

  @override
  Widget build(BuildContext context) {
    List<BannerModel> bannerList = ref.watch(menuBannerListProvider);
    return Scaffold(
      appBar: SearchAppbar(
        afterFunc: (String keyword) {
          searchFunc(keyword);
          savePageLog();
        },
        searchValue: widget.searchKeyword,
        searchPlaceHolder: widget.searchPlaceHolder,
        isPop: true,
        hasSingleValidate: true,
        resetJobPost: widget.resetJobPost,
      ),
      body: CustomScrollView(
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
                  localization.recentSearches,
                  style: TextStyle(
                      fontSize: 14.sp,
                      color: CommonColors.black2b,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          if (!isLoading)
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
                                    deleteSearchHistory(searchList[i].key);
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
            )
          else
            const SliverToBoxAdapter(child: Loader()),
          if (bannerList.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.only(bottom: 8.w, top: 48.w),
              sliver: SliverToBoxAdapter(
                child: BannerMenuSwiperWidget(bannerList: bannerList),
              ),
            ),
          const BottomPadding(),
        ],
      ),
    );
  }
}
