import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_red_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialAboutMeWidget extends ConsumerStatefulWidget {
  const TutorialAboutMeWidget({
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
  ConsumerState<TutorialAboutMeWidget> createState() =>
      _TutorialAboutMeWidgetState();
}

class _TutorialAboutMeWidgetState extends ConsumerState<TutorialAboutMeWidget>
    with AutomaticKeepAliveClientMixin {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  @override
  bool get wantKeepAlive => true;

  final textController = TextEditingController();

  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  int total = 0;
  bool isLazeLoading = false;

  List<ProfileModel> keywords = [];
  List<int> selectedKeywordNumbers = [];
  List<String> selectedKeyword = [];

  showForbiddenWordAlert(String forbiddenWord) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertConfirmRedDialog(
          alertContent: localization.77,
          redText: '금칙어: [$forbiddenWord]',
          alertConfirm: localization.confirm,
          confirmFunc: () {
            context.pop();
          },
          alertTitle: localization.78,
        );
      },
    );
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getKeywords(page)]);
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getKeywords(page);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['mpIntroduce'] != null) {
      textController.text = widget.data['mpIntroduce'];
    }
    if (widget.data['keyword'].isNotEmpty) {
      selectedKeywordNumbers = [...widget.data['keyword']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  getKeywords(int page) async {
    ApiResultModel result =
        await ref.read(defineControllerProvider.notifier).getKeywords(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<ProfileModel> resultData = result.data;
        setState(() {
          if (page == 1) {
            keywords = [...resultData];
          } else {
            keywords = [...keywords, ...resultData];
          }
          total = result.page['total'];
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    }
  }

  checkForbiddenWord(String content) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .checkForbiddenWord(content);

    if (result.status == 200) {
      widget.setData('mpIntroduce', textController.text);
      widget.setData('keyword', selectedKeywordNumbers);
      widget.writeFunc('introduce');

      widget.onPress();
    } else {
      if (result.status == 401) {
        setState(() {
          showForbiddenWordAlert(result.data ?? '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        PopScope(
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
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 18.w),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '여러분이\n누구인지 알고싶어요.',
                            style: TextStyle(
                              fontSize: 20.sp,
                              color: CommonColors.black2b,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          width: 56.w,
                          height: 56.w,
                          decoration: BoxDecoration(
                              color: CommonColors.red02, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/icon/iconManRed.png',
                            width: 36.w,
                            height: 36.w,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 36.w),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          localization.301,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.gray80,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          localization.489,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: CommonColors.gray80,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                  sliver: const SliverToBoxAdapter(
                    child: Text(
                      localization.300,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 20.w),
                  sliver: SliverToBoxAdapter(
                    child: Stack(
                      children: [
                      CommonKeyboardAction(
                      focusNode: textAreaNode,
                      child:
                        TextFormField(
                          controller: textController,
                          onTap: () {
                            ScrollCenter(textAreaKey);
                          },
                          key: textAreaKey,
                          focusNode: textAreaNode,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,

                          autocorrect: false,
                          cursorColor: CommonColors.black,
                          style: areaInputText(),
                          maxLength: 1000,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: areaInput(
                            hintText: ProfileMsgService.contentEnter,
                          ),
                          minLines: 5,
                          maxLines: 10,
                          onChanged: (value) {
                            setState(() {
                              if (textController.text.isNotEmpty) {
                                widget.setData(
                                    'mpIntroduce', textController.text);
                              }
                            });
                          },
                          onEditingComplete: () {
                            if (textController.text.isNotEmpty) {
                              FocusManager.instance.primaryFocus?.unfocus();
                            }
                          },
                        ),),
                        Positioned(
                          right: 10.w,
                          bottom: 10.w,
                          child: Text(
                            '${textController.text.length} / 1,000',
                            style: TextStyles.counter,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        const Text(
                          localization.490,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          width: 16.w,
                        ),
                        Text(
                          '${selectedKeywordNumbers.length}',
                          style: TextStyle(
                            color: CommonColors.red,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        Text(
                          ' / 20',
                          style: TextStyle(
                            color: CommonColors.gray80,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 16.w),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(
                      runSpacing: 8.w,
                      spacing: 8.w,
                      children: [
                        for (var i = 0; i < keywords.length; i++)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selectedKeywordNumbers
                                    .contains(keywords[i].keywordKey)) {
                                  selectedKeyword.remove(keywords[i].keywordName);
                                  selectedKeywordNumbers
                                      .remove(keywords[i].keywordKey);
                                } else {
                                  if (selectedKeywordNumbers.length < 20) {
                                    selectedKeyword.add(keywords[i].keywordName);
                                    selectedKeywordNumbers
                                        .add(keywords[i].keywordKey);
                                  }
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                              height: 30.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                color: selectedKeywordNumbers
                                        .contains(keywords[i].keywordKey)
                                    ? CommonColors.red02
                                    : CommonColors.grayF7,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    keywords[i].keywordName,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                      color: selectedKeywordNumbers
                                              .contains(keywords[i].keywordKey)
                                          ? CommonColors.red
                                          : CommonColors.grayB2,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Image.asset(
                                    'assets/images/icon/iconPlus.png',
                                    width: 16.w,
                                    height: 16.w,
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),

                //   GestureDetector(
                //     onTap: _loadMore,
                //     child: const Text(localization.491),
                //   ),
                if (total > keywords.length)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: _loadMore,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                          height: 40.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: CommonColors.grayF7,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                localization.491,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray66,
                                ),
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Image.asset(
                                'assets/images/icon/iconArrowDown.png',
                                width: 16.w,
                                height: 16.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                const BottomPadding(
                  extra: 100,
                ),
              ],
            ),
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
                  text: localization.next,
                  fontSize: 15,
                  confirm: textController.text.isNotEmpty ||
                      selectedKeywordNumbers.isNotEmpty,
                  onPressed: () {
                    if (textController.text.isNotEmpty ||
                        selectedKeywordNumbers.isNotEmpty) {
                      checkForbiddenWord(textController.text);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
