import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/models/event_comment_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EventDetailCommentListWidget extends ConsumerStatefulWidget {
  const EventDetailCommentListWidget(
      {required this.eventCommentItem,
      required this.reportComment,
      required this.deleteEventComment,
      required this.updateEventComment,
      required this.isReportable,
      super.key});

  final Function reportComment;
  final Function deleteEventComment;
  final Function updateEventComment;

  final EventCommentModel eventCommentItem;
  final bool isReportable;

  @override
  ConsumerState<EventDetailCommentListWidget> createState() =>
      _EventDetailCommentListWidgetState();
}

class _EventDetailCommentListWidgetState
    extends ConsumerState<EventDetailCommentListWidget> {
  returnCommentUser() {
    UserModel? userInfo = ref.read(userProvider);
    String name = widget.eventCommentItem.memberName;
    if (userInfo != null && userInfo.key != widget.eventCommentItem.memberKey) {
      name = maskName(widget.eventCommentItem.memberName);
    }
    return name;
  }

  String maskName(String name) {
    if (name.isEmpty || name == localization.withdrawnMember) return name;

    String masked = name[0] + '*' * (name.length - 1);
    return masked;
  }

  showBottom() {
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
        return ContentBottomSheet(contents: [
          BottomSheetButton(
              onTap: () {
                context.pop();
                widget.updateEventComment(widget.eventCommentItem.key);

              },
              text: localization.188),
          BottomSheetButton(
              onTap: () {
                context.pop();
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertTwoButtonDialog(
                        alertTitle: localization.189,
                        alertContent: localization.190,
                        alertConfirm: localization.delete,
                        alertCancel: localization.closed,
                        onConfirm: () {
                          widget
                              .deleteEventComment(widget.eventCommentItem.key);
                          context.pop();
                        },
                      );
                    });
              },
              text: localization.delete),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      returnCommentUser(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: CommonColors.black2b,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ConvertService.convertDateISOtoString(
                          widget.eventCommentItem.createdAt,
                          ConvertService.YYYY_MM_DD_HH_MM),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: CommonColors.gray80,
                      ),
                    )
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  if (widget.isReportable) {
                    widget.reportComment();
                  } else {
                    showBottom();
                  }
                },
                style: ButtonStyles.childBtn,
                child: Image.asset(
                  'assets/images/icon/iconKebab.png',
                  width: 20.w,
                  height: 20.w,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 14.w,
          ),
          Text(
            widget.eventCommentItem.comment,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: CommonColors.gray4d,
            ),
          ),
        ],
      ),
    );
  }
}
