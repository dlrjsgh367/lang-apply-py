import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/commute/service/commute_service.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CalendarDetailDialog extends StatefulWidget {
  const CalendarDetailDialog({
    super.key,
    required this.selectDate,
    required this.dateDate,
    required this.dayHour,
    required this.dayMinutes,
  });

  final DateTime selectDate;
  final List dateDate;
  final int dayHour;
  final int dayMinutes;

  @override
  State<CalendarDetailDialog> createState() => _CalendarDetailDialogState();
}

class _CalendarDetailDialogState extends State<CalendarDetailDialog> {
  List<Map<String, dynamic>> dataMap = [];
  bool isLoading = false;

  setDataMap() async {
    setState(() {
      isLoading = true;
    });

    for (var data in widget.dateDate) {
      Map<String, dynamic> temp = {
        'color': data['color'],
        'type': data['type'],
        'time': data['time'],
      };

      if (data['type'] == localization.outdoorWork) {
        temp['address'] = await returnAddress(data);
      }

      setState(() {
        dataMap.add(temp);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  returnAddress(dynamic data) async {
    if ((data['lat'] != null && data['long'] != null) &&
        (data['lat'] != 0.0 && data['long'] != 0.0)) {


      String returnAddress =
          await CommuteService.coord2Address(data['lat'], data['long']);

      return returnAddress;
    } else {
      return '';
    }
  }

  @override
  void initState() {
    Future(() {
      setDataMap();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, CommonSize.commonBottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TitleBottomSheet(
            title: DateFormat('yyyy${localization.year} MM${localization.month} dd${localization.day}').format(widget.selectDate),
          ),
          isLoading
              ? const Loader()
              : Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var data in dataMap)
                          Container(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                            height: 56.w,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.w,
                                  color: CommonColors.grayF2,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                      color: data['color'],
                                      shape: BoxShape.circle),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        data['type'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray4d),
                                      ),
                                      if (data['type'] == localization.outdoorWork &&
                                          data['address'] != null)
                                        Text(
                                          data['address'],
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 12.w,
                                ),
                                Text(
                                  data['time'] == localization.vacation
                                      ? ''
                                      : data['time'].substring(0, 5),
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      color: CommonColors.gray4d),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
          Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    localization.totalWorkingHours,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: CommonColors.gray4d,
                    ),
                  ),
                  SizedBox(
                    width: 12.w,
                  ),
                  Text(
                    widget.dayHour == 0 && widget.dayMinutes == 0
                        ? dataMap.isEmpty
                            ? '-'
                            : localization.minute(0)
                       : '${localization.hour(widget.dayHour)} ${localization.minute(widget.dayMinutes)}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: CommonColors.gray4d,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
