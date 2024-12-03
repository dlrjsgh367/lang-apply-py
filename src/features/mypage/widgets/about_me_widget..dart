import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_red_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AboutMeWidget extends ConsumerStatefulWidget {
  const AboutMeWidget({
    super.key,
    required this.profileData,
    required this.keywordStringData,
    required this.setProfileData,
    required this.setKeywordStringData,
  });

  final Map<String, dynamic> profileData;
  final Map<String, dynamic> keywordStringData;
  final Function setProfileData;
  final Function setKeywordStringData;

  @override
  ConsumerState<AboutMeWidget> createState() => _AboutMeWidgetState();
}

class _AboutMeWidgetState extends ConsumerState<AboutMeWidget> {
  final textController = TextEditingController();
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();

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

    savePageLog();

    if (widget.profileData['mpIntroduce'] != '') {
      textController.text = widget.profileData['mpIntroduce'] ?? '';
    }
    if (widget.profileData['keyword'].isNotEmpty) {
      selectedKeywordNumbers = [...widget.profileData['keyword']];
      selectedKeyword = [...widget.keywordStringData['keywordName']];
    }

    _getAllAsyncTasks().then((_) {
      isLoading = false;
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
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
      widget.setProfileData('mpIntroduce', textController.text);
      widget.setProfileData('keyword', selectedKeywordNumbers);
      widget.setKeywordStringData('keywordName', selectedKeyword);

      if (mounted) {
        context.pop();
      }
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (MediaQuery.of(context).viewInsets.bottom > 0) {
          FocusScope.of(context).unfocus();
        } else {
          if (!didPop) {
            setState(() {
              textController.text = '';
              widget.setProfileData('mpIntroduce', textController.text);
            });
            context.pop();
          }
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 10;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            // Right Swipe
            setState(() {
              textController.text = '';
              widget.setProfileData('mpIntroduce', textController.text);
            });
            context.pop();
          }
        },
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: CommonAppbar(
                title: localization.300,
                backFunc: () {
                  setState(() {
                    textController.text = '';
                    widget.setProfileData('mpIntroduce', textController.text);
                  });
                  context.pop();
                },
              ),
              body: !isLoading
                  ? CustomScrollView(
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
                                      color: CommonColors.red02,
                                      shape: BoxShape.circle),
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
                        ProfileTitle(
                            title: localization.300,
                            required: false,
                            text: '',
                            hasArrow: false,
                            onTap: () {}),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Stack(
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
                                    controller: textController,
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
                                          widget.setProfileData('mpIntroduce',
                                              textController.text);
                                        }
                                      });
                                    },
                                    onEditingComplete: () {
                                      if (textController.text.isNotEmpty) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      }
                                    },
                                  ),
                                ),
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
                                          selectedKeyword
                                              .remove(keywords[i].keywordName);
                                          selectedKeywordNumbers
                                              .remove(keywords[i].keywordKey);
                                        } else {
                                          if (selectedKeywordNumbers.length <
                                              20) {
                                            selectedKeyword
                                                .add(keywords[i].keywordName);
                                            selectedKeywordNumbers
                                                .add(keywords[i].keywordKey);
                                          }
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(4.w),
                                        color: selectedKeywordNumbers.contains(
                                                keywords[i].keywordKey)
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
                                                      .contains(keywords[i]
                                                          .keywordKey)
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
                    )
                  : const Loader(),
            ),
            if (!isLoading)
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: CommonSize.commonBoard(context),
                child: CommonButton(
                  fontSize: 15,
                  confirm: textController.text.isNotEmpty ||
                      selectedKeywordNumbers.isNotEmpty,
                  onPressed: () {
                    if (textController.text.isNotEmpty ||
                        selectedKeywordNumbers.isNotEmpty) {
                      checkForbiddenWord(textController.text);
                    }
                  },
                  text: localization.32,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
