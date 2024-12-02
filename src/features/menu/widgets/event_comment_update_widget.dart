import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EventCommentUpdateWidget extends StatefulWidget {
  EventCommentUpdateWidget(
      {super.key, required this.updateEventComment, required this.commentKey});

  Function updateEventComment;
  int commentKey;

  @override
  State<EventCommentUpdateWidget> createState() =>
      _EventCommentUpdateWidgetState();
}

class _EventCommentUpdateWidgetState extends State<EventCommentUpdateWidget> {
  TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        16.w,
        0,
        8.w +
            CommonSize.keyboardBottom(context) +
            CommonSize.keyboardMediaHeight(context),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                  child: Row(children: [
                    GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Container(
                        height: 24.w,
                        width: 24.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(500.w),
                            color: CommonColors.red),
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/icon/iconX.png',
                          width: 16.w,
                          height: 16.w,
                          color: Colors.white, // 이미지 색상을 하얀색으로 변경
                        ),
                      ),
                    ),
                  ]),
                ),
                Expanded(
                  child: Text(
                    '댓글 수정',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: SizedBox()),
                SizedBox(
                  width: 20.w,
                ),
              ],
            ),
            SizedBox(
              height: 20.w,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {});
                      },
                      controller: commentController,
                      style: commonInputText(),
                      cursorColor: CommonColors.black,
                      decoration: commonInput(hintText: '댓글을 입력해주세요.'),
                      onEditingComplete: () {},
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (commentController.text != '') {
                        widget.updateEventComment(
                            widget.commentKey, commentController.text);
                      }
                    },
                    style: ButtonStyles.childBtn,
                    child: Image.asset(
                      commentController.text != ''
                          ? 'assets/images/icon/IconChatSendRed.png'
                          : 'assets/images/icon/IconChatSend.png',
                      width: 48.w,
                      height: 48.w,
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
