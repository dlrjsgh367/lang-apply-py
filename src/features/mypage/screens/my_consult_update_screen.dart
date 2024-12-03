import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/title_item.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:intl/intl.dart';

class MyConsultUpdateScreen extends ConsumerStatefulWidget {
  const MyConsultUpdateScreen({super.key, required this.idx});

  final String idx;

  @override
  ConsumerState<MyConsultUpdateScreen> createState() =>
      _MyConsultUpdateScreenState();
}

class _MyConsultUpdateScreenState extends ConsumerState<MyConsultUpdateScreen>
    with Alerts, Files {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final fileInfoController = TextEditingController();
  bool passwordVisible = true;
  Map<String, dynamic> fileData = {'file': null};
  Map<String, dynamic> inputData = {
    'title': '',
    'content': '',
  };
  Map<String, dynamic> validatorList = {
    'title': true,
    'content': true,
  };
  late BoardModel boardDetailData;
  bool isLoading = true;

  late Future<void> _allAsyncTasks;

  @override
  void initState() {
    super.initState();
    _allAsyncTasks = _getAllAsyncTasks();
    _allAsyncTasks.then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([getNoticeDetailData(widget.idx)]);
  }

  getNoticeDetailData(String idx) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getBoardDetailData(idx);
    if (result.type == 1) {
      setState(() {
        boardDetailData = result.data;
        setData();
      });
    } else if (result.status != 200) {
      showDefaultToast(localization.dataCommunicationFailed);
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  updateBoard() async {
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .updateConsult(widget.idx, inputData);
    if (result.status == 200 && result.type == 1) {
      if (fileData['file'] != null && boardDetailData.files.isNotEmpty &&
          boardDetailData.files[0] != fileData['file']) {
        apiFileDelete(boardDetailData.files[0].key);
        saveFile(fileData['file'], int.parse(widget.idx));
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: localization.278,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
                context.pop();
              },
              alertTitle: localization.notification,
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
              alertContent: localization.accountRestrictedByAdministrator,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
              },
              alertTitle: localization.notification,
            );
          },
        );
      } else {
        showDefaultToast(localization.152);
      }
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  showForbiddenAlert(keyword) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: "금칙어 '" + keyword + "'가 포함되어 노무 상담 수정이 불가능합니다.",
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
        });
  }

  showFileAddModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => getProfilePhoto('gallery'),
                child: const Text(localization.photoLibrary),
              ),
              GestureDetector(
                onTap: () => getProfilePhoto('camera'),
                child: const Text(localization.156),
              ),
              GestureDetector(
                onTap: () => getProfileFile(),
                child: const Text(localization.157),
              ),
            ],
          ),
        );
      },
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                fileData['file'] = value;
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
    if (file != null) {
      setState(() {
        fileData['file'] = file;
        fileInfoController.text = file["name"];
        context.pop();
      });
    }
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
            alertContent: localization.278,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              initData();
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

  backEvent() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.cancelWriting,
            alertContent: '페이지를 이동하시겠어요?\n이동시 작성된 내용은 저장되지 않아요',
            alertConfirm: localization.confirm,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  setData() {
    setState(() {
      inputData = {
        'title': boardDetailData.title,
        'content': boardDetailData.content,
      };
      validatorList = {
        'title': false,
        'content': false,
      };
      fileData['file'] =
          boardDetailData.files.isNotEmpty ? boardDetailData.files[0] : {};
      titleController.text = boardDetailData.title;
      contentController.text = boardDetailData.content;
      fileInfoController.text =
          boardDetailData.files.isNotEmpty ? fileData['file'].name : '';
    });
  }

  initData() {
    setState(() {
      inputData = {
        'title': '',
        'content': '',
      };
      validatorList = {
        'title': true,
        'content': true,
      };
      fileData['file'] = {};
      titleController.clear();
      contentController.clear();
      fileInfoController.clear();
    });
  }

  showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.cancelWriting,
          alertContent: '페이지를 이동하시겠어요?\n이동 시 작성된 내용은 저장되지 않아요.',
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
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
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        onHorizontalDragUpdate: (details) async {
          int sensitivity = 5;
          if (details.globalPosition.dx - details.delta.dx < 60 &&
              details.delta.dx > sensitivity) {
            showCancelDialog();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              appBar: CommonAppbar(
                title: localization.281,
                backFunc: backEvent,
              ),
              body: isLoading
                  ? const Loader()
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(20.w, 22.w, 20.w, 22.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.194,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.black2b,
                                  ),
                                ),
                                Text(
                                  DateFormat('yyyy. MM. dd').format(
                                      DateTime.parse(boardDetailData.createdAt)),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // const SliverToBoxAdapter(
                        //   child: Text("상담제목"),
                        // ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: TextFormField(
                              maxLength: 50,
                              decoration: commonInput(
                                hintText: localization.170,
                              ),
                              style: commonInputText(),
                              onChanged: (value) {
                                setState(() {
                                  inputData['title'] = value;
                                  if (value != '') {
                                    validatorList['title'] = false;
                                  } else {
                                    validatorList['title'] = true;
                                  }
                                });
                              },
                              controller: titleController,
                            ),
                          ),
                        ),
                        TitleItem(title: localization.195),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                TextFormField(
                                  maxLength: 2000,
                                  minLines: 5,
                                  maxLines: 5,
                                  style: commonInputText(),
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration: areaInput(
                                    hintText: localization.282,
                                  ),
                                  // const InputDecoration(
                                  //   border: OutlineInputBorder(),
                                  //
                                  // ),
                                  onChanged: (value) {
                                    setState(() {
                                      inputData['content'] = value;
                                      if (value != '') {
                                        validatorList['content'] = false;
                                      } else {
                                        validatorList['content'] = true;
                                      }
                                    });
                                  },
                                  controller: contentController,
                                ),
                                Positioned(
                                  right: 10.w,
                                  bottom: 10.w,
                                  child: Text(
                                    '${contentController.text.length}/2000',
                                    style: TextStyles.counter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        TitleItem(title: localization.172),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                color: CommonColors.grayF7,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/icon/iconPhoto.png',
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      fileInfoController.text,
                                      style: TextStyle(
                                        color: CommonColors.gray66,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        /*const TitleItem(title: localization.270),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.w),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.w),
                                color: CommonColors.grayF7,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    localization.197,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.gray80,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),*/
                        BottomPadding(),
                        const BottomPadding(
                          extra: 100,
                        ),
                      ],
                    ),
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBoard(context),
              child: CommonButton(
                onPressed: () {
                  if (!validatorList['title'] && !validatorList['content']) {
                    updateBoard();
                  }
                },
                text: localization.edit,
                fontSize: 15,
                confirm: !validatorList['title'] && !validatorList['content'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
