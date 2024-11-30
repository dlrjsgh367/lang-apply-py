import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_constants.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/select_profile_title_widget.dart';
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
import 'package:go_router/go_router.dart';

class TutorialProfileTitleWidget extends ConsumerStatefulWidget {
  const TutorialProfileTitleWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;

  @override
  ConsumerState<TutorialProfileTitleWidget> createState() =>
      _TutorialProfileTitleWidgetState();
}

class _TutorialProfileTitleWidgetState
    extends ConsumerState<TutorialProfileTitleWidget>
    with AutomaticKeepAliveClientMixin {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> selectedDirectInputData = {
    'index': -1,
    'isDirectInput': false,
  };

  final titleController = TextEditingController();
  int selectedIndex = 0;
  String profileTitle = '';

  showProfileTitleSelection(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: CommonColors.white,
      isScrollControlled: false,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return SelectProfileTitleWidget(
          selectedDirectInputData: selectedDirectInputData,
        );
      },
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                if (value == ProfileConstants.profileTitleList.length - 1) {
                  // 직접 입력 선택
                  selectedDirectInputData['isDirectInput'] = true;
                  selectedDirectInputData['index'] = value;
                } else {
                  // 직접 입력 선택 X
                  selectedDirectInputData['isDirectInput'] = false;
                  selectedDirectInputData['index'] = value;
                  profileTitle = ProfileConstants.profileTitleList[value];
                }
              }),
            }
        });
  }

  @override
  void initState() {
    super.initState();

    if (widget.data['mpTitle'].isNotEmpty) {
      selectedDirectInputData['isDirectInput'] = !ProfileConstants.profileTitleList.contains(widget.data['mpTitle']);
      selectedDirectInputData['index'] = ProfileConstants.profileTitleList.indexOf(widget.data['mpTitle']);

      if (selectedDirectInputData['index'] == -1) {
        selectedDirectInputData['index'] = 4;
      }

      if (selectedDirectInputData['isDirectInput']) {
        // 직접 입력
        titleController.text = widget.data['mpTitle'];
      } else {
        // 직접 입력 X
        profileTitle = ProfileConstants.profileTitleList[selectedDirectInputData['index']];
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [

              ProfileTitle(
                title: localization.profileTitle,
                required: false,
                text: '',
                onTap: () {},
                hasArrow: false,
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 16.w),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      showProfileTitleSelection(context);
                    },
                    child: Container(
                      // width: CommonSize.vw,
                      padding: EdgeInsets.fromLTRB(12.w, 12.w, 12.w, 12.w),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              profileTitle.isNotEmpty
                                ? ProfileConstants.profileTitleList[selectedDirectInputData['index']]
                                : localization.setProfileTitle,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: profileTitle.isNotEmpty
                                    ? CommonColors.black2b
                                    : CommonColors.grayB2,
                              ),
                            ),
                          ),
                          Text(
                            localization.recommendation,
                            style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.red),
                          ),
                          Image.asset(
                            'assets/images/icon/iconArrowDownRed.png',
                            width: 16.w,
                            height: 16.w,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (selectedDirectInputData['isDirectInput'])
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
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
                          focusNode: textAreaNode,
                          controller: titleController,
                          key: textAreaKey,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          autocorrect: false,
                          cursorColor: CommonColors.black,
                          style: areaInputText(),
                          maxLength: 100,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: areaInput(
                            hintText: ProfileMsgService.contentEnter,
                          ),
                          minLines: 3,
                          maxLines: 3,
                          onChanged: (value) {
                            setState(() {
                              if (titleController.text.isNotEmpty) {
                                profileTitle = titleController.text;
                              }
                            });
                          },
                          onEditingComplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                        Positioned(
                          right: 10.w,
                          bottom: 10.w,
                          child: Text(
                            '${titleController.text.length}/100',
                            style: TextStyles.counter,
                          ),
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
                  context.pop();
                },
                text: localization.skipAction,
                width: 96.w,
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  confirm: profileTitle.isNotEmpty,
                  onPressed: () {
                    if (profileTitle.isNotEmpty) {
                      widget.setData('mpTitle', profileTitle);
                      widget.writeFunc('profile');
                      context.pop();
                    }
                  },
                  text: localization.completeSetup,
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
