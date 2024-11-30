import 'dart:math';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/enum/process_type_enum.dart';
import 'package:chodan_flutter_app/features/home/service/filter_service.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/premium_history_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/calednar_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PremiumHistoryScreen extends ConsumerStatefulWidget {
  const PremiumHistoryScreen({
    this.tab,
    super.key});


  final String? tab;
  @override
  ConsumerState<PremiumHistoryScreen> createState() =>
      _PremiumHistoryScreenState();
}

class _PremiumHistoryScreenState extends ConsumerState<PremiumHistoryScreen>
    with Alerts {
  late Future<void> _allAsyncTasks;

  bool isLoading = true;
  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<PremiumHistoryModel> premiumHistoryList = [];

  Map<String, dynamic> filterParam = {};

  DateTime? startDate;
  DateTime? endDate;

  static const String PS_TYPE = 'psType';

  static const String PS_PROCESS = 'psProcess';

  static const String CRSD = 'crsd';
  static const String CRED = 'cred';

  bool isGetLoading = false;

  Map<String, dynamic> selectedPremiumParam = {'psType': []};

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getPremiumHistoryData(page, filterParam),
    ]);
  }

  savePageLog() async {
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  setInitialPremiumServiceFilter(String filter){
    switch(filter){
      case 'match':
        return
          {
            'key' : PremiumServiceEnum.match.param,
            'label' : PremiumServiceEnum.match.label,
          };
      case 'area':
        return
          {
            'key' : PremiumServiceEnum.areaTop.param,
            'label' : PremiumServiceEnum.areaTop.label,
          };
      case 'theme':
      return {
        'key' : PremiumServiceEnum.theme.param,
        'label' : PremiumServiceEnum.theme.label,
      };
      default:
        return
          {
            'key' : PremiumServiceEnum.areaTop.param,
            'label' : PremiumServiceEnum.areaTop.label,
          };
    }
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    String formattedTodayDate = DateFormat('yyyy-MM-dd').format(now);
    if(widget.tab != null){
      initialSelectedPremium = [setInitialPremiumServiceFilter(widget.tab!)];
      selectedPeriodKey.add(initialSelectedPremium[0]['key']);
    }
    filterParam[CRSD] = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30 * 3)));
    filterParam[CRED] = formattedTodayDate;
    filterParam[PS_TYPE] = selectedPeriodKey;

    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  getPremiumHistoryData(int page, Map<String, dynamic> filter) async {
    if (page == 1) {
      setState(() {
        isGetLoading = true;
      });
    }
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumHistoryModel(page, filter);
    if (result.status == 200) {
      if (result.type == 1) {
        List<PremiumHistoryModel> data = result.data;
        if (page == 1) {
          premiumHistoryList = [...data];
          setState(() {
            isGetLoading = false;
          });
        } else {
          premiumHistoryList = [...premiumHistoryList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        // getEventList(page);
      });
    }
  }

  Widget processWidget(ProcessTypeEnum processTypeEnum) {
    switch (processTypeEnum) {
      case ProcessTypeEnum.rejection:
        return Container(
          width: 46.w,
          height: 30.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.w),
            color: CommonColors.blue02,
          ),
          alignment: Alignment.center,
          child: Text(
            localization.reject,
            style: TextStyle(
              fontSize: 12.sp,
              color: CommonColors.blue03,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case ProcessTypeEnum.reservation:
        return Container(
          width: 46.w,
          height: 30.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.w),
            color: CommonColors.yellow02,
          ),
          alignment: Alignment.center,
          child: Text(
            localization.scheduled,
            style: TextStyle(
              fontSize: 12.sp,
              color: CommonColors.brown03,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case ProcessTypeEnum.onGoing:
        return Container(
          width: 46.w,
          height: 30.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.w),
            color: CommonColors.red02,
          ),
          alignment: Alignment.center,
          child: Text(
            localization.inProgress,
            style: TextStyle(
              fontSize: 12.sp,
              color: CommonColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      case ProcessTypeEnum.closed:
        return Container(
          width: 46.w,
          height: 30.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.w),
            color: CommonColors.grayF2,
          ),
          alignment: Alignment.center,
          child: Text(
            localization.completed,
            style: TextStyle(
              fontSize: 12.sp,
              color: CommonColors.gray80,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      default:
        return SizedBox();
    }
  }

  String returnTitleWidget(PremiumHistoryModel premiumHistoryItem) {
    switch (premiumHistoryItem.type) {
      case PremiumServiceEnum.match:
        return premiumHistoryItem.jobpostingTitle;
      case PremiumServiceEnum.areaTop:
        return premiumHistoryItem.jobpostingTitle;
      case PremiumServiceEnum.theme:
        return premiumHistoryItem.themeTitle;
      default:
        return '';
    }
  }

  String returnContentWidget(PremiumHistoryModel premiumHistoryItem) {
    switch (premiumHistoryItem.type) {
      case PremiumServiceEnum.match:
        return returnMatchingContent(premiumHistoryItem);
      case PremiumServiceEnum.areaTop:
        return returnAddressData(premiumHistoryItem.areaTopInfoList);
      case PremiumServiceEnum.theme:
        return '테마관내 등록된 동고 : ${premiumHistoryItem.themeJobPostingCount}개';
      default:
        return '';
    }
  }

  String returnMatchingContent(PremiumHistoryModel premiumHistoryItem) {
    if (premiumHistoryItem.processType == ProcessTypeEnum.rejection) {
      return '거절사유 : ${premiumHistoryItem.rejectionReason}';
    } else {
      return premiumHistoryItem.jobpostingTitle == ''
          ? localization.jobPostRegistrationInProgress
          : premiumHistoryItem.jobpostingTitle;
    }
  }

  String returnAddressData(List<AddressModel> itemList) {
    String result = '';
    for (int i = 0; i < itemList.length; i++) {
      if (i != itemList.length - 1) {
        result += '${itemList[i].dongName}, ';
      } else {
        result += itemList[i].dongName;
      }
    }
    return result;
  }

  List<Map<String, dynamic>> initialSelectedPeriod = [
    {
      'key': 0,
      'label': localization.threeMonths,
    }
  ];

  List<int> selectedPeriodKey = [];

  bool canSelectCalendar = false;

  applyPeriod(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedPeriod = [...itemList];
      selectedPeriodKey = [...apply];
      List<Map<String, dynamic>> paramData = [];
      if (selectedPeriodKey[0] != 4) {
        selectedPeriod.clear();
        canSelectCalendar = false;
        for (int key in selectedPeriodKey) {
          paramData.add(FilterService.returnPeriodFilterParam(key));
        }
        addFilterParam(paramData);
      }
      canSelectCalendar = true;
    });
  }

  Map<String, dynamic> selectedPeriod = {};

  selectDate(bool isStart, String dateString) {
    setState(() {
      if (isStart) {
        selectedPeriod[CRSD] = dateString;
      } else {
        selectedPeriod[CRED] = dateString;
      }
    });
    if (selectedPeriod.containsKey(CRSD) && selectedPeriod.containsKey(CRED)) {
      addFilterParam([selectedPeriod]);
    }
  }

  List<Map<String, dynamic>> initialSelectedPremium = [
    {
      'key': 0,
      'label': localization.all,
    }
  ];

  List<int> selectedPremiumKey = [1, 2, 3];

  List<int> initialSelectedProcess = [
    ProcessTypeEnum.rejection.param,
    ProcessTypeEnum.reservation.param,
    ProcessTypeEnum.onGoing.param,
    ProcessTypeEnum.closed.param
  ];

  addFilterParam(List<Map<String, dynamic>> data) {
    for (Map<String, dynamic> item in data) {
      for (var key in item.keys) {
        filterParam[key] = item[key];
      }
    }
    page = 1;
    getPremiumHistoryData(page, filterParam);
  }

  applyPremium(List<Map<String, dynamic>> itemList, List<int> apply) {
    setState(() {
      initialSelectedPremium = [...itemList];
      selectedPremiumKey = [...apply];

      if (selectedPremiumKey[0] == 0) {
        selectedPremiumKey = [1, 2, 3];
      }
      selectedPremiumParam[PS_TYPE] = selectedPremiumKey;

      addFilterParam([selectedPremiumParam]);
    });
  }

  applyProcess(int key) {
    if (initialSelectedProcess.contains(key)) {
      if (initialSelectedProcess.length == 1) {
        return;
      } else {
        initialSelectedProcess.remove(key);
      }
    } else {
      initialSelectedProcess.add(key);
    }
    List<Map<String, dynamic>> param = [
      {PS_PROCESS: initialSelectedProcess}
    ];
    addFilterParam(param);
  }

  calendarOpen(type) {
    if (type == 'start') {
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
          return CalendarBottomSheet(
              title: localization.startDate,
              selectedDay: selectedPeriod[CRSD] != null
                  ? DateTime.parse(selectedPeriod[CRSD])
                  : null,
              disableAfterDay: selectedPeriod[CRED] != null
                  ? DateTime.parse(selectedPeriod[CRED])
                      .add(const Duration(days: 1))
                  : null,
              setSelectDate: (value) {
                setState(() {
                  selectDate(true, DateFormat('yyyy-MM-dd').format(value));
                });

              });
        },
      );
    } else {
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
          return CalendarBottomSheet(
              disablePreDay: selectedPeriod[CRSD] != null
                  ? DateTime.parse(selectedPeriod[CRSD])
                  : null,
              selectedDay: selectedPeriod[CRED] != null
                  ? DateTime.parse(selectedPeriod[CRED])
                  : null,
              title: localization.endDate,
              setSelectDate: (value) {
                setState(() {
                  selectDate(false, DateFormat('yyyy-MM-dd').format(value));
                });
              });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CommonAppbar(
          title: localization.myApplicationHistory,
        ),
        body: isLoading
            ? const Loader()
            : Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 20.w),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 16.w, color: CommonColors.grayF7),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 48.w,
                              clipBehavior: Clip.hardEdge,
                              padding: EdgeInsets.fromLTRB(10.w, 0.w, 0.w, 0.w),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1.w,
                                  color: CommonColors.grayF2,
                                ),
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      DefineDialog.showFilter(
                                          context,
                                          localization.applicationPeriod,
                                          FilterService.periodFilter,
                                          applyPeriod,
                                          initialSelectedPeriod,
                                          1,
                                          isRequired: true);
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      width: 70.w,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${initialSelectedPeriod[0]['label']}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: CommonColors.gray66,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/icon/iconArrowDown.png',
                                            width: 12.w,
                                            height: 12.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 8.w,
                                  ),
                                  VerticalDivider(
                                    thickness: 1.w,
                                    width: 1.w,
                                    color: CommonColors.grayF2,
                                  ),
                                  Expanded(
                                      child: Container(
                                        color:

                                        initialSelectedPeriod[0]['key'] != 4 ?
                                        CommonColors.grayF2 : Colors.transparent,

                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SelectButton(
                                            noBorder: true,
                                            isDate: true,
                                            onTap: () async {
                                              if(initialSelectedPeriod[0]['key'] == 4){
                                                calendarOpen('start');
                                              }

                                            },
                                            text: selectedPeriod
                                                    .containsKey(CRSD)
                                                ? DateFormat('yy.MM.dd').format(
                                                    DateTime.parse(
                                                        selectedPeriod[CRSD]))
                                                : '',
                                            hintText: localization.startDate,
                                          ),
                                        ),
                                        Text(
                                          '~',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray66,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Expanded(
                                          child: SelectButton(
                                            noBorder: true,
                                            isDate: true,
                                            onTap: () async {
                                              if(initialSelectedPeriod[0]['key'] == 4){
                                                calendarOpen('end');
                                              }

                                            },
                                            text: selectedPeriod
                                                    .containsKey(CRED)
                                                ? DateFormat('yy.MM.dd').format(
                                                    DateTime.parse(
                                                        selectedPeriod[CRED]))
                                                : '',
                                            hintText: localization.endDate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8.w,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.w),
                                      border: Border.all(
                                        width: 1.w,
                                        color: CommonColors.grayF2,
                                      ),
                                    ),
                                    height: 32.w,
                                    child: GestureDetector(
                                      onTap: () {
                                        DefineDialog.showFilter(
                                            context,
                                            localization.service,
                                            FilterService.premiumServiceFilter,
                                            applyPremium,
                                            initialSelectedPremium,
                                            1,
                                            isRequired: true);
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              initialSelectedPremium[0]
                                                  ['label'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: CommonColors.black2b,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/icon/iconArrowDown.png',
                                            width: 20.w,
                                            height: 20.w,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    //TODO : 버튼 선택시 색상에 대해서 추가할 것
                                    applyProcess(ProcessTypeEnum.reservation.param);
                                  },
                                  child: Container(
                                    width: 46.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.w),
                                      color: initialSelectedProcess.contains(
                                              ProcessTypeEnum.reservation.param)
                                          ? CommonColors.yellow02
                                          : CommonColors.gray100,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ProcessTypeEnum.reservation.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: initialSelectedProcess.contains(
                                                ProcessTypeEnum
                                                    .reservation.param)
                                            ? CommonColors.brown03
                                            : CommonColors.grayD9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    applyProcess(ProcessTypeEnum.onGoing.param);
                                  },
                                  child: Container(
                                    width: 46.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.w),
                                      color: initialSelectedProcess.contains(
                                              ProcessTypeEnum.onGoing.param)
                                          ? CommonColors.red02
                                          : CommonColors.gray100,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ProcessTypeEnum.onGoing.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: initialSelectedProcess.contains(
                                                ProcessTypeEnum.onGoing.param)
                                            ? CommonColors.red
                                            : CommonColors.grayD9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    applyProcess(ProcessTypeEnum.closed.param);
                                  },
                                  child: Container(
                                    width: 46.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.w),
                                      color: initialSelectedProcess.contains(
                                              ProcessTypeEnum.closed.param)
                                          ? CommonColors.grayF2
                                          : CommonColors.gray100,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ProcessTypeEnum.closed.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: initialSelectedProcess.contains(
                                                ProcessTypeEnum.closed.param)
                                            ? CommonColors.gray80
                                            : CommonColors.grayD9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    applyProcess(
                                        ProcessTypeEnum.rejection.param);
                                  },
                                  child: Container(
                                    width: 46.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.w),
                                      color: initialSelectedProcess.contains(
                                              ProcessTypeEnum.rejection.param)
                                          ? CommonColors.blue02
                                          : CommonColors.gray100,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ProcessTypeEnum.rejection.label,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: initialSelectedProcess.contains(
                                                ProcessTypeEnum.rejection.param)
                                            ? CommonColors.blue03
                                            : CommonColors.grayD9,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (premiumHistoryList.isNotEmpty && !isGetLoading)
                        Expanded(
                          child: CustomScrollView(
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    childCount: premiumHistoryList.length,
                                    (context, index) {
                                      PremiumHistoryModel premiumHistoryItem = premiumHistoryList[index];
                                      PremiumServiceEnum type = premiumHistoryItem.type;
                                      return Container(
                                        padding: EdgeInsets.fromLTRB(
                                            0, 16.w, 0, 16.w),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 1.w,
                                              color: CommonColors.grayF7,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        type.label,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: CommonColors
                                                              .black2b,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 6.w,
                                                      ),
                                                      processWidget(
                                                          premiumHistoryItem
                                                              .processType)
                                                    ],
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          localization.applicationDate,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: CommonColors
                                                                .black2b,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 6.w,
                                                        ),
                                                        Text(
                                                          ConvertService.convertDateISOtoString(
                                                              premiumHistoryItem
                                                                  .requestDate,
                                                              ConvertService
                                                                  .YYYY_MM_DD_HH_MM_dot),
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: CommonColors
                                                                .gray80,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    if (premiumHistoryItem.expireDate.isNotEmpty)
                                                      Row(
                                                        children: [
                                                          Text(
                                                            localization.endDate,
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color: CommonColors.black2b,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 6.w,
                                                          ),
                                                          Text(
                                                            ConvertService.convertDateISOtoString(
                                                                premiumHistoryItem.expireDate,
                                                                ConvertService.YYYY_MM_DD_HH_MM_dot),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(
                                                              fontSize: 11.sp,
                                                              color: CommonColors.gray80,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 4.w,
                                            ),
                                            Text(
                                              returnTitleWidget(
                                                  premiumHistoryItem),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.black2b,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 4.w,
                                            ),
                                            Text(
                                              returnContentWidget(
                                                  premiumHistoryItem),
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.gray80,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (page < lastPage)
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                      20.w, 24.w, 20.w, 0.w),
                                  sliver: SliverToBoxAdapter(
                                    child: GestureDetector(
                                      onTap: () {
                                        if (lastPage > 1 &&
                                            page + 1 <= lastPage) {
                                          _loadMore();
                                        }
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                        height: 40.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.w),
                                          color: CommonColors.grayF7,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              localization.seeMore,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                                color: CommonColors.gray66,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 6.w,
                                            ),
                                            Image.asset(
                                              'assets/images/icon/iconArrowDown.png',
                                              width: 16.w,
                                              height: 16.w,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              BottomPadding(),
                            ],
                          ),
                        ),
                      if (premiumHistoryList.isEmpty && !isGetLoading)
                        Expanded(
                            child: Center(
                                child:
                                    const CommonEmpty(text: localization.noApplicationHistoryAvailable))),
                      if (!isLoading && isGetLoading)
                        const Expanded(child: Center(child: Loader())),
                    ],
                  ),
                  if (isLazeLoading)
                    Positioned(
                      bottom: CommonSize.commonBottom,
                      child: const Loader(),
                    ),
                ],
              ));
  }
}
