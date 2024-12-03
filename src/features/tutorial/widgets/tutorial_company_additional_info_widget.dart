import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class TutorialCompanyAdditionalInfoWidget extends ConsumerStatefulWidget {
  const TutorialCompanyAdditionalInfoWidget({
    super.key,
    required this.data,
    required this.industryName,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final String industryName;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialCompanyAdditionalInfoWidget> createState() =>
      _TutorialCompanyAdditionalInfoWidgetState();
}

class _TutorialCompanyAdditionalInfoWidgetState extends ConsumerState<TutorialCompanyAdditionalInfoWidget> {
  List<DefineModel> selectedIndustry = [];
  List<int> selectedIndustryKey = [];
  String industryName = '';
  int industryMaxLength = 1;

  final numberOfEmployeesController = TextEditingController();

  addIndustry(List<DefineModel> industryItem, List<int> apply) {
    setState(() {
      selectedIndustry = [...industryItem];
      selectedIndustryKey = [...apply];
      industryName = industryItem[0].name;
    });
  }

  @override
  void initState() {
    super.initState();
    industryName = widget.industryName;
    selectedIndustryKey.add(widget.data['inIdx']);

    if (widget.data['mcEmployees'] != 0) {
      numberOfEmployeesController.text = widget.data['mcEmployees'].toString();
    } else {
      numberOfEmployeesController.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DefineModel> industryList = ref.watch(industryListProvider);
    return Stack(
      children: [
        PopScope(
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
          child: Scaffold(
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
                            localization.756,
                            style: TextStyle(
                              color: CommonColors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 20.w),
                        SelectButton(
                          onTap: () async {
                            await DefineDialog.showIndustryBottom2(context, localization.757, industryList, addIndustry, selectedIndustry, industryMaxLength);
                            widget.setData('inIdx', selectedIndustryKey[0]);
                          },
                          text: industryName, hintText: localization.selectIndustry,
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
                                controller: numberOfEmployeesController,
                                keyboardType: TextInputType.number,
                                key: const Key('tutorial-number-of-employees-input'),
                                decoration: commonInput(
                                  hintText: localization.enterNumberOfEmployees,
                                ),
                                cursorColor: Colors.black,
                                style: commonInputText(),
                                onChanged: (value) {
                                  setState(() {
                                    if (numberOfEmployeesController.text.isNotEmpty &&
                                        int.parse(numberOfEmployeesController.text) > 0) {
                                      widget.setData('mcEmployees', int.parse(numberOfEmployeesController.text));
                                    }
                                  });
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              localization.64,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: CommonColors.black2b,
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
            ),
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
                    if (selectedIndustryKey.isNotEmpty &&
                        numberOfEmployeesController.text.isNotEmpty &&
                        int.parse(numberOfEmployeesController.text) > 0) {
                      widget.writeFunc();
                      widget.onPress();
                    }
                  },
                  text: localization.next,
                  fontSize: 15,
                  confirm: selectedIndustryKey.isNotEmpty &&
                      numberOfEmployeesController.text.isNotEmpty &&
                      int.parse(numberOfEmployeesController.text) > 0,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
