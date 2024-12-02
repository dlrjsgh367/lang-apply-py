import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/work_schedule_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialWorkScheduleWidget extends ConsumerStatefulWidget {
  const TutorialWorkScheduleWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialWorkScheduleWidget> createState() =>
      _TutorialWorkScheduleWidgetState();
}

class _TutorialWorkScheduleWidgetState
    extends ConsumerState<TutorialWorkScheduleWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isLoading = true;

  List<ProfileModel> workDays = [];
  List<ProfileModel> workTimes = [];

  List<dynamic> selectedWorkDays = [];
  List<int> selectedWorkTimes = [];

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getWorkDays(), getWorkTimes()]);
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['wdIdx'].isNotEmpty) {
      selectedWorkDays = [...widget.data['wdIdx']];
    }

    if (widget.data['whIdx'].isNotEmpty) {
      selectedWorkTimes = [...widget.data['whIdx']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  getWorkDays() async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getWorkDays('PROFILE');
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          workDays = [...resultData];
        });
      }
    }
  }

  getWorkTimes() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkTimes();
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          workTimes = [...resultData];
        });
      }
    }
  }

  showBottomOccu() {
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
        return WorkScheduleBottomSheet(
          dataArr: workTimes, initItemArr: selectedWorkTimes,
          // type: '직종',
        );
      },
    ).then((value) {
      setState(() {
        selectedWorkTimes = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return isLoading
        ? const Loader()
        : Stack(
            children: [
              Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 18.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '내가 희망하는 \n근무 스케쥴을 설정할 수 있어요!',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: CommonColors.black2b,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                  color: CommonColors.red02,
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/icon/iconCalRed.png',
                                width: 36.w,
                                height: 36.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 36.w),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          '상세히 입력할수록 제안받을 확률이 높아져요!',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.gray80,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                      sliver: const SliverToBoxAdapter(
                        child: Text(
                          '근무 요일',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          runSpacing: 8.w,
                          spacing: 8.w,
                          children: [
                            for (var i = 0; i < workDays.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedWorkDays
                                        .contains(workDays[i].workDayKey)) {
                                      selectedWorkDays
                                          .remove(workDays[i].workDayKey);
                                    } else {
                                      if (selectedWorkDays.length < 3) {
                                        selectedWorkDays
                                            .add(workDays[i].workDayKey);
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.fromLTRB(8.w, 0.w, 8.w, 0),
                                  height: 34.w,
                                  // alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.w),
                                    color: selectedWorkDays
                                            .contains(workDays[i].workDayKey)
                                        ? CommonColors.red02
                                        : CommonColors.grayF7,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        workDays[i].workDayName,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: selectedWorkDays.contains(
                                                  workDays[i].workDayKey)
                                              ? CommonColors.red
                                              : CommonColors.black2b,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 20.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            const Text(
                              '근무 시간',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Text(
                              '최대 3개 옵션 등록 가능합니다.',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                  color: CommonColors.grayB2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (var i = 0; i < selectedWorkTimes.length; i++)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                        sliver: SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedWorkTimes.removeWhere(
                                    (e) => e == selectedWorkTimes[i]);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                              height: 48.w,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.w),
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      workTimes
                                          .where((e) =>
                                              e.workTimeKey ==
                                              selectedWorkTimes[i])
                                          .map((e) => e.workTimeName)
                                          .join(),
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.black2b,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/icon/iconX.png',
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                            height: 40.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.w),
                              color: CommonColors.grayF7,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '동일한 근무 시간을 중복 선택이 불가능합니다.',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: CommonColors.grayB2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // showO
                                showBottomOccu();
                              },
                              child: Container(
                                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                                height: 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(500.w),
                                  color: CommonColors.red02,
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  children: [
                                    Text(
                                      '근무 시간 추가하기',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700,
                                        color: CommonColors.red,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4.w,
                                    ),
                                    Image.asset(
                                      'assets/images/icon/iconPlus.png',
                                      width: 16.w,
                                      height: 16.w,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const BottomPadding(
                      extra: 100,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: CommonSize.commonBottom,
                child: Row(
                  children: [
                    BorderButton(
                      onPressed: () {
                        widget.onPress();
                      },
                      text: '건너뛰기',
                      width: 96.w,
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    Expanded(
                      child: CommonButton(
                        confirm: selectedWorkDays.isNotEmpty &&
                            selectedWorkTimes.isNotEmpty,
                        onPressed: () {
                          if (selectedWorkDays.isNotEmpty &&
                              selectedWorkTimes.isNotEmpty) {
                            widget.setData('wdIdx', selectedWorkDays);
                            widget.writeFunc('workDays'); // 희망 근무 요일

                            widget.setData('whIdx', selectedWorkTimes);
                            widget.writeFunc('workHour'); // 희망 근무 시간

                            widget.onPress();
                          }
                        },
                        text: '다음',
                        fontSize: 15,
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
  }
}
