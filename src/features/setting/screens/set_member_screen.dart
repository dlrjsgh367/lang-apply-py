import 'dart:async';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/enum/gender_enum.dart';
import 'package:chodan_flutter_app/features/auth/service/address_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_constants.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_msg_service.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/setting/widgets/read_only_user_info_widget.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/radio/gender_radio.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SetMemberScreen extends ConsumerStatefulWidget {
  const SetMemberScreen({super.key});

  @override
  ConsumerState<SetMemberScreen> createState() => _SetMemberScreenState();
}

class _SetMemberScreenState extends ConsumerState<SetMemberScreen> {
  final phoneNumberController = TextEditingController();
  final certificationCodeController = TextEditingController();
  final addressController = TextEditingController();
  final addressDetailController = TextEditingController();

  late Gender gender;

  String phoneNumberErrorMessage = '';
  String certificationCodeErrorMessage = '';
  String addressErrorMessage = '';
  String addressDetailErrorMessage = '';

  bool isCertificationCodeSent = false;
  bool isCheckCertificationCode = false;

  bool phoneNumberMatchRegex = false;
  bool certificationCodeMatchRegex = false;

  Map<String, dynamic> userData = {
    'meHp': '',
    'meSex': 0,
    'meAddress': '',
    'meAddressDetail': '',
    'adSi': '',
    'adGu': '',
    'adDong': '',
  };

  Map<String, dynamic> phoneData = {
    'phoneNumber': '',
    'code': '',
    'authKey': '',
  };

  bool isLoading = true;
  bool isConfirmLoading = false;

  int minutes = 3;
  int seconds = 0;
  Timer? timer;

  setUserData(String key, dynamic value) {
    userData[key] = value;
  }

  setPhoneData(String key, dynamic value) {
    phoneData[key] = value;
  }

  checkPhoneNumberErrorText() {
    setState(() {
      if (phoneNumberController.text.isEmpty) {
        phoneNumberErrorMessage = AuthMsgService.phoneEmpty;
      } else if (phoneNumberController.text.isNotEmpty &&
          !phoneNumberMatchRegex) {
        phoneNumberErrorMessage = AuthMsgService.userInfoFormat;
      } else {
        phoneNumberErrorMessage = '';
      }
    });
  }

