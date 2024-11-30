import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/home/widgets/alba_list.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_sliver_filter_widget.dart';
import 'package:chodan_flutter_app/features/theme/controller/theme_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class RecommendThemeSilverScreen extends ConsumerStatefulWidget {
  const RecommendThemeSilverScreen({super.key});



  @override
  ConsumerState<RecommendThemeSilverScreen> createState() =>
      _RecommendThemeSilverScreenState();
}

class _RecommendThemeSilverScreenState extends ConsumerState<RecommendThemeSilverScreen> {
  int key = 0;
  bool isLoader = true;
  bool setTotal = false;
  int page = 1;
  int lastPage = 1;
  int total = 0;
  bool isLazeLoading = false;
  List jobpostingList = [];
  Map<String, dynamic> currentPosition = MapService.currentPosition;
  List<ProfileModel> userProfileList = [];
  bool openedFilter = false;
  Map<String, dynamic> filterParam = {};

  @override
  void initState() {
    super.initState();
    Future(() async {
      setState(() {
        isLoader = true;
      });
      await Future.wait<void>([
        savePageLog(),
        getMiddleAgeJobPosting(page, filterParam),
        getProfileList(),
      ]);
      setState(() {
        isLoader = false;
      });
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.theme.type);
  }


  getMiddleAgeJobPosting(int page, Map<String, dynamic> params) async {
    params['paging'] = true;
    params['page'] = page;
    params['size'] = 20;
    params['jpMiddleAge'] =1;
    var beforeTotal = total;
    ApiResultModel result = await ref
        .read(themeControllerProvider.notifier)
        .getMiddleAgeJobPosting(params, key);

    if (result.type == 1) {

      if (page == 1) {
        jobpostingList = [...result.data];
      } else {
        jobpostingList = [...jobpostingList, ...result.data];
      }
      setState(() {
        lastPage = result.page['lastPage'];
        total = result.page['total'];
        isLazeLoading = false;
        if(beforeTotal == 0) {
          setTotal = true;
        }
      });
    } else {
      if (!mounted) return null;
      showErrorAlert();
    }
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getMiddleAgeJobPosting(page, filterParam);
      });
    }
  }

  showErrorAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notice,
            alertContent: localization.dataCommunicationFailed,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
              context.pop();
            },
          );
        });
  }


  getProfileList() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getProfileList(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          int filteredIndex = result.data
              .indexOf((ProfileModel element) => element.mainProfile == 1);
          if (filteredIndex != -1) {
            ProfileModel data = result.data.removeAt(filteredIndex);
            result.data.insert(0, data);
          }
          setState(() {
            userProfileList = [...result.data];
          });
        }
      }
    }
  }

  changeFilter() {
    setState(() {
      openedFilter = !openedFilter;
    });
  }

  addFilterParam(List<Map<String, dynamic>> data) {
    for (Map<String, dynamic> item in data) {
      for (var key in item.keys) {
        filterParam[key] = item[key];
      }
    }
    page = 1;
    getMiddleAgeJobPosting(page, filterParam);
  }

  removeFilterParam(List<String> data) {
    for (String key in data) {
      filterParam.remove(key);
    }
    page = 1;
    getMiddleAgeJobPosting(page, filterParam);
  }

  @override
  Widget build(BuildContext context) {
    return isLoader
        ? Container(
            color: Colors.white,
            child: const Loader(),
          )
        : Scaffold(
            appBar: const CommonAppbar(
              title: localization.seniorThemeSection,
            ),
            body: LazyLoadScrollView(
              onEndOfPage: () => _loadMore(),
              child: CustomScrollView(
                slivers: [
                  if(setTotal)
                    SliverPersistentHeader(
                      delegate: ThemeFilter(
                          widget: RecommendSilverFilterWidget(
                              addFilterParam: addFilterParam,
                              removeFilterParam: removeFilterParam,
                              totalCount: total,
                              openedFilter: openedFilter,
                              changeFilter: (){
                                changeFilter();
                              }),
                          openedFilter: openedFilter,
                        total:total
                      ),
                      pinned: true,
                    ),
                  jobpostingList.isEmpty
                      ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250.w,
                      child: const CommonEmpty(text: localization.jobPostDoesNotExist),
                    ),
                  )
                      : DecoratedSliver(
                          decoration: BoxDecoration(
                            color: CommonColors.grayF7,
                          ),
                          sliver: SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                                20.w, 2.w, 20.w, CommonSize.commonBottom),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: jobpostingList.length,
                                (context, index) {
                                  var jobpostItem = jobpostingList[index];
                                  return AlbaList(
                                    jobpostItem: jobpostItem,
                                    jobList: jobpostItem.workInfo.jobList,
                                    getProfile: getProfileList,
                                    currentPosition: currentPosition,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ));
  }
}

class ThemeFilter extends SliverPersistentHeaderDelegate {
  Widget widget;
  bool openedFilter;
  int total;

  ThemeFilter({required this.widget, required this.openedFilter,required this.total});

  @override
  double get minExtent => openedFilter ? 82.w : 48.w; // 최소 높이

  @override
  double get maxExtent => openedFilter ? 82.w : 48.w;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    if (oldDelegate is ThemeFilter) {
      return oldDelegate.openedFilter != openedFilter ||
          oldDelegate.total != total ||
          oldDelegate.widget != widget;
    }
    return true;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Align(
      child: Container(
        height:openedFilter?82.w: 48.w,
        padding: EdgeInsets.fromLTRB(0.w, 0.w, 0.w, 0.w),
        color:  CommonColors.white,
        width: double.infinity,
        child: widget,
      ),
    );
  }
}
