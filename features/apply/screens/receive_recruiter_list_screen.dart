import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/worker/controller/worker_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
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

class ReceiveRecruiterListScreen extends ConsumerStatefulWidget {
  const ReceiveRecruiterListScreen({super.key, required this.unReadCount});

  final int unReadCount;

  @override
  ConsumerState<ReceiveRecruiterListScreen> createState() =>
      _ReceiveRecruiterListScreenState();
}

class _ReceiveRecruiterListScreenState
    extends ConsumerState<ReceiveRecruiterListScreen>
    with Alerts, SingleTickerProviderStateMixin {
  late AnimationController _animateController;
  late Animation<double> _animation;
  bool _isDragging = false;
  double _previousScrollPosition = 0;

  changePostingOpenSingle(int index) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changePostingOpenSingle(index);

    setState(() {
      page = 1;
    });
    getPostingListData(page);
  }

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

  final searchController = TextEditingController();
  List<PostingModel> postingList = [];
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
  String keyWord = '';
  String searchPlaceHolder = localization.searchByJobTitleProfileTitleCandidateName;

  _boardLoadMore() async {
    if (isLazeLoading) {
      return;
    }
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

  getPostingListData(int page) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getRecruiterPostingListData(page, keyWord, 1);
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
  }

  chagnePostingOpen() async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).chagnePostingOpen();
  }

  blockCompany(int key) async {
    ApiResultModel result =
        await ref.read(applyControllerProvider.notifier).createHide(key, 2);
    if (result.type == 1) {
      showDefaultToast(localization.savedAsBlockedCandidate);
      Future(() {
        getPostingListData(page);
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
            alertContent: localization.applicationRejectionFailure,
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

  acceptJobPosting(int key) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(key, 2);

    if (result.type == 1) {
      Future(() {
        getPostingListData(page);
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
                localization.goToMatchingListAndStartChat,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: CommonColors.grayB2,
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          context.pop();
                        },
                        text: localization.closed,
                        confirm: false,
                      ),
                    ),
                    SizedBox(
                      width: 8.w,
                    ),
                    Expanded(
                      child: CommonButton(
                        onPressed: () {
                          context.pop();
                          context.push('/chat?tab=matching');
                        },
                        text: localization.goToMatchingList,
                        confirm: true,
                      ),
                    ),
                  ],
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
            alertContent: localization.applicationAcceptanceFailure,
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

  returnRequiredStatus(type) {
    if (type == 0) {
      return localization.cancel;
    } else if (type == 1) {
      return localization.unconfirmed;
    } else if (type == 2) {
      return localization.proposalAccepted;
    } else if (type == 3) {
      return localization.proposalRejected;
    } else if (type == 4) {
      return localization.confirm;
    }
  }

  openProfile(PostingModel post) async {
    final userInfo = ref.watch(userProvider);
    final isRecruiter = userInfo?.memberType == MemberTypeEnum.recruiter;
    if (isRecruiter) {
      final result = await ref
          .read(applyControllerProvider.notifier)
          .updateActivityStatus('APPLY', post.key);

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

    context
        .push("/seeker/${post.profileKey}/${post.postKey}/propose")
        .then((_) {
      getPostingListData(1);
    });
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
                  text: localization.acceptApplication,
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertTwoButtonDialog(
                            alertTitle: localization.acceptApplication,
                            alertContent: localization.confirmAcceptSelectedApplication,
                            alertConfirm: localization.confirm,
                            alertCancel: localization.cancel,
                            onConfirm: () {
                              acceptJobPosting(item.key);
                              context.pop(context);
                            },
                          );
                        });
                  },
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
                            alertTitle: localization.rejectApplication,
                            alertContent: localization.confirmRejectSelectedApplication,
                            alertConfirm: localization.confirm,
                            alertCancel: localization.cancel,
                            onConfirm: () {
                              deAcceptJobPosting(item.key);
                              context.pop(context);
                            },
                          );
                        });
                  },
                  text: localization.rejectApplication,
                )
              : const SizedBox.shrink(),
          BottomSheetButton(
              onTap: () {
                context.pop();
                context.push("/jobpost/${item.postKey}");
              },
              text: localization.receivedJobPost),
          BottomSheetButton(
              onTap: () {
                context.pop();
                openProfile(item);
              },
              text: localization.receivedProfile),
          BottomSheetButton(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertTwoButtonDialog(
                        alertTitle: localization.blockApplicant,
                        alertContent: localization.confirmBlockSelectedApplicant,
                        alertConfirm: localization.confirm,
                        alertCancel: localization.cancel,
                        onConfirm: () {
                          blockCompany(item.profileKey);
                          context.pop(context);
                        },
                      );
                    });
              },
              isRed: true,
              last: true,
              text: localization.blockApplicant),
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

  @override
  Widget build(BuildContext context) {
    List<int> matchedProfileKeyList = ref.watch(matchingKeyListProvider);
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
              decoration:
                  searchInputBig(height: 48, hintText: searchPlaceHolder),
              controller: searchController,
            ),
          ),
        ),
        Expanded(
            child: LazyLoadScrollView(
          onEndOfPage: () => _boardLoadMore(),
          child: !isLoading
              ? postingList.isNotEmpty
                  ? Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification:
                              (ScrollNotification scrollNotification) {
                            if (scrollNotification is ScrollStartNotification) {
                              setState(() {
                                _isDragging = true;
                              });
                            }
                            if (scrollNotification
                                is ScrollUpdateNotification) {
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
                                        color: Colors.transparent,
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
                                                    DateFormat(
                                                            'yyyy.MM.dd HH:mm:ss')
                                                        .format(
                                                      DateTime.parse(
                                                          postingList[index]
                                                              .createdAt
                                                              .replaceAll(
                                                                  "T", " ")),
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          CommonColors.grayB2,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        8.w, 0, 8.w, 0),
                                                    width: 1.w,
                                                    height: 12.w,
                                                    color: CommonColors.grayD9,
                                                  ),
                                                  Expanded(
                                                      child: Row(
                                                    children: [
                                                      Text(
                                                        returnRequiredStatus(
                                                            postingList[index]
                                                                .postingRequiredStatus),
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: postingList[
                                                                          index]
                                                                      .postingRequiredStatus ==
                                                                  1
                                                              ? CommonColors.red
                                                              : CommonColors
                                                                  .gray66,
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
                                                            SizedBox(
                                                                width: 4.w),
                                                          ],
                                                        ),
                                                    ],
                                                  )),
                                                ]),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showBottom(
                                                      postingList[index]);
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
                                                      "/seeker/${postingList[index].profileKey}/${postingList[index].postKey}/propose")
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
                                                          ConvertService.returnMaskingName(
                                                              matchedProfileKeyList
                                                                  .contains(
                                                                      postingList[
                                                                              index]
                                                                          .key),
                                                              postingList[index]
                                                                  .memberName),
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .gray66,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 4.w),
                                                  Wrap(
                                                    children: [
                                                      Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        postingList[index]
                                                            .profileTitle,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14.sp,
                                                          color: CommonColors
                                                              .black,
                                                        ),
                                                      ),
                                                      if (postingList[index]
                                                          .michinMatching
                                                          .isNotEmpty)
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
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
                                          GestureDetector(
                                            onTap: () {
                                              context.push(
                                                  "/jobpost/${postingList[index].postKey}");
                                            },
                                            child: ColoredBox(
                                              color: Colors.transparent,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      postingList[index].title,
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color:
                                                            CommonColors.gray4d,
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

                                                            // color: CommonColors.gray80,
                                                            color: CommonColors
                                                                .red,
                                                          ),
                                                        )
                                                      : const SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const FooterBottomPadding()
                            ],
                          ),
                        ),
                        if (isLazeLoading)
                          Positioned(
                              bottom: CommonSize.commonBottom,
                              child: const Loader())
                      ],
                    )
                  : CommonEmpty(text: localization.noListAvailable)
              : const Loader(),
        )),
      ],
    );
  }
}
