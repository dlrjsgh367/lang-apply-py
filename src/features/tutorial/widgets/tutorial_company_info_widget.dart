import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/address_service.dart';
import 'package:chodan_flutter_app/features/company/controller/company_controller.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:daum_postcode_search/daum_postcode_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialCompanyInfoWidget extends ConsumerStatefulWidget {
  const TutorialCompanyInfoWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;
  final Function onPress;


  @override
  ConsumerState<TutorialCompanyInfoWidget> createState() =>
      _TutorialCompanyInfoWidgetState();
}

class _TutorialCompanyInfoWidgetState extends ConsumerState<TutorialCompanyInfoWidget> {
  final companyNameController = TextEditingController();
  final companyAddressController = TextEditingController();
  final companyAddressDetailController = TextEditingController();

  bool isLoading = true;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getCompanyInfo()]);
  }

  getCompanyInfo() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref.read(companyControllerProvider.notifier).getCompanyInfo(userInfo.key);
      if (result.status == 200) {
        if (result.type == 1) {
          setState(() {
            companyNameController.text = result.data.companyInfo.name;
            widget.setData('mcName', companyNameController.text);
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    companyAddressController.text = widget.data['mcAddress'];
    companyAddressDetailController.text = widget.data['mcAddressDetail'];

    _getAllAsyncTasks().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  showPost() async {
    DataModel? data = await context.push('/daumpost');
    if (data != null) {
      setState(() {
        companyAddressController.text = data.address;

        int siIndex = AddressService.siNameDefine.indexWhere((el) => el['daumName'] == data.sido);
        if (siIndex > -1) {
          widget.setData('mcAdSi', AddressService.siNameDefine[siIndex]['dbName']);
        } else {
          widget.setData('mcAdSi', data.sido);
        }
        widget.setData('mcAdGu', data.sigungu);
        widget.setData('mcAdDong', data.bname);
        widget.setData('mcAddress', data.address);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
    ? Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CustomScrollView(
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
                            localization.761,
                            style: TextStyle(
                              color: CommonColors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.w),
                        Text(
                          localization.companyName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: CommonColors.black2b,
                          ),
                        ),
                        SizedBox(height: 20.w),
                        TextFormField(
                          controller: companyNameController,
                          key: const Key('tutorial-company-name-input'),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          cursorColor: CommonColors.black,
                          style: commonInputText(),
                          decoration: commonInput(
                            hintText: localization.762,
                          ),
                          minLines: 1,
                          maxLines: 1,
                          onChanged: (value) {
                            setState(() {
                              if (companyNameController.text.isNotEmpty) {
                                widget.setData('mcName', companyNameController.text);
                              }
                            });
                          },
                        ),
                        SizedBox(height:36.w),
                        Text(
                          localization.companyAddress,
                          style: commonTitleAuth(),
                        ),
                        SizedBox(height: 12.w),
                        GestureDetector(
                          onTap: showPost,
                          child: TextFormField(
                            enabled: false,
                            controller: companyAddressController,
                            key: const Key('tutorial-company-address-input'),
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
                                controller: companyAddressDetailController,
                                key: const Key('tutorial-company-address-detail-input'),
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
                                    if (companyAddressDetailController.text.isNotEmpty) {
                                      widget.setData('mcAddressDetail', companyAddressDetailController.text);
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
                              text: localization.766,
                            ),*/
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
                    widget.onPress();
                  },
                  text: localization.755,
                  width: 96.w,
                ),
                SizedBox(
                  width: 8.w,
                ),
                Expanded(
                  child: CommonButton(
                    onPressed: () {
                      if (companyNameController.text.isNotEmpty &&
                          companyAddressController.text.isNotEmpty) {
                        widget.writeFunc();
                        widget.onPress();

                      }
                    },
                    text: localization.next,
                    fontSize: 15,
                    confirm: companyNameController.text.isNotEmpty &&
                        companyAddressController.text.isNotEmpty,
                  ),
                )
              ],
            ),
          ),
        ],
      )
    : const Loader();
  }
}
