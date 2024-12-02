import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InputProfileTitleWidget extends StatefulWidget {
  const InputProfileTitleWidget({
    super.key,
    this.title,
  });

  final String? title;

  @override
  State<InputProfileTitleWidget> createState() =>
      _InputProfileTitleWidgetState();
}

class _InputProfileTitleWidgetState extends State<InputProfileTitleWidget> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  final titleController = TextEditingController();
  String titleValue = '';

  @override
  void initState() {
    super.initState();

    if (widget.title != null) {
      titleController.text = widget.title!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return    PopScope(
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
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            context.pop();
          }
        },

        child:

        Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: '프로필 제목',
              ),
              body: CustomScrollView(
                slivers: [
                  const ProfileTitle(
                    title: '프로필 제목 입력',
                    required: false,
                    text: '',
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 18.w),
                    sliver: SliverToBoxAdapter(
                      child: Stack(
                        children: [
                        CommonKeyboardAction(
                        focusNode: textAreaNode,
                        child:
                        TextFormField(

                            onTap: () {
                              ScrollCenter(textAreaKey);
                            },
                            key: textAreaKey,
                            focusNode: textAreaNode,

                            controller: titleController,

                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            autocorrect: false,
                            cursorColor: CommonColors.black,
                            style: areaInputText(),
                            maxLength: 100,
                            textAlignVertical: TextAlignVertical.top,
                            decoration: areaInput(
                              hintText: '프로필 제목을 입력해주세요.',
                            ),
                            minLines: 3,
                            maxLines: 3,
                            onEditingComplete: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                            },
                            onChanged: (value) {
                              setState(() {
                                titleValue = value;
                              });
                            },
                          ),),
                          Positioned(
                            right: 10.w,
                            bottom: 10.w,
                            child: Text(
                              '${titleValue.length}/100',
                              style: TextStyles.counter,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBoard(context),
              child: CommonButton(
                fontSize: 15,
                confirm: titleController.text.isNotEmpty,
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    context.pop(titleController.text);
                  }
                },
                text: '입력하기',
              ),
            ),
          ],
        ),
      ),

    );
  }
}
