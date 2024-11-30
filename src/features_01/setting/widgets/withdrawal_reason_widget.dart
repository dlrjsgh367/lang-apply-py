import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/setting/widgets/withdrawal_check.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawalReasonWidget extends ConsumerStatefulWidget {
  const WithdrawalReasonWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.onPress,
    required this.onCancel,
  });

  final List<DefineModel> data;
  final Function setData;
  final Function onPress;
  final Function onCancel;

  @override
  ConsumerState<WithdrawalReasonWidget> createState() => _WithdrawalReasonWidgetState();
}

class _WithdrawalReasonWidgetState extends ConsumerState<WithdrawalReasonWidget> {
  List<bool> statusList = List.filled(10, false);
  final textController = TextEditingController();
  List<int> selectedKeyList = [];
  int inputKey = 0;

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    if (mounted) {
      textController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 36.w, 20.w, 16.w),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '회원님 아쉬워요.\n왜 탈퇴하시는지 알려주시겠어요?',
                    style: TextStyles.withdrawalTitle,
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: widget.data.length,
                    (context, index) {
                      var categoryData = widget.data[index];
                      return WithdrawalCheck(
                          onTap: () {
                            setState(() {
                              // statusList[index] = value!;

                              if (selectedKeyList.contains(categoryData.key)) {
                                selectedKeyList.remove(categoryData.key);
                              } else {
                                selectedKeyList.add(categoryData.key);
                              }
                              // 기타
                              if (categoryData.isInput == 1) {
                                inputKey = categoryData.key;
                              }
                            });
                          },
                          text: categoryData.name,
                          active: selectedKeyList.contains(categoryData.key)
                          // statusList[index],

                          );
                    },
                  ),
                ),

                // SliverToBoxAdapter(
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.stretch,
                //     children: [
                //       Text(
                //         '회원님 아쉬워요.\n왜 탈퇴하시는지 알려주시겠어요?',
                //         style: TextStyles.withdrawalTitle,
                //       ),
                //       SizedBox(
                //         height: 16.w,
                //       ),
                //       for (var i = 0; i < reasonList.length; i++)
                //         WithdrawalCheck(
                //           onTap: () {
                //             setCheck(reasonList[i]);
                //           },
                //           text: reasonList[i],
                //           active: reasonList[i] == checked,
                //         ),
                //       SizedBox(
                //         height: 8.w,
                //       ),

                //         // decoration: ,
                //       ),
                //     ],
                //   ),
                // ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: TextFormField(
                    readOnly: !selectedKeyList.contains(inputKey),
                    controller: textController,
                    cursorColor: CommonColors.black,
                    style: areaInputText(),
                    maxLines: 3,
                    minLines: 3,
                    textAlignVertical: TextAlignVertical.top,

                    decoration: areaInput(
                      disable: !selectedKeyList.contains(inputKey),
                      hintText: '기타 사유를 입력해주세요',
                    ),
                    onChanged: (value) {},
                  ),
                ),
              ),
              BottomPadding(
                extra: 100,
              ),
            ],
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: CommonSize.commonBottom,
          child: Row(
            children: [
              BorderButton(
                  width: 96.w,
                  onPressed: () {
                    setState(() {
                      if (selectedKeyList.isNotEmpty) {
                        widget.setData('mocIdx', selectedKeyList);
                        widget.setData('moReason', textController.text);
                        widget.onPress();
                      }
                    });
                  },
                  text: '탈퇴하기'),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    widget.onCancel();
                  },
                  text: '취소하기',
                  confirm: true,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
