import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/features/commute/controller/commute_controller.dart';
import 'package:chodan_flutter_app/features/commute/widgets/calendar_detail_dialog.dart';
import 'package:chodan_flutter_app/features/commute/widgets/calendar_month_dialog.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/commute_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({
    super.key,
    required this.uuid,
  });

  final String uuid;

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  bool isLoading = false;
  DateTime currentDate = DateTime.now();
  DateTime selectDate = DateTime.now();
  Map<String, dynamic> rangeDate = {};
  int totalHour = 0;
  int totalMinutes = 0;
  int dayHour = 0;
  int dayMinutes = 0;
  List<Map<String, dynamic>> detailData = [];

  // -------------- 근태 기록 리스트
  getAttendanceList() async {
    List<Map<String, dynamic>> calendarDate = [];

    ApiResultModel result = await ref
        .read(commuteControllerProvider.notifier)
        .getAttendance(widget.uuid, rangeDate);
    if (result.status == 200) {
      if (result.type == 1) {
// ca_type : 타입 : 1:출근, 2:퇴근, 3:외근, 4:복귀
        for (var data in result.data['list'].entries) {
          for (var list in data.value) {
            var attendanceData = CommuteModel.fromApiJson(list);
            calendarDate.add({
              'date': attendanceData.date,
              'time': attendanceData.type == 5 ? localization.vacation : attendanceData.time,
              'isRed': attendanceData.type == 2 ? true : false, // 퇴근
              'isBlue': attendanceData.type == 1 ? true : false, // 출근
              'isYellow': attendanceData.type == 3 ? true : false, // 외근
              'isGreen': attendanceData.type == 4 ? true : false, // 복귀
              'isGrey': attendanceData.type == 5 ? true : false, // 복귀
            });
          }
        }

        ref
            .read(attendanceListProvider.notifier)
            .update((state) => calendarDate);

        setState(() {
          totalHour = result.data['extra']['HOURS'];
          totalMinutes = result.data['extra']['MINUTES'];
        });
      }
    } else {
      showErrorAlert(context, localization.notification, localization.unableToFetchAttendanceRecord);
    }
  }

  // -------------- 근태 기록 상세
  getAttendanceDetail() async {
    ApiResultModel result = await ref
        .read(commuteControllerProvider.notifier)
        .getAttendanceDetail(widget.uuid,
            DateFormat('yyyy-MM-dd').format(selectDate).toString());
    if (result.status == 200) {
      if (result.type == 1) {
        // ca_type : 타입 : 1:출근, 2:퇴근, 3:외근, 4:복귀
        if (detailData.isNotEmpty) {
          setState(() {
            detailData = [];
          });
        }
        for (var data in result.data['list'].entries) {
          for (var list in data.value) {
            var attendanceData = CommuteModel.fromApiJson(list);
            detailData.add({
              'date': attendanceData.date,
              'time': attendanceData.type == 5 ? localization.vacation : attendanceData.time,
              'isRed': attendanceData.type == 2 ? true : false, // 퇴근
              'isBlue': attendanceData.type == 1 ? true : false, // 출근
              'isYellow': attendanceData.type == 3 ? true : false, // 외근
              'isGreen': attendanceData.type == 4 ? true : false, // 복귀
              'isGrey': attendanceData.type == 5 ? true : false, // 복귀
              'lat': attendanceData.lat,
              'long': attendanceData.long,
            });
          }
        }

        setState(() {
          dayHour = result.data['extra']['HOURS'];
          dayMinutes = result.data['extra']['MINUTES'];
        });
      }
    } else {
      showErrorAlert(context, localization.notification, localization.unableToFetchAttendanceRecord);
    }
  }

  selectMonth(context) {
    showModalBottomSheet<void>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      barrierColor: CommonColors.barrier,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return CalendarMonthDialog(
            currentDate: currentDate,
            setMonth: setMonth,
          );
        });
      },
    );
  }

  setMonth(data) {
    setState(() {
      currentDate = data;

      rangeDate = {
        'st': DateFormat('yyyy-MM-dd')
            .format(DateTime(currentDate.year, currentDate.month, 1)),
        'ed': DateFormat('yyyy-MM-dd').format(
            DateTime(currentDate.year, currentDate.month + 1, 1)
                .subtract(const Duration(days: 1)))
      };
    });

    getAttendanceList();
  }

  showDetailDialog(context) {
    showModalBottomSheet<void>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.w),
          topRight: Radius.circular(24.w),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return CalendarDetailDialog(
              selectDate: selectDate,
              dateDate: setDateDot(selectDate, detailData),
              dayHour: dayHour,
              dayMinutes: dayMinutes);
        });
      },
    );
  }

  showErrorAlert(BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: localization.confirm,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop(context);
              context.pop(context);
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  setDateDot(data, List<Map<String, dynamic>> dateData) {
    var dotArr = [];
    var date = DateFormat('yyyy-MM-dd').format(data);

    for (var entry in dateData) {
      if (entry['date'] == date) {
        if (entry['isBlue'] == true) {
          if (!dotArr.contains(CommonColors.attendanceBlue)) {
            dotArr.add({
              'time': entry['time'],
              'color': CommonColors.attendanceBlue,
              'type': localization.checkIn,
              'lat': entry['lat'],
              'long': entry['long'],
            });
          }
        } else if (entry['isRed'] == true) {
          if (!dotArr.contains(CommonColors.attendanceRed)) {
            dotArr.add({
              'time': entry['time'],
              'color': CommonColors.attendanceRed,
              'type': localization.checkOut,
              'lat': entry['lat'],
              'long': entry['long'],
            });
          }
        } else if (entry['isGreen'] == true) {
          if (!dotArr.contains(CommonColors.attendanceGreen)) {
            dotArr.add({
              'time': entry['time'],
              'color': CommonColors.attendanceGreen,
              'type': localization.returnToWork,
              'lat': entry['lat'],
              'long': entry['long'],
            });
          }
        } else if (entry['isYellow'] == true) {
          if (!dotArr.contains(CommonColors.attendanceYellow)) {
            dotArr.add({
              'time': entry['time'],
              'color': CommonColors.attendanceYellow,
              'type': localization.outdoorWork,
              'lat': entry['lat'],
              'long': entry['long'],
            });
          }
        } else if (entry['isGrey'] == true) {
          if (!dotArr.contains(CommonColors.grayD9)) {
            dotArr.add({
              'time': entry['time'],
              'color': CommonColors.grayD9,
              'type': localization.vacation,
              'lat': entry['lat'],
              'long': entry['long'],
            });
          }
        }
      }
    }

    return dotArr;
  }

  Widget buildMarker(eventArr) {
    if (eventArr.length > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 34.w,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < (eventArr.length > 4 ? 4 : eventArr.length); i++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: eventArr[i]['color'],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Flexible(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            eventArr[i]['time'] == localization.vacation
                                ? eventArr[i]['time']
                                : eventArr[i]['time']
                                    .toString()
                                    .substring(0, 5),
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  void initState() {
    setState(() {
      rangeDate = {
        'st': DateFormat('yyyy-MM-dd')
            .format(DateTime(currentDate.year, currentDate.month, 1)),
        'ed': DateFormat('yyyy-MM-dd').format(
            DateTime(currentDate.year, currentDate.month + 1, 1)
                .subtract(const Duration(days: 1)))
      };
    });
    Future(() {
      getAttendanceList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var attendanceList = ref.watch(attendanceListProvider);
    return Scaffold(
      appBar: ModalAppbar(
        title: localization.attendanceLog,
      ),
      body: isLoading
          ? const Loader()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      selectMonth(context);
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          Text(
                            DateFormat('yyyy${localization.year} MM${localization.month}').format(currentDate),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 4.w,
                          ),
                          Image.asset(
                            'assets/images/icon/iconArrowDown.png',
                            width: 24.w,
                            height: 24.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    8.w,
                    0,
                    8.w,
                    16.w,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: TableCalendar(
                      availableGestures: AvailableGestures.none,
                      headerVisible: false,

                      //캘린더 총 날짜 두개
                      firstDay: DateTime.utc(2010, 10, 16),
                      lastDay: DateTime.utc(2080, 3, 14),
                      focusedDay: currentDate,

                      //위크데이 하이트
                      daysOfWeekHeight: 48.w,

                      rowHeight: 98.w,

                      //날짜 셀렉터
                      onDaySelected: (date, day) async {
                        if (!mounted) return;
                        setState(() {
                          selectDate = date;
                        });

                        await getAttendanceDetail();

                        showDetailDialog(context);
                      },

                      selectedDayPredicate: (date) {
                        return true;
                      },
                      onPageChanged: (date) {
                        setState(() {
                          currentDate = date;
                        });
                      },

                      //헤더 항목 커스텀
                      headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                          headerPadding: EdgeInsets.zero),

                      //캘린더 빌더 안에 내용물들 커스텀 여기서
                      calendarBuilders: CalendarBuilders(
                        //오늘 날짜 빌더 커스텀
                        selectedBuilder: (context, date, firstDay) {
                          return Container(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              height: 34.w,
                              child: Center(
                                child: Text(
                                  DateFormat.d().format(date),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: date.weekday == 7
                                          ? CommonColors.red
                                          : CommonColors.gray4d),
                                ),
                              ),
                            ),
                          );
                        },

                        //날짜 밑에 달린 마커 빌더
                        markerBuilder: (context, date, events) {
                          return buildMarker(setDateDot(date, attendanceList));
                        },

                        //위크데이 커스텀
                        dowBuilder: (context, day) {
                          var weekArr = [localization.monday, localization.tuesday, localization.wednesday, localization.thursday, localization.friday, localization.saturday, localization.sunday];
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.w,
                                  color: CommonColors.grayD9,
                                ),
                              ),
                            ),
                            child: Text(
                              weekArr[day.weekday - 1],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14.sp,
                                color: day.weekday == 7
                                    ? CommonColors.red
                                    : Colors.black,
                              ),
                            ),
                          );
                        },

                        //디폴트 날짜 빌더
                        defaultBuilder: (context, date, firstDay) {
                          return Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 34.w,
                              child: Center(
                                child: Text(
                                  DateFormat.d().format(date),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: date.weekday == 7
                                          ? CommonColors.red
                                          : CommonColors.gray4d),
                                ),
                              ),
                            ),
                          );
                        },

                        //선택된 날짜 아닌 데 나오는 자투리 날짜 커스텀
                        outsideBuilder: (context, date, firstDay) {
                          return Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 34.w,
                              child: Center(
                                  child: Opacity(
                                opacity: 0.5,
                                child: Text(
                                  DateFormat.d().format(date),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: date.weekday == 7
                                          ? CommonColors.red
                                          : CommonColors.gray4d),
                                ),
                              )),
                            ),
                          );
                        },

                        // 오늘
                        todayBuilder: (context, date, firstDay) {
                          return Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.w,
                                  color: CommonColors.grayF7,
                                ),
                              ),
                            ),
                            child: SizedBox(
                              height: 34.w,
                              child: Center(
                                child: Text(
                                  DateFormat.d().format(date),
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: date.weekday == 7
                                          ? CommonColors.red
                                          : CommonColors.gray4d),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        color: CommonColors.grayF7,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${DateFormat('yyyy${localization.year} MM${localization.month}').format(currentDate)} ${localization.totalWork}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray80,
                            ),
                          ),
                          Text(
                            totalHour == 0 && totalMinutes == 0
                                ? '-'
                                : '${localization.hour(totalHour)} ${localization.minute(totalMinutes)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: CommonColors.black2b,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                BottomPadding(),
              ],
            ),
    );
  }
}
