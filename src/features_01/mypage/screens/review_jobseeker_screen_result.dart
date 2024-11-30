import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluated_company_bottom_sheet.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_company_bottom_sheet.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/rating_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class ReviewJobSeekerScreen extends ConsumerStatefulWidget {
  const ReviewJobSeekerScreen({super.key});

  @override
  ConsumerState<ReviewJobSeekerScreen> createState() =>
      _ReviewJobSeekerScreenState();
}

class _ReviewJobSeekerScreenState extends ConsumerState<ReviewJobSeekerScreen> {
  int activeTab = 0;
  bool isLoading = true;

  int unratedPage = 1;
  int unratedLastPage = 1;
  int unratedTotal = 0;
  bool isUnratedLazeLoading = false;

  int ratedPage = 1;
  int ratedLastPage = 1;
  int ratedTotal = 0;
  bool isRatedLazyLoading = false;

  List<RatingModel> unratedList = [];
  List<RatingModel> ratedList = [];

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUnratedEvaluateData(unratedPage),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  Future _unratedLoadMore() async {
    if (isUnratedLazeLoading) {
      return;
    }
    if (unratedLastPage > 1 && unratedPage + 1 <= unratedLastPage) {
      setState(() {
        isUnratedLazeLoading = true;
        unratedPage = unratedPage + 1;
        getUnratedEvaluateData(unratedPage);
      });
    }
  }

  Future _ratedLoadMore() async {
    if (isRatedLazyLoading) {
      return;
    }
    if (ratedLastPage > 1 && ratedPage + 1 <= ratedLastPage) {
      setState(() {
        isRatedLazyLoading = true;
        ratedPage = ratedPage + 1;
        getRatedEvaluateData(ratedPage);
      });
    }
  }

  setTab(data) {
    setState(() {
      savePageLog(); // 페이지 로그 쌓기
      activeTab = data;
      unratedPage = 1;
      ratedPage = 1;
      if (data == 0) {
        getUnratedEvaluateData(unratedPage);
      } else {
        getRatedEvaluateData(ratedPage);
      }
    });
  }

  String getDateTimeString(String date) {
    String formattedDate =
        DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(date));
    return formattedDate;
  }

  // 미평가
  void showEvaluationModal(String name, int ratingKey) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return EvaluationCompanyBottomSheet(
          name: name,
          ratingKey: ratingKey,
            getUnratedEvaluateData: getUnratedEvaluateData,
        );
      },
    );
  }

  // 평가완료
  void showEvaluatedModal(String name, int ratingKey) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      isScrollControlled: true,
      isDismissible: false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return EvaluatedCompanyBottomSheet(
          name: name,
          ratingKey: ratingKey,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  // 미평가
  getUnratedEvaluateData(int page) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getJobSeekerEvaluateData(page, userInfo.key, 'unrated');
      if (result.status == 200) {
        if (result.type == 1) {
          List<RatingModel> resultData = result.data;
          setState(() {
            if (page == 1) {
              unratedList = [...resultData];
            } else {
              unratedList = [...unratedList, ...resultData];
            }
            unratedTotal = result.page['total'];
            unratedLastPage = result.page['lastPage'];
            isUnratedLazeLoading = false;
          });
        }
      }
    }
  }

  // 평가완료
  getRatedEvaluateData(int page) async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getJobSeekerEvaluateData(page, userInfo.key, 'rated');
      if (result.status == 200) {
        if (result.type == 1) {
          List<RatingModel> resultData = result.data;
          setState(() {
            if (page == 1) {
              ratedList = [...resultData];
            } else {
              ratedList = [...ratedList, ...resultData];
            }
            ratedTotal = result.page['total'];
            ratedLastPage = result.page['lastPage'];
            isRatedLazyLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.starRatingManagement,
      ),
      body: !isLoading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 12.w),
                  child: CommonTab(
                    setTab: setTab,
                    activeTab: activeTab,
                    tabTitleArr: const ['미평가', '평가완료'],
                  ),
                ),
                activeTab == 0
                    ? Expanded(
                        child: unratedList.isNotEmpty
                            ? LazyLoadScrollView(
                                onEndOfPage: () => _unratedLoadMore(),
                                child: CustomScrollView(
                                  slivers: [
                                    SliverPadding(
                                      padding:
                                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          childCount: unratedList.length,
                                          (context, index) {
                                            var unratedData =
                                                unratedList[index];
                                            return GestureDetector(
                                              onTap: () {
                                                savePageLog();
                                                showEvaluationModal(
                                                    unratedData.name,
                                                    unratedData.key); // 미평가
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: index == 0 ? 0 : 8.w),
                                                padding: EdgeInsets.fromLTRB(
                                                    20.w, 20.w, 20.w, 16.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                    color: CommonColors.grayF2,
                                                    width: 1.w,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.w),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            unratedData.name,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  CommonColors
                                                                      .black2b,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3.w),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            unratedData.title,
                                                            style: TextStyle(
                                                              fontSize: 13.sp,
                                                              color:
                                                                  CommonColors
                                                                      .gray4d,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.w),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '사직일 ${getDateTimeString(unratedData.resignDate)}',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color:
                                                                  CommonColors
                                                                      .grayB2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    if (isUnratedLazeLoading) const Loader(),
                                    const BottomPadding(),
                                  ],
                                ),
                              )
                            : const CommonEmpty(text: localization.noDataAvailable))
                    : Expanded(
                        child: ratedList.isNotEmpty
                            ? LazyLoadScrollView(
                                onEndOfPage: () => _ratedLoadMore(),
                                child: CustomScrollView(
                                  slivers: [
                                    SliverPadding(
                                      padding:
                                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                      sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                          childCount: ratedList.length,
                                          (context, index) {
                                            var ratedData = ratedList[index];
                                            return GestureDetector(
                                              onTap: () {
                                                showEvaluatedModal(
                                                    ratedData.name,
                                                    ratedData.key); // 평가 완료
                                              },
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    top: index == 0 ? 0 : 8.w),
                                                padding: EdgeInsets.fromLTRB(
                                                    20.w, 20.w, 20.w, 16.w),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                    color: CommonColors.grayF2,
                                                    width: 1.w,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.w),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: [
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            ratedData.name,
                                                            style: TextStyle(
                                                              fontSize: 15.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  CommonColors
                                                                      .black2b,
                                                            ),
                                                          ),
                                                          SizedBox(height: 3.w),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            ratedData.title,
                                                            style: TextStyle(
                                                              fontSize: 13.sp,
                                                              color:
                                                                  CommonColors
                                                                      .gray4d,
                                                            ),
                                                          ),
                                                          SizedBox(height: 2.w),
                                                          Text(
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '사직일 ${getDateTimeString(ratedData.resignDate)}',
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color:
                                                                  CommonColors
                                                                      .grayB2,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    if (isUnratedLazeLoading) const Loader(),
                                    const BottomPadding(),
                                  ],
                                ),
                              )
                            : const CommonEmpty(text: localization.noDataAvailable),
                      ),
              ],
            )
          : const Loader(),
    );
  }
}
