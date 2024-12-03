import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/education_add_modal_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InputEducationWidget extends ConsumerStatefulWidget {
  const InputEducationWidget({
    super.key,
    required this.profileData,
    required this.setProfileData,
  });

  final Map<String, dynamic> profileData;
  final Function setProfileData;

  @override
  ConsumerState<InputEducationWidget> createState() =>
      _InputEducationWidgetState();
}

class _InputEducationWidgetState extends ConsumerState<InputEducationWidget> {
  List educationList = [];
  List<ProfileModel> schoolTypes = [];

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

    savePageLog();

    if (widget.profileData['educationList'].isNotEmpty) {
      educationList = [...widget.profileData['educationList']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
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
          title: localization.educationLevel,
        ),
        body: !isLoading
            ? Stack(children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomScrollView(
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
                        padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: educationList.length,
                            (context, index) {
                              var item = educationList[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: 16.w),
                                padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
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
                              showEducationAddModal();
                            },
                            child: Container(
                              height: 48.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.w),
                                  color: CommonColors.red02),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/icon/iconPlusRed.png',
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
                                      color: CommonColors.red,
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
                  bottom: CommonSize.commonBottom,
                  child: CommonButton(
                    confirm: educationList.isNotEmpty,
                    onPressed: () {
                      if (educationList.isNotEmpty) {
                        widget.setProfileData('educationList', educationList);
                        context.pop();
                      }
                    },
                    text: localization.32,
                  ),
                ),
              ])
            : const Loader(),
      ),
    );
  }
}
