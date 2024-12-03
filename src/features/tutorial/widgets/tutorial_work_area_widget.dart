import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialWorkAreaWidget extends ConsumerStatefulWidget {
  const TutorialWorkAreaWidget({
    super.key,
    required this.data,
    required this.areaList,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final List<AddressModel> areaList;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialWorkAreaWidget> createState() =>
      _TutorialWorkAreaWidgetState();
}

class _TutorialWorkAreaWidgetState extends ConsumerState<TutorialWorkAreaWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<AddressModel> selectedAreaList = [];
  List selectedAreaKey = [];
  int maxLength = 10;

  addWorkArea(List<AddressModel> addressItem, List<int> apply, int adParent) {
    setState(() {
      selectedAreaList = [...addressItem];
      selectedAreaKey = apply;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.data['adIdx'].isNotEmpty) {
      selectedAreaKey = widget.data['adIdx'];
      selectedAreaList = widget.areaList;
    }
  }

  Future<void> getAreaList(DefineEnum defineTypeEnum) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getAreaList(defineTypeEnum);
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(areaListProvider.notifier).update((state) => result.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AddressModel> areaList = ref.watch(areaListProvider);
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
                          '내가 원하는 근무지역을\n10곳까지 선택할 수 있어요!',
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
                          'assets/images/icon/iconPinBig.png',
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
                    '희망 지역에서 제안을 받거나\n공고를 찾아볼 수 있어요.',
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
                      await DefineDialog.showAreaBottom(context, localization.selectRegion,
                          areaList, addWorkArea, selectedAreaList, maxLength);
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
                            localization.511,
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
                        localization.512,
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
                        '${selectedAreaList.length}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' / 10',
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
                      for (var i = 0; i < selectedAreaList.length; i++)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAreaList.removeAt(i);
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
                                  selectedAreaList[i].selectionName,
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
                text: localization.755,
                width: 96.w,
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    if (selectedAreaList.isNotEmpty) {
                      widget.setData('adIdx', selectedAreaKey);
                      widget.writeFunc('area');

                      widget.onPress();
                    }
                  },
                  text: localization.next,
                  fontSize: 15,
                  confirm: selectedAreaList.isNotEmpty,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
