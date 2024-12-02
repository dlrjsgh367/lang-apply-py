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
      showDefaultToast('데이터 통신에 실패하였습니다.');
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
      showDefaultToast('데이터 통신에 실패하였습니다.');
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
              alertContent: '작성하신 문의가 성공적으로 등록되었습니다.',
              alertConfirm: '확인',
              confirmFunc: () {
                initData();
                setState(() {
                  activeTab = 1;
                  getBoardListData(1);
                });
                context.pop();
              },
              alertTitle: '안내',
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
              alertContent: '운영자에 의하여 작성이 제한된 회원입니다.',
              alertConfirm: '확인',
              confirmFunc: () {
                context.pop();
              },
              alertTitle: '알림',
            );
          },
        );
      } else {
        showDefaultToast('등록에 실패하였습니다.');
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
            alertTitle: '알림',
            alertContent: "금칙어 '" + keyword + "'가 포함되어 문의 등록이 불가능합니다.",
            alertConfirm: '확인',
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
            alertContent: '작성하신 문의가 성공적으로 등록되었습니다.',
            alertConfirm: '확인',
            confirmFunc: () {
              initData();
              context.pop();
              setTab(1);
            },
            alertTitle: '알림',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: '파일 업로드에 실패했습니다. 다시 시도해 주세요.',
            alertConfirm: '확인',
            confirmFunc: () {
              context.pop();
            },
            alertTitle: '알림',
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
                text: '사진 보관함'),
            BottomSheetButton(
                onTap: () {
                  getProfilePhoto('camera');
                },
                text: '사진 찍기'),
            BottomSheetButton(
                onTap: () {
                  getProfileFile();
                },
                text: '파일 선택'),
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
                  text: '삭제'),
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
              alertTitle: '작성 취소',
              alertContent: '페이지를 이동하시겠어요?\n이동 시 작성된 내용은 저장되지 않아요',
              alertConfirm: '확인',
              alertCancel: '취소',
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
                title: '고객센터',
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
                                        "문의하기 및 고객센터 이용안내",
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
                                              '서비스 이용 중 불편 사항 또는 궁금한 사항을 물어 보세요.',
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
                                              '평일 09:00~17:00까지 문의 하신 내용은 당일 답변 드립니다.',
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
                                              '17시 이후 문의하신 내용은 다음날 답변 드리고\n법정 공휴일과 같은 휴무일에 문의하신 내용은 휴무일 종료 이후 첫 근무일에 답변 드립니다.',
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
                                              '문의사항 증가시 답변 기간이 최대 2~3일(근무일 기준) 소요될 수 있습니다. ',
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
                                  "문의유형",
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
                                  hintText: '선택해주세요.',
                                  text: inputData['categoryKey'] == 7 ||
                                          inputData['categoryKey'] == -1
                                      ? ''
                                      : selectTitle,
                                ),
                                SizedBox(
                                  height: 36.w,
                                ),
                                Text(
                                  "문의내용",
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
                                    hintText: '제목을 입력해주세요.',
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
                                          hintText: '내용을 작성해주세요.',
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
                                  "첨부파일",
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
                                                    '파일 선택하기',
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
                                        '최대 100MB까지 첨부 가능합니다.',
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
                                        '상담과 무관한 내용이거나 음란 및 불법적인 내용은 통보 없이\n삭제될 수 있습니다.',
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
                                                '(필수)',
                                                style: TextStyle(
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5.sp,
                                                    color: CommonColors.red),
                                              ),
                                              SizedBox(width: 4.w),
                                              Text(
                                                '개인정보 수집 및 이용안내 동의',
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
                                  text: "문의 보내기",
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
                                          "문의 내역",
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
                                            text: '문의 내역이 없습니다.')
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
