import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/jobposting_edit_enum.dart';
import 'package:chodan_flutter_app/enum/jobposting_manage_tap_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_closed_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_publishing_widget.dart';
import 'package:chodan_flutter_app/features/jobposting/widgets/jobposting_waiting_permission_widget.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

class JobpostingManageScreen extends ConsumerStatefulWidget {
  const JobpostingManageScreen({this.tab, super.key});

  final String? tab;

  @override
  ConsumerState<JobpostingManageScreen> createState() =>
      _JobpostingManageScreenState();
}

class _JobpostingManageScreenState extends ConsumerState<JobpostingManageScreen>
    with SingleTickerProviderStateMixin, Alerts {
  bool isLoading = true;
  late TabController tabController;

  ScrollController tabScrollController = ScrollController();

  int activeTab = 0;

  int page = 1;
  int lastPage = 1;
  bool isLazeLoading = false;
  List<JobpostModel> jobpostList = [];

  bool isRunning = false;

  List<JobpostingManageTapEnum> jobpostingStateType = [
    JobpostingManageTapEnum.waitingPermission,
    JobpostingManageTapEnum.publishing,
    JobpostingManageTapEnum.closed,
  ];

  List gKArr = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  late Future<void> _allAsyncTasks;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      getJobpostingListData(page, jobpostingStateType[activeTab].listApiParams)
    ]);
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    if (widget.tab != null) {
      activeTab = int.parse(widget.tab!);
    }
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  getJobpostingListData(int page, Map<String, dynamic> params) async {
    UserModel? userInfo = ref.read(userProvider);
    Map<String, dynamic> ownerIdxParam = {'ownerIdx': userInfo!.key};
    params = {...params, ...ownerIdxParam};
    params.addAll(ownerIdxParam);
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingListData(page, params);
    if (result.status == 200) {
      if (result.type == 1) {
        List<JobpostModel> data = result.data;
        if (page == 1) {
          jobpostList = [...data];
        } else {
          jobpostList = [...jobpostList, ...data];
        }
        setState(() {
          lastPage = result.page['lastPage'];
          isLazeLoading = false;
        });
      }
    }
  }

  reregisterJobposting(int jobpostKey) async {
    // Map<String, dynamic> params = {
    //   'jpIdx' : jobpost.key,
    //   'jpOwnerIdx' : jobpost.owner.key,
    //   'jpTitle' : jobpost.title,
    //   'jpPostPeriod' : jobpost.postPeriod,
    //   'jpPostState' : jobpost.postState,
    //   'workCondition' : {
    //     'jpSalaryType' : jobpost.salaryType.param,
    //     'jpSalary' : jobpost.salary,
    //     'jpSalaryNegotiable' : ,
    //     'wtIdx' : ,
    //     'jpProbationPeriod' : ,
    //     'wpIdx' : ,
    //     'jpPeriodChangeable' : ,
    //     'wdIdx' : [],
    //   }
    //
    // };

    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getJobpostingDetailForUpdate(jobpostKey);
    if (result.status == 200) {
      if (result.type == 1) {
        Map<String, dynamic> jobData = result.data;
        List<Map<String, dynamic>> preferentialConditions = [];
        for (int i = 0;
            i <
                jobData['recruitmentCondition']['preferentialConditions']
                    .length;
            i++) {
          preferentialConditions.add({
            'jppcType': 'key',
            'pcIdx': jobData['recruitmentCondition']['preferentialConditions']
                [i]
          });
        }
        Map<String, dynamic> params = {
          'jpIdx': jobData['jpIdx'],
          'jpOwnerIdx': jobData['jpOwner']['meidx'],
          'jpTitle': jobData['jpTitle'],
          'jpPostPeriod': jobData['jpPostPeriod'],
          'jpPostState': jobData['jpPostState'],
          'workCondition': {
            'jpSalaryType': jobData['workCondition']['jpSalaryType'],
            'jpSalary': jobData['workCondition']['jpSalary'],
            'jpSalaryNegotiable': jobData['workCondition']
                ['jpSalaryNegotiable'],
            'wtIdx': jobData['workCondition']['wtIdx'],
            'jpProbationPeriod': jobData['workCondition']['jpProbationPeriod'],
            'wpIdx': jobData['workCondition']['wpIdx'],
            'jpPeriodChangeable': jobData['workCondition']
                ['jpPeriodChangeable'],
            'wdIdx': jobData['workCondition']['workDays'],
            'jpDaysChangeable': jobData['workCondition']['jpDaysChangeable'],
            'workHour': jobData['workCondition']['workHour'],
            'jpWorkHourChangeable': jobData['workCondition']
                ['jpWorkHourChangeable'],
            'restHour': jobData['workCondition']['restHour'],
            'jpRestHourChangeable': jobData['workCondition']
                ['jpRestHourChangeable'],
            'jpContractualWorkHour': jobData['workCondition']
                ['jpContractualWorkHour'],
            'jpAddressType': jobData['jpAddressType'],
            'jpAddress': jobData['jpAddress'],
            'jpAddressDetail': jobData['jpAddressDetail'],
            'adSi': jobData['jpAdSi'],
            'adGu': jobData['jpAdGu'],
            'adDong': jobData['jpAdDongName'],
          },
          'recruitmentCondition': {
            'jpJobPosition': jobData['recruitmentCondition']['jpJobPosition'],
            'jpRecruitedCount': jobData['recruitmentCondition']
                ['jpRecruitedCount'],
            'jpSex': jobData['recruitmentCondition']['jpSex'],
            'jpAgeMin': jobData['recruitmentCondition']['jpAgeMin'],
            'jpAgeMax': jobData['recruitmentCondition']['jpAgeMax'],
            'jpMiddleAge': jobData['recruitmentCondition']['jpMiddleAge'],
            'stIdx': jobData['recruitmentCondition']['stIdx'],
            'jpCareerType': jobData['recruitmentCondition']['jpCareerType'],
            'jpCareerMin': jobData['recruitmentCondition']['jpCareerMin'],
            'jpCareerMax': jobData['recruitmentCondition']['jpCareerMax'],
            'preferentialConditions': preferentialConditions,
            'jpApplyEligibility': jobData['recruitmentCondition']
                ['jpApplyEligibility']
          },
          'workInfo': jobData['workInfo'],
          'managerInfoDto': {
            'jpManagerName': jobData['managerInfo']['jpManagerName'],
            'jpManagerHp': jobData['managerInfo']['jpManagerHp'],
            'jpManagerEmail': jobData['managerInfo']['jpManagerEmail'],
            'jpManagerNameDisplay': jobData['managerInfo']
                ['jpManagerNameDisplay'],
            'jpManagerHpDisplay': jobData['managerInfo']['jpManagerHpDisplay'],
            'jpManagerEmailDisplay': jobData['managerInfo']
                ['jpManagerEmailDisplay'],
            'jpCompanyNameType': jobData['jpCompanyNameType'],
            'jpCompanyName': jobData['jpCompanyName'],
            'jpManagerIdx': jobData['jpManager']['meIdx']
          }
        };
        ApiResultModel reregisterResult = await ref
            .read(jobpostingControllerProvider.notifier)
            .reRegisterJobposting(params);
        if (reregisterResult.status == 200) {
          if (reregisterResult.type == 1) {
            setState(() {
              isRunning = false;
            });
            //TODO : 상태 수정
          }
        } else if (result.status != 200) {
          setState(() {
            isRunning = false;
          });
          showDefaultToast(localization.dataCommunicationFailed);
        } else {
          setState(() {
            isRunning = false;
          });
          if (!mounted) return null;
          showNetworkErrorAlert(context);
        }
      }
    } else if (result.status != 200) {
      setState(() {
        isRunning = false;
      });
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      setState(() {
        isRunning = false;
      });
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  setTab(int tab) {
    activeTab = tab;
    page = 1;
    getJobpostingListData(page, jobpostingStateType[activeTab].listApiParams);
  }

  void setTabScroll(int tab) {
    var activeGk = gKArr[tab];
    RenderBox? box = activeGk.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      double xDouble = position.dx;
      if (tabScrollController.position.pixels <
              tabScrollController.position.maxScrollExtent ||
          xDouble < 17.5) {
        tabScrollController.animateTo(
          xDouble + tabScrollController.position.pixels - 17.5,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    }
  }

  deleteJobposting(int jobpostKey) async {
    ApiResultModel result = await ref.read(jobpostingControllerProvider.notifier).deleteJobposting(jobpostKey);
    if (result.status == 200 && result.type == 1) {
      setState(() {
        List newJobposting = jobpostList
            .where((JobpostModel element) => element.key != jobpostKey)
            .toList();
        jobpostList = [...newJobposting];
      });
    } else {
      showErrorAlert(context,localization.guide,localization.dataCommunicationFailed);
    }
  }

  closeJobposting(int jobpostKey) async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .closeJobposting(jobpostKey);
    if (result.status == 200 && result.type == 1) {
      setTab(2);
      //setState(() {
      // List newJobposting = jobpostList.where((JobpostModel element) => element.key != jobpostKey).toList();
      // jobpostList = [...newJobposting];

      //});
    } else {
      showErrorAlert(context,localization.guide,localization.dataCommunicationFailed);
    }
  }

  showDeleteJobpostingAlert(int jobpostKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
            alertTitle:localization.deleteJobPost,
            alertContent:localization.confirmDeleteJobPostIrreversible,
            alertConfirm:localization.confirm,
            alertCancel:localization.cancel,
            onConfirm: () {
              deleteJobposting(jobpostKey);
              context.pop();
              context.pop();
            });
      },
    );
  }

  showClosedJobpostingAlert(int jobpostKey) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
            alertTitle:localization.jobPostClosed,
            alertContent:localization.confirmCloseJobPostBeforeEndDate,
            alertConfirm:localization.confirm,
            alertCancel:localization.cancel,
            onConfirm: () {
              closeJobposting(jobpostKey);
              context.pop();
              context.pop();
            });
      },
    );
  }

  showWaitingBottom(JobpostModel item, BuildContext context) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(contents: [
          BottomSheetButton(onTap: () {
            context.pop();
            context.push('/mypage/jobposting/${JobpostingEditEnum.update.path}/${item.key}').then((_){
              pushAfterFunc();
              // context.pop();
            });
          }, text:localization.editJobPost),
          BottomSheetButton(
            onTap: () {
              showDeleteJobpostingAlert(item.key);
            },
            text:localization.delete,
            isRed: true,
          )
        ]);
      },
    );
  }

  showPublishingBottom(JobpostModel item, BuildContext context) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(contents: [
          BottomSheetButton(onTap: () {
            context.push('/my/premium').then((_){
              pushAfterFunc();
              context.pop();
            });
          }, text:localization.applyPaidProduct),
          BottomSheetButton(onTap: () {
            context.pop();
            context.push('/mypage/jobposting/${JobpostingEditEnum.update.path}/${item.key}').then((_){
              pushAfterFunc();
            });
          }, text:localization.editJobPost),
          BottomSheetButton(onTap: () {
            showClosedJobpostingAlert(item.key);
          }, text:localization.jobPostClosed),
          BottomSheetButton(
            onTap: () {
              showDeleteJobpostingAlert(item.key);
            },
            text:localization.delete,
            isRed: true,
          )
        ]);
      },
    );
  }

  showClosedBottom(JobpostModel item, BuildContext context) {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(contents: [
          BottomSheetButton(onTap: () {
            context.push(
                '/mypage/jobposting/${JobpostingEditEnum.reregister.path}/${item.key}').then((_){
              pushAfterFunc();
              context.pop();
            });
          }, text:localization.repostJobPost),
          BottomSheetButton(
            onTap: () {
              showDeleteJobpostingAlert(item.key);
            },
            text:localization.delete,
            isRed: true,
          )
        ]);
      },
    );
  }


  _loadMore() {
    if (isLazeLoading) {
      return;
    }
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
        page = page + 1;
        getJobpostingListData(
            page, jobpostingStateType[activeTab].listApiParams);
      });
    }
  }

  pushAfterFunc(){
    page = 1;
    getJobpostingListData(
        page, jobpostingStateType[activeTab].listApiParams);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title:localization.jobPostManagement,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
            child: CommonTab(
              setTab: setTab,
              activeTab: activeTab,
              tabTitleArr: [
                JobpostingManageTapEnum.waitingPermission.label,
                JobpostingManageTapEnum.publishing.label,
                JobpostingManageTapEnum.closed.label
              ],
            ),
          ),
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: [
              jobpostList.isEmpty ? CommonEmpty(
                  text:localization.jobPostDoesNotExist
                     ) :
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: LazyLoadScrollView(
                  onEndOfPage: () => _loadMore(),
                  child: CustomScrollView(
                    slivers: [
                      if (activeTab == 0)
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                childCount: jobpostList.length,
                                (context, index) {
                          JobpostModel jobpostItem = jobpostList[index];
                          return JobpostingWaitingPermissionWidget(
                            jobpostItem: jobpostItem,
                            deleteJobposting: showDeleteJobpostingAlert,
                            pushAfterFunc: pushAfterFunc,
                            showEventModal: showWaitingBottom,
                          );
                        })),
                      if (activeTab == 1)
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                childCount: jobpostList.length,
                                (context, index) {
                          JobpostModel jobpostItem = jobpostList[index];
                          return JobpostingPublishingWidget(
                              jobpostItem: jobpostItem,
                              deleteJobposting: showDeleteJobpostingAlert,
                              closeJobposting: showClosedJobpostingAlert,
                              pushAfterFunc: pushAfterFunc,
                            showEventModal : showPublishingBottom,
                          );
                        })),
                      if (activeTab == 2)
                        SliverList(
                            delegate: SliverChildBuilderDelegate(
                                childCount: jobpostList.length,
                                (context, index) {
                          JobpostModel jobpostItem = jobpostList[index];
                          return JobpostingClosedWidget(
                            jobpostItem: jobpostItem,
                            deleteJobposting: showDeleteJobpostingAlert,
                            reregisterJobposting: reregisterJobposting,
                            pushAfterFunc: pushAfterFunc,
                            showEventModal: showClosedBottom,
                          );
                        })),
                      if (activeTab == 1)
                        const BottomPadding(
                          extra: 100,
                        ),
                    ],
                  ),
                ),
              ),
              // if (activeTab == 1)
              //   Positioned(
              //     left: 20.w,
              //     right: 20.w,
              //     bottom: CommonSize.commonBottom,
              //     child: CommonButton(
              //       fontSize: 15,
              //       onPressed: () {
              //         context.push('/my/paidproduct/match');
              //       },
              //       confirm: true,
              //       text: '${PremiumServiceEnum.match.label} 신청 내역',
              //       width: CommonSize.vw,
              //     ),
              //   ),
              if (isLazeLoading)
                Positioned(
                    bottom: CommonSize.commonBottom, child: const Loader()),
              if (isRunning) const Positioned(child: Loader())
            ],
          )),
        ],
      ),
    );
  }
}
