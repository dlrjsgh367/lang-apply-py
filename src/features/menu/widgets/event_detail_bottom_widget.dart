import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/event_join_type_enum.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EventDetailBottomWidget extends ConsumerStatefulWidget {
  const EventDetailBottomWidget(
      {required this.eventItem,
      required this.applyEvent,
      required this.commentController,
      super.key});

  final BoardModel eventItem;
  final Function applyEvent;
  final TextEditingController commentController;

  @override
  ConsumerState<EventDetailBottomWidget> createState() =>
      _EventDetailBottomWidgetState();
}

class _EventDetailBottomWidgetState
    extends ConsumerState<EventDetailBottomWidget> {
  bool isJoin = false;

  @override
  void initState() {
    setState(() {
      isJoin = widget.eventItem.isJoined;
    });
    super.initState();
  }

  Future<void> _handleApplyEvent() async {
    var result = await widget.applyEvent(
        widget.eventItem.key, widget.eventItem.joinType);
    if (result) {
      setState(() {
        isJoin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.eventItem.joinType) {
      case EventJoinTypeEnum.apply:
        return Container(
          padding: EdgeInsets.fromLTRB(
              20.w, 8.w, 20.w, 8.w + CommonSize.safePaddingBottom),
          decoration: BoxDecoration(
            color: CommonColors.white,
          ),
          child: isJoin
              ? CommonButton(
                  fontSize: 15,
                  onPressed: () {
                    null;
                  },
                  text: '응모 완료',
                  confirm: false,
                )
              : CommonButton(
                  fontSize: 15,
                  onPressed: () {
                    _handleApplyEvent();
                  },
                  text: '응모하기',
                  confirm: true,
                ),
        );

      case EventJoinTypeEnum.comment:
        return Container(
          padding: EdgeInsets.fromLTRB(
            0,
            8.w,
            0,
            8.w +
                CommonSize.keyboardBottom(context) +
                CommonSize.keyboardMediaHeight(context),
          ),
          decoration: BoxDecoration(
            color: CommonColors.white,
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    controller: widget.commentController,
                    style: commonInputText(),
                    cursorColor: CommonColors.black,
                    decoration: commonInput(hintText: '댓글을 남겨보세요.'),
                    onEditingComplete: () {
                      if (widget.commentController.text.isNotEmpty) {
                        widget.applyEvent(
                            widget.eventItem.key, widget.eventItem.joinType);
                      }
                    },
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (widget.commentController.text.isNotEmpty) {
                    widget.applyEvent(
                        widget.eventItem.key, widget.eventItem.joinType);
                  }
                },
                style: ButtonStyles.childBtn,
                child: Image.asset(
                  widget.commentController.text.isNotEmpty
                      ? 'assets/images/icon/IconChatSendRed.png'
                      : 'assets/images/icon/IconChatSend.png',
                  width: 48.w,
                  height: 48.w,
                ),
              ),
            ],
          ),
        );
      case EventJoinTypeEnum.etc:
        return const SizedBox();
    }
  }
}
