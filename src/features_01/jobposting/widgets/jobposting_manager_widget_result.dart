import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/input_depth_enum.dart';
import 'package:chodan_flutter_app/enum/display_type_enum.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_msg_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_check.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_msg_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingManagerWidget extends ConsumerStatefulWidget {
  const JobpostingManagerWidget(
      {required this.jobpostingData,
      required this.setData,
      super.key});

  final Map<String, dynamic> jobpostingData;
  final Function setData;

  @override
  ConsumerState<JobpostingManagerWidget> createState() =>
      _JobpostingManagerWidgetState();
}

class _JobpostingManagerWidgetState extends ConsumerState<JobpostingManagerWidget> {
  final managerNameController = TextEditingController();
  final managerHpController = TextEditingController();
  final managerEmailController = TextEditingController();
  final hpFocus = FocusNode();


  bool isConfirm = false;

  DisplayTypeEnum isManagerNameDisplay = DisplayTypeEnum.display;
  DisplayTypeEnum isManagerHpDisplay = DisplayTypeEnum.display;
  DisplayTypeEnum isManagerEmailDisplay = DisplayTypeEnum.display;

  void toggleManagerNameDisplay(DisplayTypeEnum displayType) {
    setState(() {
      isManagerNameDisplay = displayType == DisplayTypeEnum.display
          ? DisplayTypeEnum.hidden
          : DisplayTypeEnum.display;
    });
  }

  void toggleManagerHpDisplay(DisplayTypeEnum displayType) {
    setState(() {
      isManagerHpDisplay = displayType == DisplayTypeEnum.display
          ? DisplayTypeEnum.hidden
          : DisplayTypeEnum.display;
    });
  }

  void toggleManagerEmailDisplay(DisplayTypeEnum displayType) {
    setState(() {
      isManagerEmailDisplay = displayType == DisplayTypeEnum.display
          ? DisplayTypeEnum.hidden
          : DisplayTypeEnum.display;
    });
  }

