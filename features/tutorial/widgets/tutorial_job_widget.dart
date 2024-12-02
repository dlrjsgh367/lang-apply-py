import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialJobWidget extends ConsumerStatefulWidget {
  const TutorialJobWidget({
    super.key,
    required this.data,
    required this.jobList,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final List<DefineModel> jobList;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialJobWidget> createState() => _TutorialJobWidgetState();
}

class _TutorialJobWidgetState extends ConsumerState<TutorialJobWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<DefineModel> selectedJobList = [];
  List selectedJobKey = [];
  int maxLength = 5;

  addWorkJob(List<DefineModel> jobItem, List<int> apply) {
    setState(() {
      selectedJobList = [...jobItem];
      selectedJobKey = [...apply];
    });
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['joIdx'].isNotEmpty) {
      selectedJobKey = widget.data['joIdx'];
      selectedJobList = widget.jobList;
    }
  }


  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
    super.build(context);
    return Stack(
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
                          '내가 원하는 직종을\n5종까지 선택할 수 있어요!',
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
                            color: CommonColors.red02, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/icon/iconOccuRed.png',
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
                    '희망하는 직종을 제안받을 수 있어요.',
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
                  child: GestureDetector(
                    onTap: () async {
                      await DefineDialog.showJobBottom(context, '직종', jobList, addWorkJob, selectedJobList, maxLength, DefineEnum.job);
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
                            '희망 직종 설정하기',
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
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Text(
                        '선택된 희망 직종',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: 16.w,
                      ),
                      Text(
                        '${selectedJobList.length}',
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
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.w,
                    children: [
                      for (var i = 0; i < selectedJobList.length; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedJobList.removeAt(i);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                            height: 30.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.w),
                              color: CommonColors.grayF7,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedJobList[i].name,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Image.asset(
                                  'assets/images/icon/iconX.png',
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
                  onPressed: () {
                    if (selectedJobList.isNotEmpty) {
                      widget.setData('joIdx', selectedJobKey);
                      widget.writeFunc('job');
                      widget.onPress();
                    }

                  },
                  text: '다음',
                  fontSize: 15,
                  confirm: selectedJobList.isNotEmpty,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
