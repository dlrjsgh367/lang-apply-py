import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/like_hide_tap_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/hides_company_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/likes_company_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyCompanyScreen extends ConsumerStatefulWidget {
  const MyCompanyScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<MyCompanyScreen> createState() => _MyCompanyScreenState();
}

class _MyCompanyScreenState extends ConsumerState<MyCompanyScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController tabController;

  ScrollController tabScrollController = ScrollController();

  int activeTab = 0;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<CompanyModel> companyList = [];

  List<LikeHideTapEnum> companyTapState = [
    LikeHideTapEnum.likes,
    LikeHideTapEnum.hides,
  ];

  bool isRunning = false;

  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    if (activeTab == 0) {
      await Future.wait<void>([
        // readAllAlarm(ref),
        getCompanyLikesListData(page),
        getCompanyHidesKeyList(),
      ]);
    } else {
      await Future.wait<void>([
        // readAllAlarm(ref),
        getCompanyHidesListData(page),
        getCompanyHidesKeyList(),
      ]);
    }
  }

  getCompanyLikesListData(int page) async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getCompanyLikesListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<CompanyModel> data = result.data;
        if (page == 1) {
          companyList = [...data];
        } else {
          companyList = [...companyList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
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
  getCompanyHidesListData(int page) async {
    ApiResultModel result = await ref
        .read(mypageControllerProvider.notifier)
        .getCompanyHidesListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<CompanyModel> data = result.data;
        if (page == 1) {
          companyList = [...data];
        } else {
          companyList = [...companyList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    savePageLog();

    tabController = TabController(length: 2, vsync: this);
    if (widget.tab != null) {
      activeTab = int.parse(widget.tab!);
    }
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  setTab(data) {
    activeTab = data;
    page = 1;
    if (activeTab == 0) {
      getCompanyLikesListData(page);
    } else {
      getCompanyHidesListData(page);

    }
  }

  addHidesCompany(int idx) async {
    var result =
        await ref.read(companyControllerProvider.notifier).addHidesCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterHidesFunc(idx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  deleteHidesCompany(int mcIdx) async {
    var result = await ref
        .read(companyControllerProvider.notifier)
        .deleteHidesCompany(mcIdx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterHidesFunc(mcIdx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  addLikesCompany(int idx) async {
    var result =
        await ref.read(companyControllerProvider.notifier).addLikesCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
        return result.data;
      }
    } else {
      if (result.type == -2801) {
        showDefaultToast(localization.alreadyRegisteredFavoriteCompany);
      }
    }
  }

  deleteLikesCompany(int idx) async {
    var result = await ref
        .read(companyControllerProvider.notifier)
        .deleteLikesCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  toggleLikeCompany(List list, int companyKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(companyKey)) {
      await deleteLikesCompany(companyKey);
    } else {
      await addLikesCompany(companyKey);
    }
    isRunning = false;
  }

  toggleHideCompany(List list, int idx) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(idx)) {
      await deleteHidesCompany(idx);
    } else {
      await addHidesCompany(idx);
    }
    isRunning = false;
  }

  likeAfterHidesFunc(int key) {
    List<int> hideList = ref.read(companyHidesKeyListProvider);
    if (hideList.contains(key)) {
      hideList.remove(key);
      showDefaultToast(localization.removedFromBlockedCompanies);
    } else {
      hideList.add(key);
      showDefaultToast(localization.addedToBlockedCompanies);
    }
    setState(() {
      ref
          .read(companyHidesKeyListProvider.notifier)
          .update((state) => hideList);
    });
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(companyLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.removedFromFavoriteCompanies);
    } else {
      likeList.add(key);
      showDefaultToast(localization.addedToFavoriteCompanies);
    }
    setState(() {
      ref
          .read(companyLikesKeyListProvider.notifier)
          .update((state) => [...likeList]);
    });
  }

  _loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        if (activeTab == 0) {
          getCompanyLikesListData(page);
        } else {
          getCompanyHidesListData(page);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.favoriteOrBlockedCompanies,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
            child: CommonTab(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: const [localization.favoriteCompanies, localization.blockedCompanies],
            ),
          ),
          Expanded(
            child: companyList.isEmpty
                ? CommonEmpty(
                    text: activeTab == 0 ? '관심 기업이 없습니다.' : '차단 기업이 없습니다.')
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      LazyLoadScrollView(
                        onEndOfPage: () => _loadMore(),
                        child: activeTab == 0
                            ? CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        childCount: companyList.length,
                                        (context, index) {
                                          CompanyModel companyItem =
                                              companyList[index];
                                          return LikesCompanyWidget(
                                              toggleLikeCompany:
                                                  toggleLikeCompany,
                                              companyItem: companyItem);
                                        },
                                      ),
                                    ),
                                  ),
                                  const BottomPadding(),
                                ],
                              )
                            : CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding:
                                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        childCount: companyList.length,
                                        (context, index) {
                                          CompanyModel companyItem =
                                              companyList[index];
                                          return HidesCompanyWidget(
                                              // addHidesCompany : addHidesCompany,
                                              // deleteHidesCompany : deleteHidesCompany,
                                              toggleHideCompany:
                                                  toggleHideCompany,
                                              companyItem: companyItem);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      if (isLazeLoading)
                        Positioned(
                            bottom: CommonSize.commonBottom,
                            child: const Loader())
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
