// import 'dart:async';
//
// import 'package:chodan_flutter_app/core/common/size_unit.dart';
// import 'package:chodan_flutter_app/core/utils/convert_service.dart';
// import 'package:chodan_flutter_app/enum/define_enum.dart';
// import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
// import 'package:chodan_flutter_app/models/api_result_model.dart';
// import 'package:chodan_flutter_app/models/define_model.dart';
// import 'package:chodan_flutter_app/style/color_style.dart';
// import 'package:chodan_flutter_app/style/input_style.dart';
// import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
// import 'package:chodan_flutter_app/widgets/button/border_button.dart';
// import 'package:chodan_flutter_app/widgets/button/collapse_btn.dart';
// import 'package:chodan_flutter_app/widgets/button/common_button.dart';
// import 'package:chodan_flutter_app/widgets/filter/filter_check_btn.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
//
// class DefineJobListWidget extends ConsumerStatefulWidget {
//   const DefineJobListWidget(
//       {required this.title,
//       required this.defineList,
//       required this.isOpen,
//       required this.setIsOpen,
//       required this.apply,
//       required this.initSelectedList,
//       required this.maxLength,
//       this.setData,
//       required this.defineType,
//       required this.selectedJobList,
//       required this.selectedJobKeyList,
//       super.key});
//
//   final String title;
//   final List defineList;
//
//   final bool isOpen;
//
//   final Function(bool) setIsOpen;
//   final Function apply;
//
//   final List initSelectedList;
//   final DefineEnum defineType;
//   final int maxLength;
//
//   final Function? setData;
//
//   final List selectedJobList;
//   final List selectedJobKeyList;
//
//   @override
//   ConsumerState<DefineJobListWidget> createState() =>
//       _DefineJobListWidgetState();
// }
//
// class _DefineJobListWidgetState extends ConsumerState<DefineJobListWidget> {
//   final TextEditingController _searchController = TextEditingController();
//
//   int page = 1;
//
//   int lastPage = 1;
//
//   bool isLazeLoading = false;
//   List selectedJobList = [];
//   List<int> selectedJobKeyList = [];
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future _loadMore() async {
//     if (isLazeLoading) {
//       return;
//     }
//     if (lastPage > 1 && page + 1 <= lastPage) {
//       setState(() {
//         isLazeLoading = true;
//         page = page + 1;
//         searchDefine(_searchController.text, page);
//       });
//     }
//   }
//
//   Timer? _debounce;
//
//   void searchInputChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       searchDefine(value, page);
//     });
//   }
//
//   searchDefine(String input, int page) async {
//     ApiResultModel result = await ref
//         .read(defineControllerProvider.notifier)
//         .searchDefine(widget.defineType, input);
//     if (result.status == 200) {
//       if (result.type == 1) {
//         if (page == 1) {
//           setState(() {
//             ref
//                 .read(searchDefineListProvider.notifier)
//                 .update((state) => result.data);
//           });
//         } else {
//           setState(() {
//             ref
//                 .read(searchDefineListProvider.notifier)
//                 .update((state) => [...state, ...result.data]);
//           });
//         }
//         lastPage = result.page['lastPage'];
//         isLazeLoading = false;
//       }
//     }
//   }
//
//   void clearSelectedList() {
//     selectedList.clear();
//     selectedKeyList.clear();
//   }
//
//   void deleteSelectedList(DefineModel defineData) {
//     selectedKeyList.remove(defineData.key);
//     selectedList.removeWhere((element) => element.key == defineData.key);
//   }
//
//   void addSelectedList(DefineModel defineData, bool isAll) {
//     DefineModel defineDataCopy = DefineModel.copy(defineData);
//     if (isAll) {
//       defineDataCopy.name =
//           ConvertService.removeParentheses('${defineData.name} 전체');
//     }
//     selectedJobKeyList.add(defineData.key);
//     selectedJobList.add(defineDataCopy);
//   }
//
//   selectItem(DefineModel item, {bool isAll = false}) {
//     setState(() {
//       selectedJobKeyList.contains(item.key)
//           ? deleteSelectedList(item)
//           : selectedJobList.length >= widget.maxLength
//               ? null
//               : addSelectedList(item, isAll);
//     });
//   }
//
//   returnSearchName(DefineModel item) {
//     String name = item.name;
//     if ((widget.defineType == DefineEnum.job ||
//             widget.defineType == DefineEnum.industry) &&
//         item.parent != null &&
//         item.parent!.key != 0) {
//       name = '${item.name} ( ${setJobParentName('', item.parent)} )';
//     }
//     return name;
//   }
//
//   setJobParentName(String name, DefineModel? item) {
//     String jobName = name;
//     if (item != null) {
//       if (jobName != '') {
//         jobName = '$name < ${item.name}';
//       } else {
//         jobName = item.name;
//       }
//       if (item.parent != null && item.parent!.key != 0) {
//         jobName = setJobParentName(jobName, item.parent);
//       }
//     }
//     return jobName;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<DefineModel> searchList = ref.watch(searchDefineListProvider);
//     return PopScope(
//       canPop: false,
//       onPopInvoked: (didPop) {
//         if (MediaQuery.of(context).viewInsets.bottom > 0) {
//           FocusScope.of(context).unfocus();
//         } else {
//           if (!didPop) {
//             context.pop();
//           }
//         }
//       },
//       child: Padding(
//         padding: EdgeInsets.fromLTRB(
//             0,
//             0,
//             0,
//             CommonSize.keyboardBottom(context) +
//                 CommonSize.keyboardMediaHeight(context) +
//                 30.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TitleBottomSheet(title: '${widget.title} 선택'),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
//               child: TextFormField(
//                 controller: _searchController,
//                 style: commonInputText(),
//                 cursorColor: CommonColors.black,
//                 maxLines: 1,
//                 minLines: null,
//                 decoration: searchInput(
//                   hintText: '${widget.title}을 검색해주세요',
//                   clearFunc: () {
//                     _searchController.clear;
//                     setState(() {
//                       _searchController.text = '';
//                     });
//
//                     searchInputChanged(_searchController.text);
//                   },
//                   height: 50,
//                 ),
//                 onChanged: (value) {
//                   page = 1;
//                   searchInputChanged(value);
//                 },
//               ),
//             ),
//             Flexible(
//               child: LazyLoadScrollView(
//                 onEndOfPage: () =>
//                     _searchController.text != '' ? _loadMore() : null,
//                 child: CustomScrollView(
//                   shrinkWrap: true,
//                   slivers: [
//                     _searchController.text != ''
//                         ? SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (BuildContext context, int index) {
//                                 final oneDepthData = searchList[index];
//                                 return GestureDetector(
//                                   onTap: () {
//                                     selectItem(oneDepthData);
//                                   },
//                                   child: FilterCheckBtn(
//                                       active: selectedJobKeyList
//                                           .contains(oneDepthData.key),
//                                       backColor: CommonColors.white,
//                                       text: returnSearchName(oneDepthData)),
//                                 );
//                               },
//                               childCount: searchList.length,
//                             ),
//                           )
//                         : SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (BuildContext context, int depthOneIndex) {
//                                 final oneDepthData =
//                                     widget.defineList[depthOneIndex];
//                                 return oneDepthData.child.isNotEmpty
//                                     ? CollapseBtn(
//                                         childArr: [
//                                           ListView.builder(
//                                             shrinkWrap: true,
//                                             physics:
//                                                 const NeverScrollableScrollPhysics(),
//                                             itemCount:
//                                                 oneDepthData.child.length + 1,
//                                             itemBuilder:
//                                                 (context, depthTwoIndex) {
//                                               if (depthTwoIndex == 0) {
//                                                 return GestureDetector(
//                                                   onTap: () {
//                                                     selectItem(oneDepthData,
//                                                         isAll: true);
//
//                                                     if (widget.setData !=
//                                                         null) {
//                                                       widget.setData!(
//                                                           'formattedDepthName',
//                                                           widget
//                                                               .defineList[
//                                                                   depthOneIndex]
//                                                               .name);
//                                                     }
//                                                   },
//                                                   child: FilterCheckBtn(
//                                                       active: selectedJobKeyList
//                                                           .contains(
//                                                               oneDepthData.key),
//                                                       backColor:
//                                                           CommonColors.grayF7,
//                                                       text:
//                                                           '${oneDepthData.name} 전체'),
//                                                 );
//                                               } else {
//                                                 final twoDepthData =
//                                                     oneDepthData.child[
//                                                         depthTwoIndex - 1];
//                                                 return twoDepthData
//                                                         .child.isNotEmpty
//                                                     ? CollapseBtn(
//                                                         openColor:
//                                                             CommonColors.grayF2,
//                                                         paddingLeft: 32,
//                                                         backColor:
//                                                             CommonColors.grayF7,
//                                                         title:
//                                                             twoDepthData.name,
//                                                         childArr: [
//                                                             ListView.builder(
//                                                               shrinkWrap: true,
//                                                               physics:
//                                                                   const NeverScrollableScrollPhysics(),
//                                                               itemCount:
//                                                                   twoDepthData
//                                                                           .child
//                                                                           .length +
//                                                                       1,
//                                                               itemBuilder: (context,
//                                                                   depthThreeIndex) {
//                                                                 if (depthThreeIndex ==
//                                                                     0) {
//                                                                   return GestureDetector(
//                                                                     onTap: () {
//                                                                       selectItem(
//                                                                           twoDepthData,
//                                                                           isAll:
//                                                                               true);
//
//                                                                       if (widget
//                                                                               .setData !=
//                                                                           null) {
//                                                                         widget.setData!(
//                                                                             'formattedDepthName',
//                                                                             '${widget.defineList[depthOneIndex].name} > ${widget.defineList[depthOneIndex].child[depthTwoIndex - 1].name}');
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         FilterCheckBtn(
//                                                                       backColor:
//                                                                           CommonColors
//                                                                               .grayF2,
//                                                                       paddingLeft:
//                                                                           44,
//                                                                       active: selectedJobKeyList
//                                                                           .contains(
//                                                                               twoDepthData.key),
//                                                                       text:
//                                                                           '${twoDepthData.name} 전체',
//                                                                     ),
//                                                                   );
//                                                                 } else {
//                                                                   final threeDepthData =
//                                                                       twoDepthData
//                                                                               .child[
//                                                                           depthThreeIndex -
//                                                                               1];
//                                                                   return GestureDetector(
//                                                                     onTap: () {
//                                                                       selectItem(
//                                                                           threeDepthData);
//
//                                                                       if (widget
//                                                                               .setData !=
//                                                                           null) {
//                                                                         widget.setData!(
//                                                                             'formattedDepthName',
//                                                                             '${widget.defineList[depthOneIndex].name} > ${widget.defineList[depthOneIndex].child[depthTwoIndex - 1].name} > ${widget.defineList[depthOneIndex].child[depthTwoIndex - 1].child[depthThreeIndex - 1].name}');
//                                                                       }
//                                                                     },
//                                                                     child:
//                                                                         FilterCheckBtn(
//                                                                       backColor:
//                                                                           CommonColors
//                                                                               .grayF2,
//                                                                       paddingLeft:
//                                                                           44,
//                                                                       active: selectedJobKeyList
//                                                                           .contains(
//                                                                               threeDepthData.key),
//                                                                       text: threeDepthData
//                                                                           .name,
//                                                                     ),
//                                                                   );
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ])
//                                                     : CollapseBtn(
//                                                         openColor:
//                                                             CommonColors.grayF2,
//                                                         paddingLeft: 32,
//                                                         backColor:
//                                                             CommonColors.grayF7,
//                                                         title:
//                                                             twoDepthData.name,
//                                                         childArr: [
//                                                           GestureDetector(
//                                                             onTap: () {
//                                                               selectItem(
//                                                                   twoDepthData);
//                                                             },
//                                                             child:
//                                                                 FilterCheckBtn(
//                                                               active: selectedJobKeyList
//                                                                   .contains(
//                                                                       twoDepthData
//                                                                           .key),
//                                                               backColor:
//                                                                   CommonColors
//                                                                       .grayF7,
//                                                               paddingLeft: 32,
//                                                               text: twoDepthData
//                                                                   .name,
//                                                             ),
//                                                           )
//                                                         ],
//                                                       );
//                                               }
//                                             },
//                                           ),
//                                         ],
//                                         title: ConvertService.removeParentheses(
//                                             oneDepthData.name),
//                                       )
//                                     : GestureDetector(
//                                         onTap: () {
//                                           selectItem(oneDepthData);
//                                         },
//                                         child: FilterCheckBtn(
//                                             active: selectedJobKeyList
//                                                 .contains(oneDepthData.key),
//                                             backColor: CommonColors.white,
//                                             text: oneDepthData.name),
//                                       );
//                               },
//                               childCount: widget.defineList.length,
//                             ),
//                           ),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 20.w,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Text(
//                   '${selectedJobList.length} ',
//                   style: TextStyle(
//                     fontSize: 13.w,
//                     color: CommonColors.red,
//                   ),
//                 ),
//                 Text(
//                   ' / ${widget.maxLength}',
//                   style: TextStyle(
//                     fontSize: 13.w,
//                     color: CommonColors.grayB2,
//                   ),
//                 ),
//                 SizedBox(
//                   width: 20.w,
//                 ),
//               ],
//             ),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 0),
//               child: Row(
//                 children: [
//                   for (var item in selectedJobList)
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           deleteSelectedList(item);
//                         });
//                       },
//                       child: Container(
//                         margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
//                         padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
//                         height: 35.w,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: CommonColors.white,
//                           borderRadius: BorderRadius.circular(500.w),
//                           border: Border.all(
//                             width: 1.w,
//                             color: CommonColors.red,
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               item.name,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w500,
//                                 fontSize: 12.sp,
//                                 color: CommonColors.red,
//                               ),
//                             ),
//                             SizedBox(
//                               width: 2.w,
//                             ),
//                             Image.asset(
//                               'assets/images/icon/iconCloseXRed.png',
//                               width: 18.w,
//                               height: 18.w,
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
//               child: Row(
//                 children: [
//                   BorderButton(
//                     onPressed: () {
//                       setState(() {
//                         clearSelectedList();
//                       });
//                     },
//                     text: '초기화',
//                     width: 96.w,
//                   ),
//                   SizedBox(
//                     width: 8.w,
//                   ),
//                   Expanded(
//                     child: CommonButton(
//                       fontSize: 15,
//                       onPressed: () {
//                         widget.apply(selectedJobList, selectedJobKeyList);
//                         context.pop();
//                       },
//                       text: '적용',
//                       confirm: true,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
