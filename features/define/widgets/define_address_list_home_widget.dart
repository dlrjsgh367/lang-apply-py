import 'dart:async';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/collapse_btn.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/filter/filter_check_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class DefineAddressListHomeWidget extends ConsumerStatefulWidget {
  const DefineAddressListHomeWidget(
      {required this.title,
      required this.addressList,
      required this.isOpen,
      required this.setIsOpen,
      required this.apply,
      required this.initSelectedList,
      required this.defaultArea,
      required this.maxLength,
      required this.originPosition,
      super.key});

  final String title;
  final List<AddressModel> addressList;

  final List<AddressModel> initSelectedList;

  final bool isOpen;

  final Function(bool) setIsOpen;

  final Function apply;

  final AddressModel defaultArea;

  final int maxLength;
  final Map<String, dynamic> originPosition;

  @override
  ConsumerState<DefineAddressListHomeWidget> createState() =>
      _DefineAddressListHomeWidgetState();
}

class _DefineAddressListHomeWidgetState
    extends ConsumerState<DefineAddressListHomeWidget> {
  bool isSearchMode = false;

  final TextEditingController _searchController = TextEditingController();

  List<AddressModel> selectedList = [];

  List<int> selectedKeyList = [];

  int page = 1;

  int lastPage = 1;

  bool isLazeLoading = false;

  int adParent = 0;

  Timer? _debounce;

  void searchInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchDefine(value, page);
    });
  }

  searchDefine(String input, int page) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .searchArea(DefineEnum.area, input, page);
    if (result.status == 200) {
      if (result.type == 1) {
        if (page == 1) {
          setState(() {
            isSearchMode = true;
            ref
                .read(searchAddressListProvider.notifier)
                .update((state) => result.data);
          });
        } else {
          setState(() {
            ref
                .read(searchAddressListProvider.notifier)
                .update((state) => [...state, ...result.data]);
          });
        }
        lastPage = result.page['lastPage'];
        isLazeLoading = false;
      }
    }
  }

  void clearSelectedList() {
    selectedList.clear();
    selectedKeyList.clear();
  }

  void deleteSelectedList(AddressModel defineData) {
    selectedKeyList.remove(defineData.key);
    selectedList.removeWhere((element) => element.key == defineData.key);
  }

  selectionName(String origin, bool isAll) {
    if (isAll) {
      return '$origin ${localization.all}';
    } else {
      return origin;
    }
  }

  void addSelectedList(AddressModel addressData, int depth, bool isAll) {
    if (selectedKeyList.isEmpty) {
      adParent = addressData.parentKey;
    }

    selectedKeyList.add(addressData.key);
    AddressModel addressDataCopy = addressData;

    if (depth == 1) {
      addressDataCopy.selectionName = selectionName(addressDataCopy.si, isAll);
    } else if (depth == 2) {
      addressDataCopy.selectionName = selectionName(addressDataCopy.gu, isAll);
    } else {
      addressDataCopy.selectionName =
          selectionName(addressDataCopy.dongName, isAll);
    }
    selectedList.add(addressDataCopy);
  }

  selectItem(AddressModel item, {int depth = -1, bool isAll = false}) async {
    setState(() {
      selectedKeyList.contains(item.key)
          ? deleteSelectedList(item)
          : selectedList.length >= widget.maxLength
              ? changeSelect(item, depth, isAll)
              : addSelectedList(item, depth, isAll);
    });
  }

  changeSelect(dynamic item, int depth, bool isAll) {
    selectedKeyList.removeLast();
    selectedList.removeLast();
    addSelectedList(item, depth, isAll);
  }

  getThreeDepthAddress(
      int depthOneIndex, int depthTwoIndex, int parentKey) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .getAreaChildList(DefineEnum.area, parentKey);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref.read(areaListProvider.notifier).update((state) {
            state[depthOneIndex].child[depthTwoIndex].child = result.data;
            return [...state];
          });
        });
      }
    }
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        searchDefine(_searchController.text, page);
      });
    }
  }

  resetFilter(BuildContext context) async {
    clearSelectedList();

    AddressModel address = AddressModel(
      key: widget.defaultArea.key,
      parentKey: widget.defaultArea.parentKey,
      administCode: widget.defaultArea.administCode,
      si: widget.defaultArea.si,
      gu: widget.defaultArea.gu,
      dong: widget.defaultArea.dong,
      legalCode: widget.defaultArea.legalCode,
      dongName: widget.defaultArea.dongName,
      child: widget.defaultArea.child,
      selectionName: widget.defaultArea.selectionName,
      lat: widget.originPosition['lat'],
      lng: widget.originPosition['lng'],
    );

    selectItem(address, depth: -1);
  }

  @override
  void initState() {
    for (AddressModel item in widget.initSelectedList) {
      selectItem(item, depth: -1);
    }
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<AddressModel> searchList = ref.watch(searchAddressListProvider);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            0,
            8.w,
            0,
            CommonSize.keyboardBottom(context) +
                CommonSize.keyboardMediaHeight(context) +
                30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TitleBottomSheet(title: localization.selectRegion),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 8.w),
              child: TextFormField(
                cursorColor: Colors.black,
                controller: _searchController,
                style: commonInputText(),
                decoration: searchInput(
                  height: 50,
                  hintText: localization.searchRegion,
                  clearFunc: () {
                    _searchController.clear;
                    setState(() {
                      _searchController.text = '';
                      isSearchMode = false;
                    });
                    searchInputChanged(_searchController.text);
                  },
                ),
                onChanged: (value) {
                  page = 1;
                  searchInputChanged(value);
                },
              ),
            ),
            Flexible(
              child: LazyLoadScrollView(
                onEndOfPage: () => isSearchMode ? _loadMore() : null,
                child: CustomScrollView(
                  shrinkWrap: true,
                  slivers: [
                    _searchController.text != ''
                        ? SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                                final AddressModel oneDepthData =
                                    searchList[index];
                                return GestureDetector(
                                  onTap: () {
                                    selectItem(oneDepthData, depth: -1);
                                  },
                                  child: FilterCheckBtn(
                                    active: selectedKeyList
                                        .contains(oneDepthData.key),
                                    backColor: CommonColors.white,
                                    text:
                                        '${oneDepthData.si} ${oneDepthData.gu} ${oneDepthData.dongName}',
                                  ),
                                );
                              },
                              childCount: searchList.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int depthOneIndex) {
                                final oneDepthData =
                                    widget.addressList[depthOneIndex];
                                return oneDepthData.child.isNotEmpty
                                    ? CollapseBtn(
                                        childArr: [
                                          ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                oneDepthData.child.length,
                                            itemBuilder:
                                                (context, depthTwoIndex) {
                                              final twoDepthData = oneDepthData
                                                  .child[depthTwoIndex];
                                              return CollapseBtn(
                                                  openColor:
                                                      CommonColors.grayF2,
                                                  paddingLeft: 32,
                                                  backColor:
                                                      CommonColors.grayF7,
                                                  extraFunc: () async {
                                                    await getThreeDepthAddress(
                                                        depthOneIndex,
                                                        depthTwoIndex,
                                                        twoDepthData.key);
                                                  },
                                                  title: twoDepthData.gu,
                                                  childArr: [
                                                    ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount: twoDepthData
                                                          .child.length,
                                                      itemBuilder: (context,
                                                          depthThreeIndex) {
                                                        final threeDepthData =
                                                            twoDepthData.child[
                                                                depthThreeIndex];
                                                        return GestureDetector(
                                                          onTap: () {
                                                            selectItem(
                                                                threeDepthData,
                                                                depth: 3);
                                                          },
                                                          child: FilterCheckBtn(
                                                            backColor:
                                                                CommonColors
                                                                    .grayF2,
                                                            paddingLeft: 44,
                                                            active: selectedKeyList
                                                                .contains(
                                                                    threeDepthData
                                                                        .key),
                                                            text: threeDepthData
                                                                .dongName,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ]);
                                            },
                                          ),
                                        ],
                                        title: oneDepthData.si,
                                      )
                                    : FilterCheckBtn(
                                        active: selectedKeyList
                                            .contains(oneDepthData.key),
                                        backColor: CommonColors.white,
                                        text: oneDepthData.si);
                              },
                              childCount: widget.addressList.length,
                            ),
                          ),
                  ],
                ),
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
              padding: EdgeInsets.fromLTRB(16.w, 8.w, 16.w, 0),
              child: Row(
                children: [
                  for (var item in selectedList)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          deleteSelectedList(item);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
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
                              item.selectionName,
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
                        resetFilter(context);
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
                      onPressed: () {
                        if (selectedList.isNotEmpty) {
                          widget.apply(selectedList, selectedKeyList, adParent);
                          Navigator.pop(context);
                        } else {
                          showDefaultToast(localization.selectRegionPrompt);
                        }
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
      ),
    );
  }
}
