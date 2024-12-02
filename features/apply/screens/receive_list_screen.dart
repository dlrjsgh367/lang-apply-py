import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/posting_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:chodan_flutter_app/features/apply/widgets/search_dialog_widget.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

class ReceiveListScreen extends ConsumerStatefulWidget {
  const ReceiveListScreen({
    super.key,
    required this.getUnReadCount,
    required this.unReadCount,
  });

  final Function getUnReadCount;
  final int unReadCount;

  @override
  ConsumerState<ReceiveListScreen> createState() => _ReceiveListScreenState();
}

class _ReceiveListScreenState extends ConsumerState<ReceiveListScreen>
    with Alerts, SingleTickerProviderStateMixin {
  late AnimationController _animateController;
  late Animation<double> _animation;
  bool _isDragging = false;
  double _previousScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    Future(() async {
      await getPostingListData(page);
      chagnePostingOpen();
      setState(() {
        isLoading = false;
      });
    });

    _animateController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animateController,
      curve: Curves.linear,
    );
    _animateController.value = 1;
  }

  _onUpdateScroll(metrics) {
    if (_isDragging) {
      final double currentScrollPosition = metrics.pixels;
      if (currentScrollPosition > _previousScrollPosition) {
        _animateController.animateBack(0,
            duration: const Duration(milliseconds: 100));
      } else if (currentScrollPosition < _previousScrollPosition) {
        _animateController.forward();
      }
      _previousScrollPosition = currentScrollPosition;
    }
  }

  chagnePostingOpen() async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).chagnePostingOpen();
  }

  final searchController = TextEditingController();
  List<PostingModel> postingList = [];
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
  String keyWord = '';
  String searchPlaceHolder = localization.searchByJobTitleCompanyName;

  _boardLoadMore() async {
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
      });
      page = page + 1;
      Future(() {
        getPostingListData(page);
      });
    }
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.type == 1) {
      if (result.status == 200) {
        setState(() {
          ref.read(userProvider.notifier).update((state) => result.data);
        });
      }
    }
  }

  getPostingListData(int page) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getPostingListData(page, keyWord, 2);
    if (result.type == 1) {
      setState(() {
        List<PostingModel> data = result.data;
        if (page == 1) {
          postingList = [...data];
        } else {
          postingList = [...postingList, ...data];
        }
        lastPage = result.page['lastPage'];
        total = result.page['total'];
        isLazeLoading = false;
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
    isLoading = false;
  }

  blockCompany(int key) async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).createHide(key, 1);
    if (result.type == 1) {
      Future(() {
        getPostingListData(page);
        showDefaultToast(localization.savedAsBlockedCompany);
      });
      context.pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.blockFailure,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    }
  }

  deAcceptJobPosting(int key) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(key, 3);
    if (result.type == 1) {
      Future(() {
        getPostingListData(page);
      });
      context.pop();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.proposalRejectionFailed,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              Future(() {
                getPostingListData(page);
              });
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    }
  }

  acceptJobPosting(dynamic item) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(item.key, 2);
    if (result.type == 1) {
      Future(() {
        getPostingListData(page);
        List<int> list = ref.watch(applyOrProposedJobpostKeyListProvider);
        list.add(item.postKey);
        ref
            .read(applyOrProposedJobpostKeyListProvider.notifier)
            .update((state) => list);
      });
      context.pop();
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
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return ContentBottomSheet(
            contents: [
              SizedBox(
                height: 20.w,
              ),
              Center(
                child: Image.asset(
                  'assets/images/icon/iconCheckRec.png',
                  width: CommonSize.vw / 3,
                  height: CommonSize.vw / 3,
                ),
              ),
              SizedBox(
                height: 20.w,
              ),
              Text(
                localization.matchedSuccessfully,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.black2b,
                ),
              ),
              SizedBox(
                height: 10.w,
              ),
              Text(
                localization.chatWillOpenSoonAndCompanyWillContact,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.grayB2,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                child: CommonButton(
                  onPressed: () {
                    context.pop();
                  },
                  text: localization.confirm,
                  confirm: true,
                ),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.proposalAcceptanceFailed,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              Future(() {
                getPostingListData(page);
              });
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    }
  }

  returnLeftDay(String date) {
    date = date.replaceAll("T", " ");
    DateTime postingDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    if (isDoneDay(date)) {
      return localization.closed;
    } else {
      int difference = postingDate.difference(now).inDays;
      if (difference > 0) {
        return 'D-$difference';
      } else if (difference == 0) {
        return localization.closingToday;
      } else {
        return localization.closed;
      }
    }
  }

  isDoneDay(String date) {
    if (date == '') {
      return false;
    }
    String endDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(date));
    var toDay = DateTime.now();
    return !DateTime.parse(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(endDate)))
        .isAfter(toDay);
  }

  isBeforeSevenDay(String date) {
    date = date.replaceAll("T", " ");
    DateTime postingDate = DateTime.parse(date);
    DateTime now = DateTime.now();
    int difference = postingDate.difference(now).inDays;
    if (difference >= 0 && difference < 8) {
      return true;
    } else {
      return false;
    }
  }

  returnRequiredStatus(int type) {
    if (type == 0) {
      return localization.cancel;
    } else if (type == 1) {
      return localization.unconfirmed;
    } else if (type == 2) {
      return localization.proposalAccepted;
    } else if (type == 3) {
      return localization.rejected;
    } else if (type == 4) {
      return localization.confirm;
    }
  }

  showBottom(PostingModel item) {
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
          !isDoneDay(item.postingPeriod) &&
                  (item.postingRequiredStatus == 1 ||
                      item.postingRequiredStatus == 4)
              ? BottomSheetButton(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertTwoButtonDialog(
                            alertTitle: localization.acceptProposal,
                            alertContent: localization.confirmAcceptSelectedProposal,
                            alertConfirm: localization.confirmAcceptance,
                            alertCancel: localization.cancel,
                            onConfirm: () {
                              acceptJobPosting(item);
                              context.pop(context);
                            },
                          );
                        });
                  },
                  text: localization.acceptProposal,
                )
              : const SizedBox.shrink(),
          !isDoneDay(item.postingPeriod) &&
                  (item.postingRequiredStatus == 1 ||
                      item.postingRequiredStatus == 4)
              ? BottomSheetButton(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertTwoButtonDialog(
                            alertTitle: localization.rejectProposal,
                            alertContent: localization.confirmRejectSelectedProposal,
                            alertConfirm: localization.proposalRejected,
                            alertCancel: localization.cancel,
                            onConfirm: () {
                              deAcceptJobPosting(item.key);
                              context.pop(context);
                            },
                          );
                        });
                  },
                  text: localization.rejectProposal,
                )
              : SizedBox.shrink(),
          BottomSheetButton(
              onTap: () {
                context.pop();
                openJobpost(item);
              },
              text: localization.receivedJobPostProposal),
          BottomSheetButton(
              onTap: () {
                context.pop();
                context.push("/my/profile/${item.profileKey}");
              },
              text: localization.receivedProfileProposal),
          BottomSheetButton(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertTwoButtonDialog(
                        alertTitle: localization.blockCompany,
                        alertContent: localization.confirmBlockSelectedCompany,
                        alertConfirm: localization.blockUser,
                        alertCancel: localization.cancel,
                        onConfirm: () {
                          blockCompany(item.postKey);
                          context.pop(context);
                        },
                      );
                    });
              },
              text: localization.blockCompany,
              isRed: true),
        ]);
      },
    );
  }

  showSearchDialog() {
    showModalSideSheet(
      width: CommonSize.vw,
      useRootNavigator: false,
      withCloseControll: false,
      ignoreAppBar: true,
      context: context,
      transitionDuration: const Duration(milliseconds: 200),
      body: SearchDialogWidget(
        afterFunc: search,
        searchValue: keyWord,
        searchPlaceHolder: searchPlaceHolder,
        resetJobPost: reset,
      ),
    );
  }

  search(text) {
    setState(() {
      keyWord = text;
      searchController.text = text;
      getPostingListData(1);
    });
  }

  reset() {
    setState(() {
      keyWord = '';
      searchController.text = '';
      getPostingListData(1);
    });
  }

  openJobpost(PostingModel post) async {
    final userInfo = ref.watch(userProvider);
    final isJobSeeker = userInfo?.memberType == MemberTypeEnum.jobSeeker;

    if (isJobSeeker) {
      final result = await ref
          .read(applyControllerProvider.notifier)
          .updateActivityStatus('PROPOSE', post.key);

      if (result.status == 200) {
        setState(() {
          final index = postingList.indexWhere((el) => el.key == post.key);
          if (index > -1) {
            setState(() {
              postingList[index] =
                  postingList[index].copyWith(postingRequiredStatus: 4);
            });
          }
        });
      }
    }
    context.push("/jobpost/${post.postKey}/propose").then((_) {
      getPostingListData(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          axisAlignment: -1,
          child: Container(
            color: CommonColors.red,
            padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
            child: TextFormField(
              onTap: () {
                showSearchDialog();
              },
              readOnly: true,
              cursorColor: CommonColors.black,
              style: searchInputBigText(),
              decoration: searchInput(
                height: 50,
                hintText: localization.searchByJobTitleCompanyName,
                clearFunc: () {
                  searchController.clear;
                  setState(() {
                    searchController.text = '';
                  });
                },
              ),
              controller: searchController,
            ),
          ),
        ),
        Expanded(
            child: LazyLoadScrollView(
          onEndOfPage: () => _boardLoadMore(),
          child: !isLoading
              ? postingList.isNotEmpty
                  ? NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollNotification) {
                        if (scrollNotification is ScrollStartNotification) {
                          setState(() {
                            _isDragging = true;
                          });
                        }
                        if (scrollNotification is ScrollUpdateNotification) {
                          _onUpdateScroll(scrollNotification.metrics);
                        }
                        if (scrollNotification is ScrollEndNotification) {
                          setState(() {
                            _isDragging = false;
                          });
                        }
                        return false;
                      },
                      child: CustomScrollView(
                        physics: ClampingScrollPhysics(),
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              childCount: postingList.length,
                              // childCount: 20,
                              (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(20.w),
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
                                            child: Row(children: [
                                              Text(
                                                '${DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(postingList[index].createdAt))} | ',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: CommonColors.grayB2,
                                                ),
                                              ),
                                              Text(
                                                '${returnRequiredStatus(postingList[index].postingRequiredStatus)}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: postingList[index]
                                                              .postingRequiredStatus ==
                                                          1
                                                      ? CommonColors.red
                                                      : CommonColors.gray66,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.w,
                                              ),
                                              if (postingList[index]
                                                      .postingOpenStatus ==
                                                  0)
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/icon/NewIcon.png',
                                                      width: 16.w,
                                                      height: 16.w,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                  ],
                                                ),
                                            ]),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showBottom(postingList[index]);
                                            },
                                            child: Image.asset(
                                              'assets/images/icon/iconKebab.png',
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8.w),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .push(
                                                  "/jobpost/${postingList[index].postKey}/propose")
                                              .then((_) {
                                            getPostingListData(1);
                                          });
                                        },
                                        child: ColoredBox(
                                          color: Colors.transparent,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      postingList[index]
                                                          .companyName,
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color:
                                                            CommonColors.gray66,
                                                      ),
                                                    ),
                                                  ),
                                                  postingList[index]
                                                              .postingPeriod !=
                                                          ''
                                                      ? Text(
                                                          returnLeftDay(
                                                              postingList[index]
                                                                  .postingPeriod),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 13.sp,
                                                            color: isBeforeSevenDay(
                                                                    postingList[
                                                                            index]
                                                                        .postingPeriod)
                                                                ? CommonColors
                                                                    .red
                                                                : CommonColors
                                                                    .gray80,
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                              SizedBox(height: 4.w),
                                              Wrap(
                                                children: [
                                                  Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    postingList[index].title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14.sp,
                                                      color: CommonColors.black,
                                                    ),
                                                  ),
                                                  if (postingList[index]
                                                      .michinMatching
                                                      .isNotEmpty)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8.0),
                                                      child: Image.asset(
                                                          'assets/images/icon/iconMichinMatching.png',
                                                          width: 63.0),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8.w),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          FooterBottomPadding()
                        ],
                      ),
                    )
                  : CommonEmpty(text: localization.noListAvailable)
              : Loader(),
        )),
      ],
    );
  }
}
