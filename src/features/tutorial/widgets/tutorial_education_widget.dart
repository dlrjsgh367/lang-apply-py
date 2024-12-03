import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/mypage/enum/education_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/education_add_modal_widget.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialEducationWidget extends ConsumerStatefulWidget {
  const TutorialEducationWidget({
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
  ConsumerState<TutorialEducationWidget> createState() =>
      _TutorialEducationWidgetState();
}

class _TutorialEducationWidgetState
    extends ConsumerState<TutorialEducationWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List educationList = [];
  List<ProfileModel> schoolTypes = [];
  Education education = Education.unspecified;

  bool isLoading = true;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getSchoolType()]);
  }

  showEducationAddModal() {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return EducationAddModalWidget(
          schoolTypes: schoolTypes,
        );
      },
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                educationList.add(value);
              })
            }
        });
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['educationList'].isNotEmpty) {
      education = Education.additional;
      educationList = [...widget.data['educationList']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  getSchoolType() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getSchoolType();
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          schoolTypes = [...resultData];
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
                                localization.539,
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
                                'assets/images/icon/iconEduRed.png',
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
                          localization.540,
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
                                    educationList.clear();
                                    education = Education.unspecified;
                                  });
                                },
                                groupValue: education.value,
                                value: Education.unspecified.value,
                                label: Education.unspecified.label,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: ProfileRadio(
                                onChanged: (value) {
                                  setState(() {
                                    education = Education.additional;
                                    showEducationAddModal();
                                  });
                                },
                                groupValue: education.value,
                                value: Education.additional.value,
                                label: Education.additional.label,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: educationList.length,
                          (context, index) {
                            var item = educationList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16.w),
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                              decoration: BoxDecoration(
                                color: CommonColors.grayF7,
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (item['mpeName'].isNotEmpty)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['mpeName'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                            ),
                                            if (item['mpeName'].isNotEmpty)
                                              TextButton(
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertTwoButtonDialog(
                                                            alertTitle: localization.delete,
                                                            alertContent: localization.541,
                                                            alertConfirm: localization.confirm,
                                                            alertCancel: localization.cancel,
                                                            onConfirm: () {
                                                              setState(() {
                                                                educationList.remove(item);
                                                                context.pop();
                                                              });
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
                                          height: 12.w,
                                        ),
                                      ],
                                    ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${ProfileService.educationTypeKeyToString(schoolTypes, item['stIdx'])} ${item['mpeStatus']}',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 16.w,
                                          ),
                                          if (item['mpeDate'] != null)
                                            Text(
                                              ProfileService.formatToYearMonthKorean(item['mpeDate']),
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (item['mpeName'].isEmpty)
                                        TextButton(
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertTwoButtonDialog(
                                                      alertTitle: localization.delete,
                                                      alertContent: localization.541,
                                                      alertConfirm: localization.confirm,
                                                      alertCancel: localization.cancel,
                                                      onConfirm: () {
                                                        setState(() {
                                                          educationList.remove(item);
                                                          context.pop();
                                                        });
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
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 24.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () {
                            // 디자인 변경으로 주석
                            // 미기재 상태에서 하단 학력추가 버튼 누르면 옵션이 자동으로 학력추가로 변경
                            // if (education.value == 1) {
                            //   setState(() {
                            //     education = Education.additional;
                            //   });
                            // }
                            if (education.value == 2) {
                              showEducationAddModal();
                            }
                          },
                          child: Container(
                            height: 48.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              color: education.value != 1
                                ? CommonColors.red02
                                : CommonColors.gray300,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  education.value != 1
                                    ? 'assets/images/icon/iconPlusRed.png'
                                    : 'assets/images/icon/iconPlusGray.png',
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                SizedBox(
                                  width: 6.w,
                                ),
                                Text(
                                  localization.542,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: education.value != 1
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
                          if ((education == Education.unspecified &&
                                  educationList.isEmpty) ||
                              (education == Education.additional &&
                                  educationList.isNotEmpty)) {
                            widget.setData('educationList', educationList);
                            widget.writeFunc('education');

                            widget.onPress();
                          }
                        },
                        text: localization.next,
                        fontSize: 15,
                        confirm: (education == Education.unspecified &&
                                educationList.isEmpty) ||
                            (education == Education.additional &&
                                educationList.isNotEmpty),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        // Column(
        //     children: [
        //       const Text('학력을 요구하는 업무 지원에 훨씬 유리해요!'),
        //       Row(
        //         children: [
        //           ProfileRadio(
        //             onChanged: (value) {
        //               setState(() {
        //                 educationList.clear();
        //                 education = Education.unspecified;
        //               });
        //             },
        //             groupValue: education.value,
        //             value: Education.unspecified.value,
        //             label: Education.unspecified.label,
        //           ),
        //           const SizedBox(width: 100),
        //           ProfileRadio(
        //             onChanged: (value) {
        //               setState(() {
        //                 education = Education.additional;
        //                 showEducationAddModal();
        //               });
        //             },
        //             groupValue: education.value,
        //             value: Education.additional.value,
        //             label: Education.additional.label,
        //           ),
        //         ],
        //       ),
        //       GestureDetector(
        //         onTap: () {
        //           // 미기재 상태에서 하단 학력추가 버튼 누르면 옵션이 자동으로 학력추가로 변경
        //           if (education.value == 1) {
        //             setState(() {
        //               education = Education.additional;
        //             });
        //           }
        //           showEducationAddModal();
        //         },
        //         child: const Text(localization.542),
        //       ),
        //       if (educationList.isNotEmpty)
        //         ListView.builder(
        //           shrinkWrap: true,
        //           itemCount: educationList.length,
        //           itemBuilder: (BuildContext context, int index) {
        //             var educationData = educationList[index];
        //             return Column(
        //               crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [

        //           },
        //         ),

        : const Loader();
  }
}
