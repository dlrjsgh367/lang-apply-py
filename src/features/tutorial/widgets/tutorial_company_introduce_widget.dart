import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TutorialCompanyIntroduceWidget extends ConsumerStatefulWidget {
  const TutorialCompanyIntroduceWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialCompanyIntroduceWidget> createState() =>
      _TutorialCompanyIntroduceWidgetState();
}

class _TutorialCompanyIntroduceWidgetState
    extends ConsumerState<TutorialCompanyIntroduceWidget> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  final companyIntroduceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    companyIntroduceController.text = widget.data['mcIntroduce'];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: CommonColors.red02,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localization.767,
                          style: TextStyle(
                            color: CommonColors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                      Text(
                        localization.companyIntroduction,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          color: CommonColors.black2b,
                        ),
                      ),
                      SizedBox(height: 20.w),
                      Stack(
                        children: [
                          CommonKeyboardAction(
                            focusNode: textAreaNode,
                            child: TextFormField(
                              onTap: () {
                                ScrollCenter(textAreaKey);
                              },
                              key: textAreaKey,
                              focusNode: textAreaNode,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              cursorColor: Colors.black,
                              controller: companyIntroduceController,
                              decoration: areaInput(
                                hintText: localization.enterContent,
                              ),
                              maxLength: 1000,
                              maxLines: 4,
                              minLines: 4,
                              textAlignVertical: TextAlignVertical.top,
                              style: commonInputText(),
                              onChanged: (value) {
                                setState(() {
                                  if (companyIntroduceController
                                      .text.isNotEmpty) {
                                    widget.setData('mcIntroduce',
                                        companyIntroduceController.text);
                                  }
                                });
                              },
                            ),
                          ),
                          Positioned(
                            right: 10.w,
                            bottom: 10.w,
                            child: Text(
                              '${companyIntroduceController.text.length} / 1,000',
                              style: TextStyles.counter,
                            ),
                          ),
                        ],
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
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: CommonSize.commonBoard(context),
          child: Row(
            children: [
              BorderButton(
                onPressed: () {
                  widget.onPress();
                },
                text: localization.755,
                width: 96.w,
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    if (companyIntroduceController.text.isNotEmpty) {
                      widget.writeFunc();
                      widget.onPress();
                    }
                  },
                  text: localization.next,
                  fontSize: 15,
                  confirm: companyIntroduceController.text.isNotEmpty,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
