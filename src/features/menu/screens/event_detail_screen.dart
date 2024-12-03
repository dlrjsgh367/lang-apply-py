import 'dart:async';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/branch_dynamiclink.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/event_join_type_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_comment_update_widget.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_detail_blocked_comment_widget.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_detail_bottom_widget.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_detail_comment_list_widget.dart';
import 'package:chodan_flutter_app/features/menu/widgets/event_detail_content_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/models/event_comment_model.dart';
import 'package:chodan_flutter_app/models/report_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/report_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:share_plus/share_plus.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({required this.idx, super.key});

  final String idx;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late Future<void> _allAsyncTasks;
  BoardModel? eventItem;
  bool isLoading = true;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<EventCommentModel> eventCommentList = [];
  final TextEditingController commentController = TextEditingController();
  final TextEditingController commentReportReasonController =
      TextEditingController();

  List<ReportModel> reportList = [];

  ReportModel? reportReason;

  setReportReason(ReportModel reason) {
    setState(() {
      reportReason = reason;
    });
  }

  setReportDetail(String stringValue) {
    setState(() {
      reportDetail = stringValue;
    });
  }

  String reportDetail = '';

  bool isRunning = false;
  Timer? runningTimer;

  final GlobalKey _key = GlobalKey();

  getEventDetail(int eventKey) async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getEventDetail(eventKey);
    if (result.status == 200) {
      if (result.type == 1) {
        eventItem = result.data;
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: localization.125,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
              context.pop();
            },
          );
        },
      );
    }
  }

  getEventDetailComment(int eventKey, int page) async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getEventDetailComment(eventKey, page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<EventCommentModel> data = result.data;
        if (page == 1) {
          eventCommentList = [...data];
        } else {
          eventCommentList = [...eventCommentList, ...data];
        }
        lastPage = result.page['lastPage'];
        setState(() {
          isLazeLoading = false;
        });
      }
    }
  }

  getReportReasonList() async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getReportReasonList();
    if (result.status == 200) {
      if (result.type == 1) {
        reportList = result.data;
      }
    }
  }

  bool isEmptyOrSpaces(String text) {
    return text.trim().isEmpty;
  }

  applyEvent(int eventKey, EventJoinTypeEnum eventJoinType) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (isRunning) {
      return false;
    } else {
      isRunning = true;
    }
    String? evComment;
    if (eventJoinType == EventJoinTypeEnum.comment) {
      if (!isEmptyOrSpaces(commentController.text)) {
        evComment = commentController.text;
      } else {
        //TODO : EVENT '' 값일때 댓글 입력이 가능한지에 대해서 문의 중
        showDefaultToast(localization.126);
        commentController.text = '';
        isRunning = false;
        return false;
      }
    }
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .applyEvent(eventKey, eventJoinType, evComment);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showDefaultToast(localization.127);
        if (eventJoinType == EventJoinTypeEnum.comment) {
          commentController.text = '';
          page = 1;
          getEventDetailComment(int.parse(widget.idx), page);
          Scrollable.ensureVisible(_key.currentContext!,
              alignment: 0.5, duration: const Duration(milliseconds: 500));
        }
        return true;
      }
    } else if (result.status == 412) {
      showDefaultToast(localization.126);
      return false;
    } else if (result.status == 409) {
      showDefaultToast(localization.128);
      return false;
    } else {
      showDefaultToast(localization.129);
      return false;
    }
  }

  reportEventComment(EventCommentModel eventComment) async {
    if (isRunning) {
      return;
    } else {
      isRunning = true;
    }
    if (reportReason == null) {
      isRunning = false;
      showDefaultToast(localization.130);
      return;
    }

    Map<String, dynamic> params = {
      'reCategory': 1,
      'reOriginal': eventComment.key,
      'reTitle': eventComment.comment,
      'reAccused': eventComment.memberKey,
      'reReason': reportReason!.key,
      'reDetail': reportDetail
    };

    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .reportEventComment(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        //TODO : EVENT 이벤트 신고 토스트 메세지 이미지 추가
        showDefaultToast(localization.reportSubmitted);
        if (mounted) {
          context.pop();
        }
      }
    } else if (result.status == 401) {
      showDefaultToast(localization.cannotReportYourOwnPost);
    } else if (result.status == 409) {
      showDefaultToast(localization.133);
    } else {
      showDefaultToast(localization.dataCommunicationFailed);
    }
  }

  deleteEventComment(int key) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).deleteEventComment(key);
    if (result.status == 200) {
      page = 1;
      getEventDetailComment(int.parse(widget.idx), page);
      showDefaultToast(localization.135);
    }
  }

  updateEventCommentAlert(int key) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return EventCommentUpdateWidget(
            updateEventComment: updateEventComment, commentKey: key);
      },
    );
  }

  updateEventComment(int key, String comment) async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .updateEventComment(key, comment);
    if (result.status == 200) {
      page = 1;
      getEventDetailComment(int.parse(widget.idx), page);
      showDefaultToast(localization.136);
      context.pop();
    }
  }

  void showReportAlert(String msg, [Function? afterFunc]) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
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
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter bottomState) {
            return ReportBottomSheet(
              title: localization.137,
              text: msg,
              afterFunc: afterFunc != null
                  ? () {
                      afterFunc();
                    }
                  : null,
              setData: (ReportModel value) {
                bottomState(() {
                  setReportReason(value);
                });
              },
              groupValue: reportReason,
              selectedValue: reportReason,
              textController: commentReportReasonController,
              reportList: reportList,
              setReportDetail: (String value) {
                bottomState(() {
                  setReportDetail(value);
                });
              },
            );
          });
        }).whenComplete(() {
      commentReportReasonController.text = '';
      setReportReason(reportList[0]);
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getEventDetail(int.parse(widget.idx)),
      getEventDetailComment(int.parse(widget.idx), page),
      getReportReasonList()
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.event.type);
  }

  @override
  void initState() {
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });

    super.initState();
  }

  BranchDynamicLink dynamicLink = BranchDynamicLink();

  void openShare(String url) async {
    Share.share(
      await dynamicLink.generateLink(context, url),
    );
    runningTimer = Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        isRunning = false;
      });
    });
  }

  @override
  void dispose() {
    commentController.dispose();
    commentReportReasonController.dispose();
    if (runningTimer != null && runningTimer!.isActive) {
      runningTimer!.cancel();
    }
    super.dispose();
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getEventDetailComment(int.parse(widget.idx), page);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.watch(userProvider);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: CommonAppbar(
          title: localization.event,
          actions: [
            AppbarButton(
              onPressed: () {
                if (!isRunning) {
                  setState(() {
                    isRunning = true;
                  });
                  // 활동 로그 쌓기
                  openShare('event/${widget.idx}');
                }
              },
              imgUrl: 'iconShare.png',
              plural: true,
            ),
          ],
        ),
        body: isLoading || eventItem == null
            ? const Loader()
            : Stack(
                alignment: Alignment.center,
                children: [
                  LazyLoadScrollView(
                    onEndOfPage: () => _loadMore(),
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: EventDetailContentWidget(
                            eventItem: eventItem!,
                          ),
                        ),
                        if (eventItem!.joinType == EventJoinTypeEnum.comment)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 8.w),
                              child: Container(
                                padding: EdgeInsets.only(top: 20.w),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      width: 1.w,
                                      color: CommonColors.grayE6,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '댓글 (${eventCommentList.length})',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (eventItem!.joinType == EventJoinTypeEnum.comment)
                          SliverList(
                            key: _key,
                            delegate: SliverChildBuilderDelegate(
                              childCount: eventCommentList.length,
                              (context, index) {
                                EventCommentModel eventCommentItem =
                                    eventCommentList[index];
                                return eventCommentItem.isBlocked
                                    ? const EventDetailBlockedCommentWidget()
                                    : EventDetailCommentListWidget(
                                        eventCommentItem: eventCommentItem,
                                        deleteEventComment: deleteEventComment,
                                        updateEventComment:
                                            updateEventCommentAlert,
                                        reportComment: () {
                                          showReportAlert('신고', () {
                                            reportEventComment(
                                                eventCommentItem);
                                          });
                                        },
                                        isReportable: userInfo!.key !=
                                            eventCommentItem.memberKey);
                              },
                            ),
                          ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                              height: 16.w +
                                  50.w +
                                  30.w +
                                  CommonSize.keyboardBottom(context)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: EventDetailBottomWidget(
                      eventItem: eventItem!,
                      applyEvent: applyEvent,
                      commentController: commentController,
                    ),
                  ),
                  if (isLazeLoading)
                    Positioned(
                      bottom: CommonSize.commonBottom,
                      child: const Loader(),
                    ),
                ],
              ),
      ),
    );
  }
}
