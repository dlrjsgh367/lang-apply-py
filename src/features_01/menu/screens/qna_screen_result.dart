import 'dart:io';

import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_detail_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/qna_list.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/qna_type_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/empty/common_empty.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:chodan_flutter_app/widgets/tabs/common_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';

import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

import 'package:chodan_flutter_app/models/board_category_model.dart';

import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_widget.dart';

import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';

import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';

class QnaScreen extends ConsumerStatefulWidget {
  const QnaScreen({super.key});

  @override
  ConsumerState<QnaScreen> createState() => _QnaScreenState();
}

class _QnaScreenState extends ConsumerState<QnaScreen>
    with SingleTickerProviderStateMixin, Alerts, Files {
  //
  final FocusNode textAreaNode = FocusNode();

  //
  TabController? _tabController;

  int _currentLength = 0;
  bool isBackStatus = false;

  void _updateLength() {
    setState(() {
      _currentLength = contentController.text.length;
    });
  }

  showTermsAlert() {
    showDialog(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return TermsItemDetailWidget(
          termsType: checkUser(),
          termsKey: getTermsDataByType('info'),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      setState(() {
        contentController.addListener(_updateLength);
        isLoading = false;
      });
    });
  }

  List<BoardModel> boardList = [];
  bool isLoading = true;
  var isLazeLoading = false;
  var page = 1;
  var lastPage = 1;
  var total = 0;
  late Future<void> _allAsyncTasks;
  List<BoardCategoryModel> boardCategoryList = [];
  int defaultQnaCategory = 7;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final fileInfoController = TextEditingController();

  Map<String, dynamic> fileData = {'file': null};
  Map<String, dynamic> inputData = {
    'categoryKey': -1,
    'title': '',
    'content': '',
    'isInfoStatus': false,
  };
  Map<String, dynamic> validatorList = {
    'categoryKey': true,
    'title': true,
    'content': true,
    'isInfoStatus': true,
  };

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getBoardListData(page),
      getBoardCategoryListData(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  checkUser() {
    var user = ref.watch(userProvider);
    switch (user?.memberType) {
      case MemberTypeEnum.jobSeeker:
        return 1;
      case MemberTypeEnum.recruiter:
        return 2;
      case null:
        return 1;
    }
  }

  getTermsDataByType(String type) {
    switch (type) {
      case 'service':
        return 26;
      case 'info':
        return 27;
      case 'location':
        return 28;
    }
  }

  showQnaType() {
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
      useSafeArea: true,
      builder: (BuildContext context) {
        return QnaTypeBottomSheet(
          dataArr: boardCategoryList,
          initItem: selectCategory,
        );
      },
    ).then((value) {
      setState(() {
        selectCategory = value;
        isBackStatus = true;
        selectTitle = selectCategory.bcName;
        inputData['categoryKey'] = selectCategory.bcIdx;

        validatorList['categoryKey'] = false;
      });
    });
  }

  late BoardCategoryModel selectCategory;

  String selectTitle = '';

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      inputData['isInfoStatus'] = value;
      validatorList['isInfoStatus'] = !value;
      isBackStatus = true;
    });
  }

  _boardLoadMore() async {
    if (lastPage > 1 && page + 1 <= lastPage) {
      setState(() {
        isLazeLoading = true;
      });
      page = page + 1;
      getBoardListData(page);
    }
  }

  getBoardListData(int page) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getQnaListData(page);
    if (result.type == 1) {
      setState(() {
        List<BoardModel> data = result.data;
        if (page == 1) {
          boardList = [...data];
        } else {
          boardList = [...boardList, ...data];
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

  getBoardCategoryListData() async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .getBoardCategoryListData(defaultQnaCategory.toString());
    if (result.type == 1) {
      setState(() {
        List<BoardCategoryModel> data = result.data;

        boardCategoryList = [...data];
        selectCategory = boardCategoryList[0];
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  initData() {
    setState(() {
      inputData = {
        'categoryKey': -1,
        'title': '',
        'content': '',
        'isInfoStatus': false,
      };
      validatorList = {
        'categoryKey': true,
        'title': true,
        'content': true,
        'isInfoStatus': true,
      };
      fileData = {'file': null};
      selectCategory = boardCategoryList[0];
      titleController.clear();
      contentController.clear();
      fileInfoController.clear();
      isLoading = false;
      isBackStatus = false;
    });
  }

  createQna() async {
    if (isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).createQna(inputData);
    if (result.status == 200 && result.type == 1) {
      if (fileData['file'] != null) {
        saveFile(fileData['file'], result.data);
      } else {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.inquirySuccessfullyRegistered,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                initData();
                setState(() {
                  activeTab = 1;
                  getBoardListData(1);
                });
                context.pop();
              },
              alertTitle: localization.notice,
            );
          },
        );
      }
    } else if (result.status != 200) {
      if (result.status == 401 && result.type == -2001) {
        showForbiddenAlert(result.data);
      } else if (result.type == -609) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.restrictedByAdmin,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
              },
              alertTitle: localization.notification,
            );
          },
        );
      } else {
        showDefaultToast(localization.registrationFailed);
      }
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }

    setState(() {
      isLoading = false;
    });
  }

  showForbiddenAlert(keyword) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: "금칙어 '" + keyword + "'가 포함되어 문의 등록이 불가능합니다.",
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
        });
  }

  void saveFile(dynamic file, int key) async {
    List fileInfo = [
      {
        'fileType': 'BOARD_FILES',
        'files': [file]
      },
    ];
    var result = await runS3FileUpload(fileInfo, key);
    if (result == true) {
      setState(() {
        fileData['file'] = null;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: localization.inquirySuccessfullyRegistered,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              initData();
              context.pop();
              setTab(1);
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
            alertContent: localization.fileUploadFailedRetry,
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

  showFileAddModal() {
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
        return ContentBottomSheet(
          contents: [
            BottomSheetButton(
                onTap: () {
                  getProfilePhoto('gallery');
                },
                text: localization.photoGallery),
            BottomSheetButton(
                onTap: () {
                  getProfilePhoto('camera');
                },
                text: localization.takePhoto),
            BottomSheetButton(
                onTap: () {
                  getProfileFile();
                },
                text: localization.fileSelect),
            if (fileData['file'] != null)
              BottomSheetButton(
                  onTap: () {
                    setState(() {
                      fileData['file'] = null;
                      fileInfoController.clear();
                      context.pop();
                    });
                  },
                  isRed: true,
                  text: localization.delete),
          ],
        );
      },
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                fileData['file'] = value;
                isBackStatus = true;
              })
            }
        });
  }

  void getProfilePhoto(String type) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        fileData['file'] = photo;
        fileInfoController.text = photo["name"];
        context.pop();
      });
    }
  }

  void getProfileFile() async {
    var file = await getCustomFile();
    if (file != null && file != {}) {
      setState(() {
        fileData['file'] = file;
        fileInfoController.text = file["name"];
        context.pop();
      });
    }
  }

  @override
  void dispose() {
    _allAsyncTasks.whenComplete(() {});
    super.dispose();
  }

  showQnaDetailAlert(key) {
    context.push('/qna/$key');
  }

  backEvent() {
    if (activeTab == 0 && isBackStatus) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertTwoButtonDialog(
              alertTitle: localization.cancelWriting,
              alertContent: localization.confirmPageNavigationWithoutSaving,
              alertConfirm: localization.confirm,
              alertCancel: localization.cancel,
              onConfirm: () {
                context.pop(context);
                context.pop(context);
              },
            );
          });
    } else {
      context.pop(context);
    }
  }

  int activeTab = 0;

  setTab(data) {
    setState(() {
      if (activeTab != data && data == 0) {
        initData();
      }

      if (activeTab != data && data == 1) {
        getBoardListData(page);
      }
      savePageLog(); // 페이지 로그 쌓기
      activeTab = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        backEvent();
      },
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onHorizontalDragUpdate: (details) async {
              int sensitivity = 5;
              if (details.globalPosition.dx - details.delta.dx < 60 &&
                  details.delta.dx > sensitivity) {
                backEvent();
              }
            },
            child: Scaffold(
              appBar: CommonAppbar(
                title: localization.customerSupport,
                backFunc: backEvent,
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 8.w),
                    child: CommonTab(
                      setTab: setTab,
                      activeTab: activeTab,
                      tabTitleArr: const ['문의하기', '내 문의 내역'],
                    ),
                  ),
                  Expanded(
                    child: activeTab == 0
                        ? SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20.w,
                              16.w,
                              20.w,
                              CommonSize.commonBoard(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.w),
                                    color: CommonColors.grayF7,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        localization.inquiryAndSupportGuide,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 16.w),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(6.w),
                                            width: 3.w,
                                            height: 3.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              localization.reportServiceIssuesOrQuestions,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(6.w),
                                            width: 3.w,
                                            height: 3.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              localization.weekdayResponse,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(6.w),
                                            width: 3.w,
                                            height: 3.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              localization.nextDayResponseAfter5PM,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(6.w),
                                            width: 3.w,
                                            height: 3.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              localization.delayedResponseNotice,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: CommonColors.gray80,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 24.w,
                                ),
                                Text(
                                  localization.inquiryType,
                                  style: TextStyle(
                                    color: CommonColors.black2b,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 20.w,
                                ),
                                SelectButton(
                                  onTap: () {
                                    showQnaType();
                                  },
                                  hintText: localization.pleaseSelect,
                                  text: inputData['categoryKey'] == 7 ||
                                          inputData['categoryKey'] == -1
                                      ? ''
                                      : selectTitle,
                                ),
                                SizedBox(
                                  height: 36.w,
                                ),
                                Text(
                                  localization.inquiryContent,
                                  style: TextStyle(
                                    color: CommonColors.black2b,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 20.w,
                                ),
                                TextFormField(
                                  maxLength: 50,
                                  decoration: commonInput(
                                    hintText: localization.enterTitle,
                                  ),
                                  style: commonInputText(),
                                  onChanged: (value) {
                                    setState(() {
                                      inputData['title'] = value;
                                      isBackStatus = true;
                                      if (value != '') {
                                        validatorList['title'] = false;
                                      } else {
                                        validatorList['title'] = true;
                                      }
                                    });
                                  },
                                  controller: titleController,
                                ),
                                SizedBox(
                                  height: 12.w,
                                ),
                                Stack(
                                  children: [
                                    CommonKeyboardAction(
                                      focusNode: textAreaNode,
                                      child: TextFormField(
                                        focusNode: textAreaNode,
                                        controller: contentController,
                                        maxLength: 2000,
                                        style: areaInputText(),
                                        decoration: areaInput(
                                          hintText: localization.enterContent,
                                        ),
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        minLines: 5,
                                        maxLines: 5,
                                        onChanged: (value) {
                                          setState(() {
                                            inputData['content'] = value;
                                            isBackStatus = true;
                                            if (value != '') {
                                              validatorList['content'] = false;
                                            } else {
                                              validatorList['content'] = true;
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      right: 10.w,
                                      bottom: 10.w,
                                      child: Text('$_currentLength/2,000',
                                          style: TextStyles.counter),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 36.w,
                                ),
                                Text(
                                  localization.attachment,
                                  style: TextStyle(
                                    color: CommonColors.black2b,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: 15.w,
                                ),
                                Row(
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: showFileAddModal,
                                        child: Container(
                                            padding: EdgeInsets.fromLTRB(
                                                20.w, 14.w, 20.w, 14.w),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              color: CommonColors.grayF7,
                                            ),
                                            child: fileInfoController
                                                    .text.isNotEmpty
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        flex: 8,
                                                        child: Text(
                                                          fileInfoController
                                                              .text,
                                                          style: TextStyle(
                                                            fontSize: 14.sp,
                                                            color: CommonColors
                                                                .gray4d,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ),
                                                      if (fileData['file'] !=
                                                          null)
                                                        Text(
                                                          '${ConvertService.kbToMb(fileData['file']['size']).toStringAsFixed(2)}MB',
                                                          style: TextStyle(
                                                            fontSize: 13.sp,
                                                            color: CommonColors
                                                                .grayB2,
                                                          ),
                                                        )
                                                    ],
                                                  )
                                                : Text(
                                                    localization.selectFile,
                                                    style: TextStyle(
                                                      fontSize: 14.sp,
                                                      color:
                                                          CommonColors.gray4d,
                                                    ),
                                                  )),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 16.w,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(6.w),
                                      width: 3.w,
                                      height: 3.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CommonColors.red,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        localization.maxFileSize100MB,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: CommonColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.all(6.w),
                                      width: 3.w,
                                      height: 3.w,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CommonColors.red,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        localization.inappropriateContentWarning,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: CommonColors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 35.w,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(16.w, 36.w, 0, 52.w),
                                  child: Row(
                                    children: [
                                      CircleCheck(
                                        size: 20,
                                        value: inputData['isInfoStatus'],
                                        isTerms: true,
                                        onChanged: (value) {
                                          updateTermsStatus(value,
                                              'isInfoStatus', true, false);
                                        },
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showTermsAlert();
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                localization.mandatory,
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5.sp,
                                                    color: CommonColors.red),
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                localization.privacyConsent,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: CommonColors.gray80,
                                                ),
                                              ),
                                              Image.asset(
                                                'assets/images/icon/iconArrowRightThin.png',
                                                width: 14.w,
                                                height: 14.w,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CommonButton(
                                  confirm: !validatorList['categoryKey'] &&
                                      !validatorList['title'] &&
                                      !validatorList['content'] &&
                                      !validatorList['isInfoStatus'],
                                  onPressed: () {
                                    if (!isLoading) {
                                      if (!validatorList['categoryKey'] &&
                                          !validatorList['title'] &&
                                          !validatorList['content'] &&
                                          !validatorList['isInfoStatus']) {
                                        createQna();
                                      }
                                    }
                                  },
                                  text: localization.submitInquiry,
                                )
                              ],
                            ),
                          )
                        : isLoading
                            ? const Loader()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        20.w, 16.w, 20.w, 8.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          localization.inquiryHistory,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                        Text(
                                          "총 $total건",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.gray80,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: boardList.isEmpty
                                        ? const CommonEmpty(
                                            text: localization.noInquiriesAvailable)
                                        : LazyLoadScrollView(
                                            onEndOfPage: _boardLoadMore,
                                            child: ListView.builder(
                                              padding: EdgeInsets.fromLTRB(
                                                  20.w,
                                                  0,
                                                  20.w,
                                                  CommonSize.commonBottom),
                                              itemCount: boardList.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return QnaList(
                                                  hasReply: boardList[index]
                                                          .boStatus ==
                                                      "DONE",
                                                  index: index,
                                                  onTap: () =>
                                                      showQnaDetailAlert(
                                                          boardList[index].key),
                                                  text: boardList[index].title,
                                                  date: DateFormat('yyyy.MM.dd')
                                                      .format(
                                                    DateTime.parse(
                                                        boardList[index]
                                                            .createdAt
                                                            .replaceAll(
                                                                "T", " ")),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) const Loader(),
        ],
      ),
    );
  }
}
