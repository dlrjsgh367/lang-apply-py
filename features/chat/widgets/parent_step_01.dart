import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/contract/validator/contract_validator.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:daum_postcode_search/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ParentStep01 extends ConsumerStatefulWidget {
  ParentStep01({super.key, required this.setData, required this.onPress});

  final Function setData;
  final Function onPress;

  @override
  ConsumerState<ParentStep01> createState() => _ParentStep01State();
}

class _ParentStep01State extends ConsumerState<ParentStep01> {

  setData(key, value) {
    widget.setData(key, value);
  }

  Map<String, dynamic>? parentSelectedDropdown;
  List<Map<String, dynamic>> parentList = [
    {'name': '부', 'key': 1},
    {'name': '모', 'key': 2},
    {'name': '법정대리인', 'key': 3},
  ];

  showParentDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CommonColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      barrierColor: CommonColors.barrier,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(
          contents: [
            for (var i = 0; i < parentList.length; i++)
              BottomSheetButton(
                onTap: () {
                  setState(() {
                    parentSelectedDropdown = parentList[i];

                    setData('paType', parentList[i]['key']);
                  });
                  context.pop();
                },
                text: parentList[i]['name'],
                isRed: parentSelectedDropdown == parentList[i],
              ),
          ],
        );
      },
    );
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        parentAddressController.text = data.address;
        setData('paParentAddress', data.address);
      });
    }
  }

  TextEditingController parentNameController = TextEditingController();
  TextEditingController parentBirthController = TextEditingController();
  TextEditingController parentPhoneController = TextEditingController();
  TextEditingController parentAddressController = TextEditingController();
  TextEditingController parentAddressDetailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            padding:
                EdgeInsets.fromLTRB(20.w, 32.w, 20.w, CommonSize.commonBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '친권자 정보',
                  style: commonTitleAuth(),
                ),
                SizedBox(height: 16.w),
                TextFormField(
                    controller: parentNameController,
                    maxLength: 50,
                    maxLines: null,
                    autocorrect: false,
                    cursorColor: Colors.black,
                    onChanged: (value) {
                      setData('paParentName', parentNameController.text);
                    },
                    style: commonInputText(),
                    decoration: commonInput(
                      hintText: '이름을 입력하세요',
                    )),
                // if (!parentValidator['parentName'])
                //   const Text('이름을 입력해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  controller: parentBirthController,
                  maxLength: 8,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setData('paParentBirth', parentBirthController.text);
                  },
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '생년월일 8자리를 확인해주세요.',
                  ),
                ),
                // if (!parentValidator['parentBirth'])
                //   const Text('생년월일을 입력해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                TextFormField(
                  controller: parentPhoneController,
                  maxLength: 11,
                  keyboardType: TextInputType.phone,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  onChanged: (value) {
                    setData('paParentPhone', parentPhoneController.text);
                    // setState(() {
                    //   params[] = ;
                    // });
                  },
                  style: commonInputText(),
                  decoration: commonInput(
                    hintText: '휴대폰 번호를 입력하세요',
                  ),
                ),
                // if (!parentValidator['parentPhone'])
                //   const Text('휴대폰 번호를 확인해주세요.'),
                SizedBox(
                  height: 12.w,
                ),
                SelectButton(
                    onTap: () {
                      showParentDialog();
                    },
                    text: parentList.map((e) {
                      if (e == parentSelectedDropdown) {
                        return e['name'];
                      } else {
                        return '';
                      }
                    }).join(),
                    hintText: '근로자와의 관계를 선택해주세요'),

                // if (!parentValidator['type'])
                //   const Text('근로자와의 관계를 선택해주세요.'),
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
                    controller: parentAddressController,
                    maxLines: null,
                    autocorrect: false,
                    cursorColor: Colors.black,
                    style: commonInputText(),
                    decoration: commonInput(
                      disable: true,
                      hintText: '[주소 검색] 도로명 또는 지번 주소를 입력해 주세요.',
                    ),
                    readOnly: true,
                    onChanged: (value) {
                      setData('paParentAddress', parentAddressController.text);
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
                        controller: parentAddressDetailController,
                        maxLines: null,
                        autocorrect: false,
                        cursorColor: Colors.black,
                        style: commonInputText(),
                        decoration: commonInput(
                          hintText: '(선택) 층, 동, 호수 등 상세 주소를 입력해 주세요.',
                        ),
                        onChanged: (value) {
                          setData('paParentAddress',
                              parentAddressDetailController.text);
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
                    )*/
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
