import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddCompanyOwnerWidget extends ConsumerStatefulWidget {
  const AddCompanyOwnerWidget({
    super.key,
    required this.data,
  });

  final CompanyModel data;

  @override
  ConsumerState<AddCompanyOwnerWidget> createState() =>
      _AddCompanyOwnerWidgetState();
}

class _AddCompanyOwnerWidgetState extends ConsumerState<AddCompanyOwnerWidget> {
  Map<String, dynamic> ownerData = {
    'mcRegistrationNumber': '', // 사업자등록번호
    'mcOwnerName': '', // 대표자명
    'mcOpeningDate': '', // 개업일자
  };

  bool isLoading = true;

  bool registrationNumberMatchRegex = false;
  bool openingDateMatchRegex = false;

  final registrationNumberController = TextEditingController();
  final ownerNameController = TextEditingController();
  final openingDateController = TextEditingController();

  setOwnerData(String key, dynamic value) {
    ownerData[key] = value;
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
      ApiResultModel result = await ref.read(companyControllerProvider.notifier).getCompanyInfo(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          setState(() {
            ownerData['mcRegistrationNumber'] = result.data.companyInfo.registrationNumber;
            ownerData['mcOwnerName'] = result.data.companyInfo.companyOwnerName;
            ownerData['mcOpeningDate'] = result.data.companyInfo.companyOpeningDay;

            registrationNumberController.text = result.data.companyInfo.registrationNumber;
            ownerNameController.text = result.data.companyInfo.companyOwnerName;
            openingDateController.text = result.data.companyInfo.companyOpeningDay;
          });
        }
      }
    }
  }

  showErrorAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.businessVerificationFailed,
            alertContent: localization.businessValidationFailedCheckInfo,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
            },
          );
        },
    );
  }

  updateCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref.read(companyControllerProvider.notifier).updateCompanyInfo(ownerData, userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          if (mounted) {
            context.pop();
            showDefaultToast(localization.editCompleted);
          }
        }
      } else {
        if (result.status == 424) {
          if (mounted) {
            showErrorAlert(context);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: CommonAppbar(
          title: localization.businessCertification,
        ),
        body: !isLoading
          ? Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              localization.businessRegistrationNumber,
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 20.w),
                            TextFormField(
                              controller: registrationNumberController,
                              key: const Key('update-registration-number-input'),
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.black,
                              inputFormatters: [RegistrationNumberTextInputFormatter()],
                              decoration: commonInput(
                                hintText: localization.enter10DigitBusinessRegistrationNumber,
                              ),
                              style: commonInputText(),
                              // maxLength 10이지만 하이픈 때문에 + 2
                              maxLength: 12,
                              onChanged: (value) {
                                setState(() {
                                  registrationNumberMatchRegex = ValidateService.registrationNumberRegex(registrationNumberController.text);

                                  if (registrationNumberMatchRegex && registrationNumberController.text.isNotEmpty) {
                                    setOwnerData('mcRegistrationNumber', registrationNumberController.text);
                                  }
                                });
                              },
                            ),
                            SizedBox(height:36.w),
                            Text(
                              localization.representativeName,
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 20.w),
                            TextFormField(
                              controller: ownerNameController,
                              key: const Key('update-owner-name-input'),
                              keyboardType: TextInputType.text,
                              decoration: commonInput(
                                hintText: localization.enterRepresentativeName,
                              ),
                              style: commonInputText(),
                              maxLength: 50,
                              minLines: 1,
                              maxLines: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣ㆍᆞᆢa-zA-Z\s]')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  if (ownerNameController.text.isNotEmpty) {
                                    setOwnerData('mcOwnerName', ownerNameController.text);
                                  }
                                });
                              },
                            ),
                            SizedBox(height:36.w),
                            Text(
                              localization.businessStartDate,
                              style: commonTitleAuth(),
                            ),
                            SizedBox(height: 20.w),
                            TextFormField(
                              controller: openingDateController,
                              key: const Key('update-opening-date-input'),
                              keyboardType: TextInputType.number,
                              autocorrect: false,
                              cursorColor: CommonColors.black,
                              style: commonInputText(),
                              inputFormatters: [DateTextInputFormatter()],
                              decoration: suffixInput(
                                hintText: localization.enter8DigitBusinessStartDate,
                              ),
                              // maxLength 8이지만 하이픈 때문에 + 2
                              maxLength: 10,
                              minLines: 1,
                              maxLines: 1,
                              onChanged: (value) {
                                setState(() {
                                  openingDateMatchRegex = ValidateService.dateNumberRegex(openingDateController.text);

                                  if (openingDateMatchRegex && openingDateController.text.isNotEmpty) {
                                    setOwnerData('mcOpeningDate', openingDateController.text);
                                  }
                                });
                              },
                            ),
                            SizedBox(height: 36.w),
                            CommonButton(
                              confirm: registrationNumberController.text.isNotEmpty &&
                                  ownerNameController.text.isNotEmpty &&
                                  openingDateController.text.isNotEmpty,
                              onPressed: () {
                                if (registrationNumberController.text.isNotEmpty &&
                                    ownerNameController.text.isNotEmpty &&
                                    openingDateController.text.isNotEmpty
                                ) {
                                  updateCompanyInfo();
                                }
                              },
                              text: localization.verify,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const FooterBottomPadding(),
                  ],
                ),
              ],
            ) : const Loader(),
      ),
    );
  }
}
