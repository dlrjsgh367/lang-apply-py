import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/enum/career_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/career_add_modal_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/career_job_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';

class InputCareerWidget extends ConsumerStatefulWidget {
  const InputCareerWidget({
    super.key,
    required this.profileData,
    required this.setProfileData,
    this.jobDepthDataList,
    this.setJobDepthData,
    required this.totalCareerMonths,
    required this.setTotalCareerMonths,
  });

  final Map<String, dynamic> profileData;
  final Function setProfileData;
  final List? jobDepthDataList;
  final Function? setJobDepthData;
  final int totalCareerMonths;
  final Function setTotalCareerMonths;

  @override
  ConsumerState<InputCareerWidget> createState() => _InputCareerWidgetState();
}

class _InputCareerWidgetState extends ConsumerState<InputCareerWidget> {
  List<ProfileModel> workTypes = [];
  List careerList = [];
  Career career = Career.entry;
  int totalCareerMonths = 0;

  bool isLoading = true;
  List<CareerJobModel> jobDataList = [];

  setJobData(CareerJobModel jobData) {
    jobDataList.add(jobData);
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getWorkTypes()]);
  }

  showCareerAddModal(List<ProfileModel> workTypes) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return CareerAddModalWidget(
          workTypes: workTypes,
          setJobData: setJobData,
        );
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          careerList.add(value);
          totalCareerMonths += ProfileService.calculateTotalCareerMonths(
              value['mpcStartDate'], value['mpcEndDate']);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    savePageLog();

    if (widget.profileData['careerList'].isNotEmpty) {
      career = Career.experienced;
      careerList = [...widget.profileData['careerList']];
      totalCareerMonths = widget.totalCareerMonths;

      if (widget.jobDepthDataList != null) {
        jobDataList = [...widget.jobDepthDataList!];
      }
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 10;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: const CommonAppbar(
              title: localization.career,
            ),
            body: !isLoading
                ? CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  localization.showcaseYourExperience,
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
                                  'assets/images/icon/iconBagRed.png',
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
                            localization.experienceImprovesJobSupport,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray80,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 24.w),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: ProfileRadio(
                                  onChanged: (value) {
                                    setState(() {
                                      careerList.clear();
                                      totalCareerMonths = 0;
                                      widget.setTotalCareerMonths(totalCareerMonths);
                                      career = Career.entry;
                                    });
                                  },
                                  groupValue: career.value,
                                  value: Career.entry.value,
                                  label: Career.entry.label,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ProfileRadio(
                                  onChanged: (value) {
                                    setState(() {
                                      career = Career.experienced;
                                      showCareerAddModal(workTypes);
                                    });
                                  },
                                  groupValue: career.value,
                                  value: Career.experienced.value,
                                  label: Career.experienced.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (career.value == 1)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: localization.total,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.black2b),
                                  ),
                                  TextSpan(
                                    text: '${totalCareerMonths ~/ 12}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CommonColors.red),
                                  ),
                                  TextSpan(
                                    text: localization.year,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.black2b),
                                  ),
                                  TextSpan(
                                    text: '${totalCareerMonths % 12}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: CommonColors.red),
                                  ),
                                  TextSpan(
                                    text: localization.months,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.black2b),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (careerList.isNotEmpty && jobDataList.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: careerList.length,
                              (context, index) {
                                var careerData = careerList[index];
                                var jobData = jobDataList[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                      top: index == 0 ? 0 : 12.w),
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 16.w, 20.w, 16.w),
                                  decoration: BoxDecoration(
                                    color: CommonColors.grayF7,
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child:  Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                '${ProfileService.convertWorkType(careerData['wtIdx'])} ${ProfileService.formatCareerPeriod(careerData['mpcStartDate'], careerData['mpcEndDate'])}',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray80,
                                                ),
                                              ),
                                              Text(
                                                jobData.formattedDepthName,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray80,
                                                ),
                                              ),
                                            ],
                                          ),),

                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertTwoButtonDialog(
                                                        alertTitle: localization.delete,
                                                        alertContent:
                                                            localization.confirmDeleteExperience,
                                                        alertConfirm: localization.confirm,
                                                        alertCancel: localization.cancel,
                                                        onConfirm: () {
                                                          setState(() {
                                                            careerList.remove(
                                                                careerData);
                                                            totalCareerMonths -=
                                                                ProfileService.calculateTotalCareerMonths(
                                                                    careerData[
                                                                        'mpcStartDate'],
                                                                    careerData[
                                                                        'mpcEndDate']);
                                                          });
                                                          context.pop();
                                                        });
                                                  });
                                            },
                                            style: ButtonStyles.childBtn,
                                            child: Image.asset(
                                              'assets/images/icon/iconTrashCan.png',
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6.w,
                                      ),
                                      Text(
                                        careerData['mpcName'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 16.w,
                                      ),
                                      Text(
                                        careerData['mpcWork'],
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                        sliver: SliverToBoxAdapter(
                          child: GestureDetector(
                            onTap: () {
                              // 디자인 변경으로
                              // 신입 상태에서 하단 경력추가 버튼 누르면 옵션이 자동으로 경력으로 변경
                              // if (career.value == 0) {
                              //   setState(() {
                              //     career = Career.experienced;
                              //   });
                              // }
                              if (career.value == 1) {
                                showCareerAddModal(workTypes);
                              }
                            },
                            child: Container(
                              height: 48.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: career.value != 0
                                    ? CommonColors.red02
                                    : CommonColors.gray300,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    career.value != 0
                                        ? 'assets/images/icon/iconPlusRed.png'
                                        : 'assets/images/icon/iconPlusGray.png',
                                    width: 18.w,
                                    height: 18.w,
                                  ),
                                  SizedBox(
                                    width: 6.w,
                                  ),
                                  Text(
                                    localization.addExperience,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: career.value != 0
                                          ? CommonColors.red
                                          : CommonColors.grayB2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const BottomPadding(
                        extra: 100,
                      ),
                    ],
                  )
                : const Loader(),
          ),
          if (!isLoading)
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBottom,
              child: CommonButton(
                fontSize: 15,
                confirm: (career == Career.entry && careerList.isEmpty) ||
                    (career == Career.experienced && careerList.isNotEmpty),
                onPressed: () {
                  if ((career == Career.entry && careerList.isEmpty) ||
                      (career == Career.experienced && careerList.isNotEmpty)) {
                    widget.setProfileData('careerList', careerList);
                    widget.setTotalCareerMonths(totalCareerMonths);
                    widget.setProfileData('mpHaveCareer', career.value);
                    if (widget.setJobDepthData != null) {
                      widget.setJobDepthData!(jobDataList);
                    }
                    context.pop();
                  }
                },
                text: localization.enterData,
              ),
            ),
        ],
      ),
    );
  }
}
