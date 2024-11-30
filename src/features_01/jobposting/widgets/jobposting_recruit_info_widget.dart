import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/input_step_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_red_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingRecruitInfoWidget extends ConsumerStatefulWidget {
  const JobpostingRecruitInfoWidget(
      {required this.jobpostingData,
      required this.setData,
      required this.initSelectedList,
      required this.setInitSelectedList,
      required this.stepController,
      super.key});

  final Map<String, dynamic> jobpostingData;
  final Function setData;

  final List<DefineModel> initSelectedList;

  final Function setInitSelectedList;

  final InputStepController stepController;

  @override
  ConsumerState<JobpostingRecruitInfoWidget> createState() =>
      _JobpostingRecruitInfoWidgetState();
}

class _JobpostingRecruitInfoWidgetState
    extends ConsumerState<JobpostingRecruitInfoWidget> {
  final TextEditingController workDetailController = TextEditingController();
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();

  bool isConfirm = false;

  List<int> selectedWorkKey = [];

  List<DefineModel> initialSelectedItem = [];

  int maxLength = 10;

  @override
  void initState() {
    Future(() {
      savePageLog();
    });

    workDetailController.text =
        widget.jobpostingData[InputDepthEnum.workInfo.key]['jpWork'] ?? '';
    selectedWorkKey = [
      ...widget.jobpostingData[InputDepthEnum.workInfo.key]['joIdx']
    ];
    initialSelectedItem = [...widget.initSelectedList];
    widget.stepController.changeStep(InputStepEnum.ongoing);

    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    workDetailController.dispose();
    super.dispose();
  }

  apply(List<DefineModel> itemList, List<int> apply) {
    setState(() {
      initialSelectedItem = [...itemList];
      selectedWorkKey = [...apply];
    });
  }

  checkForbiddenWord(String text) async {
    ApiResultModel result = await ref
        .read(defineControllerProvider.notifier)
        .checkForbiddenWord(text);

    if (result.status == 200) {
      if (result.type == 1) {
        widget.setData('jpWork', workDetailController.text,
            depth: InputDepthEnum.workInfo);
        widget.setData('joIdx', selectedWorkKey,
            depth: InputDepthEnum.workInfo);
        widget.setInitSelectedList(initialSelectedItem);
        widget.stepController
            .changeStep(InputStepEnum.ongoing, isComplete: true);
        context.pop();
      } else {}
    } else if (result.status == 401) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmRedDialog(
            alertContent: '입력하신 내용을 확인 후 다시 저장해주세요.',
            redText: '금칙어: [$result]',
            alertConfirm: '확인',
            confirmFunc: () {
              context.pop();
            },
            alertTitle: '금칙어가 감지되었어요.',
          );
        },
      );

      //TODO : 알럿띄우기
    }
  }

  bool confirm() {
    if (workDetailController.text.isNotEmpty &&
        selectedWorkKey.isNotEmpty &&
        initialSelectedItem.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> jobList = ref.watch(jobListProvider);
    return PopScope(
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
          int sensitivity = 15;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            // Right Swipe
            context.pop();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: const CommonAppbar(
                title: '업무 정보',
              ),
              body: CustomScrollView(
                slivers: [
                  ProfileTitle(
                    title: '직종',
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  if (initialSelectedItem.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.w),
                      sliver: SliverToBoxAdapter(
                        child: Wrap(
                          children: [
                            for (int i = 0; i < initialSelectedItem.length; i++)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    initialSelectedItem.removeAt(i);
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                  height: 30.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.w),
                                    color: CommonColors.grayF7,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        initialSelectedItem[i].name,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Image.asset(
                                        'assets/images/icon/iconX.png',
                                        width: 16.w,
                                        height: 16.w,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  if (initialSelectedItem.length < 10)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 36.w),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
                          onTap: () async {
                            await DefineDialog.showJobBottom(
                                context,
                                '직종',
                                jobList,
                                apply,
                                initialSelectedItem,
                                maxLength,
                                DefineEnum.job);
                          },
                          child: Container(
                            height: 48.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.w),
                                color: CommonColors.red02),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/icon/iconPlusRed.png',
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                SizedBox(
                                  width: 6.w,
                                ),
                                Text(
                                  '직종 선택하기',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ProfileTitle(
                    title: '담당업무 상세',
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
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
                            controller: workDetailController,
                            autocorrect: false,
                            cursorColor: CommonColors.black,
                            style: areaInputText(),
                            maxLength: 5000,
                            decoration: areaInput(
                              hintText: ProfileMsgService.contentEnter,
                            ),
                            textAlignVertical: TextAlignVertical.top,
                            minLines: 4,
                            maxLines: 4,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onEditingComplete: () {},
                          ),
                        ),
                        Positioned(
                            right: 10.w,
                            bottom: 10.w,
                            child: Text(
                              '${workDetailController.text.length} / 5000',
                              style: TextStyles.counter,
                            )),
                      ],
                    )),
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
              bottom: CommonSize.commonBottom,
              child: CommonButton(
                fontSize: 15,
                onPressed: () {
                  if (confirm()) {
                    checkForbiddenWord(workDetailController.text);
                  }
                },
                confirm: confirm(),
                text: '입력하기',
                width: CommonSize.vw,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
