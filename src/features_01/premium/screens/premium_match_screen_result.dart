import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_price_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_check.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_check_inner.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_title.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class PremiumMatchScreen extends ConsumerStatefulWidget {
  const PremiumMatchScreen({super.key});

  @override
  ConsumerState<PremiumMatchScreen> createState() => _PremiumMatchScreenState();
}

class _PremiumMatchScreenState extends ConsumerState<PremiumMatchScreen> {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  late Future<void> _allAsyncTasks;
  bool isLoading = true;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  bool isAgree = false;

  List<JobpostModel> jobpostList = [];

  List<int> selectedJobposting = [];

  PremiumModel? premiumData;

  bool isApplyNewJobposting = false;

  bool isApplyExistingJobposting = false;

  bool isRunning = false;

  String premiumCode = PremiumServiceEnum.match.code;

  final newJobpostingController = TextEditingController();
  String newJobpostingValue = '';

  getJobpostingLinkWithMatch(int page) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingLinkWithMatch(page);
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
    await Future.wait<void>(
        [getPremiumServiceMatch(), getJobpostingLinkWithMatch(page)]);
  }

  @override
  void initState() {
    Future(() async {
      savePageLog();
      await getPremiumServiceMatch();
      await getJobpostingLinkWithMatch(page);
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    newJobpostingController.dispose();
    super.dispose();
  }

  loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getJobpostingLinkWithMatch(page);
      });
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

  tryApplyMatchJobposting() {
    if (isApplyNewJobposting &&
        ConvertService.isNotEmptyValidate(newJobpostingController.text) &&
        isApplyExistingJobposting &&
        selectedJobposting.isEmpty) {
      showErrorAlert(localization.enterHiringRequestDetails);
    } else if (isApplyNewJobposting &&
        !ConvertService.isNotEmptyValidate(newJobpostingController.text)) {
      showErrorAlert(localization.enterHiringRequestDetails);
    } else if (isApplyExistingJobposting && selectedJobposting.isEmpty) {
      showErrorAlert(localization.selectServiceTargetJobPosts);
    } else if (!isApplyNewJobposting && !isApplyExistingJobposting) {
      showErrorAlert(localization.selectServiceToApply);
    } else {
      applyMatchJobposting();
    }
  }

  isConfirm() {
    if ((isApplyNewJobposting &&
            ConvertService.isNotEmptyValidate(newJobpostingController.text) &&
            isApplyExistingJobposting &&
            selectedJobposting.isEmpty) ||
        (isApplyNewJobposting &&
            !ConvertService.isNotEmptyValidate(newJobpostingController.text)) ||
        (isApplyExistingJobposting && selectedJobposting.isEmpty) ||
        (!isApplyNewJobposting && !isApplyExistingJobposting) ||
        !isAgree) {
      return false;
    } else {
      return true;
    }
  }

  applyMatchJobposting() async {
    if (isRunning) {
      return;
    }
    Map<String, dynamic> params = {"cpCode": premiumCode};
    List<int> type = [];
    if (isApplyNewJobposting) {
      type.add(1);
      params['mmDetail'] = newJobpostingController.text;
    }
    if (isApplyExistingJobposting) {
      type.add(2);
      params['jpIdx'] = selectedJobposting;
    }
    params['mmType'] = type;
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .applyMatchJobposting(params);
    isRunning = false;

    if (result.status == 200) {
      if (result.type == 1) {
        showConfirm('${PremiumServiceEnum.match.label} 등록에 성공했습니다.');
      }
    } else {
      if (result.type == -1705 || result.type == -1706) {
        showPayError();
      } else if (result.type == -2404) {
        showErrorAlert(localization.crazyMatchingOnlyForGeneralPosts);
      } else {
        showErrorAlert(localization.crazyMatchingApplicationFailed);
      }
    }
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

  bool test1 = false;

  int setTotal(bool isApplyNewJobposting, bool isApplyExistingJobposting,
      List<int> selectedJobposting) {
    if (isApplyNewJobposting && isApplyExistingJobposting) {
      return selectedJobposting.length + 1;
    }
    if (isApplyNewJobposting) {
      return 1;
    }
    if (isApplyExistingJobposting) {
      return selectedJobposting.length;
    }
    return 0;
  }

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      isAgree = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
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
      child: GestureDetector(
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
          appBar: CommonAppbar(
            title: PremiumServiceEnum.match.label,
          ),
          body: isLoading
              ? const Loader()
              : Stack(
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
                                        width: 16.w,
                                        color: CommonColors.grayF7),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.fromLTRB(
                                          16.w, 12.w, 16.w, 12.w),
                                      decoration: BoxDecoration(
                                        color: CommonColors.grayF7,
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(
                                            localization.jobPostRegistrationAgency,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: CommonColors.gray4d,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 4.w,
                                          ),
                                          Text(
                                            localization.minimumThreeRecommendationsPerJobPost,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: CommonColors.gray4d,
                                            ),
                                          ),
                                        ],
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
                                          localization.threeDays,
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
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                              sliver: ApplyTitle(
                                text: '${PremiumServiceEnum.match.label} 신청',
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.w),
                              sliver: ApplyCheck(
                                text:
                                    localization.shortTermJobManagerRegistersPostsAndRecommendsCandidates,
                                title: localization.applyToNewJobPostIncludingRegistration,
                                onChanged: (value) {
                                  setState(() {
                                    isApplyNewJobposting =
                                        !isApplyNewJobposting;
                                  });
                                },
                                groupValue: isApplyNewJobposting,
                                value: true,
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(44.w, 8.w, 20.w, 0.w),
                              sliver: SliverToBoxAdapter(
                                child: Stack(
                                  children: [
                                    CommonKeyboardAction(
                                      focusNode: textAreaNode,
                                      child: TextFormField(
                                        onTap: () {
                                          ScrollCenter(textAreaKey);
                                        },
                                        key: textAreaKey,
                                        focusNode: textAreaNode,
                                        textInputAction:
                                            TextInputAction.newline,
                                        keyboardType: TextInputType.multiline,
                                        readOnly: !isApplyNewJobposting,
                                        controller: newJobpostingController,
                                        autocorrect: false,
                                        cursorColor: CommonColors.black,
                                        style: areaInputText(),
                                        maxLength: 1000,
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        decoration: areaInput(
                                          disable: !isApplyNewJobposting,
                                          hintText:
                                              localization.enterEmployeeTasksAndHiringConditions,
                                        ),
                                        minLines: 3,
                                        maxLines: 3,
                                        onChanged: (value) {
                                          setState(() {
                                            newJobpostingValue = value;
                                          });
                                        },
                                        onEditingComplete: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.w,
                                      bottom: 10.w,
                                      child: Text(
                                        '${newJobpostingValue.length} / 1000',
                                        style: TextStyles.counter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0.w),
                              sliver: ApplyCheck(
                                text:
                                    localization.selectExistingJobPostsForRecommendations,
                                title: localization.applyToExistingJobPosts,
                                onChanged: (value) {
                                  if (jobpostList.isNotEmpty) {
                                    setState(() {
                                      isApplyExistingJobposting =
                                          !isApplyExistingJobposting;
                                      if (!isApplyExistingJobposting) {
                                        selectedJobposting.clear();
                                      }
                                    });
                                  }
                                },
                                groupValue: isApplyExistingJobposting,
                                value: true,
                              ),
                            ),
                            if (jobpostList.isNotEmpty)
                              SliverPadding(
                                padding:
                                    EdgeInsets.fromLTRB(48.w, 20.w, 20.w, 0.w),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    childCount: jobpostList.length,
                                    (context, index) {
                                      JobpostModel jobItem = jobpostList[index];
                                      return ApplyCheckInner(
                                        text: ConvertService
                                            .convertDateISOtoString(
                                                jobItem.createdAt,
                                                ConvertService
                                                    .YYYY_MM_DD_HH_MM),
                                        title: jobItem.title,
                                        onChanged: () {
                                          if (isApplyExistingJobposting) {
                                            toggleCheckBox(jobItem.key);
                                          }
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
                              padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 0),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                            '${setTotal(isApplyNewJobposting, isApplyExistingJobposting, selectedJobposting)}건',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: CommonColors.red,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${ConvertService.returnStringWithCommaFormat(setTotal(isApplyNewJobposting, isApplyExistingJobposting, selectedJobposting) * premiumData!.finalPrice)} ${premiumData!.priceType.label}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 32.w,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          10.w, 16.w, 20.w, 16.w),
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
                                        if (isConfirm()) {
                                          tryApplyMatchJobposting();
                                        }
                                      },
                                      text: localization.submitPaymentAndConsultationRequest,
                                      fontSize: 15,
                                      confirm: isConfirm(),
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
                ),
        ),
      ),
    );
  }
}
