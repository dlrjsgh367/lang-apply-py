import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/title_item.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/etc/sliver_divider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

class MyConsultDetailScreen extends ConsumerStatefulWidget {
  const MyConsultDetailScreen({
    super.key,
    required this.idx,
  });

  final String idx;

  @override
  ConsumerState<MyConsultDetailScreen> createState() =>
      _MyConsultDetailScreenState();
}

class _MyConsultDetailScreenState extends ConsumerState<MyConsultDetailScreen>
    with Alerts, Files {
  late BoardModel boardDetailData;
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
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getNoticeDetailData(String idx) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getBoardDetailData(idx);
    if (result.type == 1) {
      setState(() {
        boardDetailData = result.data;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  deleteBoard() async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).deleteBoard(widget.idx);
    if (result.status == 200 && result.type == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.consultationDeleted,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  askDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.deleteConsultation,
          alertContent: localization.confirmConsultationDeletion,
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            deleteBoard();
            context.pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _allAsyncTasks.whenComplete(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.read(userProvider);
    return Scaffold(
      appBar: const CommonAppbar(
        title: localization.consultationForm,
      ),
      body: !isLoading
          ? Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.all(20.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              localization.consultationTitle,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.black2b),
                            ),
                            Expanded(
                              child: Text(
                                DateFormat('yyyy.MM.dd').format(
                                  DateTime.parse(
                                    boardDetailData.createdAt
                                        .replaceAll("T", " "),
                                  ),
                                ),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            border: Border.all(
                              width: 1.w,
                              color: CommonColors.grayF2,
                            ),
                          ),
                          child: Text(
                            boardDetailData.title,
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.black2b),
                          ),
                        ),
                      ),
                    ),
                    const TitleItem(title: localization.consultationContent),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            border: Border.all(
                              width: 1.w,
                              color: CommonColors.grayF2,
                            ),
                          ),
                          child: Text(
                            boardDetailData.content,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.black2b,
                              fontWeight: FontWeight.w500,
                            ),

                          ),
                        ),
                      ),
                    ),
                    const TitleItem(title: localization.attachment),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (boardDetailData.files.isNotEmpty) {
                                  fileDownload(boardDetailData.files[0].url,
                                      boardDetailData.files[0].name);
                                }
                              },
                              child: Container(
                                height: 80.w,
                                width: 80.w,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: CommonColors.grayF7,
                                  borderRadius: BorderRadius.circular(8.w),
                                ),
                                child: boardDetailData.files.isNotEmpty
                                    ? ExtendedImgWidget(
                                        imgUrl: boardDetailData.files[0].url,
                                        imgWidth: 80.w,
                                        imgHeight: 80.w,
                                        imgFit: BoxFit.cover,
                                      )
                                    : const Center(
                                        child: Text("-"),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverDivider(),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 36.w, 20.w, 20.w),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Text(
                              localization.consultationResponse,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.black2b),
                            ),
                            if (boardDetailData.relatedResList != null)
                              Expanded(
                                child: Text(
                                  DateFormat('yyyy.MM.dd').format(
                                    DateTime.parse(boardDetailData
                                        .relatedResList!.createdAt
                                        .replaceAll("T", " ")),
                                  ),
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray80),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 20.w),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                          decoration: BoxDecoration(
                            color: CommonColors.grayF7,
                            borderRadius: BorderRadius.circular(8.w),
                          ),
                          child: Text(
                            boardDetailData.boStatus == "DONE"
                                ? boardDetailData.relatedResList!.content
                                : localization.noResponsesRegistered,
                            textAlign: boardDetailData.boStatus == "DONE"
                                ? TextAlign.left
                                : TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray80,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (boardDetailData.boStatus == "DONE" &&
                        boardDetailData.relatedResList != null &&
                        boardDetailData.relatedResList!.files.isNotEmpty)
                      const TitleItem(title: localization.attachment),
                    if (boardDetailData.boStatus == "DONE" &&
                        boardDetailData.relatedResList != null &&
                        boardDetailData.relatedResList!.files.isNotEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 36.w),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  fileDownload(
                                      boardDetailData
                                          .relatedResList!.files[0].url,
                                      boardDetailData
                                          .relatedResList!.files[0].name);
                                },
                                child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    padding: EdgeInsets.fromLTRB(
                                        20.w, 5.w, 20.w, 5.w),
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: Text(
                                      boardDetailData
                                          .relatedResList!.files[0].name,
                                      textAlign:
                                          boardDetailData.boStatus == "DONE"
                                              ? TextAlign.left
                                              : TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray80,
                                      ),
                                    )),
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
                if (boardDetailData.writeKey == userInfo?.key)
                  Positioned(
                    left: 20.w,
                    right: 20.w,
                    bottom: CommonSize.commonBottom,
                    child: boardDetailData.boStatus != "DONE"
                        ? Row(
                            children: [
                              BorderButton(
                                width: 96.w,
                                onPressed: () {
                                  askDelete();
                                },
                                text: localization.delete,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: CommonButton(
                                  onPressed: () {
                                    context
                                        .push(
                                            '/my/consult/create/${widget.idx}')
                                        .then(
                                          (_) =>
                                              {getNoticeDetailData(widget.idx)},
                                        );
                                  },
                                  text: localization.editPost,
                                  confirm: true,
                                ),
                              ),
                            ],
                          )
                        : CommonButton(
                            fontSize: 15,
                            onPressed: () {
                              askDelete();
                            },
                            text: localization.deletePost,
                            confirm: true),
                  ),
              ],
            )
          : const Loader(),
    );
  }
}
