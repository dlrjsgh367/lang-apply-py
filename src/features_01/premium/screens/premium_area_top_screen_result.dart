import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_price_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_widget.dart';
import 'package:chodan_flutter_app/features/define/controller/define_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_box.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_check_inner.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_title.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/define_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class PremiumAreaTopScreen extends ConsumerStatefulWidget {
  const PremiumAreaTopScreen({super.key});

  @override
  ConsumerState<PremiumAreaTopScreen> createState() =>
      _PremiumAreaTopScreenState();
}

class _PremiumAreaTopScreenState extends ConsumerState<PremiumAreaTopScreen> {
  late Future<void> _allAsyncTasks;
  bool isLoading = true;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;

  List<JobpostModel> jobpostList = [];

  List<int> selectedJobposting = [];

  bool isRunning = false;
  bool isAgree = false;

  PremiumModel? premiumData;

  String premiumCode = PremiumServiceEnum.areaTop.code;

  List<AddressModel> initialSelectedItem = [];
  List<int> selectedAreaKey = [];

  int maxLength = 5;

  getJobpostingLinkWithAreatop(int page) async {
    // params['']
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingLinkWithAreaTop(page);
    if (result.status == 200) {
      if (result.type == 1) {
        List<JobpostModel> data = result.data;
        if (page == 1) {
          jobpostList = [...data];
        } else {
          jobpostList = [...jobpostList, ...data];
        }
        lastPage = result.page['lastPage'];
        isLazeLoading = false;
      }
    }
  }

  loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getJobpostingLinkWithAreatop(page);
      });
    }
  }

  showConfirm(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notice,
            alertConfirm: localization.confirm,
            alertContent: message,
            confirmFunc: () {
              context.pop();
              context.pop();
            },
          );
        });
  }

  showPayError() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.notice,
            alertContent: localization.insufficientChocoBalance,
            alertConfirm: localization.moveToRechargePage,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop();
              context.push('/my/choco');
            },
          );
        });
  }

  showErrorAlert(String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notice,
            alertConfirm: localization.confirm,
            alertContent: message,
            confirmFunc: () {
              context.pop();
            },
          );
        });
  }

  applyAreaTopJobposting() async {
    if (isRunning) {
      return;
    }
    Map<String, dynamic> params = {
      "adIdx": [...selectedAreaKey],
      "cpCode": premiumCode,
      "jpIdx": [...selectedJobposting]
    };
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .applyAreaTopJobposting(params);
    isRunning = false;
    if (result.status == 200) {
      if (result.type == 1) {
        showConfirm('${PremiumServiceEnum.areaTop.label} 등록에 성공했습니다.');
      }
    } else {
      if (result.type == -1705 || result.type == -1706) {
        showPayError();
      } else {
        showErrorAlert(localization.dataCommunicationFailed);
      }
    }
  }

  toggleCheckBox(int key) {
    setState(() {
      if (selectedJobposting.contains(key)) {
        selectedJobposting.remove(key);
      } else {
        selectedJobposting.add(key);
      }
    });
  }

  getPremiumServiceMatch() async {
    ApiResultModel result = await ref
        .read(premiumControllerProvider.notifier)
        .getPremiumService(premiumCode);
    if (result.status == 200) {
      if (result.type == 1) {
        premiumData = result.data;
      }
    }
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getPremiumServiceMatch(),
      getJobpostingLinkWithAreatop(page),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
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

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      isAgree = value;
    });
  }

  apply(List<AddressModel> addressItem, List<int> apply, int adParent) {
    setState(() {
      initialSelectedItem = [...addressItem];
      selectedAreaKey = apply;
    });
  }


  @override
  Widget build(BuildContext context) {
    List<AddressModel> areaList = ref.watch(areaListProvider);
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 15;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: const CommonAppbar(
          title: localization.regionalTopExposure,
        ),
        body: !isLoading
            ? Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: LazyLoadScrollView(
                      onEndOfPage: () => loadMore(),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 20.w),
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
                                    padding: EdgeInsets.fromLTRB(
                                        16.w, 12.w, 16.w, 12.w),
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: Text(
                                      localization.highlightedJobPostsInSelectedRegions,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: CommonColors.gray4d,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localization.serviceFee,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Text(
                                        returnServicePrice(premiumData!),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8.w,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localization.serviceDuration,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Text(
                                        '${premiumData!.expireDay}일',
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
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                            sliver: const ApplyTitle(
                              text: localization.selectTopExposureRegions,
                            ),
                          ),
                          if (initialSelectedItem.length < 5)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                              sliver: SliverToBoxAdapter(
                                child: Text(
                                  localization.selectFivePreferredRegions,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                            ),
                          if (initialSelectedItem.length < 5)
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await DefineDialog
                                            .addressDialogThreeDepthOnly(
                                                context,
                                                localization.regionSelection,
                                                areaList,
                                                apply,
                                                initialSelectedItem,
                                                maxLength);
                                      },
                                      child: Image.asset(
                                        'assets/images/icon/iconPlusInner.png',
                                        width: 24.w,
                                        height: 24.w,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (initialSelectedItem.isNotEmpty)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                              sliver: SliverToBoxAdapter(
                                child: Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.w,
                                  children: [
                                    for (int i = 0;
                                        i < initialSelectedItem.length;
                                        i++)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            initialSelectedItem.removeAt(i);
                                          });
                                        },
                                        child: ProfileBox(
                                          hasClose: true,
                                          text: initialSelectedItem[i]
                                              .selectionName,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                            sliver: const ApplyTitle(
                              text: localization.applyJobPostsForExposure,
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                            sliver: SliverToBoxAdapter(
                              child: Text(
                                localization.selectExistingJobPostsForExposure,
                                style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CommonColors.gray80),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                childCount: jobpostList.length,
                                (context, index) {
                                  JobpostModel jobItem = jobpostList[index];
                                  return ApplyCheckInner(
                                    text: ConvertService.convertDateISOtoString(
                                        jobItem.createdAt,
                                        ConvertService.YYYY_MM_DD_HH_MM),
                                    title: jobItem.title,
                                    onChanged: () {
                                      toggleCheckBox(jobItem.key);
                                    },
                                    groupValue: selectedJobposting
                                        .contains(jobItem.key),
                                    value: true,
                                  );
                                },
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(20.w, 48.w, 20.w, 0),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        localization.totalPaymentAmount,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12.w,
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${selectedJobposting.length}건',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.red,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${ConvertService.returnStringWithCommaFormat(selectedJobposting.length * premiumData!.finalPrice)} ${premiumData!.priceType.label}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        0.w, 16.w, 0.w, 16.w),
                                    child: TermsItemWidget(
                                      isRequired: true,
                                      isDetail: true,
                                      requireText: localization.mandatory,
                                      text: localization.termsOfService,
                                      status: isAgree,
                                      checkString: 'isServiceStatus',
                                      termsType: 2,
                                      termsDataIdx: 26,
                                      updateStatus: updateTermsStatus,
                                    ),
                                  ),
                                  CommonButton(
                                    onPressed: () {
                                      if (selectedAreaKey.isNotEmpty &&
                                          selectedJobposting.isNotEmpty &&
                                          isAgree) {
                                        applyAreaTopJobposting();
                                      }
                                    },
                                    text: localization.makePayment,
                                    fontSize: 15,
                                    confirm: selectedAreaKey.isNotEmpty &&
                                        selectedJobposting.isNotEmpty &&
                                        isAgree,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const BottomPadding(),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : const Loader(),
      ),
    );
  }
}
