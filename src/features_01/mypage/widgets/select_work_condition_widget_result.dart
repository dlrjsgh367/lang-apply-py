import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SelectWorkConditionWidget extends ConsumerStatefulWidget {
  const SelectWorkConditionWidget({
    super.key,
    required this.profileData,
    required this.setProfileData,
  });

  final Map<String, dynamic> profileData;
  final Function setProfileData;

  @override
  ConsumerState<SelectWorkConditionWidget> createState() =>
      _SelectWorkConditionWidgetState();
}

class _SelectWorkConditionWidgetState
    extends ConsumerState<SelectWorkConditionWidget> {
  bool isLoading = true;

  List<ProfileModel> workTypes = [];
  List<ProfileModel> workPeriodList = [];

  List selectedWorkTypes = [];
  List selectedWorkPeriodList = [];

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getWorkTypes(), getWorkPeriodList()]);
  }

  @override
  void initState() {
    super.initState();

    savePageLog();

    if (widget.profileData['wtIdx'].isNotEmpty) {
      selectedWorkTypes = widget.profileData['wtIdx'];
    }

    if (widget.profileData['wpIdx'].isNotEmpty) {
      selectedWorkPeriodList = widget.profileData['wpIdx'];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
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
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 15;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      child: Scaffold(
        appBar: const CommonAppbar(
          title: localization.desiredWorkConditions,
        ),
        body: !isLoading
            ? Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localization.suggestDesiredWorkConditions,
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
                            localization.detailedInputImprovesProposalChances,
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
                                localization.employmentType,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CommonColors.black2b),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 4.w),
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.red),
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
                                localization.employmentPeriod,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: CommonColors.black2b),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 4.w),
                                width: 4.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.red),
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
                  Positioned(
                    left: 20.w,
                    right: 20.w,
                    bottom: CommonSize.commonBottom,
                    child: CommonButton(
                      fontSize: 15,
                      confirm: selectedWorkTypes.isNotEmpty &&
                          selectedWorkPeriodList.isNotEmpty,
                      onPressed: () {
                        if (selectedWorkTypes.isNotEmpty &&
                            selectedWorkPeriodList.isNotEmpty) {
                          widget.setProfileData('wtIdx', selectedWorkTypes);
                          widget.setProfileData('wpIdx', selectedWorkPeriodList);
                          context.pop();
                        }
                      },
                      text: localization.enterData,
                    ),
                  ),
                ],
              )
            : const Loader(),
      ),
    );
  }
}
