import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/filter/filter_check_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ReportReasonDialogWidget extends ConsumerStatefulWidget {
  const ReportReasonDialogWidget({
    super.key,
    required this.setReportReason,
    required this.showChatReportAlert,
  });

  final Function setReportReason;
  final Function showChatReportAlert;

  @override
  ConsumerState<ReportReasonDialogWidget> createState() =>
      _ReportReasonDialogWidgetState();
}

class _ReportReasonDialogWidgetState
    extends ConsumerState<ReportReasonDialogWidget> {
  int? selectReason;
  List reportList = [];

  // -------------- 신고 사유 목록 가져오기
  getReportReasonList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getReportReasonList();
    if (result.status == 200) {
      if (result.type == 1) {
        ref
            .read(reportReasonListProvider.notifier)
            .update((state) => result.data);
        setState(() {
          reportList = result.data;
        });
      }
    }
  }

  @override
  void initState() {
    Future(() {
      getReportReasonList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const TitleBottomSheet(title: '신고 사유'),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 10.w, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var data in reportList)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectReason = data.key;
                          widget.setReportReason(
                              {'key': data.key, 'reason': data.reason});
                        });
                      },
                      child: FilterCheckBtn(
                        backColor: CommonColors.white,
                        paddingLeft: 0,
                        paddingRight: 0,
                        active:
                            selectReason != null && selectReason! == data.key,
                        text: data.reason,
                      ),
                    ),

                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       selectReason = data.key;
                  //     });
                  //     Map<String, dynamic> value = {
                  //       'key': data.key,
                  //       'reason': data.reason
                  //     };
                  //     widget.setReportReason(value);
                  //   },
                  //   child: ColoredBox(
                  //     color: Colors.transparent,
                  //     child: Row(
                  //       children: [
                  //         Container(
                  //           width: 20.0,
                  //           height: 20.0,
                  //           decoration: BoxDecoration(
                  //             color: selectReason != null &&
                  //                 selectReason! == data.key
                  //                 ? Colors.red
                  //                 : Colors.grey,
                  //             borderRadius: const BorderRadius.all(
                  //                 Radius.circular(50.0)),
                  //           ),
                  //         ),
                  //         Text(data.reason),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 0),
            child: CommonButton(
              onPressed: () {
                if (selectReason != null) {
                  widget.showChatReportAlert(context);
                }
              },
              text: '신고하기',
              confirm: selectReason != null,
            ),
          ),
        ],
      ),
    );
    Wrap(
      children: [
        SizedBox(
          width: CommonSize.vw,
          child: Column(
            children: [
              Row(
                children: [
                  const Text('신고 사유'),
                  TextButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: const Icon(
                        Icons.close,
                        size: 30.0,
                      )),
                ],
              ),
              Column(
                children: [
                  for (var data in reportList)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectReason = data.key;
                        });
                        Map<String, dynamic> value = {
                          'key': data.key,
                          'reason': data.reason
                        };
                        widget.setReportReason(value);
                      },
                      child: ColoredBox(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: selectReason != null &&
                                        selectReason! == data.key
                                    ? Colors.red
                                    : Colors.grey,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(50.0)),
                              ),
                            ),
                            Text(data.reason),
                          ],
                        ),
                      ),
                    ),
                  ElevatedButton(
                      onPressed: () {
                        widget.showChatReportAlert(context);
                      },
                      child: const Text('신고하기')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
