import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/apply/widgets/apply_type_widget.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/jobposting/controller/jobposting_controller.dart';
import 'package:chodan_flutter_app/features/mypage/controller/mypage_controller.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
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
import 'package:chodan_flutter_app/features/apply/controller/apply_controller.dart';
import 'package:chodan_flutter_app/features/apply/widgets/search_dialog_widget.dart';
import 'package:modal_side_sheet/modal_side_sheet.dart';

class ApplyListScreen extends ConsumerStatefulWidget {
  const ApplyListScreen({super.key});

  @override
  ConsumerState<ApplyListScreen> createState() => _ApplyListScreenState();
}

class _ApplyListScreenState extends ConsumerState<ApplyListScreen>
    with Alerts, SingleTickerProviderStateMixin {
  late AnimationController _animateController;
  late Animation<double> _animation;
  bool _isDragging = false;
  double _previousScrollPosition = 0;

  List profileKeyList = [];

  @override
  void initState() {
    super.initState();
    Future(() async {
      await getPostingListData(page);
      getProfileKeyList();
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

    setState(() {
      isLoading = false;
    });
  }

  Future<String> getProfileKeyList() async {
    UserModel? userInfo = ref.read(userProvider);
    String profilePhotoUrl = '';
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(mypageControllerProvider.notifier)
          .getProfileList(userInfo.key);
      if (result.type == 1) {
        if (result.status == 200) {
          setState(() {
            if (result.data.isNotEmpty) {
              for (var item in result.data) {
                profileKeyList.add(item.key);
              }
            }
          });
        }
      }
    }
    return profilePhotoUrl;
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
  String searchPlaceHolder = localization.searchByJobTitleProfileTitleCompanyName;

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

  getPostingListData(int page) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .getPostingListData(page, keyWord, 1);
    if (result.type == 1) {
      setState(() {
        List<PostingModel> data = result.data;
        if (page == 1) {
          postingList = [...data];
        } else {
          postingList = [...postingList, ...data];
        }
        ref.read(applyPostListProvider.notifier).update((state) => postingList);
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

  cancelJobPosting(int key) async {
    ApiResultModel result = await ref
        .read(applyControllerProvider.notifier)
        .changeStatusJobActivity(key, 0);
    if (result.type == 1) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.applicationCancelSuccess,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              Future(() {
                getPostingListData(page);
                getApplyOrProposedJobpostKey();
              });
              context.pop();
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.applicationCancelFailure,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              Future(() {
                getPostingListData(page);
              });
              context.pop();
              context.pop();
            },
            alertTitle: localization.notification,
          );
        },
      );
    }
  }

  getApplyOrProposedJobpostKey() async {
    ApiResultModel result = await ref
        .read(jobpostingControllerProvider.notifier)
        .getApplyOrProposedJobpostKey();
    if (result.status == 200) {
      if (result.type == 1) {
        setState(() {
          ref.read(applyOrProposedJobpostKeyListProvider.notifier).update(
                  (state) =>
              [...result.data['jpIdx'], ...result.data['jpIdxApproved']]);
        });
      }
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
      }
    }
  }

  isDoneDay(String date) {
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
    context.push("/seeker/${post.profileKey}");
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
          BottomSheetButton(
              onTap: () {
                context.pop();
                if (profileKeyList.contains(item.profileKey)) {
                  context.push('/my/profile/${item.profileKey}');
                } else {
                  context.push("/seeker/${item.profileKey}");
                }
              },
              text: localization.appliedProfile),
          BottomSheetButton(
              onTap: () {
                context.pop();
                context.push("/jobpost/${item.postKey}/apply").then((_) {
                  getPostingListData(1);
                });
              },
              text: localization.appliedJobPost),
          !isDoneDay(item.postingPeriod) && item.postingRequiredStatus == 1
              ? BottomSheetButton(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertTwoButtonDialog(
                            alertTitle: localization.cancelApplication,
                            alertContent: localization.confirmCancelSelectedJobPost,
                            alertConfirm: localization.cancelApplication,
                            alertCancel: localization.closed,
                            onConfirm: () {
                              cancelJobPosting(item.key);
                              context.pop(context);
                            },
                          );
                        });
                  },
                  text: localization.cancelApplication,
                  isRed: true,
                )
              : const SizedBox.shrink(),
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

  returnStatusText(PostingModel item) {
    if (item.postingRequiredStatus == 0) {
      return localization.cancelApplication;
    } else if (item.postingRequiredStatus == 1) {
      return localization.unread;
    } else if (item.postingRequiredStatus == 2) {
      return localization.accepted;
    } else if (item.postingRequiredStatus == 3) {
      return localization.rejected;
    } else if (item.postingRequiredStatus == 4) {
      return localization.read;
    } else {
      return localization.read;
    }
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
                  hintText: localization.searchByJobTitleProfileTitleCompanyName,
                  clearFunc: () {
                    searchController.clear;
                    setState(() {
                      searchController.text = '';
                    });
                  }),
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
                        onNotification:
                            (ScrollNotification scrollNotification) {
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
                                        GestureDetector(
                                          onTap: () {
                                            context
                                                .push(
                                                    "/jobpost/${postingList[index].postKey}/apply")
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
                                                        DateFormat(
                                                                'yyyy.MM.dd HH:mm')
                                                            .format(DateTime.parse(
                                                                postingList[
                                                                        index]
                                                                    .createdAt)),
                                                        style: TextStyle(
                                                          fontSize: 12.sp,
                                                          color: CommonColors
                                                              .grayB2,
                                                        ),
                                                      ),
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
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        postingList[index]
                                                            .companyName,
                                                        style: TextStyle(
                                                          fontSize: 13.sp,
                                                          color: CommonColors
                                                              .gray66,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      returnLeftDay(
                                                          postingList[index]
                                                              .postingPeriod
                                                              .replaceAll(
                                                                  "T", " ")),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13.sp,
                                                        color: isBeforeSevenDay(
                                                                postingList[
                                                                        index]
                                                                    .postingPeriod
                                                                    .replaceAll(
                                                                        "T",
                                                                        " "))
                                                            ? CommonColors.red
                                                            : CommonColors
                                                                .gray80,
                                                      ),
                                                    ),
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
                                                        color:
                                                            CommonColors.black,
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
                                            context.push('/my/profile/${postingList[index].profileKey}');
                                          },
                                          child: ColoredBox(
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                ApplyTypeWidget(
                                                    btnTitle: returnStatusText(
                                                        postingList[index]),
                                                    type: postingList[index]
                                                        .postingRequiredStatus),
                                                SizedBox(width: 10.w),
                                                Expanded(
                                                  child: Text(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    postingList[index]
                                                        .profileTitle,
                                                    style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.gray4d,
                                                    ),
                                                  ),
                                                ),
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
                      )
                    : CommonEmpty(
                        text: keyWord == '' ? localization.noListAvailable : localization.noSearchResults)
                : Loader(),
          ),
        ),
      ],
    );
  }
}
