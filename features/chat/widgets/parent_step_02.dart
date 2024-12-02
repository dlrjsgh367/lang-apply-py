import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:daum_postcode_search/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ParentStep02 extends ConsumerStatefulWidget {
  ParentStep02({super.key, required this.setData, required this.onPress});

  final Function setData;
  final Function onPress;

  @override
  ConsumerState<ParentStep02> createState() => _ParentStep02State();
}

class _ParentStep02State extends ConsumerState<ParentStep02> {
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
      case 'paWorkerName':
        params['paWorkerName'] == null || params['paWorkerName'].isEmpty
            ? setState(() {
          parentValidator['workerName'] = false;
        })
            : setState(() {
          parentValidator['workerName'] = true;
        });
      case 'paWorkerBirth':
        params['paWorkerBirth'] == null ||
            params['paWorkerBirth'].isEmpty ||
            ContractValidator.validateDateNumber(params['paWorkerBirth']) ==
                false
            ? setState(() {
          parentValidator['workerBirth'] = false;
        })
            : setState(() {
          parentValidator['workerBirth'] = true;
        });
      case 'paWorkerPhone':
        params['paWorkerPhone'] == null ||
            params['paWorkerPhone'].isEmpty ||
            ContractValidator.validatePhoneNumber(
                params['paWorkerPhone']) ==
                false
            ? setState(() {
          parentValidator['workerPhone'] = false;
        })
            : setState(() {
          parentValidator['workerPhone'] = true;
        });
      case 'paWorkerAddress':
        params['paWorkerAddress'] == null || params['paWorkerAddress'].isEmpty
            ? setState(() {
          parentValidator['workerAddress'] = false;
        })
            : setState(() {
          parentValidator['workerAddress'] = true;
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


  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        workerAddressController.text = data.address;
        setData('paWorkerAddress', data.address);
      });
    }
  }

  returnValidator() {
    if (!parentValidator['workerName'] &&
        !parentValidator['workerBirth'] &&
        !parentValidator['workerPhone'] &&
        !parentValidator['workerAddress']) {
      return '';
    } else if (!parentValidator['workerName']) {
      return '근로자 이름을 확인해주세요.';
    } else if (!parentValidator['workerBirth']) {
      return '근로자 생년월일을 확인해주세요.';
    } else if (!parentValidator['workerPhone']) {
      return '근로자 휴대폰 번호를 확인해주세요.';
    } else if (!parentValidator['workerAddress']) {
      return '근로자 주소를 확인해주세요.';
    }
  }

  TextEditingController workerNameController = TextEditingController();
  TextEditingController workerBirthController = TextEditingController();
  TextEditingController workerPhoneController = TextEditingController();
  TextEditingController workerAddressController = TextEditingController();
  TextEditingController workerAddressDetailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.w, 32.w, 20.w, CommonSize.commonBottom ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '근로자 정보',
                  style: commonTitleAuth(),
                ),
                SizedBox(height: 16.w),
                TextFormField(
                  controller: workerNameController,
                  maxLength: 50,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setData('paWorkerName', workerNameController.text);
                  },
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '이름을 입력해주세요',
                  ),
                ),
                // if (!parentValidator['workerName'])
                //   const Text('이름을 입력해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  controller: workerBirthController,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setData('paWorkerBirth', workerBirthController.text);
                  },
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '생년월일 8자리를 확인해주세요.',
                  ),
                ),
                // if (!parentValidator['workerBirth'])
                //   const Text('생년월일을 입력해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  controller: workerPhoneController,
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setData('paWorkerPhone', workerPhoneController.text);
                  },
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '휴대폰 번호를 입력해주세요',
                  ),
                ),
                // if (!parentValidator['workerPhone'])
                //   const Text('휴대폰 번호를 확인해주세요.'),
                SizedBox(
                  height: 36.w,
                ),
                Text(
                  '주소',
                  style: commonTitleAuth(),
                ),
                SizedBox(
                  height: 16.w,
                ),
                GestureDetector(
                  onTap: showPost,
                  child: TextFormField(
                    controller: workerAddressController,
                    maxLines: null,
                    autocorrect: false,
                    cursorColor: Colors.black,
                    readOnly: true,
                    style: commonInputText(),
                    decoration:
                        commonInput(hintText: '[주소 검색] 도로명 또는 지번 주소를 입력해 주세요.', disable: true),
                    onChanged: (value) {
                      setData('paWorkerAddress', workerAddressController.text);
                    },
                  ),
                ),
                SizedBox(
                  height: 12.w,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: workerAddressDetailController,
                        maxLines: null,
                        autocorrect: false,
                        cursorColor: Colors.black,
                        style: commonInputText(),
                        decoration: commonInput(
                          hintText: '(선택) 층, 동, 호수 등 상세 주소를 입력해 주세요.',
                        ),
                        onChanged: (value) {
                          setData('paWorkerAddressDetail',
                              workerAddressDetailController.text);
                        },
                      ),
                    ),
                    /*SizedBox(
                      width: 4.w,
                    ),
                    CommonButton(
                      width: 96.w,
                      onPressed: showPost,
                      text: '주소검색',
                      confirm: true,
                      fontSize: 15,
                    ),*/
                  ],
                ),
                SizedBox(
                  height: 12.w,
                ),
                !parentValidator['workerName'] ||
                    !parentValidator['workerBirth'] ||
                    !parentValidator['workerPhone'] ||
                    !parentValidator['workerAddress']
                    ? Text(
                  returnValidator(),
                  style: commonErrorAuth(),
                )
                    : const Text(''),
                SizedBox(
                  height: 12.w,
                ),
                CommonButton(
                  text: '다음',
                  fontSize: 15,
                  confirm: parentValidator['workerName'] &&
                      parentValidator['workerBirth'] &&
                      parentValidator['workerPhone'] &&
                      parentValidator['workerAddress'],
                  onPressed: () {
                    if (parentValidator['workerName'] &&
                        parentValidator['workerBirth'] &&
                        parentValidator['workerPhone'] &&
                        parentValidator['workerAddress']) {
                      widget.onPress();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
