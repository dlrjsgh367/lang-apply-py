import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/home/widgets/alba_list.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/features/user/controller/user_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyRecruitScreen extends ConsumerStatefulWidget {
  const MyRecruitScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<MyRecruitScreen> createState() => _MyRecruitScreenState();
}

class _MyRecruitScreenState extends ConsumerState<MyRecruitScreen>
    with SingleTickerProviderStateMixin, Alerts {
  bool isLoading = true;
  late TabController tabController;

  ScrollController tabScrollController = ScrollController();

  int activeTab = 0;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<JobpostModel> jobpostList = [];

  Map<String, dynamic> currentPosition = MapService.currentPosition;

  bool isRunning = false;

  List<ProfileModel> userProfileList = [];

  late Future<void> _allAsyncTasks;

  getScrappedJobposting(int page) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getScrappedJobpost(page);
    if (result.status == 200) {
      if (result.type == 1) {
        bool isExistJobPostList = jobpostList.isEmpty;
        List<JobpostModel> data = result.data;

        if (page == 1) {
          jobpostList = [...data];
        } else {
          jobpostList = [...jobpostList, ...data];
        }

        if (isExistJobPostList && data.isNotEmpty) {
          await Future.wait<void>([
            getCurrentLocation(),
            getProfileList(),
            getUserClipAnnouncementList()
          ]);
        }

        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    }
  }

  getCurrentLocation() async {
    UserModel? userInfo = ref.read(userProvider);
    LocationService? locationService;
    if (userInfo != null) {
      locationService = LocationService(user: userInfo);
    } else {
      locationService = LocationService(user: userInfo);
    }
    Position? location = await locationService.returnCurrentLocation();
    if (location != null) {
      setState(() {
        currentPosition['lat'] = location.latitude;
        currentPosition['lng'] = location.longitude;
      });
    }
  }

  getLatestJobposting(int page) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getLatestJobpost(page);
    if (result.status == 200) {
      if (result.type == 1) {
        bool isExistJobPostList = jobpostList.isEmpty;
        List<JobpostModel> data = result.data;

        if (page == 1) {
          jobpostList = [...data];
        } else {
          jobpostList = [...jobpostList, ...data];
        }

        ref.read(lastJobpostProvider.notifier).update((state) => jobpostList);

        if (isExistJobPostList && data.isNotEmpty) {
          await Future.wait<void>([
            getCurrentLocation(),
            getProfileList(),
            getUserClipAnnouncementList()
          ]);
        }

        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    if (activeTab == 0) {
      await Future.wait<void>([
        getScrappedJobposting(page),
      ]);
    } else {
      await Future.wait<void>([
        getLatestJobposting(page),
      ]);
    }
  }

  getUserClipAnnouncementList() async {
    ApiResultModel result = await ref
        .read(userControllerProvider.notifier)
        .getUserClipAnnouncementList();
    if (result.type == 1) {
      setState(() {
        ref.read(userClipAnnouncementListProvider.notifier).update((state) => result.data);
      });
    }
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
          userProfileList = [...result.data];
        }
      }
    }
  }

  void addScrappedJobposting(int idx) async {
    var result = await ref
        .read(jobpostingControllerProvider.notifier)
        .addScrappedJobposting(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterScrapFunc(idx);
      }
    } else {
      showDefaultToast('데이터 통신에 실패하였습니다.');
    }
  }

  void deleteScrappedCompany(int idx) async {
    var result = await ref
        .read(jobpostingControllerProvider.notifier)
        .deleteScrappedCompany(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterScrapFunc(idx);
      }
    } else {
      showDefaultToast('데이터 통신에 실패하였습니다.');
    }
  }

  likeAfterScrapFunc(int key) {
    List likeList = ref.read(userClipAnnouncementListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast('스크랩공고에서 삭제했어요!');
    } else {
      likeList.add(key);
      showDefaultToast('스크랩공고로 저장했어요!');
    }
    setState(() {
      ref
          .read(userClipAnnouncementListProvider.notifier)
          .update((state) => [...likeList]);
    });
  }

  @override
  void initState() {
    super.initState();
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
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  setTab(data) {
    activeTab = data;
    page = 1;
    if (activeTab == 0) {
      getScrappedJobposting(page);
    } else {
      getLatestJobposting(page);
    }
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
          getScrappedJobposting(page);
        } else {
          getLatestJobposting(page);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var lastPostList = ref.watch(lastJobpostProvider);

    return Scaffold(
      appBar: const CommonAppbar(
        title: '스크랩/최근 본 공고',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
            child: CommonTab(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: const ['스크랩 공고', '최근 본 공고'],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Loader()
                : jobpostList.isEmpty
                    ? CommonEmpty(
                        text: activeTab == 0
                            ? '스크랩한 공고가 없습니다.'
                            : '촤근 본 공고가 없습니다.')
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          LazyLoadScrollView(
                            onEndOfPage: () => _loadMore(),
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding:
                                      EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      childCount: activeTab == 1
                                          ? lastPostList.length
                                          : jobpostList.length,
                                      (context, index) {
                                        JobpostModel jobpostItem =
                                            activeTab == 1
                                                ? lastPostList[index]
                                                : jobpostList[index];
                                        return AlbaList(
                                          jobpostItem: jobpostItem,
                                          jobList: jobpostItem.jobList,
                                          currentPosition: currentPosition,
                                          getProfile: getProfileList,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const BottomPadding(),
                              ],
                            ),
                          ),
                          if (isLazeLoading)
                            Positioned(
                                bottom: CommonSize.commonBottom,
                                child: const Loader()),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
