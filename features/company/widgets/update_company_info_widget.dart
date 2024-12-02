import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/address_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UpdateCompanyInfoWidget extends ConsumerStatefulWidget {
  const UpdateCompanyInfoWidget({
    super.key,
    required this.data,
  });

  final CompanyModel data;

  @override
  ConsumerState<UpdateCompanyInfoWidget> createState() =>
      _UpdateCompanyInfoWidgetState();
}

class _UpdateCompanyInfoWidgetState
    extends ConsumerState<UpdateCompanyInfoWidget> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  Map<String, dynamic> companyData = {
    'mcName': '', // 기업명
    'inIdx': 0, // 업종 키 값
    'mcEmployees': 0, // 직원 수
    'mcAddress': '', // 기업 주소
    'mcAddressDetail': '', // 기업 상세 주소
    'mcIntroduce': '', // 소개글
  };

  bool isLoading = true;

  List<DefineModel> selectedIndustry = [];
  List<DefineModel> initialSelectedIndustryList = [];

  List<int> selectedIndustryKey = [];
  int industryMaxLength = 1;

  final companyNameController = TextEditingController();
  final numberOfEmployeesController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyAddressDetailController = TextEditingController();
  final companyIntroduceController = TextEditingController();

  setCompanyData(String key, dynamic value) {
    companyData[key] = value;
  }

  addIndustry(List<DefineModel> industryItem, List<int> apply) {
    setState(() {
      selectedIndustry = [...industryItem];
      selectedIndustryKey = [...apply];
    });
  }

  void addSelectedIndustryList(DefineModel defineData, bool isAll) {
    DefineModel defineDataCopy = DefineModel.copy(defineData);
    if (isAll) {
      defineDataCopy.name =
          ConvertService.removeParentheses('${defineData.name} ${localization.all}');
    }
    selectedIndustry.add(defineDataCopy);
  }

  selectIndustryItem(DefineModel item, {bool isAll = false}) {
    setState(() {
      if (initialSelectedIndustryList.length <= industryMaxLength) {
        addSelectedIndustryList(item, isAll);
      }
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getCompanyInfo()]);
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      setState(() {
        for (DefineModel item in initialSelectedIndustryList) {
          selectIndustryItem(item);
        }

        isLoading = false;
      });
    });
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        companyAddressController.text = data.address;

        int siIndex = AddressService.siNameDefine
            .indexWhere((el) => el['daumName'] == data.sido);
        if (siIndex > -1) {
          setCompanyData(
              'mcAdSi', AddressService.siNameDefine[siIndex]['dbName']);
        } else {
          setCompanyData('mcAdSi', data.sido);
        }
        setCompanyData('mcAdGu', data.sigungu);
        setCompanyData('mcAdDong', data.bname);
        setCompanyData('mcAddress', data.address);
      });
    }
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
            companyData['mcName'] = result.data.companyInfo.name;
            companyData['inIdx'] = result.data.companyInfo.industryKey;
            companyData['mcEmployees'] =
                result.data.companyInfo.numberOfEmployees;
            companyData['mcAddress'] = result.data.companyInfo.address;
            companyData['mcAddressDetail'] =
                result.data.companyInfo.addressDetail;
            companyData['mcIntroduce'] =
                result.data.companyInfo.companyIntroduce;

            companyNameController.text = result.data.companyInfo.name;
            companyAddressController.text = result.data.companyInfo.address;
            companyAddressDetailController.text =
                result.data.companyInfo.addressDetail;
            companyIntroduceController.text =
                result.data.companyInfo.companyIntroduce;
            // 직원수
            if (companyData['mcEmployees'] != 0) {
              numberOfEmployeesController.text =
                  companyData['mcEmployees'].toString();
            } else {
              numberOfEmployeesController.text = '';
            }

            // 업종
            DefineModel jobModel = DefineModel(
              key: result.data.companyInfo.industryKey,
              depth: 0,
              name: result.data.industryName,
              child: [],
              isInput: 0,
              parent: null,
              parentKey: 0,
            );
            initialSelectedIndustryList.add(jobModel);
            selectedIndustryKey.add(result.data.companyInfo.industryKey);
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
          .updateCompanyInfo(companyData, userInfo.key);
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

  @override
  Widget build(BuildContext context) {
    List<DefineModel> industryList = ref.watch(industryListProvider);
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
        child: Stack(
          children: [
            Scaffold(
              appBar: CommonAppbar(
                title: localization.basicInformation,
              ),
              body: !isLoading
                  ? Column(
                      children: [
                        Expanded(
                            child: CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      height: 48.w,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                        color: CommonColors.red02,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        localization.enterCompanyInformationAndIntroduction,
                                        style: TextStyle(
                                          color: CommonColors.red,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.w),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            localization.companyName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 4.w),
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.red),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.w),
                                    TextFormField(
                                      controller: companyNameController,
                                      keyboardType: TextInputType.text,
                                      key: const Key(
                                          'update-company-name-input'),
                                      decoration: commonInput(
                                        hintText: localization.enterCompanyName,
                                      ),
                                      style: commonInputText(),
                                      onChanged: (value) {
                                        setState(() {
                                          if (companyNameController
                                              .text.isNotEmpty) {
                                            setCompanyData('mcName',
                                                companyNameController.text);
                                          }
                                        });
                                      },
                                    ),
                                    SizedBox(height: 36.w),
                                    Text(
                                      localization.industry,
                                      style: commonTitleAuth(),
                                    ),
                                    SizedBox(height: 20.w),
                                    SelectButton(
                                      onTap: () async {
                                        await DefineDialog.showIndustryBottom2(
                                            context,
                                            localization.industry,
                                            industryList,
                                            addIndustry,
                                            selectedIndustry,
                                            industryMaxLength);
                                        setCompanyData(
                                            'inIdx', selectedIndustryKey[0]);
                                      },
                                      text: selectedIndustry.isNotEmpty
                                          ? selectedIndustry[0].name
                                          : '',
                                      hintText: localization.selectIndustry,
                                    ),
                                    SizedBox(height: 36.w),
                                    Text(
                                      localization.numberOfEmployees,
                                      style: commonTitleAuth(),
                                    ),
                                    SizedBox(height: 12.w),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                numberOfEmployeesController,
                                            keyboardType: TextInputType.number,
                                            key: const Key(
                                                'update-number-of-employees-input'),
                                            decoration: commonInput(
                                              hintText: localization.enterNumberOfEmployees,
                                            ),
                                            maxLength: 8,
                                            style: commonInputText(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (numberOfEmployeesController
                                                        .text.isNotEmpty &&
                                                    int.parse(
                                                            numberOfEmployeesController
                                                                .text) >
                                                        0) {
                                                  setCompanyData(
                                                      'mcEmployees',
                                                      int.parse(
                                                          numberOfEmployeesController
                                                              .text));
                                                } else {
                                                  setCompanyData(
                                                      'mcEmployees', 0);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Text(
                                          localization.numOfPeople(''),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 36.w),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            localization.companyAddress,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16.sp,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(left: 4.w),
                                          width: 4.w,
                                          height: 4.w,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.red),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.w),
                                    GestureDetector(
                                      onTap: showPost,
                                      child: TextFormField(
                                        enabled: false,
                                        controller: companyAddressController,
                                        key: const Key(
                                            'update-company-address-input'),
                                        autocorrect: false,
                                        style: commonInputText(),
                                        maxLength: null,
                                        decoration: commonInput(
                                          hintText: localization.searchAddressEnterRoadOrLotNumberAddress,
                                          disable: true,
                                        ),
                                        minLines: 1,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: 10.w),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                                companyAddressDetailController,
                                            key: const Key(
                                                'update-company-address-detail-input'),
                                            keyboardType: TextInputType.text,
                                            autocorrect: false,
                                            cursorColor: CommonColors.black,
                                            style: commonInputText(),
                                            maxLength: 100,
                                            decoration: suffixInput(
                                              hintText: localization.optionalEnterDetailedAddress,
                                            ),
                                            minLines: 1,
                                            maxLines: 1,
                                            onChanged: (value) {
                                              setState(() {
                                                if (companyAddressDetailController
                                                    .text.isNotEmpty) {
                                                  setCompanyData(
                                                      'mcAddressDetail',
                                                      companyAddressDetailController
                                                          .text);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        /*SizedBox(width: 4.w),
                                    CommonButton(
                                      width: 90.w,
                                      height: 48.w,
                                      confirm: true,
                                      onPressed: showPost,
                                      text: '주소검색',
                                    ),*/
                                      ],
                                    ),
                                    SizedBox(height: 36.w),
                                    Text(
                                      localization.companyIntroduction,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.sp,
                                        color: CommonColors.black2b,
                                      ),
                                    ),
                                    SizedBox(height: 10.w),
                                    Stack(
                                      children: [
                                        CommonKeyboardAction(
                                          focusNode: textAreaNode,
                                          child: TextFormField(
                                            onTap: () {
                                              ScrollCenter(textAreaKey);
                                            },
                                            key: textAreaKey,
                                            focusNode: textAreaNode,
                                            textInputAction:
                                                TextInputAction.newline,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller:
                                                companyIntroduceController,
                                            decoration: areaInput(
                                              hintText: localization.enterContent,
                                            ),
                                            maxLength: 1000,
                                            textAlignVertical:
                                                TextAlignVertical.top,
                                            maxLines: 4,
                                            minLines: 4,
                                            style: commonInputText(),
                                            onChanged: (value) {
                                              setState(() {
                                                if (companyIntroduceController
                                                    .text.isNotEmpty) {
                                                  setCompanyData(
                                                      'mcIntroduce',
                                                      companyIntroduceController
                                                          .text);
                                                } else {
                                                  setCompanyData(
                                                      'mcIntroduce',
                                                      companyIntroduceController
                                                          .text);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          right: 10.w,
                                          bottom: 10.w,
                                          child: Text(
                                            '${companyIntroduceController.text.length} / 1,000',
                                            style: TextStyles.counter,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const BottomPadding(
                              extra: 100,
                            ),
                          ],
                        )),
                        KeyboardVisibilityBuilder(
                          builder: (context, visibility) {
                            return SizedBox(
                              height: visibility ? 44 : 0,
                            );
                          },
                        ),
                      ],
                    )
                  : const Loader(),
            ),
            if (!isLoading)
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: CommonSize.commonBottom,
                child: CommonButton(
                  fontSize: 15,
                  confirm: companyNameController.text.isNotEmpty &&
                      companyAddressController.text.isNotEmpty,
                  onPressed: () {
                    if (companyNameController.text.isNotEmpty &&
                        companyAddressController.text.isNotEmpty) {
                      updateCompanyInfo();
                    }
                  },
                  text: localization.edit,
                ),
              )
          ],
        ),
      ),
    );
  }
}
