import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/point_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class PointScreen extends ConsumerStatefulWidget {
  const PointScreen({super.key});

  @override
  ConsumerState<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends ConsumerState<PointScreen> {
  List<PointModel> pointList = [];
  int totalPoint = 0;

  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  int total = 0;
  bool isLazeLoading = false;

  String getDateTimeString(String date) {
    String formattedDate =
        DateFormat('yyyy.MM.dd HH:mm:ss').format(DateTime.parse(date));
    return formattedDate;
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getMyTotalPoint(),
      getPointList(page),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
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

  getMyTotalPoint() async {
    ApiResultModel result =
        await ref.read(mypageControllerProvider.notifier).getMyTotalPoint();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          totalPoint = result.data ?? 0;
        });
      }
    }
  }

  getPointList(int page) async {
    ApiResultModel result =
        await ref.read(mypageControllerProvider.notifier).getPointList(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<PointModel> resultData = result.data;
        setState(() {
          if (page == 1) {
            pointList = [...resultData];
          } else {
            pointList = [...pointList, ...resultData];
          }
          total = result.page['total'];
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
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
        getPointList(page);
      });
    }
  }

  returnPointType(String type) {
    switch (type) {
      case 'LOGIN_JOBSEEKER':
        return '로그인';
      case 'PROFILE_JOBSEEKER':
        return '프로필 등록';
      case 'SCRAP_JOB_POSTING':
        return '채용 공고 스크랩';
      case 'ADD_COMPANY_LIKES':
        return '관심 기업 추가';
      case 'SHARE_JOB_POSTING':
        return '채용 공고 공유';
      case 'APPLY_JOB':
        return '입사 지원';
      case 'VIEW_JOB_POSTING':
        return '채용 공고 보기';
      case 'LOGIN_RECRUITER':
        return '로그인';
      case 'CREATE_COMPANY_INFO':
        return '기업 정보 등록';
      case 'CREATE_JOB_POSTING':
        return '채용 공고 등록';
      case 'VIEW_JOBSEEKER':
        return '인재 살펴 보기';
      case 'OFFER_JOB':
        return '일자리 제안하기';
      case 'ADD_JOBSEEKER_LIKES':
        return '관심 인재 추가';
      case 'INVITE':
        return '초대';
      case 'INVITE_SUCCESS':
        return '초대 성공';
      case 'COMPLETE_RATING':
        return '별점 평가 완료';
      case 'WRITE_LABOR_CONSULT':
        return '노무 상담 글쓰기';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: '활동 포인트 관리',
      ),
      body: LazyLoadScrollView(
        onEndOfPage: () => _loadMore(),
        child: !isLoading
            ? CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 24.w, 16.w, 28.w),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
                        decoration: BoxDecoration(
                          color: CommonColors.grayF7,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '나의 활동 포인트',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  color: CommonColors.gray66,
                                  fontWeight: FontWeight.w500),
                            ),
                            Expanded(
                              child: Text(
                                '$totalPoint P',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: CommonColors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TitleMenu(title: '활동 포인트 내역'),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    sliver: pointList.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: pointList.length,
                              (context, index) {
                                var pointData = pointList[index];
                                return Container(
                                  padding:
                                      EdgeInsets.fromLTRB(0, 20.w, 0, 20.w),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1.w,
                                        color: CommonColors.grayF7,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        getDateTimeString(pointData.createdAt),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.grayB2,
                                        ),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              returnPointType(pointData.pointName),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.gray4d,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            pointData.pointAmount > 0
                                                ? '+${pointData.pointAmount}P'
                                                : '${pointData.pointAmount}P',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: pointData.pointAmount > 0
                                                  ? CommonColors.red
                                                  : CommonColors.gray4d,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: SizedBox(
                              height: CommonSize.vh / 2,
                                child: const CommonEmpty(text: '활동한 내역이 없어요.')),
                          ),
                  ),
                  const BottomPadding(),
                  if (isLazeLoading) const Loader(),
                ],
              )
            : const Loader(),
      ),
    );
  }
}
