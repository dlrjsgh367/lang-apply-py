import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CalendarMonthDialog extends StatefulWidget {
  const CalendarMonthDialog({
    super.key,
    required this.currentDate,
    required this.setMonth,
  });

  final DateTime currentDate;
  final Function setMonth;

  @override
  State<CalendarMonthDialog> createState() => _CalendarMonthDialogState();
}

class _CalendarMonthDialogState extends State<CalendarMonthDialog> {
  late DateTime alertDate = widget.currentDate;

  setCurrentYear(type) {
    if (type == 'add') {
      var year = int.parse(DateFormat('yyyy').format(selectYear));
      selectYear = DateTime(year + 1, 1, 1);
    }

    if (type == 'subs') {
      var year = int.parse(DateFormat('yyyy').format(selectYear));
      selectYear = DateTime(year - 1, 1, 1);
    }
  }

  late DateTime selectYear = widget.currentDate;

  setMonth() {
    widget.setMonth(alertDate);
    context.pop();
  }

  setAlertMonth(data) {
    setState(() {
      var year = int.parse(DateFormat('yyyy').format(selectYear));
      alertDate = DateTime(year, data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(44.w, 36.w, 20.w, CommonSize.commonBottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                setCurrentYear('subs');
                              });
                            },
                            style: ButtonStyles.childBtn,
                            child: Image.asset(
                              'assets/images/icon/iconArrowUpThin.png',
                              width: 28.w,
                              height: 28.w,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              DateFormat('yyyy').format(selectYear),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: CommonColors.gray4d,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                          // selectYear.year < DateTime.now().year
                          //     ?
                          TextButton(
                                  onPressed: () {
                                    setState(() {
                                      setCurrentYear('add');
                                    });
                                  },
                                  style: ButtonStyles.childBtn,
                                  child: Image.asset(
                                    'assets/images/icon/iconArrowDownThin.png',
                                    width: 28.w,
                                    height: 28.w,
                                  ),
                                )
                              // : SizedBox(),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 32.w,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < 4; i++)
                            Row(
                              children: [
                                for (var j = 0; j < 3; j++)
                                  Expanded(
                                    child: TextButton(
                                      style: ButtonStyles.childBtn,
                                      onPressed:
                                      /*DateFormat('yyyy')
                                                      .format(alertDate) ==
                                                  DateFormat('yyyy')
                                                      .format(selectYear) &&
                                              (3 * i + j + 1) > DateTime.now().month
                                          ? null
                                          : */
                                          () async {
                                              setAlertMonth(3 * i + j + 1);

                                              await setMonth();
                                            },
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 10.w, 0, 10.w),
                                        child: Text(
                                          '${3 * i + j + 1}${localization.month}',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            color:
                                            /*DateFormat('yyyy')
                                                            .format(alertDate) ==
                                                        DateFormat('yyyy')
                                                            .format(selectYear) &&
                                                    (3 * i + j + 1) >
                                                        DateTime.now().month
                                                ? CommonColors.gray66
                                                : */
                                            DateFormat('yyyy')
                                                .format(alertDate) ==
                                                DateFormat('yyyy')
                                                    .format(selectYear) &&
                                                3 * i + j + 1 == alertDate.month
                                                ? CommonColors.red
                                                : CommonColors.gray66,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 15,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              width: 64.w,
              child: Image.asset(
                'assets/images/icon/iconX.png',
                width: 20.w,
                height: 20.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
