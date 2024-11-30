import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/auth/service/validate_service.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialCompanyManagerWidget extends ConsumerStatefulWidget {
  const TutorialCompanyManagerWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;

  @override
  ConsumerState<TutorialCompanyManagerWidget> createState() =>
      _TutorialCompanyManagerWidgetState();
}

class _TutorialCompanyManagerWidgetState extends ConsumerState<TutorialCompanyManagerWidget> {
  bool isNameChecked = false;
  bool isPhoneNumberChecked = false;
  bool isEmailChecked = false;

  bool phoneNumberMatchRegex = false;
  bool emailMatchRegex = false;

  final managerNameController = TextEditingController();
  final managerPhoneNumberController = TextEditingController();
  final managerEmailController = TextEditingController();
  final hpFocus = FocusNode();

  int boolToInt(bool value) {
    return value ? 0 : 1;
  }

  bool intToBool(int value) {
    return value == 0 ? true : false; // 비공개는 true
  }

  @override
  void initState() {
    super.initState();

    managerNameController.text = widget.data['mcManagerName'];
    managerPhoneNumberController.text =  widget.data['mcManagerHp'];
    managerEmailController.text =  widget.data['mcManagerEmail'];

    isNameChecked = intToBool(widget.data['mcManagerNameDisplay']);
    isPhoneNumberChecked = intToBool(widget.data['mcManagerHpDisplay']);
    isEmailChecked = intToBool(widget.data['mcManagerEmailDisplay']);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 48.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          color: CommonColors.red02,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          localization.enterRecruitmentManagerInfo,
                          style: TextStyle(
                            color: CommonColors.red,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                      Text(
                        localization.contactPersonName,
                        style: commonTitleAuth(),
                      ),
                      SizedBox(height: 20.w),
                      TextFormField(
                        cursorColor: Colors.black,
                        controller: managerNameController,
                        key: const Key('update-manager-name-input'),
                        keyboardType: TextInputType.text,
                        decoration: commonInput(
                          hintText: localization.enterManagerName,
                        ),
                        style: commonInputText(),
                        onChanged: (value) {
                          setState(() {
                            if (managerNameController.text.isNotEmpty) {
                              widget.setData('mcManagerName', managerNameController.text);
                            }
                          });
                        },
                        onEditingComplete: (){
                          if (managerNameController.text.isNotEmpty) {
                            FocusScope.of(context).requestFocus(hpFocus);
                          }else{
                            FocusManager.instance.primaryFocus?.unfocus();
                          }
                        },
                      ),
                      /*CheckboxListTile(
                        title: const Text(localization.contactPersonNameHidden),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: isNameChecked,
                        onChanged: (value) {
                          setState(() {
                            isNameChecked = !isNameChecked;
                            widget.setData('mcManagerNameDisplay', boolToInt(isNameChecked));
                          });
                        },
                      ),*/
                      SizedBox(height:36.w),
                      Text(
                        localization.contactPersonPhone,
                        style: commonTitleAuth(),
                      ),
                      SizedBox(height: 20.w),
                      TextFormField(
                        cursorColor: Colors.black,
                        focusNode: hpFocus,
                        controller: managerPhoneNumberController,
                        key: const Key('update-manager-phoneNumber-input'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [PhoneNumberTextInputFormatter()],
                        decoration: commonInput(
                          hintText: localization.enterManagerContact,
                        ),
                        style: commonInputText(),
                        // maxLength 11이지만 하이픈 때문에 + 2
                        maxLength: 13,
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            phoneNumberMatchRegex = ValidateService.phoneNumberOnlyElevenRegex(managerPhoneNumberController.text);
                            if (phoneNumberMatchRegex && managerPhoneNumberController.text.isNotEmpty) {
                              widget.setData('mcManagerHp', managerPhoneNumberController.text);
                            }
                          });
                        },
                      ),
                      /*CheckboxListTile(
                        title: const Text(localization.contactPersonPhoneHidden),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: isPhoneNumberChecked,
                        onChanged: (value) {
                          setState(() {
                            isPhoneNumberChecked = !isPhoneNumberChecked;
                            widget.setData('mcManagerHpDisplay', boolToInt(isPhoneNumberChecked));
                          });
                        },
                      ),*/
                      SizedBox(height:36.w),
                      Text(
                        localization.contactPersonEmail,
                        style: commonTitleAuth(),
                      ),
                      SizedBox(height: 20.w),
                      TextFormField(
                        controller: managerEmailController,
                        key: const Key('update-company-address-detail-input'),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: suffixInput(
                          hintText: localization.enterManagerEmail,
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            emailMatchRegex = ValidateService.emailRegex(managerEmailController.text);

                            if (emailMatchRegex && managerEmailController.text.isNotEmpty) {
                              widget.setData('mcManagerEmail', managerEmailController.text);
                            }
                          });
                        },
                      ),
                      /*CheckboxListTile(
                        title: const Text(localization.contactPersonEmailHidden),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: isEmailChecked,
                        onChanged: (value) {
                          setState(() {
                            isEmailChecked = !isEmailChecked;
                            widget.setData('mcManagerEmailDisplay', boolToInt(isEmailChecked));
                          });
                        },
                      ),*/
                      SizedBox(height:36.w),
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
                  onPressed: () {
                    if (managerNameController.text.isNotEmpty &&
                        managerPhoneNumberController.text.isNotEmpty &&
                        managerEmailController.text.isNotEmpty
                    ) {
                      widget.writeFunc();
                      context.pop();
                    }
                  },
                  text: localization.completeSetup,
                  fontSize: 15,
                  confirm: managerNameController.text.isNotEmpty &&
                      managerPhoneNumberController.text.isNotEmpty &&
                      managerEmailController.text.isNotEmpty,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
