import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/recommend/controller/recommend_controller.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_swiper.dart';
import 'package:chodan_flutter_app/features/recommend/widgets/recommend_theme_swiper.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

class RecommendTodayWidget extends ConsumerStatefulWidget {
  const RecommendTodayWidget(
      {super.key, required this.scrapJobseeker, required this.applyJobposting});

  final Function scrapJobseeker;
  final Function applyJobposting;

  @override
  ConsumerState<RecommendTodayWidget> createState() =>
      _RecommendTodayWidgetState();
}

class _RecommendTodayWidgetState extends ConsumerState<RecommendTodayWidget> {
  List recommendList = [];
  List recommendBannerList = [];
  List dayList = [];
  Map<String, dynamic> currentPosition = {'lat': 37.5665, 'lng': 126.9780};
  bool isLoading = true;

  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getRecommend(),
      getCurrentLocation(),
    ]);
  }

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();

    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
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

  getRecommend() async {
    ApiResultModel result = await ref
        .read(recommendControllerProvider.notifier)
        .getRecommend({'size': 5});
    if (result.type == 1) {
      setState(() {
        recommendList = result.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? recommendList.isEmpty
            ? const CommonEmpty(text: localization.noRecommendedJobsAvailable)
            : CustomScrollView(
                slivers: [
                  RecommendSwiper(
                    currentPosition: currentPosition,
                    recommendData: recommendList,
                    scrapJobseeker: widget.scrapJobseeker,
                    applyJobposting: widget.applyJobposting,
                  ),
                ],
              )
        : const Loader();
  }
}
