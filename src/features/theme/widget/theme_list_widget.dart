import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/banner/service/banner_service.dart';
import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_banner_half_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_banner_inner_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_banner_outter_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_thum_half_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_thum_inner_widget.dart';
import 'package:chodan_flutter_app/features/theme/widget/theme_thum_outter_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/red_back.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeListWidget extends ConsumerStatefulWidget {
  const ThemeListWidget({super.key});

  @override
  ConsumerState<ThemeListWidget> createState() => _ThemeListWidgetState();
}

class _ThemeListWidgetState extends ConsumerState<ThemeListWidget> {
  int type = 0;
  List themeList = [];
  bool isLoader = false;
  bool isLazeLoading = false;
  int page = 1;
  int lastPage = 1;
  List themeSettingList = [];

  bool silver = false;

  @override
  void initState() {
    super.initState();
    Future(() {
      setState(() {
        isLoader = true;
      });
      initSilver();
      getTheme(page);
    });
  }

  initSilver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (prefs.getString('silver') == 'true') {
        silver = true;
      } else {
        silver = false;
      }
    });
  }

  getTheme(int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 5,
    };
    ApiResultModel result =
        await ref.read(themeControllerProvider.notifier).getTheme(params);

    if (result.type == 1) {
      await getthemeSettingList(result.data);

      if (page == 1) {
        themeList = [...result.data];
      } else {
        themeList = [...themeList, ...result.data];
      }
      lastPage = result.page['lastPage'];
      isLazeLoading = false;
      setState(() {
        isLoader = false;
      });
    } else {
      setState(() {
        isLoader = false;
      });
      if (!mounted) return null;
      showErrorAlert();
    }
  }

  getthemeSettingList(List list) async {
    for (int i = 0; i < list.length; i++) {
      String type = list[i].displayCategory == 1 ? 'theme' : 'banner';

      Map<String, dynamic> params = {
        "paging": false,
        "props": "seq",
        "dirs": "asc",
      };
      ApiResultModel result = await ref
          .read(themeControllerProvider.notifier)
          .getthemeSettingList(params, list[i].key, type);

      if (result.status == 200) {
        themeSettingList.add(result.data);
      } else {
        if (!mounted) return null;
        showErrorAlert();
      }
    }
  }

  showErrorAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.guide,
            alertContent: localization.dataCommunicationFailed,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
              context.pop();
            },
          );
        });
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getTheme(page);
      });
    }
  }

  String returnThemeType(ThemeModel data) {
    String type = '';
    if (data.orderType == 1) {
      type = 'DoubleCole';
    } else if (data.orderType == 2) {
      type = 'OneCole';
    } else if (data.orderType == 3) {
      type = 'OneHalfRow';
    } else if (data.orderType == 4) {
      type = 'OneRow';
    } else if (data.orderType == 5) {
      type = 'DoubleHalfRow';
    } else if (data.orderType == 6) {
      type = 'DoubleRow';
    }
    return type;
  }
  moveUrl(ThemeSettingModel data) async {
    UserModel? userInfo = ref.watch(userProvider);
    BannerService bannerService = BannerService(user: userInfo);
    bannerService.moveUrl(context, ref, data);
  }

  @override
  Widget build(BuildContext context) {
    return isLoader
        ? const Loader()
        : themeList.isEmpty
            ? const CommonEmpty(text: localization.746)
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  const RedBack(
                    extraHeight: 80,
                  ),
                  themeSettingList.isEmpty
                      ? const CommonEmpty(text: localization.noListAvailable)
                      : Container(
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20.w),
                              topRight: Radius.circular(20.w),
                            ),
                          ),
                          child: LazyLoadScrollView(
                            onEndOfPage: () => _loadMore(),
                            child: CustomScrollView(
                              slivers: [
                                if (silver)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          12.w, 20.w, 12.w, 20.w),
                                      child: GestureDetector(
                                        onTap: () {
                                          context.push('/recommend/theme/silver');
                                        },
                                        child: Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 4 / 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.w),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      offset: Offset(0, 2.w),
                                                      blurRadius: 16.w,
                                                      color:
                                                          const Color.fromRGBO(
                                                              0, 0, 0, 0.06),
                                                    ),
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  'assets/images/default/imgSilver.jpg',
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 16.w,
                                              left: 20.w,
                                              child: Text(
                                                localization.748,
                                                style: TextStyle(
                                                  fontSize: 24.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                        childCount: themeList.length,
                                        (context, index) {
                                  ThemeModel themeData = themeList[index];
                                  List settingList = themeSettingList[index];
                                  return CustomScrollView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      slivers: [
                                        if (themeData.displayCategory == 1 &&
                                            themeData.viewType == 1)
                                          ThemeThumOutterWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              themeSettingList: settingList),
                                        if (themeData.displayCategory == 1 &&
                                            themeData.viewType == 2)
                                          ThemeThumInnerWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              themeSettingList: settingList),
                                        if (themeData.displayCategory == 1 &&
                                            themeData.viewType == 3)
                                          ThemeThumHalfWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              themeSettingList: settingList),
                                        if (themeData.displayCategory == 2 &&
                                            themeData.viewType == 1)
                                          ThemeBannerOutterWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              moveUrl:moveUrl,
                                              themeSettingList: settingList),
                                        if (themeData.displayCategory == 2 &&
                                            themeData.viewType == 2)
                                          ThemeBannerInnerWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              moveUrl:moveUrl,
                                              themeSettingList: settingList),
                                        if (themeData.displayCategory == 2 &&
                                            themeData.viewType == 3)
                                          ThemeBannerHalfWidget(
                                              type: returnThemeType(themeData),
                                              themeData: themeData,
                                              moveUrl:moveUrl,
                                              themeSettingList: settingList),
                                      ]);
                                })),
                                const FooterBottomPadding(),
                              ],
                            ),
                          ),
                        ),
                ],
              );
  }
}
