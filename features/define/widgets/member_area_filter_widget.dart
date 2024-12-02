import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/filter/filter_check_btn.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MemberAreaFilterWidget extends ConsumerStatefulWidget {
  const MemberAreaFilterWidget({
    required this.title,
    required this.defineList,
    required this.apply,
    required this.initSelectedList,
    required this.maxLength,
    super.key});

  final String title;
  final List<ProfileAreaModel> defineList;

  final Function apply;

  final List<AreaInfoModel> initSelectedList;
  final int maxLength;

  @override
  ConsumerState<MemberAreaFilterWidget> createState() => _MemberAreaFilterWidgetState();
}

class _MemberAreaFilterWidgetState extends ConsumerState<MemberAreaFilterWidget> {

  List<int> selectedKeyList = [];

  List<AreaInfoModel> selectedList = [];

  changeSelect(dynamic item, bool isAll){
  selectedKeyList.removeLast();
  selectedList.removeLast();
  addSelectedList(item, isAll);
}

  selectItem(AreaInfoModel item, {bool isAll = false}) {
    setState(() {
      selectedKeyList.contains(item.key)
          ?
      deleteSelectedList(item)
          :
      selectedList.length >= widget.maxLength
          ?
            changeSelect(item, isAll)
          : addSelectedList(item, isAll);
    });
  }

  void clearSelectedList() {
    selectedList.clear();
    selectedKeyList.clear();
  }

  void deleteSelectedList(AreaInfoModel defineData) {
    selectedKeyList.remove(defineData.key);
    selectedList.removeWhere((element) => element.key == defineData.key);
  }

  void addSelectedList(AreaInfoModel defineData, bool isAll) {
    selectedKeyList.add(defineData.key);
    AreaInfoModel defineDataCopy = defineData;
    // if (isAll) {
    //   defineDataCopy.label =
    //       ConvertService.removeParentheses('${defineData['label']} 전체');
    // }
    selectedList.add(defineDataCopy);
  }

  @override
  void initState() {
    for(var item in widget.initSelectedList){
      selectItem(item);
    }
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBottomSheet(title: '${widget.title} ${localization.choice}'),
          Flexible(
            child: CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int depthOneIndex) {
                      final oneDepthData = widget.defineList[depthOneIndex].areaInfo;
                      return GestureDetector(
                        onTap: () {
                          selectItem(oneDepthData);
                        },
                        child: FilterCheckBtn(
                            active: selectedKeyList.contains(oneDepthData.key),
                            backColor: CommonColors.white,
                            text: oneDepthData.dongName),
                      );

                    },
                    childCount: widget.defineList.length,
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 20.w,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${selectedList.length} ',
                style: TextStyle(
                  fontSize: 13.w,
                  color: CommonColors.red,
                ),
              ),
              Text(
                ' / ${widget.maxLength}',
                style: TextStyle(
                  fontSize: 13.w,
                  color: CommonColors.grayB2,
                ),
              ),
              SizedBox(
                width: 20.w,
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
            child: Row(
              children: [
                for (AreaInfoModel item in selectedList)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        deleteSelectedList(item);
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 6.w),
                      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                      height: 35.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: CommonColors.white,
                        borderRadius: BorderRadius.circular(500.w),
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.red,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            item.dongName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                              color: CommonColors.red,
                            ),
                          ),
                          SizedBox(
                            width: 2.w,
                          ),
                          Image.asset(
                            'assets/images/icon/iconCloseXRed.png',
                            width: 18.w,
                            height: 18.w,
                          ),
                        ],
                      ),
                    ),
                  )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
            child: Row(
              children: [
                BorderButton(
                  onPressed: () {
                    setState(() {
                      clearSelectedList();
                    });
                  },
                  text: localization.reset,
                  width: 96.w,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: CommonButton(
                    fontSize: 15,
                    onPressed: () {
                      widget.apply(selectedList, selectedKeyList);
                      context.pop();
                    },
                    text: localization.apply2,
                    confirm: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
