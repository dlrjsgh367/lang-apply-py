import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SalaryFilterWidget extends ConsumerStatefulWidget {
  const SalaryFilterWidget({
    super.key,
    required this.getPostList,
    required this.applySalaryType,
    required this.applySalary,
    required this.initSelected,
    required this.initSalary,
  });

  final Function getPostList;
  final Function applySalaryType;
  final String initSelected;
  final Function applySalary;
  final int initSalary;

  @override
  ConsumerState<SalaryFilterWidget> createState() => _SalaryFilterWidgetState();
}

class _SalaryFilterWidgetState extends ConsumerState<SalaryFilterWidget> {
  TextEditingController salaryController = TextEditingController();
  final formatCurrency = NumberFormat('#,###');

  String selectedType = '';
  int salary = 0;

  @override
  void initState() {
    if (widget.initSelected.isNotEmpty) {
      setState(() {
        selectedType = widget.initSelected;
      });
    }
    if (widget.initSalary > 0 ) {
      setState(() {
        salary = widget.initSalary;
        salaryController.text = formatCurrency.format(salary);
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, CommonSize.keyboardHeight + 30.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBottomSheet(title: localization.salary),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'TIME';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: selectedType == 'TIME'
                                ? CommonColors.red
                                : Colors.white,
                            border: Border(
                              top: BorderSide(
                                  color: selectedType == 'TIME'
                                      ? Colors.red
                                      : CommonColors.gray),
                              left: BorderSide(
                                  color: selectedType == 'TIME'
                                      ? Colors.red
                                      : CommonColors.gray),
                              bottom: BorderSide(
                                  color: selectedType == 'TIME'
                                      ? Colors.red
                                      : CommonColors.gray),
                            ),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12.0),
                                topLeft: Radius.circular(12.0)),
                          ),
                          child: Center(
                              child: Text(
                            localization.hourlyRate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: selectedType == 'TIME'
                                  ? Colors.white
                                  : CommonColors.black2b,
                            ),
                          )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'DAY';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: selectedType == 'DAY'
                                ? CommonColors.red : Colors.white,
                            border: Border.all(color: selectedType == 'DAY'
                                ? CommonColors.red : CommonColors.gray),
                          ),
                          child: Center(
                              child: Text(
                            localization.dailyRate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: selectedType == 'DAY'
                                  ? CommonColors.white : CommonColors.black2b,
                            ),
                          )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedType = 'MONTH';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            color: selectedType == 'MONTH'
                                ? CommonColors.red : Colors.white,
                            border: Border(
                              top: BorderSide(color: selectedType == 'MONTH'
                                  ? CommonColors.red : CommonColors.gray),
                              right: BorderSide(color: selectedType == 'MONTH'
                                  ? CommonColors.red : CommonColors.gray),
                              bottom: BorderSide(color: selectedType == 'MONTH'
                                  ? CommonColors.red : CommonColors.gray),
                            ),
                            borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(12.0),
                                topRight: Radius.circular(12.0)),
                          ),
                          child: Center(
                              child: Text(
                            localization.monthlySalary,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: selectedType == 'MONTH'
                                  ? CommonColors.white : CommonColors.black2b,
                            ),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.w,
                ),
                TextFormField(
                  controller: salaryController,
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  maxLines: null,
                  autocorrect: false,
                  cursorColor: Colors.black,
                  textAlign: TextAlign.end,
                  onChanged: (value) {
                    setState(() {
                      salary = ConvertService.convertStringToInt(
                          ConvertService.removeAllComma(salaryController.text));
                    });
                  },
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
                        locale: 'ko', decimalDigits: 0, symbol: ''),
                  ],
                  style: commonInputText(),
                  decoration: suffixInput(
                    suffixText: localization.won,
                    suffixSize: 14.sp,
                    suffixColor: CommonColors.black2b,
                  ),
                ),
                SizedBox(
                  height: 20.w,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        BorderButton(
                          onPressed: () {
                            setState(() {
                              selectedType = '';
                              salary = 0;
                            });
                            widget.applySalaryType(selectedType);
                            widget.applySalary(salary);

                            widget.getPostList(1);
                            context.pop();
                          },
                          text: localization.reset,
                          width: 96.w,
                        ),
                        SizedBox(
                          width: 8.w,
                        ),
                      ],
                    ),
                    Expanded(
                      child: CommonButton(
                        fontSize: 15,
                        onPressed: () {
                          if (selectedType.isNotEmpty) {
                            widget.applySalaryType(selectedType);
                          }
                          if (salary > 0) {
                            widget.applySalary(salary);
                          }
                          widget.getPostList(1);
                          context.pop();
                        },
                        text: localization.apply2,
                        confirm: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
