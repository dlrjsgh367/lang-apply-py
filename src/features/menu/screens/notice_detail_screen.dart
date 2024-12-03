import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

class NoticeDetailScreen extends ConsumerStatefulWidget {
  const NoticeDetailScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends ConsumerState<NoticeDetailScreen>
    with Alerts {
  late BoardModel noticeDetailData;
  bool isLoading = true;

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
      getNoticeDetailData(widget.idx),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  getNoticeDetailData(String idx) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getBoardDetailData(idx);
    if (result.type == 1) {
      setState(() {
        noticeDetailData = result.data;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  String noticeType(int intValue){
    switch(intValue){
      case 2:
        return localization.guide;
      case 3:
        return localization.event;
        default:
          return localization.guide;
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
        title: localization.144,
      ),
      body: !isLoading
          ? SingleChildScrollView(
              padding: EdgeInsets.only(bottom: CommonSize.commonBottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(20.w, 12.w, 20.w, 12.w),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CommonColors.grayE6,
                          width: 1.w,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "[${noticeDetailData.boardTypeName}]  ${noticeDetailData.title}",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CommonColors.gray4d,
                          ),
                        ),
                        SizedBox(
                          height: 8.w,
                        ),
                        Text(
                          DateFormat('yyyy.MM.dd HH:mm').format(
                            DateTime.parse(
                              noticeDetailData.createdAt.replaceAll("T", " "),
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: CommonColors.gray80,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 0),
                    child: Html(
                      data: noticeDetailData.content,
                    ),
                  ),
                ],
              ),
            )
          : const Loader(),
    );
  }
}
