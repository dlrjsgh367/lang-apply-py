import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:chodan_flutter_app/models/board_model.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/widgets/etc/box_board.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

class NoticeScreen extends ConsumerStatefulWidget {
  const NoticeScreen({super.key});

  @override
  ConsumerState<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends ConsumerState<NoticeScreen> with Alerts {
  List<BoardModel> boardList = [];
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
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
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getNoticeListData(page);
    if (result.type == 1) {
      setState(() {
        List<BoardModel> data = result.data;
        if (page == 1) {
          boardList = [...data];
        } else {
          boardList = [...boardList, ...data];
        }
        lastPage = result.page['lastPage'];
        total = result.page['total'];
        isLazeLoading = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.announcement,
      ),
      body: !isLoading
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 4.w),
                  child: Text(
                    "총 $total건",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: CommonColors.gray66,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: LazyLoadScrollView(
                      onEndOfPage: _boardLoadMore,
                      child: ListView.builder(
                        padding:
                        EdgeInsets.only(bottom: CommonSize.commonBottom),
                        itemCount: boardList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return BoxBoard(
                            type:boardList[index].boardType,
                            typeName : boardList[index].boardTypeName,
                            index: index,
                            onTap: () {
                              context.push('/notice/${boardList[index].key}');
                            },
                            title:
                                boardList[index].title,
                            text: DateFormat('yyyy.MM.dd HH:mm').format(
                              DateTime.parse(boardList[index]
                                  .createdAt
                                  .replaceAll("T", " ")),
                            ),
                          );
                        },
                      )),
                ),
              ],
            )
          : const Loader(),
    );
  }
}
