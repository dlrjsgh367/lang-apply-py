import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/faq_collapse_btn.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/faq_category_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_category_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

class FaqScreen extends ConsumerStatefulWidget {
  const FaqScreen({super.key});

  @override
  ConsumerState<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends ConsumerState<FaqScreen> with Alerts {
  List<BoardModel> boardList = [];
  List<BoardCategoryModel> boardCategoryList = [];
  int _selectedBoardCategory = 0;
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  late Future<void> _allAsyncTasks;

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getBoardListData(page),
      getBoardCategoryListData(),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  _boardLoadMore() async {
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
      });
      page = page + 1;
      getBoardListData(page);
    }
  }

  getBoardListData(int page) async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getFaqListData(page, _selectedBoardCategory);
    if (result.type == 1) {
      setState(() {
        List<BoardModel> data = result.data;
        if (page == 1) {
          boardList = [...data];
          collapseArr = List.filled(result.page['total'], 0);
        } else {
          boardList = [...boardList, ...data];
        }
        lastPage = result.page['lastPage'];
        isLazeLoading = false;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  getBoardCategoryListData() async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getBoardCategoryListData('16');
    if (result.type == 1) {
      setState(() {
        List<BoardCategoryModel> data = result.data;

        boardCategoryList = [
          BoardCategoryModel.fromParams(0, 0, 0, localization.all, localization.all),
          ...data
        ];
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  @override
  void dispose() {
    _allAsyncTasks.whenComplete(() {});
    super.dispose();
  }

  List<int> collapseArr = [];

  setCollapse(index) {
    setState(() {
      if (collapseArr[index] == 1) {
        collapseArr[index] = 0;
      } else {
        collapseArr[index] = 1;
      }
    });
  }

  isContain(index) {
    if (collapseArr[index] == 1) {
      return true;
    } else {
      return false;
    }
  }

  showFaqCategory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FaqCategoryBottomSheet(
            boardCategoryList: boardCategoryList, initItem: selectItem);
      },
    ).then((value) => setState(() {
          selectItem = value;
          _selectedBoardCategory = selectItem.bcIdx;
          getBoardListData(1);
        }));
  }

  BoardCategoryModel selectItem =
      BoardCategoryModel.fromParams(0, 0, 0, localization.all, localization.all);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: 'FAQ',
      ),
      body: !isLoading
          ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: SelectButton(
                      onTap: () {
                        showFaqCategory();
                      },
                      text: selectItem.bcName,
                      hintText: localization.141),
                ),
                Expanded(
                  child:  boardList.isNotEmpty? 
                  LazyLoadScrollView(
                    onEndOfPage: _boardLoadMore,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          20.w, 20.w, 20.w, CommonSize.commonBottom),
                      itemCount: boardList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return FaqCollapseBtn(
                            childArr: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0.w, 0, 20.w),
                                child: Container(
                                  padding: EdgeInsets.all(20.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.w),
                                    color: CommonColors.grayF7,
                                  ),
                                  child: Html(
                                    data: boardList[index].content,
                                  ),
                                ),
                              ),
                            ],
                            title:
                                "[${boardList[index].boardTypeName}] ${boardList[index].title}");
                      },
                    ),
                  ):CommonEmpty(text: localization.142),
                ),
              ],
            )
          : const Loader(),
    );
  }
}
