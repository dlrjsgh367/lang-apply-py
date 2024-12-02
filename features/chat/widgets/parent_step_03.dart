import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ParentStep03 extends ConsumerStatefulWidget {
  ParentStep03({
    super.key,
    required this.setData,
    required this.onPress,
    required this.data,
  });

  final Function setData;
  final Function onPress;
  final Map<String, dynamic> data;

  @override
  ConsumerState<ParentStep03> createState() => _ParentStep03State();
}

class _ParentStep03State extends ConsumerState<ParentStep03> {
  getPartnerCompanyInfo() async {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    UserModel? partnerInfo;
    ApiResultModel result = await ref
        .read(authControllerProvider.notifier)
        .getPartnerUserData('recruiter', roomInfo!.partnerKey);
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          partnerInfo = result.data;
        });

        if (partnerInfo != null) {
          setState(() {
            setData('paCompanyName', partnerInfo!.companyInfo!.name);
            companyNameController.text = partnerInfo!.companyInfo!.name;
            setData(
                'paCompanyPhone', partnerInfo!.companyInfo!.managerPhoneNumber.replaceAll("-", ""));
            companyPhoneController.text =
                partnerInfo!.companyInfo!.managerPhoneNumber.replaceAll("-", "");
            companyAddressController.text =
                '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}' ==
                        ' '
                    ? ''
                    : '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}';
            setData(
                'paCompanyAddress',
                '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}' ==
                        ' '
                    ? ''
                    : '${partnerInfo!.companyInfo!.address} ${partnerInfo!.companyInfo!.addressDetail}');
          });
        }
      }
    }
  }

  returnValidator() {
    if (!parentValidator['companyName'] &&
        !parentValidator['companyPhone'] &&
        !parentValidator['companyAddress']) {
      return '';
    } else if (!parentValidator['companyName']) {
      return '업체명을 확인해주세요.';
    } else if (!parentValidator['companyPhone']) {
      return '업체 전화번호를 확인해주세요.';
    } else if (!parentValidator['companyAddress']) {
      return '근무지 주소를 확인해주세요.';
    }
  }

  @override
  void initState() {
    Future(() {
      getPartnerCompanyInfo();
    });
    super.initState();
  }

  bool isAgree = false;
  Map<String, dynamic> parentValidator = {
    'type': false,
    'parentName': false,
    'parentBirth': false,
    'parentPhone': false,
    'parentAddress': false,
    'workerName': false,
    'workerBirth': false,
    'workerPhone': false,
    'workerAddress': false,
    'companyName': false,
    'companyPhone': false,
    'companyAddress': false,
  };
  Map<String, dynamic> params = {
    'paType': 0,
    'paParentName': '',
    'paParentBirth': '',
    'paParentPhone': '',
    'paParentAddress': '',
    'paParentAddressDetail': '',
    'paWorkerName': '',
    'paWorkerBirth': '',
    'paWorkerPhone': '',
    'paWorkerAddress': '',
    'paWorkerAddressDetail': '',
    'paCompanyName': '',
    'paCompanyPhone': '',
    'paCompanyAddress': '',
  };

  formValidator(String type) {
    switch (type) {
      case 'paCompanyName':
        params['paCompanyName'] == null || params['paCompanyName'].isEmpty
            ? setState(() {
                parentValidator['companyName'] = false;
              })
            : setState(() {
                parentValidator['companyName'] = true;
              });
      case 'paCompanyPhone':
        params['paCompanyPhone'] == null || params['paCompanyPhone'].isEmpty
            ? setState(() {
                parentValidator['companyPhone'] = false;
              })
            : setState(() {
                parentValidator['companyPhone'] = true;
              });
      case 'paCompanyAddress':
        params['paCompanyAddress'] == null || params['paCompanyAddress'].isEmpty
            ? setState(() {
                parentValidator['companyAddress'] = false;
              })
            : setState(() {
                parentValidator['companyAddress'] = true;
              });
    }
  }

  setData(key, value) {
    setState(() {
      params[key] = value;
    });
    widget.setData(key, value);
    formValidator(key);
  }

  TextEditingController companyNameController = TextEditingController();
  TextEditingController companyPhoneController = TextEditingController();
  TextEditingController companyAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.w, 32.w, 20.w, CommonSize.commonBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '사업장 정보',
                  style: commonTitleAuth(),
                ),
                SizedBox(height: 16.w),
                TextFormField(
                  enabled: false,
                  controller: companyNameController,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '회사명',
                  ),
                ),
                // if (!parentValidator['companyName'])
                //   const Text('이름을 입력해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  enabled: false,
                  controller: companyPhoneController,
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '회사 전화번호',
                  ),
                ),
                // if (!parentValidator['companyPhone'])
                //   const Text('휴대폰 번호를 확인해주세요.'),
                // const Text('근로자 주소'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  enabled: false,
                  controller: companyAddressController,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  style: commonInputText(),
                  decoration: commonInput(),
                ),
                // if (!parentValidator['companyAddress'])
                //   const Text('주소를 입력해주세요.'),
                SizedBox(
                  height: 40.w,
                ),
                Text(
                  '본인은 위 근로자 ${widget.data['paWorkerName']}(이)가 위 사업장에서\n'
                  '근로를 하는것에 대하여 동의합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CommonColors.gray66,
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(
                  height: 16.w,
                ),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(DateTime.now()),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CommonColors.gray80,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(
                  height: 24.w,
                ),
                Text(
                  '친권자 : ${widget.data['paParentName']}',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: CommonColors.gray4d,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(
                  height: 68.w,
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAgree = !isAgree;
                    });
                  },
                  child: ColoredBox(
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        CircleCheck(
                          onChanged: (value) {},
                          readOnly: true,
                          value: isAgree,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                        Text(
                          '(필수)',
                          style: TextStyle(
                            color: CommonColors.red,
                            fontSize: 13.sp,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            ' 내용에 이상이 없음을 확인하였습니다.',
                            style: TextStyle(
                                fontSize: 13.sp, color: CommonColors.gray80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 12.w,
                ),
                !parentValidator['companyName'] ||
                    !parentValidator['companyPhone'] ||
                    !parentValidator['companyAddress']
                    ? Text(
                  returnValidator(),
                  style: commonErrorAuth(),
                )
                    : const Text(''),
                SizedBox(
                  height: 12.w,
                ),
                CommonButton(
                  text: '제출하기',
                  fontSize: 15,
                  onPressed: () {
                    setState(() {
                      if (parentValidator['companyName'] &&
                          parentValidator['companyPhone'] &&
                          parentValidator['companyAddress'] &&
                          isAgree) {
                        widget.onPress();
                      }
                    });
                  },
                  confirm: parentValidator['companyName'] &&
                      parentValidator['companyPhone'] &&
                      parentValidator['companyAddress'] &&
                      isAgree,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
