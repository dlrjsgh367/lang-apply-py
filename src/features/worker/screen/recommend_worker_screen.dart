import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/features/worker/widgets/recommend_seeker_swiper.dart';
import 'package:chodan_flutter_app/features/worker/widgets/recommend_seeker_theme_swiper.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/appbar/red_appbar.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_bottom_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendWorkerScreen extends ConsumerStatefulWidget {
  const RecommendWorkerScreen({super.key});

  @override
  ConsumerState<RecommendWorkerScreen> createState() =>
      _RecommendWorkerScreenState();
}

class _RecommendWorkerScreenState extends ConsumerState<RecommendWorkerScreen>
    with Alerts {
  int activeTab = 0;

  bool isLoading = true;

  bool isRunning = false;

  late Future<void> _allAsyncTasks;
  List<ProfileModel> workerList = [];

  Map<String, dynamic> currentPosition = MapService.currentPosition;

  List<ProfileModel> bottomWorkerList = [];

  void setTab(data) {
    setState(() {
      activeTab = data;
    });
  }

  getRecommendWorkerList() async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getRecommendWorkerList();
    if (result.status == 200) {
      if (result.type == 1) {
        workerList = result.data;
      }
    } else if (result.status != 200) {
      showDefaultToast('데이터 통신에 실패하였습니다.');
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
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

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getRecommendWorkerList(),
      getCurrentLocation(),
      getUserData(),
    ]);
  }

  getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    if (token != null) {
      ApiResultModel result =
          await ref.read(authControllerProvider.notifier).getUserData();
      if (result.type == 1) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
          ref.read(userAuthProvider.notifier).update((state) => result.data);
        });
      }
    }
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.recommendedWorker.type);
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RedAppbar(
        setTab: setTab,
        activeTab: activeTab,
        tabTitleArr: const ['AI 추천 인재'],
      ),
      bottomNavigationBar: const CommonBottomAppbar(
        type: 'recommend',
      ),
      body: !isLoading
          ? workerList.isNotEmpty
              ? CustomScrollView(
                  slivers: [
                    RecommendSeekerSwiper(
                        workerList: workerList,
                        currentPosition: currentPosition),
                  ],
                )
              : const CommonEmpty(text: '추천인재가 없습니다.')
          : const Loader(),
    );
  }
}
