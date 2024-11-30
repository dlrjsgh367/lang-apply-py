import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/date_select_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatePickerDropdownWidget extends StatefulWidget {
  const DatePickerDropdownWidget({
    super.key,
    required this.initialYear,
    required this.startYear,
    required this.endYear,
    this.currentYear,
    required this.month,
    this.isStart = false,
    required this.setData,

    this.extraText,
    this.workDateInfo,
  });

  final int initialYear;
  final int startYear;
  final int endYear;
  final int? currentYear;
  final int month;
  final bool isStart;
  final Function setData;
  final String ?  extraText;
  final Map<String, dynamic>? workDateInfo;

  @override
  State<DatePickerDropdownWidget> createState() =>
      _DatePickerDropdownWidgetState();
}

class _DatePickerDropdownWidgetState extends State<DatePickerDropdownWidget> {
  final List<String> _monthList = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  final List<String> _yearList = [];
  String? selectedMonth;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    for (int i = widget.endYear; i >= widget.startYear; i--) {
      _yearList.add(i.toString());
    }
  }

  showYear() {
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
      isScrollControlled: true,
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DateSelectBottomSheet(
          title: localization.selectYear,
          dataArr: _yearList,
          initItem: selectedYear,
        );
      },
    ).then((value) {
      if (value != null) {
        selectedYear = value;
        if (widget.isStart) {
          widget.setData('startYear', selectedYear);
        } else {
          widget.setData('endYear', selectedYear);
        }
      }
    });
  }

  showMonth() {
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
      isScrollControlled: true,
      barrierColor: CommonColors.barrier,
      useSafeArea: true,
      builder: (BuildContext context) {
        return DateSelectBottomSheet(
          title: localization.selectMonth,
          dataArr: _monthList,
          initItem: selectedMonth,
        );
      },
    ).then((value) {
      if (value != null) {
        selectedMonth = value;

        if (widget.isStart) {
          widget.setData('startMonth', selectedMonth);
        } else {
          widget.setData('endMonth', selectedMonth);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: SelectButton(
          onTap: () {
            showYear();
          },
          text: widget.isStart ? widget.workDateInfo!['startYear'] : widget.workDateInfo!['endYear'],
          hintText: localization.selectYear,
        )),
        SizedBox(
          width: 8.w,
        ),
        Expanded(
          child: SelectButton(
            onTap: () {
              showMonth();
            },
            text: widget.isStart ? widget.workDateInfo!['startMonth'] : widget.workDateInfo!['endMonth'],
            hintText: localization.selectMonth,
          ),
        ),
        if(widget.extraText != null)
        Padding(padding: EdgeInsets.fromLTRB(12.w, 0, 36.w, 0),
          child: Text(
            widget.extraText!,
            style: TextStyle(fontSize: 14.sp, color: CommonColors.black2b),
          ),
        ),

      ],
    );
  }
}
