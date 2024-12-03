import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_msg_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/password_input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  Map<String, dynamic> passwordData = {
    'mePassword': '',
    'meNewPassword': '',
  };

  setPasswordData(String key, String value) {
    passwordData[key] = value;
  }

  final passwordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordConfirmController = TextEditingController();

  String passwordErrorMessage = '';
  String newPasswordErrorMessage = '';
  String newPasswordConfirmMessage = '';

  bool passwordVisible = true;
  bool newPasswordVisible = true;
  bool newPasswordConfirmVisible = true;

  bool newPasswordMatchRegex = false;
  bool newPasswordConfirmMatchRegex = false;

  bool isPasswordMatch = false;

  final newPasswordFocus = FocusNode();
  final newPasswordConfirmFocus = FocusNode();

  checkPasswordErrorText() {
    setState(() {
      if (passwordController.text.isEmpty) {
        passwordErrorMessage = AuthMsgService.pwEnter;
      } else if (!isPasswordMatch) {
        passwordErrorMessage = AuthMsgService.userInfoFormat;
      } else {
        passwordErrorMessage = '';
      }
    });
  }

  checkNewPasswordErrorText() {
    setState(() {
      newPasswordErrorMessage = '';

      if (newPasswordController.text.isEmpty) {
        newPasswordErrorMessage = AuthMsgService.pwEnter;
      } else if (!newPasswordMatchRegex) {
        newPasswordErrorMessage = AuthMsgService.pwFormat;
      } else if (passwordController.text == newPasswordController.text) {
        newPasswordErrorMessage = AuthMsgService.pwError;
      } else if (newPasswordController.text.isEmpty &&
          newPasswordConfirmController.text.isNotEmpty) {
        newPasswordErrorMessage = AuthMsgService.pwMismatch;
      } else if (newPasswordController.text.isNotEmpty &&
          newPasswordConfirmController.text.isNotEmpty &&
          newPasswordController.text != newPasswordConfirmController.text) {
        newPasswordErrorMessage = AuthMsgService.pwMismatch;
      }
    });
  }

  checkNewPasswordConfirmText() {
    setState(() {
      if (newPasswordController.text == newPasswordConfirmController.text) {
        newPasswordConfirmMessage = AuthMsgService.pwAvailable;
      }
    });
  }

  showConfirmAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertConfirmDialog(
          alertTitle: localization.411,
          alertContent: localization.708,
          alertConfirm: localization.confirm,
          confirmFunc: () {
            context.pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    Future(() {
      savePageLog();
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  checkPasswordMatch() async {
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .checkPasswordMatch(passwordController.text);
    if (result.status == 200 && result.type == 1) {
      setState(() {
        isPasswordMatch = result.data; // 일치 하면 true, 아니면 false
        checkPasswordErrorText();
      });
    }
  }

  updatePassword() async {
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .updatePassword(passwordData);
    if (result.status == 200) {
      setState(() {
        context.pop();
        showDefaultToast(localization.709);
      });
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
            context.pop();
          }
        }
      },
      child: Stack(
        children: [
          GestureDetector(
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
            child: Scaffold(
              appBar: const CommonAppbar(
                title: localization.411,
              ),
              body: CustomScrollView(
                slivers: [
                  const ProfileTitle(
                    title: localization.710,
                    required: false,
                    hasArrow: false,
                    text: '',
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: passwordController,
                        key: const Key('update-password-input'),
                        keyboardType: TextInputType.text,
                        obscureText: passwordVisible,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: passwordInput(
                          hintText: AuthMsgService.pwEnter,
                          isVisible: !passwordVisible,
                          hasClear: passwordController.text.isNotEmpty,
                          clearFunc: () {
                            setState(() {
                              isPasswordMatch = false;
                              passwordController.clear();
                              checkPasswordErrorText();
                            });
                          },
                          iconFunc: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            checkPasswordMatch();

                            if (passwordController.text.isNotEmpty) {
                              setPasswordData(
                                  'mePassword', passwordController.text);
                            }
                          });
                        },
                        onEditingComplete: () {
                          if (isPasswordMatch &&
                              passwordController.text.isNotEmpty) {
                            FocusScope.of(context)
                                .requestFocus(newPasswordFocus);
                          }
                        },
                      ),
                    ),
                  ),
                  if (passwordErrorMessage.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 4.w, 0, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              passwordErrorMessage,
                              style: TextStyles.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 24.w,
                    ),
                  ),
                  ProfileTitle(
                    title: localization.711,
                    required: false,
                    text: '',
                    onTap: () {},
                    hasArrow: false,
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: newPasswordController,
                        key: const Key('update-new-password-input'),
                        keyboardType: TextInputType.text,
                        focusNode: newPasswordFocus,
                        obscureText: newPasswordVisible,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: passwordInput(
                          hintText: localization.712,
                          isVisible: !newPasswordVisible,
                          hasClear: newPasswordController.text.isNotEmpty,
                          clearFunc: () {
                            setState(() {
                              newPasswordController.clear();
                              checkNewPasswordErrorText();
                            });
                          },
                          iconFunc: () {
                            setState(() {
                              newPasswordVisible = !newPasswordVisible;
                            });
                          },
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            newPasswordMatchRegex =
                                ValidateService.passwordRegex(value);
                            checkNewPasswordErrorText();
                          });
                        },
                        onEditingComplete: () {
                          if (newPasswordMatchRegex &&
                              newPasswordController.text != '') {
                            FocusScope.of(context)
                                .requestFocus(newPasswordConfirmFocus);
                          }
                        },
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        controller: newPasswordConfirmController,
                        key: const Key('update-new-password-confirm-input'),
                        keyboardType: TextInputType.text,
                        focusNode: newPasswordConfirmFocus,
                        obscureText: newPasswordConfirmVisible,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: passwordInput(
                          hintText: localization.713,
                          isVisible: !newPasswordConfirmVisible,
                          hasClear:
                              newPasswordConfirmController.text.isNotEmpty,
                          clearFunc: () {
                            setState(() {
                              newPasswordConfirmController.clear();
                              checkNewPasswordErrorText();
                            });
                          },
                          iconFunc: () {
                            setState(() {
                              newPasswordConfirmVisible =
                                  !newPasswordConfirmVisible;
                            });
                          },
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            newPasswordConfirmMatchRegex =
                                ValidateService.passwordRegex(value);
                            checkNewPasswordErrorText();
                            checkNewPasswordConfirmText();

                            if (newPasswordConfirmMatchRegex &&
                                newPasswordController.text.isNotEmpty) {
                              setPasswordData(
                                  'meNewPassword', newPasswordController.text);
                            }
                          });
                        },
                        onEditingComplete: () {
                          if (newPasswordConfirmMatchRegex &&
                              newPasswordConfirmController.text.isNotEmpty) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                      ),
                    ),
                  ),
                  if (newPasswordErrorMessage.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 4.w, 0, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              newPasswordErrorMessage,
                              style: TextStyles.error,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (newPasswordErrorMessage.isEmpty &&
                      newPasswordConfirmMessage.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 4.w, 0, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 4.w,
                            ),
                            Image.asset(
                              'assets/images/icon/iconConfirm.png',
                              width: 14.w,
                              height: 14.w,
                            ),
                            SizedBox(
                              width: 4.w,
                            ),
                            Text(
                              newPasswordConfirmMessage,
                              style: TextStyles.confirm,
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
          ),
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: CommonSize.commonBoard(context),
            child: CommonButton(
              confirm: isPasswordMatch &&
                  newPasswordMatchRegex &&
                  newPasswordConfirmMatchRegex &&
                  passwordController.text != newPasswordController.text &&
                  newPasswordController.text ==
                      newPasswordConfirmController.text,
              onPressed: () {
                UserModel? userInfo = ref.read(userProvider);
                if (isPasswordMatch &&
                    newPasswordMatchRegex &&
                    newPasswordConfirmMatchRegex &&
                    passwordController.text != newPasswordController.text &&
                    newPasswordController.text ==
                        newPasswordConfirmController.text) {
                  if (userInfo!.loginType == 'email') {
                    updatePassword();
                  } else {
                    showConfirmAlert();
                  }
                }
              },
              fontSize: 15,
              text: localization.714,
            ),
          ),
        ],
      ),
    );
  }
}
