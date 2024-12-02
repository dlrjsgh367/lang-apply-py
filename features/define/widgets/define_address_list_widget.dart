import 'dart:async';

import 'package:chodan_flutter_app/core/common/size_unit.dart';
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
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class DefineAddressListWidget extends ConsumerStatefulWidget {
  const DefineAddressListWidget(
      {required this.title,
      required this.addressList,
      required this.isOpen,
      required this.setIsOpen,
      required this.apply,
      required this.initSelectedList,
      required this.maxLength,
      super.key});

  final String title;
  final List<AddressModel> addressList;

  final List<AddressModel> initSelectedList;

  final bool isOpen;

  final Function(bool) setIsOpen;

  final Function apply;

  final int maxLength;

  @override
  ConsumerState<DefineAddressListWidget> createState() =>
      _DefineAddressListWidgetState();
}

class _DefineAddressListWidgetState
    extends ConsumerState<DefineAddressListWidget> {
  bool isSearchMode = false;

  final TextEditingController _searchController = TextEditingController();

  List<AddressModel> selectedList = [];

  List<int> selectedKeyList = [];

  int page = 1;

  int lastPage = 1;

  bool isLazeLoading = false;

  int adParent = 0;

  Timer? _debounce;

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  void selectItem(AddressModel item, {int depth = -1, bool isAll = false}) {
    setState(() {
      if (selectedKeyList.contains(item.key)) {
        deleteSelectedList(item);
      } else {
        if (selectedList.length < widget.maxLength) {
          if (isAll) {
            // 모든 하위 항목 제거
            if (depth == 2) {
              removeParentAll(item, depth);
            }
            removeAllChildren(item);
            // 전체 항목 추가
            addSelectedList(item, depth, isAll);
          } else {
            // 상위의 '전체' 선택 해제
            removeParentAll(item, depth);
            addSelectedList(item, depth, isAll);
          }
        }
      }
    });
  }

  void removeParentAll(AddressModel child, int childDepth) {
    AddressModel? parent = findParentAll(child, childDepth);
    while (parent != null) {
      deleteSelectedList(parent);
      parent = findParentAll(parent, getDepth(parent) - 1);
    }
  }

  AddressModel? findParentAll(AddressModel child, int childDepth) {
    if (childDepth == 3) {
      // 3뎁스인 경우, 2뎁스와 1뎁스를 확인
      for (var address in widget.addressList) {
        for (var subAddress in address.child) {
          if (subAddress.key == child.parentKey &&
              selectedKeyList.contains(subAddress.key) &&
              address.selectionName != '' &&
              subAddress.selectionName.endsWith(' ${localization.all}')) {
            return subAddress;
          }
        }
        if (address.key == getGrandParentKey(child) &&
            selectedKeyList.contains(address.key) &&
            address.selectionName != '' &&
            address.selectionName.endsWith(' ${localization.all}')) {
          return address;
        }
      }
    } else if (childDepth == 2) {
      // 2뎁스인 경우, 1뎁스만 확인
      for (var address in widget.addressList) {
        if (address.key == child.parentKey &&
            selectedKeyList.contains(address.key) &&
            address.selectionName != '' &&
            address.selectionName.endsWith(' ${localization.all}')) {
          return address;
        }
      }
    }
    return null;
  }

  int getDepth(AddressModel item) {
    if (item.dongName.isNotEmpty) return 3;
    if (item.gu.isNotEmpty) return 2;
    return 1;
  }

  int getGrandParentKey(AddressModel child) {
    for (var address in widget.addressList) {
      for (var subAddress in address.child) {
        if (subAddress.key == child.parentKey) {
          return address.key;
        }
      }
    }
    return -1;
  }

  void removeAllChildren(AddressModel parent) {
    selectedList.removeWhere((element) => isChildOf(element, parent));
    selectedKeyList.removeWhere(
        (key) => selectedList.every((element) => element.key != key));
  }

  bool isChildOf(AddressModel child, AddressModel parent) {
    if (child.parentKey == parent.key) {
      return true;
    }

    // 재귀적으로 상위 부모 확인
    AddressModel? currentParent = findAddressModelByKey(child.parentKey);
    while (currentParent != null) {
      if (currentParent.key == parent.key) {
        return true;
      }
      currentParent = findAddressModelByKey(currentParent.parentKey);
    }

    return false;
  }

  AddressModel? findAddressModelByKey(int key) {
    for (var address in widget.addressList) {
      if (address.key == key) return address;
      for (var child in address.child) {
        if (child.key == key) return child;
        // 3뎁스까지 검색
        for (var grandChild in child.child) {
          if (grandChild.key == key) return grandChild;
        }
      }
    }
    return null;
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

  void searchInputChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchDefine(value, page);
    });
  }

  @override
  void initState() {
    for (AddressModel item in widget.initSelectedList) {
      selectItem(item, depth: -1);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<AddressModel> searchList = ref.watch(searchAddressListProvider);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            context.pop();
          }
        }
      },
      child: GestureDetector(
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
                  controller: _searchController,
                  style: commonInputText(),
                  decoration: searchInput(
                    height: 50,
                    hintText: localization.searchRegion,
                    clearFunc: () {
                      _searchController.clear;
                      setState(() {
                        isSearchMode = false;
                        _searchController.text = '';
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
                                                  oneDepthData.child.length + 1,
                                              itemBuilder:
                                                  (context, depthTwoIndex) {
                                                if (depthTwoIndex == 0) {
                                                  return GestureDetector(
                                                    onTap: () {
                                                      selectItem(oneDepthData,
                                                          depth: 1,
                                                          isAll: true);
                                                    },
                                                    child: FilterCheckBtn(
                                                      backColor:
                                                          CommonColors.grayF2,
                                                      paddingLeft: 44,
                                                      active: selectedKeyList
                                                          .contains(
                                                              oneDepthData.key),
                                                      text:
                                                          '${oneDepthData.si} ${localization.all}',
                                                    ),
                                                  );
                                                } else {
                                                  final twoDepthData =
                                                      oneDepthData.child[
                                                          depthTwoIndex - 1];
                                                  return CollapseBtn(
                                                      openColor:
                                                          CommonColors.grayF2,
                                                      paddingLeft: 32,
                                                      backColor:
                                                          CommonColors.grayF7,
                                                      extraFunc: () async {
                                                        await getThreeDepthAddress(
                                                            depthOneIndex,
                                                            depthTwoIndex - 1,
                                                            twoDepthData.key);
                                                      },
                                                      title: twoDepthData.gu,
                                                      childArr: [
                                                        ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              const NeverScrollableScrollPhysics(),
                                                          itemCount:
                                                              twoDepthData.child
                                                                      .length +
                                                                  1,
                                                          itemBuilder: (context,
                                                              depthThreeIndex) {
                                                            // if (depthThreeIndex ==
                                                            //         0 &&
                                                            //     twoDepthData
                                                            //             .gu !=
                                                            //         '세종특별자치시') {
                                                            if (depthThreeIndex ==
                                                                0) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  selectItem(
                                                                      twoDepthData,
                                                                      depth: 2,
                                                                      isAll:
                                                                          true);
                                                                },
                                                                child:
                                                                    FilterCheckBtn(
                                                                  backColor:
                                                                      CommonColors
                                                                          .grayF2,
                                                                  paddingLeft:
                                                                      44,
                                                                  active: selectedKeyList
                                                                      .contains(
                                                                          twoDepthData
                                                                              .key),
                                                                  text:
                                                                      '${twoDepthData.gu} ${localization.all}',
                                                                ),
                                                              );
                                                            } else {
                                                              // final threeDepthData = twoDepthData
                                                              //             .gu !=
                                                              //         '세종특별자치시'
                                                              //     ? twoDepthData
                                                              //             .child[
                                                              //         depthThreeIndex -
                                                              //             1]
                                                              //     : twoDepthData
                                                              //             .child[
                                                              //         depthThreeIndex];
                                                              final threeDepthData =
                                                                  twoDepthData
                                                                          .child[
                                                                      depthThreeIndex -
                                                                          1];
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  selectItem(
                                                                      threeDepthData,
                                                                      depth: 3);
                                                                },
                                                                child:
                                                                    FilterCheckBtn(
                                                                  backColor:
                                                                      CommonColors
                                                                          .grayF2,
                                                                  paddingLeft:
                                                                      44,
                                                                  active: selectedKeyList
                                                                      .contains(
                                                                          threeDepthData
                                                                              .key),
                                                                  text: threeDepthData
                                                                      .dongName,
                                                                ),
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ]);
                                                }
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
                        onPressed: () {
                          widget.apply(selectedList, selectedKeyList, adParent);
                          Navigator.pop(context);
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
      ),
    );
  }
}
