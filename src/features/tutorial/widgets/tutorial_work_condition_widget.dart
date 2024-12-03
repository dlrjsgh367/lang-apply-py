import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialWorkConditionWidget extends ConsumerStatefulWidget {
  const TutorialWorkConditionWidget({
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
  ConsumerState<TutorialWorkConditionWidget> createState() =>
      _TutorialWorkConditionWidgetState();
}

class _TutorialWorkConditionWidgetState
    extends ConsumerState<TutorialWorkConditionWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool isLoading = true;

  List<ProfileModel> workTypes = [];
  List<ProfileModel> workPeriodList = [];

  List<dynamic> selectedWorkTypes = [];
  List<dynamic> selectedWorkPeriodList = [];

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getWorkTypes(), getWorkPeriodList()]);
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['wtIdx'].isNotEmpty) {
      selectedWorkTypes = [...widget.data['wtIdx']];
    }

    if (widget.data['wpIdx'].isNotEmpty) {
      selectedWorkPeriodList = [...widget.data['wpIdx']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  getWorkTypes() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkTypes();
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          workTypes = [...resultData];
        });
      }
    }
  }

  getWorkPeriodList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getWorkPeriodList();
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          workPeriodList = [...resultData];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return !isLoading
        ? Stack(
            children: [
              Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                localization.554,
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
                                'assets/images/icon/iconDocRed.png',
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
                          localization.555,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.gray80,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              localization.83,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.black2b),
                            ),
                            SizedBox(
                              width: 16.w,
                            ),
                            Text(
                              '${selectedWorkTypes.length}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ' / 5',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.gray80,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.w,
                          mainAxisExtent: 40.w,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          childCount: workTypes.length,
                          (BuildContext context, int index) {
                            var data = workTypes[index];
                            bool isSelected =
                                selectedWorkTypes.contains(data.workTypeKey);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedWorkTypes.remove(data.workTypeKey);
                                  } else {
                                    if (selectedWorkTypes.length < 5) {
                                      selectedWorkTypes.add(data.workTypeKey);
                                    }
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.w),
                                  color: isSelected
                                      ? CommonColors.red02
                                      : CommonColors.grayF7,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  data.workTypeName,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: isSelected
                                        ? CommonColors.red
                                        : CommonColors.black2b,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              localization.84,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.black2b),
                            ),
                            SizedBox(
                              width: 16.w,
                            ),
                            Text(
                              '${selectedWorkPeriodList.length}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              ' / 3',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.gray80,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          runSpacing: 8.w,
                          spacing: 8.w,
                          children: [
                            // var data = workPeriodList[index];
                            for (var i = 0; i < workPeriodList.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (selectedWorkPeriodList.contains(
                                        workPeriodList[i].workPeriodKey)) {
                                      selectedWorkPeriodList.remove(
                                          workPeriodList[i].workPeriodKey);
                                    } else {
                                      if (selectedWorkPeriodList.length < 3) {
                                        selectedWorkPeriodList.add(
                                            workPeriodList[i].workPeriodKey);
                                      }
                                    }
                                  });
                                },
                                child: Container(
                                  width: i == workPeriodList.length - 1 &&
                                          i % 2 == 0
                                      ? CommonSize.vw - 40.w
                                      : (CommonSize.vw - 40.w - 8.w) * 0.5,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.w),
                                    color: selectedWorkPeriodList.contains(
                                            workPeriodList[i].workPeriodKey)
                                        ? CommonColors.red02
                                        : CommonColors.grayF7,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        workPeriodList[i].workPeriodName,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: selectedWorkPeriodList
                                                  .contains(workPeriodList[i]
                                                      .workPeriodKey)
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
                    const BottomPadding(
                      extra: 100,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: CommonSize.commonBoard(context),
                child: Row(
                  children: [
                    BorderButton(
                      onPressed: () {
                        widget.onPress();
                      },
                      text: localization.755,
                      width: 96.w,
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          if (selectedWorkTypes.isNotEmpty &&
                              selectedWorkPeriodList.isNotEmpty) {
                            widget.setData('wtIdx', selectedWorkTypes);
                            widget.writeFunc('workType'); // 희망 근무 형태

                            widget.setData('wpIdx', selectedWorkPeriodList);
                            widget.writeFunc('workPeriod'); // 희망 근무 기간

                            widget.onPress();
                          }
                        },
                        text: localization.next,
                        fontSize: 15,
                        confirm: selectedWorkTypes.isNotEmpty &&
                            selectedWorkPeriodList.isNotEmpty,
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        : const Loader();
  }
}
