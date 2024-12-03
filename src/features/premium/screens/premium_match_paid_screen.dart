import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/posting_collapse_btn.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/features/premium/screens/premium_match_screen.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';

class PremiumMatchPaidScreen extends ConsumerStatefulWidget {
  const PremiumMatchPaidScreen({super.key});

  @override
  ConsumerState<PremiumMatchPaidScreen> createState() =>
      _PremiumMatchPaidScreenState();
}

class _PremiumMatchPaidScreenState
    extends ConsumerState<PremiumMatchPaidScreen> {
  bool isLoading = true;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  List<PremiumModel> premiumMatchItemList = [];

  late Future<void> _allAsyncTasks;

  getPremiumMatchPaidList(int page) async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumMatchPaidList(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<PremiumModel> data = result.data;
        if (page == 1) {
          premiumMatchItemList = [...data];
        } else {
          premiumMatchItemList = [...premiumMatchItemList, ...data];
        }
        lastPage = result.page['lastPage'];
        setState(() {
          isLazeLoading = false;
        });
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getPremiumMatchPaidList(page)]);
  }

  Future _loadMore() async {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getPremiumMatchPaidList(page);
      });
    }
  }

  showPremiumMatchSAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PremiumMatchScreen();
      },
    );
  }

  @override
  void initState() {
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

  List<PremiumModel> premiumData = [];

  DateFormat dateFormat = DateFormat(localization.239);
  bool isSameMonth(String date1, String date2){

    int date1Month = dateFormat.parse(date1).month;
    int date2Month = dateFormat.parse(date2).month;
    return date1Month == date2Month;
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: '${PremiumServiceEnum.match.label} 신청 내역',
      ),
      body: !isLoading
          ? premiumMatchItemList.isNotEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 0),
                            child: Container(
                              height: 48.w,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1.w,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                              ),
                              child: Text(
                                localization.589,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.gray4d,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: LazyLoadScrollView(
                              onEndOfPage: () => _loadMore(),
                              child: CustomScrollView(
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      childCount: premiumMatchItemList.length,
                                      (context, index) {
                                        PremiumModel premiumMatchItem = premiumMatchItemList[index];

                                        final isMonthSame = index == premiumMatchItemList.length-1
                                            ? false :
                                        isSameMonth(premiumMatchItemList[index].matchRequestDate, premiumMatchItemList[index+1].matchRequestDate);
                                        if(isMonthSame && index != premiumMatchItemList.length-1){
                                          premiumData.add(premiumMatchItem);
                                          return const SizedBox();
                                        }else{
                                          premiumData.add(premiumMatchItem);
                                          List<PremiumModel> temp = [...premiumData];
                                          premiumData = [];
                                          return PostingCollapseBtn(
                                            childArr: [
                                              for(int i = 0; i<temp.length;i++)
                                              Container(
                                                height: 64.w,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1.w,
                                                      color: CommonColors.grayF7,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Text(
                                                      temp[i].matchRequestDate,
                                                      style: TextStyle(
                                                        fontSize: 14.sp,
                                                        color:
                                                        CommonColors.black2b,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 24.w,
                                                      width: 55.w,
                                                      decoration: BoxDecoration(
                                                        color: temp[i]
                                                            .matchProcess
                                                            .label ==
                                                            localization.declined
                                                            ? CommonColors.grayF2
                                                            : CommonColors.red,
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                          500.w,
                                                        ),
                                                      ),
                                                      alignment: Alignment.center,
                                                      child: Text(
                                                        temp[i]
                                                            .matchProcess.label,
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                          color: temp[i]
                                                              .matchProcess
                                                              .label ==
                                                              localization.declined
                                                              ? CommonColors
                                                              .grayB2
                                                              : CommonColors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            title: '${dateFormat.parse(temp[0].matchRequestDate).month}월',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  const BottomPadding(
                                    extra: 100,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20.w,
                      right: 20.w,
                      bottom: CommonSize.commonBottom,
                      child: CommonButton(
                        fontSize: 15,
                        onPressed: () {
                          showPremiumMatchSAlert();
                        },
                        confirm: true,
                        text: '${PremiumServiceEnum.match.label} 신청하기',
                        width: CommonSize.vw,
                      ),
                    ),
                    if (isLazeLoading)
                      Positioned(
                          bottom: CommonSize.commonBottom,
                          child: const Loader())
                  ],
                )
              : CommonEmpty(
                  text: '${PremiumServiceEnum.match.label} 신청 기록이 없어요.')
          : const Loader(),
    );
  }
}
