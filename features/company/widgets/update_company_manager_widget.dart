import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_check.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_title.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddCompanyManagerWidget extends ConsumerStatefulWidget {
  const AddCompanyManagerWidget({
    super.key,
    required this.data,
  });

  final CompanyModel data;

  @override
  ConsumerState<AddCompanyManagerWidget> createState() =>
      _AddCompanyManagerWidgetState();
}

class _AddCompanyManagerWidgetState
    extends ConsumerState<AddCompanyManagerWidget> {
  Map<String, dynamic> managerData = {
    'mcManagerName': '', // 담당자명
    'mcManagerNameDisplay': 1, // 담당자명 공개 여부
    'mcManagerHp': '', // 담당자 연락처
    'mcManagerHpDisplay': 1, // 담당자 연락처 공개 여부
    'mcManagerEmail': '', // 담당자 이메일
    'mcManagerEmailDisplay': 1, // 담당자 이메일 공개 여부
  };

  bool isLoading = true;

  bool isNameChecked = false;
  bool isPhoneNumberChecked = false;
  bool isEmailChecked = false;

  bool phoneNumberMatchRegex = true;
  bool emailMatchRegex = true;

  final managerNameController = TextEditingController();
  final managerPhoneNumberController = TextEditingController();
  final managerEmailController = TextEditingController();

  setManagerData(String key, dynamic value) {
    managerData[key] = value;
  }

  int boolToInt(bool value) {
    return value ? 0 : 1;
  }

  bool intToBool(int value) {
    return value == 0 ? true : false; // 비공개는 true
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getCompanyInfo()]);
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  getCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .getCompanyInfo(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          setState(() {
            managerData['mcManagerName'] = result.data.companyInfo.managerName;
            managerData['mcManagerHp'] =
                result.data.companyInfo.managerPhoneNumber;
            managerData['mcManagerEmail'] =
                result.data.companyInfo.managerEmail;

            managerData['mcManagerNameDisplay'] =
                result.data.companyInfo.managerNameDisplay;
            managerData['mcManagerHpDisplay'] =
                result.data.companyInfo.managerHpDisplay;
            managerData['mcManagerEmailDisplay'] =
                result.data.companyInfo.managerEmailDisplay;

            managerNameController.text = result.data.companyInfo.managerName;
            managerPhoneNumberController.text =
                result.data.companyInfo.managerPhoneNumber;
            managerEmailController.text = result.data.companyInfo.managerEmail;

            isNameChecked =
                intToBool(result.data.companyInfo.managerNameDisplay);
            isPhoneNumberChecked =
                intToBool(result.data.companyInfo.managerHpDisplay);
            isEmailChecked =
                intToBool(result.data.companyInfo.managerEmailDisplay);
          });
        }
      }
    }
  }

  updateCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(companyControllerProvider.notifier)
          .updateCompanyInfo(managerData, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          if (mounted) {
            context.pop();
            showDefaultToast(localization.editCompleted);
          }
        }
      }
    }
  }

  returnCaption() {

    if (managerPhoneNumberController.text.isNotEmpty && !ValidateService.phoneNumberOnlyElevenRegex(
            managerPhoneNumberController.text)) {
      return localization.checkContactNumber;
    } else if (managerEmailController.text.isNotEmpty && !ValidateService.emailRegex(managerEmailController.text)) {
      return localization.checkEmail;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: CommonAppbar(
              title: localization.recruitmentContact,
            ),
            body: CustomScrollView(
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
                        localization.changesNotAppliedToCompanyInfoWhenPosting,
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
                  required: false,
                  text: '',
                  onTap: () {},
                  hasArrow: false,
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                  sliver: SliverToBoxAdapter(
                    child: TextFormField(
                      controller: managerNameController,
                      key: const Key('update-manager-name-input'),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      cursorColor: CommonColors.black,
                      style: commonInputText(),
                      maxLength: 20,
                      onTapOutside: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      decoration: commonInput(
                        hintText: localization.enterContactPersonName,
                      ),
                      minLines: 1,
                      maxLines: 1,
                      onChanged: (value) {
                        setState(() {
                          setManagerData(
                              'mcManagerName', managerNameController.text);
                        });
                      },
                      onEditingComplete: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ),
                PostingCheck(
                  onChanged: (value) {
                    setState(() {
                      isNameChecked = !isNameChecked;
                      setManagerData(
                          'mcManagerNameDisplay', boolToInt(isNameChecked));
                    });
                  },
                  groupValue: isNameChecked,
                  value: true,
                  label: localization.contactPersonNamePrivate,
                ),
                ProfileTitle(
                  title: localization.contactPersonPhone,
                  required: false,
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
                          controller: managerPhoneNumberController,
                          cursorColor: Colors.black,
                          key: const Key('update-manager-phoneNumber-input'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [PhoneNumberTextInputFormatter()],
                          decoration: commonInput(
                            hintText: localization.enterContactPersonPhone,
                          ),
                          onTapOutside: (value) {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                          maxLength: 13,
                          style: commonInputText(),
                          onChanged: (value) {
                            setState(() {
                              if (managerPhoneNumberController.text.isNotEmpty) {
                                phoneNumberMatchRegex =
                                    ValidateService.phoneNumberOnlyElevenRegex(
                                        managerPhoneNumberController.text);
                              } else {
                                phoneNumberMatchRegex = true;
                              }

                              if (phoneNumberMatchRegex) {
                                setManagerData('mcManagerHp',
                                    managerPhoneNumberController.text);
                              }
                            });
                          },
                          onEditingComplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                PostingCheck(
                  onChanged: (value) {
                    setState(() {
                      isPhoneNumberChecked = !isPhoneNumberChecked;
                      setManagerData('mcManagerHpDisplay',
                          boolToInt(isPhoneNumberChecked));
                    });
                  },
                  groupValue: isPhoneNumberChecked,
                  value: true,
                  label: localization.contactPersonPhonePrivate,
                ),
                ProfileTitle(
                  title: localization.contactPersonEmail,
                  required: false,
                  text: '',
                  onTap: () {},
                  hasArrow: false,
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                  sliver: SliverToBoxAdapter(
                    child: TextFormField(
                      controller: managerEmailController,
                      key: const Key('update-company-address-detail-input'),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      cursorColor: CommonColors.black,
                      style: commonInputText(),
                      maxLength: null,
                      decoration: suffixInput(
                        hintText: localization.enterEmail,
                      ),
                      onTapOutside: (value) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      minLines: 1,
                      maxLines: 1,
                      onChanged: (value) {
                        setState(() {
                          if (managerEmailController.text.isNotEmpty) {
                            emailMatchRegex = ValidateService.emailRegex(
                                managerEmailController.text);
                          } else {
                            emailMatchRegex = true;
                          }

                          if (emailMatchRegex) {
                            setManagerData(
                                'mcManagerEmail', managerEmailController.text);
                          }
                        });
                      },
                      onEditingComplete: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                    ),
                  ),
                ),
                PostingCheck(
                  onChanged: (value) {
                    setState(() {
                      isEmailChecked = !isEmailChecked;
                      setManagerData(
                          'mcManagerEmailDisplay', boolToInt(isEmailChecked));
                    });
                  },
                  groupValue: isEmailChecked,
                  value: true,
                  label: localization.emailPrivate,
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
            bottom: 80.w,
            child: Column(
              children: [
                Text(
                  returnCaption(),
                  style: commonErrorAuth(),
                ),
                SizedBox(height: 5.w),
              ],
            ),
          ),
          if (!isLoading)
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBottom,
              child: CommonButton(
                fontSize: 15,
                confirm: emailMatchRegex &&
                    phoneNumberMatchRegex,
                onPressed: () {
                  if (emailMatchRegex &&
                      phoneNumberMatchRegex) {
                    updateCompanyInfo();
                  }
                },
                text: localization.edit,
              ),
            )
        ],
      ),
    );
  }
}
