import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_hides_widget.dart';
import 'package:chodan_flutter_app/features/worker/widgets/worker_likes_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyWorkerScreen extends ConsumerStatefulWidget {
  const MyWorkerScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<MyWorkerScreen> createState() => _MyWorkerBlockScreenState();
}

class _MyWorkerBlockScreenState extends ConsumerState<MyWorkerScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController tabController;

  ScrollController tabScrollController = ScrollController();
  int activeTab = 0;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  List<ProfileModel> workerList = [];

  bool isRunning = false;

  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    if (activeTab == 0) {
      await Future.wait<void>([
        getWorkerLikesKeyList(),
        getWorkerLikesListData(page),
      ]);
    } else {
      await Future.wait<void>([
        getWorkerHidesKeyList(),
        getWorkerHidesListData(page),
      ]);
    }

    savePageLog();
  }
  getWorkerHidesKeyList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerHidesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref
              .read(workerHidesKeyListProvider.notifier)
              .update((state) => [...result.data]);
        });
      }
    }
  }

  getWorkerLikesKeyList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerLikesKeyList();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref
              .read(workerLikesKeyListProvider.notifier)
              .update((state) => [...result.data]);
        });
      }
    }
  }
  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  setTab(data) {
    activeTab = data;
    page = 1;
    if (activeTab == 0) {
      getWorkerLikesListData(page);
    } else {
      getWorkerHidesListData(page);
    }
  }

  getWorkerLikesListData(int page) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getWorkerLikesListData(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> data = result.data;
        if (page == 1) {
          workerList = [...data];
        } else {
          workerList = [...workerList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
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
        List<ProfileModel> data = result.data;
        if (page == 1) {
          workerList = [...data];
        } else {
          workerList = [...workerList, ...data];
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

  addHidesWorker(int idx) async {
    var result =
    await ref.read(workerControllerProvider.notifier).addHidesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterHidesFunc(idx);
      }
    } else {
      showDefaultToast(localization.failedToAddBlockedCandidate);
    }
  }

  deleteHidesWorker(int idx) async {
    var result = await ref
        .read(workerControllerProvider.notifier)
        .deleteHidesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterHidesFunc(idx);
      }
    } else {
      showDefaultToast(localization.failedToRemoveBlockedCandidate);
    }
  }

  addLikesWorker(int idx) async {
    var result =
    await ref.read(workerControllerProvider.notifier).addLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
        return result.data;
      }
    } else {
      if (result.type == -2801) {
        showDefaultToast(localization.alreadyRegisteredFavoriteCandidate);
      }
    }
  }

  deleteLikesWorker(int idx) async {
    var result = await ref
        .read(workerControllerProvider.notifier)
        .deleteLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      showDefaultToast(localization.failedToRemoveFavoriteCandidate);
    }
  }

  toggleLikesWorker(List list, int profileKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(profileKey)) {
      await deleteLikesWorker(profileKey);
    } else {
      await addLikesWorker(profileKey);
    }
    isRunning = false;
  }

  toggleHidesWorker(List list, int profileKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    if (list.contains(profileKey)) {
      await deleteHidesWorker(profileKey);
    } else {
      await addHidesWorker(profileKey);
    }
    isRunning = false;
  }

  likeAfterHidesFunc(int key) {
    List hideList = ref.read(workerHidesKeyListProvider);
    if (hideList.contains(key)) {
      hideList.remove(key);
      showDefaultToast(localization.removedFromBlockedCandidates);
    } else {
      hideList.add(key);
      showDefaultToast(localization.savedToBlockedCandidates);
    }
    setState(() {
      ref
          .read(workerHidesKeyListProvider.notifier)
          .update((state) => [...hideList]);
    });
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(workerLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.removedFromFavoriteCandidates);
    } else {
      likeList.add(key);
      showDefaultToast(localization.savedToFavoriteCandidates);
    }
    setState(() {
      ref
          .read(workerLikesKeyListProvider.notifier)
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
          getWorkerLikesListData(page);
        } else {
          getWorkerHidesListData(page);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.favoriteOrBlockedCandidates,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
            child: CommonTab(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: const [localization.favoriteCandidate, localization.blockedCandidate],
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                !isLoading
                    ? workerList.isNotEmpty
                    ? LazyLoadScrollView(
                  onEndOfPage: () => _loadMore(),
                  child: CustomScrollView(
                    slivers: [
                      if (activeTab == 0)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: workerList.length,
                                (context, index) {
                              ProfileModel workerItem =
                              workerList[index];
                              return WorkerLikesWidget(
                                  toggleLikesWorker:
                                  toggleLikesWorker,
                                  workerItem: workerItem,
                                  index: index);
                            },
                          ),
                        ),
                      if (activeTab == 1)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: workerList.length,
                                (context, index) {
                              ProfileModel workerItem =
                              workerList[index];
                              return WorkerHidesWidget(
                                toggleHidesWorker: toggleHidesWorker,
                                workerItem: workerItem,
                                index: index,
                              );
                            },
                          ),
                        ),
                      const BottomPadding(),
                    ],
                  ),
                )
                    : CommonEmpty(
                    text: activeTab == 0 ? '관심인재가 없습니다.' : '차단인재가 없습니다.')
                    : const Loader(),
                if (isLazeLoading)
                  Positioned(
                    bottom: CommonSize.commonBottom,
                    child: Loader(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