  checkCertificationCodeErrorText() {
    setState(() {
      if (certificationCodeController.text.isEmpty) {
        certificationCodeErrorMessage = AuthMsgService.certificationCodeEmpty;
      } else if (certificationCodeController.text.length != 6) {
        certificationCodeErrorMessage =
            AuthMsgService.certificationCodeMismatch;
      } else {
        certificationCodeErrorMessage = '';
      }
    });
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    if (timer != null) {
      timer!.cancel();
    }
    setState(() {
      minutes = 3;
      seconds = 0;
    });

    timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (minutes == 0 && seconds == 0) {
          timer.cancel();
        } else if (seconds == 0) {
          minutes--;
          seconds = 59;
        } else {
          seconds--;
        }
      });
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getUserData()]);
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        addressController.text = data.address;

        int siIndex = AddressService.siNameDefine
            .indexWhere((el) => el['daumName'] == data.sido);
        if (siIndex > -1) {
          setUserData('adSi', AddressService.siNameDefine[siIndex]['dbName']);
        } else {
          setUserData('adSi', data.sido);
        }
        setUserData('adGu', data.sigungu);
        setUserData('adDong', data.bname);
        setUserData('meAddress', data.address);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    savePageLog();

    _getAllAsyncTasks().then((_) {
      UserModel? userInfo = ref.read(userProvider);
      if (userInfo != null) {
        userData['meHp'] = userInfo.phoneNumber;
        userData['meSex'] = userInfo.gender;
        userData['meAddress'] = userInfo.address;
        userData['meAddressDetail'] = userInfo.addressDetail;

        phoneNumberController.text =
            AuthService.formatPhoneNumber(userInfo.phoneNumber);
        phoneData['phoneNumber'] = userInfo.phoneNumber;

        addressController.text = userInfo.address;
        addressDetailController.text = userInfo.addressDetail;

        if (userInfo.gender == 2) {
          gender = Gender.male;
        } else {
          gender = Gender.female;
        }
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
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

  sendPhoneNumberValidator() async {
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .sendPhoneNumberValidator(
            0, AuthService.phoneNumberEditUpdate(phoneNumberController.text));
    if (result.status == 200) {
      setState(() {
        setPhoneData('authKey', result.data.authKey);

        isCertificationCodeSent = true;
        startTimer();
      });
    }
  }

  checkValidatePhoneNumber() async {
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .checkValidatePhoneNumber(phoneData);
    if (result.status == 200) {
      setState(() {
        phoneNumberErrorMessage = AuthMsgService.certificationCodeConfirmed;
        isCheckCertificationCode = true;
        userData['meHp'] = phoneData['phoneNumber'];
      });
    } else {
      if (result.status == 409) {
        setState(() {
          certificationCodeErrorMessage =
              AuthMsgService.certificationCodeAbsence;
        });
      } else {
        setState(() {
          certificationCodeErrorMessage =
              AuthMsgService.certificationCodeMismatch;
        });
      }
    }
  }

  updateUserInfo() async {
    setState(() {
      isConfirmLoading = true;
    });
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(authControllerProvider.notifier)
          .updateUserInfo(userData, 'normal', userInfo.key);
      if (result.status == 200) {
        setState(() {
          context.pop();
          showDefaultToast(localization.699);
        });
      }
    }
    setState(() {
      isConfirmLoading = false;
    });
  }

  isUpdateState() {
    UserModel? userInfo = ref.read(userProvider);

    if (userData['meHp'] == userInfo!.phoneNumber &&
        userData['meSex'] == userInfo.gender &&
        userData['meAddress'] == userInfo.address &&
        userData['meAddressDetail'] == userInfo.addressDetail) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.read(userProvider);
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
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            context.pop();

          }
        },
        child: Stack(
          children: [
            Scaffold(
                appBar: const CommonAppbar(
                  title: localization.409,
                ),
                body: isLoading
                    ? const Loader()
                    : userInfo != null
                        ? CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 20.w),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: ReadOnlyUserInfoWidget(
                                    title: localization.700,
                                    content: userInfo.id,
                                    hasIcon: true,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 34.w),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: ReadOnlyUserInfoWidget(
                                    title: localization.701,
                                    content: userInfo.name,
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 34.w),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: ReadOnlyUserInfoWidget(
                                          title: localization.231,
                                          content: userInfo.birth,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Container(
                                        width: 90.w,
                                        height: 48.w,
                                        padding:
                                            EdgeInsets.fromLTRB(0, 5.w, 0, 5.w),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 1.w,
                                            color: CommonColors.grayF2,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6.w),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GenderRadio(
                                                onChanged: (value) {
                                                  setState(() {
                                                    gender = Gender.male;
                                                    setUserData(
                                                        'meSex', gender.value);
                                                  });
                                                },
                                                groupValue: gender.value,
                                                value: Gender.male.value,
                                                label: Gender.male.label,
                                              ),
                                            ),
                                            Container(
                                              width: 1,
                                              height: 36.w,
                                              color: CommonColors.grayF2,
                                            ),
                                            Expanded(
                                              child: GenderRadio(
                                                onChanged: (value) {
                                                  setState(() {
                                                    gender = Gender.female;
                                                    setUserData(
                                                        'meSex', gender.value);
                                                  });
                                                },
                                                groupValue: gender.value,
                                                value: Gender.female.value,
                                                label: Gender.female.label,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(height: 36.w),
                                      Text(
                                        localization.702,
                                        style: commonTitleAuth(),
                                      ),
                                      SizedBox(height: 12.w),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: phoneNumberController,
                                              key:
                                                  const Key('update-phone-input'),
                                              keyboardType: TextInputType.number,
                                              inputFormatters: [
                                                PhoneNumberTextInputFormatter()
                                              ],
                                              autocorrect: false,
                                              cursorColor: CommonColors.black,
                                              style: commonInputText(),
                                              maxLength: 13,
                                              decoration: suffixInput(
                                                hintText:
                                                    AuthMsgService.phoneNumEnter,
                                              ),
                                              minLines: 1,
                                              maxLines: 1,
                                              onChanged: (value) {
                                                setState(() {
                                                  phoneNumberMatchRegex =
                                                      ValidateService
                                                          .phoneNumberOnlyElevenRegex(
                                                              phoneNumberController
                                                                  .text);
                                                  checkPhoneNumberErrorText();

                                                  if (phoneNumberMatchRegex &&
                                                      phoneNumberController
                                                          .text.isNotEmpty) {
                                                    setPhoneData(
                                                        'phoneNumber',
                                                        AuthService
                                                            .phoneNumberEditUpdate(
                                                                phoneNumberController
                                                                    .text));
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          SizedBox(
                                            width: 90.w,
                                            child: !isCertificationCodeSent
                                              ? CommonButton(
                                                  confirm: phoneNumberController.text.length == AuthConstants.phoneNumberMaxLength &&
                                                      AuthService.phoneNumberEditUpdate(phoneNumberController.text) != userInfo.phoneNumber
                                                      && !isCertificationCodeSent,
                                                  onPressed: () {
                                                    setState(() {
                                                      if (phoneNumberController.text.length == AuthConstants.phoneNumberMaxLength
                                                          && AuthService.phoneNumberEditUpdate(phoneNumberController.text) != userInfo.phoneNumber) {
                                                        certificationCodeController.text = '';
                                                        phoneNumberErrorMessage = '';
                                                        isCheckCertificationCode = false;

                                                        sendPhoneNumberValidator();
                                                      }
                                                    });
                                                  },
                                                  text: localization.703,
                                                )
                                              : BorderButton(
                                                  width: 90.w,
                                                  red: true,
                                                  onPressed: () {
                                                    setState(() {
                                                      if (phoneNumberController.text.length == AuthConstants.phoneNumberMaxLength) {
                                                        certificationCodeController.text = '';
                                                        phoneNumberErrorMessage = '';
                                                        isCheckCertificationCode = false;

                                                        sendPhoneNumberValidator();
                                                      }
                                                    });
                                                  },
                                                  text: localization.704,
                                                ),
                                          ),
                                        ],
                                      ),
                                      if (phoneNumberErrorMessage != '')
                                        phoneNumberErrorMessage == localization.705
                                            ? Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
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
                                                  localization.705,
                                                  style: TextStyles.confirm,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ):

                                        Row(
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
                                              phoneNumberErrorMessage,
                                              style: TextStyles.error,
                                            ),
                                          ],
                                        ),


                                    ],
                                  ),
                                ),
                              ),
                              if (isCertificationCodeSent &&
                                  !isCheckCertificationCode)
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                                  sliver: SliverToBoxAdapter(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: AutofillGroup(
                                                child: TextFormField(
                                                  controller: certificationCodeController,
                                                  key: const Key('update-phone-check-input'),
                                                  keyboardType: TextInputType.number,
                                                  autocorrect: false,
                                                  cursorColor: CommonColors.black,
                                                  style: commonInputText(),
                                                  maxLength: 13,
                                                  decoration: suffixInput(
                                                    hintText: AuthMsgService.certificationCodeEnter,
                                                    suffixText: '0$minutes :  ${seconds < 10 ? '0$seconds' : seconds}',
                                                  ),
                                                  autofillHints: const [AutofillHints.oneTimeCode],
                                                  minLines: 1,
                                                  maxLines: 1,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      checkCertificationCodeErrorText();

                                                      if (certificationCodeController.text.length == 6 &&
                                                          certificationCodeController.text.isNotEmpty) {
                                                        setPhoneData(
                                                            'code',
                                                            AuthService.phoneNumberEditUpdate(
                                                                certificationCodeController.text));
                                                      }
                                                    });
                                                  },
                                                ),
                                              )
                                              ,
                                            ),
                                            SizedBox(width: 4.w),
                                            SizedBox(
                                              width: 90.w,
                                              child: CommonButton(
                                                confirm: true,
                                                onPressed: () {
                                                  setState(() {
                                                    checkValidatePhoneNumber();
                                                  });
                                                },
                                                text: localization.verify,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (certificationCodeErrorMessage != '')
                                          Row(
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
                                                certificationCodeErrorMessage,
                                                style: TextStyles.error,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        localization.address,
                                        style: commonTitleAuth(),
                                      ),
                                      SizedBox(height: 20.w),
                                      GestureDetector(
                                        onTap: showPost,
                                        child: TextFormField(
                                          enabled: false,
                                          controller: addressController,
                                          readOnly: true,
                                          key: const Key('update-address-input'),
                                          autocorrect: false,
                                          style: commonInputText(),
                                          maxLength: null,
                                          decoration: commonInput(
                                            disable: true,
                                            hintText: AuthMsgService.addressEnter,
                                          ),
                                          minLines: 1,
                                          maxLines: 1,
                                        ),
                                      ),
                                      if(addressErrorMessage != '')
                                        Row(
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
                                              addressErrorMessage,
                                              style: TextStyles.error,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 8.w, 20.w, 0),
                                sliver: SliverToBoxAdapter(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextFormField(
                                              controller: addressDetailController,
                                              key: const Key(
                                                  'update-address-detail-input'),
                                              keyboardType: TextInputType.text,
                                              autocorrect: false,
                                              cursorColor: CommonColors.black,
                                              style: commonInputText(),
                                              maxLength: 100,
                                              decoration: suffixInput(
                                                hintText: AuthMsgService
                                                    .addressDetailEnter,
                                              ),
                                              minLines: 1,
                                              maxLines: 1,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (addressDetailController
                                                      .text.isNotEmpty) {
                                                    setUserData(
                                                        'meAddressDetail',
                                                        addressDetailController
                                                            .text);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                          /*SizedBox(width: 4.w),
                                          SizedBox(
                                            width: 90.w,
                                            child: CommonButton(
                                              confirm: true,
                                              onPressed: showPost,
                                              text: localization.707,
                                            ),
                                          ),*/
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const BottomPadding(extra: 100),
                            ],
                          )
                        : const SizedBox()),
            if (!isLoading && userInfo != null)
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: CommonSize.commonBoard(context),
                child: CommonButton(
                  confirm: ((userData['meHp'].isNotEmpty &&
                      userData['meSex'] != 0 &&
                      userData['meAddress'].isNotEmpty) &&
                      ((isCertificationCodeSent && isCheckCertificationCode) ||
                          (!isCertificationCodeSent &&
                              !isCheckCertificationCode)) && !(phoneNumberController.text.length == AuthConstants.phoneNumberMaxLength &&
                      AuthService.phoneNumberEditUpdate(phoneNumberController.text) != userInfo.phoneNumber
                      && !isCertificationCodeSent) && !phoneNumberMatchRegex &&
                      phoneNumberController
                          .text.isNotEmpty && phoneNumberErrorMessage.isEmpty || phoneNumberErrorMessage == localization.705),
                  onPressed: () {
                    if ((userData['meHp'].isNotEmpty &&
                            userData['meSex'] != 0 &&
                            userData['meAddress'].isNotEmpty) &&
                        ((isCertificationCodeSent && isCheckCertificationCode) ||
                            (!isCertificationCodeSent &&
                                !isCheckCertificationCode)) && !(phoneNumberController.text.length == AuthConstants.phoneNumberMaxLength &&
                        AuthService.phoneNumberEditUpdate(phoneNumberController.text) != userInfo.phoneNumber
                        && !isCertificationCodeSent) && !phoneNumberMatchRegex &&
                        phoneNumberController
                            .text.isNotEmpty && (phoneNumberErrorMessage.isEmpty || phoneNumberErrorMessage == localization.705) && !isConfirmLoading) {
                      updateUserInfo();
                    }
                  },
                  fontSize: 15,
                  text: localization.edit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