  @override
  void initState() {

    Future(() {
      savePageLog();
    });

    managerNameController.text =
        widget.jobpostingData[InputDepthEnum.managerInfoDto.key]
                ['jpManagerName'] ??
            '';
    managerHpController.text = widget
            .jobpostingData[InputDepthEnum.managerInfoDto.key]['jpManagerHp'] ??
        '';
    managerEmailController.text =
        widget.jobpostingData[InputDepthEnum.managerInfoDto.key]
                ['jpManagerEmail'] ??
            '';
    isManagerNameDisplay = setDisplayTypeEnumFromInt(
        widget.jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerNameDisplay']);
    isManagerHpDisplay = setDisplayTypeEnumFromInt(
        widget.jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerHpDisplay']);
    isManagerEmailDisplay = setDisplayTypeEnumFromInt(
        widget.jobpostingData[InputDepthEnum.managerInfoDto.key]
            ['jpManagerEmailDisplay']);
    confirm();
    super.initState();
  }

  confirm() {
    setState(() {
      if (managerNameController.text.isNotEmpty &&
          managerHpController.text.isNotEmpty &&
          managerEmailController.text.isNotEmpty &&
          ValidateService.emailRegex(managerEmailController.text)
      ) {
        isConfirm = true;
      } else {
        isConfirm = false;
      }
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    managerNameController.dispose();
    managerHpController.dispose();
    managerEmailController.dispose();
    super.dispose();
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
            context.pop();
          }
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 15;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            // Right Swipe
            context.pop();
          }
        },
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child:
        Stack(
          children: [
        Scaffold(
          appBar: const CommonAppbar(
            title: localization.contactPersonInfo,
          ),
          body:
              CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                    sliver: SliverToBoxAdapter(
                      child: Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: CommonColors.red02,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localization.jobPostEditDoesNotAffectCompanyInfo,
                          style: TextStyle(
                            color: CommonColors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ProfileTitle(
                    title: localization.contactPersonName,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: managerNameController,
                            key: const Key('jobposting_manager_name'),
                            autocorrect: false,
                            cursorColor: CommonColors.black,
                            style: commonInputText(),
                            maxLength: 1000,
                            decoration: commonInput(
                              hintText: ProfileMsgService.contentEnter,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            onChanged: (value) {
                              confirm();
                            },
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          if(!ValidateService.isValidName(managerNameController.text))
                            Text(localization.checkContactPersonName,
                              style: commonErrorAuth(),
                            )
                        ],
                      ),
                    ),
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleManagerNameDisplay(isManagerNameDisplay);
                    },
                    groupValue: isManagerNameDisplay,
                    value: DisplayTypeEnum.hidden,
                    label: localization.contactPersonNameHidden,
                  ),
                  ProfileTitle(
                    title: localization.contactPersonPhone,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: managerHpController,
                            key: const Key('jobposting_manager_phoneNumber'),
                            keyboardType: TextInputType.phone,
                            focusNode: hpFocus,
                            autocorrect: false,
                            cursorColor: CommonColors.black,
                            style: commonInputText(),
                            maxLength: 13,
                            decoration: commonInput(
                              hintText: ProfileMsgService.contentEnter,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            onChanged: (value) {
                              confirm();
                            },
                            inputFormatters: [PhoneNumberTextInputFormatter()],
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          if(!ValidateService.phoneNumberRegex(managerHpController.text))
                            Text(localization.checkPhoneNumber,
                              style: commonErrorAuth(),
                            )
                        ],
                      ),
                    ),
                  ),
                  PostingCheck(
                    onChanged: (value) {
                      toggleManagerHpDisplay(isManagerHpDisplay);
                    },
                    groupValue: isManagerHpDisplay,
                    value: DisplayTypeEnum.hidden,
                    label: localization.contactPersonPhoneHidden,
                  ),
                  ProfileTitle(
                    title: localization.contactPersonEmail,
                    required: true,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: managerEmailController,
                            key: const Key('jobposting_manager_email'),
                            autocorrect: false,
                            cursorColor: CommonColors.black,
                            style: commonInputText(),
                            maxLength: 1000,
                            decoration: suffixInput(
                              hintText: ProfileMsgService.contentEnter,
                            ),
                            minLines: 1,
                            maxLines: 1,
                            onChanged: (value) {
                              confirm();
                            },
                            textInputAction: TextInputAction.next,
                            onEditingComplete: () {
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                          if(!ValidateService.emailRegex(managerEmailController.text))
                            Text(localization.checkEmailAddress,
                              style: commonErrorAuth(),
                            )
                        ],
                      ),
                    ),
                  ),

                  PostingCheck(
                    onChanged: (value) {
                      toggleManagerEmailDisplay(isManagerEmailDisplay);
                    },
                    groupValue: isManagerEmailDisplay,
                    value: DisplayTypeEnum.hidden,
                    label: localization.contactPersonEmailHidden,
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
              child: CommonButton(
                fontSize: 15,
                onPressed: () {
                  if (managerNameController.text.isNotEmpty &&
                      managerHpController.text.isNotEmpty &&
                      managerEmailController.text.isNotEmpty &&
                      ValidateService.emailRegex(managerEmailController.text)
                  ) {
                    widget.setData('jpManagerName', managerNameController.text,
                        depth: InputDepthEnum.managerInfoDto);
                    widget.setData('jpManagerHp', managerHpController.text,
                        depth: InputDepthEnum.managerInfoDto);
                    widget.setData('jpManagerEmail', managerEmailController.text,
                        depth: InputDepthEnum.managerInfoDto);
                    widget.setData(
                        'jpManagerNameDisplay', isManagerNameDisplay.param,
                        depth: InputDepthEnum.managerInfoDto);
                    widget.setData('jpManagerHpDisplay', isManagerHpDisplay.param,
                        depth: InputDepthEnum.managerInfoDto);
                    widget.setData(
                        'jpManagerEmailDisplay', isManagerEmailDisplay.param,
                        depth: InputDepthEnum.managerInfoDto);
                    context.pop();
                  }
                },
                confirm: isConfirm,
                text: localization.enterData,
                width: CommonSize.vw,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
