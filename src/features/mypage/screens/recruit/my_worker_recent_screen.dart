import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/location_service.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/map/service/map_service.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/jobposting_recruiter_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class MyWorkerRecentScreen extends ConsumerStatefulWidget {
  const MyWorkerRecentScreen({super.key});

  @override
  ConsumerState<MyWorkerRecentScreen> createState() =>
      _MyWorkerRecentScreenState();
}

class _MyWorkerRecentScreenState extends ConsumerState<MyWorkerRecentScreen>
    with Alerts {
  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  List<ProfileModel> workerList = [];

  bool isRunning = false;

  bool isLoading = true;

  Map<String, dynamic> currentPosition = MapService.currentPosition;

  late Future<void> _allAsyncTasks;

  _loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
      });
    }
  }

  getLatestWorkerListData(int page) async {
    ApiResultModel result = await ref
        .read(workerControllerProvider.notifier)
        .getLatestWorkerListData(page);
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

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getLatestWorkerListData(page),
      getCurrentLocation(),
    ]);
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

  proposeJobpost(int profileKey, int jobpostKey) async {
    if (isRunning) {
      return;
    }
    isRunning = true;
    Map<String, dynamic> params = {
      "mpIdx": profileKey,
      "jpIdx": jobpostKey,
    };

    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .proposeJobpost(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.387);
      } else {
        showDefaultToast(localization.388);
      }
    } else if (result.status == 409) {
      showDefaultToast(localization.389);
    } else if (result.status == 401) {
      if (result.type == -2504) {
        showDefaultToast(localization.390);
      } else {
        showDefaultToast(localization.391);
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.388);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  showBottomSuggestJobposting(int profileKey) {
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
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return JobpostingRecruiterBottomSheet(
          apply: proposeJobpost,
          profileKey: profileKey,
        );
      },
    );
  }

  double distanceBetween(
      {required double endLatitude, required double endLongitude}) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
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

  deleteLikesWorker(int idx) async {
    var result = await ref
        .read(workerControllerProvider.notifier)
        .deleteLikesWorker(idx);
    if (result.status == 200) {
      if (result.type == 1) {
        likeAfterLikesFunc(idx);
      }
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
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
        showDefaultToast(localization.alreadySavedAsInterestedCompany);
      }
    }
  }

  likeAfterLikesFunc(int key) {
    List likeList = ref.read(workerLikesKeyListProvider);
    if (likeList.contains(key)) {
      likeList.remove(key);
      showDefaultToast(localization.392);
    } else {
      likeList.add(key);
      showDefaultToast(localization.393);
    }
    setState(() {
      ref
          .read(workerLikesKeyListProvider.notifier)
          .update((state) => [...likeList]);
    });
  }

  String mergeJob(List<ProfileJobModel> itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (i != itemList.length - 1) {
        result += '${itemList[i].name} / ';
      } else {
        result += itemList[i].name;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    List<int> workerLikesKeyList = ref.watch(workerLikesKeyListProvider);
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
    return Scaffold(
        appBar: const CommonAppbar(
          title: localization.359,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            !isLoading
                ? workerList.isNotEmpty
                    ? LazyLoadScrollView(
                        onEndOfPage: () => _loadMore(),
                        child: CustomScrollView(
                          slivers: [
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: workerList.length,
                                (context, index) {
                                  ProfileModel workerItem = workerList[index];
                                  return GestureDetector(
                                    onTap: () {
                                      context.push('/seeker/${workerItem.key}');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                          20.w, 12.w, 20.w, 20.w),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: CommonColors.grayF2,
                                            width: 1.w,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            workerItem.profileTitle,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: CommonColors.black2b,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12.w,
                                          ),
                                          Row(
                                            children: [
                                              ClipOval(
                                                child: workerItem
                                                            .profileImg!.key !=
                                                        0
                                                    ? SizedBox(
                                                        width: 120.w,
                                                        height: 120.w,
                                                        child:
                                                            ExtendedImgWidget(
                                                          imgUrl: workerItem
                                                              .profileImg!.url,
                                                          imgWidth: 120.w,
                                                          // imgHeight: 120.w,
                                                          imgFit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : WorkerDefaultImgWidget(
                                                        colorCode: workerItem
                                                            .userInfo.color,
                                                        name: ConvertService
                                                                .isNotEmptyValidate(
                                                                    workerItem
                                                                        .userInfo
                                                                        .name)
                                                            ? workerItem
                                                                .userInfo
                                                                .name[0]
                                                            : '',
                                                        width: 120.w,
                                                        height: 120.w,
                                                      ),
                                              ),
                                              SizedBox(width: 16.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          ConvertService
                                                              .returnMaskingName(
                                                            matchedProfileKeyList
                                                                .contains(
                                                              workerItem.key,
                                                            ),
                                                            workerItem
                                                                .userInfo.name,
                                                          ),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 4.w,
                                                        ),
                                                        Text(
                                                          '(${ConvertService.calculateAge(workerItem.userInfo.birth)}세, ${returnConditionGenderNameFromParam(workerItem.userInfo.gender)})',
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 2.w),
                                                    Row(
                                                      children: [
                                                        Image.asset(
                                                          'assets/images/icon/iconPinGray.png',
                                                          width: 14.w,
                                                          height: 14.w,
                                                        ),
                                                        SizedBox(
                                                          width: 4.w,
                                                        ),
                                                        Text(
                                                          '${distanceBetween(endLatitude: workerItem.userInfo.lat, endLongitude: workerItem.userInfo.long)}km',
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 4.w,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            ConvertService.returnMaskingSiGuDong(
                                                                matchedProfileKeyList
                                                                    .contains(workerItem
                                                                        .key),
                                                                workerItem
                                                                    .userInfo
                                                                    .si,
                                                                workerItem
                                                                    .userInfo
                                                                    .gu,
                                                                workerItem
                                                                    .userInfo
                                                                    .dongName),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 12.sp,
                                                              color:
                                                                  CommonColors
                                                                      .gray80,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 38.w,
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        mergeJob(workerItem
                                                            .profileJobs),
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .gray80,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8.w,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: CommonButton(
                                                            height: 32.w,
                                                            confirm: true,
                                                            onPressed: () {
                                                              showBottomSuggestJobposting(
                                                                  workerItem!
                                                                      .key);
                                                            },
                                                            text: localization.344,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 12.w,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () {
                                                            toggleLikesWorker(
                                                                workerLikesKeyList,
                                                                workerItem.key);
                                                          },
                                                          child: Image.asset(
                                                            workerLikesKeyList
                                                                    .contains(
                                                                        workerItem
                                                                            .key)
                                                                ? 'assets/images/icon/iconHeartActive.png'
                                                                : 'assets/images/icon/iconRedHeart.png',
                                                            width: 24.w,
                                                            height: 24.w,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const BottomPadding(),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          showBottomSuggestJobposting(1);
                        },
                        child: CommonEmpty(text: localization.394))
                : const Loader(),
            if (isLazeLoading)
              Positioned(
                bottom: CommonSize.commonBottom,
                child: const Loader(),
              ),
          ],
        ));
  }
}
