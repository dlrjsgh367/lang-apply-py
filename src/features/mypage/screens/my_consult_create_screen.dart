import 'dart:io';

import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/title_item.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/password_input_style.dart';

class MyConsultCreateScreen extends ConsumerStatefulWidget {
  const MyConsultCreateScreen({super.key});

  @override
  ConsumerState<MyConsultCreateScreen> createState() =>
      _MyConsultCreateScreenState();
}

class _MyConsultCreateScreenState extends ConsumerState<MyConsultCreateScreen>
    with Alerts, Files {
  FocusNode textAreaNode = FocusNode();
  GlobalKey textAreaKey = GlobalKey();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final fileInfoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool passwordVisible = true;
  bool isRunning = false;

  Map<String, dynamic> fileData = {'file': null};
  Map<String, dynamic> inputData = {
    'title': '',
    'content': '',
    'hiddenStatus': false,
    'password': ''
  };
  Map<String, dynamic> validatorList = {
    'title': true,
    'content': true,
    'password': true,
  };

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  createBoard() async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });
    var user = ref.watch(userProvider);
    int memberType = user?.memberType == MemberTypeEnum.jobSeeker ? 6 : 5;
    ApiResultModel result = await ref
        .read(menuControllerProvider.notifier)
        .createConsult(inputData, memberType);
    setState(() {
      isRunning = false;
    });
    if (result.status == 200 && result.type == 1) {
      if (fileData['file'] != null) {
        saveFile(fileData['file'], result.data);
      } else {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertConfirmDialog(
                alertContent: localization.254,
                alertConfirm: localization.confirm,
                confirmFunc: () {
                  isRunning = true;
                  initData();
                  context.pop();
                  context.pop();
                },
                alertTitle: localization.notification,
              );
            });
      }
    } else {
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
        if (!mounted) return null;
        showDefaultToast(localization.255);
      }
    }
  }

  showForbiddenAlert(keyword) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: "금칙어 '" + keyword + "'가 포함되어 노무 상담 등록이 불가능합니다.",
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
                onTap: () => getAttachedPhoto('gallery'), text: localization.photoLibrary),
            BottomSheetButton(
                onTap: () => getAttachedPhoto('camera'), text: localization.156),
            BottomSheetButton(onTap: () => getAttachedFile(), text: localization.157),
          ],
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

  void getAttachedPhoto(String type) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        fileData['file'] = photo;
        fileInfoController.text = photo["name"];
        context.pop();
      });
    }
  }

  void getAttachedFile() async {
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
            alertContent: localization.254,
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
            alertContent: '페이지를 이동하시겠어요?\n이동 시 작성된 내용은 저장되지 않아요',
            alertConfirm: localization.confirm,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  initData() {
    setState(() {
      inputData = {
        'title': '',
        'content': '',
        'hiddenStatus': false,
        'password': ''
      };
      validatorList = {'title': true, 'content': true, 'password': true};
      fileData = {'file': null};
      titleController.clear();
      contentController.clear();
      fileInfoController.clear();
      _passwordController.clear();
    });
  }

  bool setConfirm() {
    if (!validatorList['title'] && !validatorList['content']) {
      if (inputData['hiddenStatus']) {
        if (!validatorList['password']) {
          return true;
        }
      } else {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();
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
            showCancelDialog();
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
                title: localization.258,
                backFunc: () {
                  showCancelDialog();
                },
              ),
              body: CustomScrollView(
                slivers: [
                  const TitleItem(title: localization.194),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: TextFormField(
                        maxLength: 50,
                        cursorColor: Colors.black,
                        style: commonInputText(),
                        decoration: commonInput(
                          hintText: localization.170,
                        ),
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
                        textInputAction: TextInputAction.next,
                        onEditingComplete: () {
                          FocusScope.of(context).nextFocus();
                        },
                      ),
                    ),
                  ),
                  const TitleItem(title: localization.195),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: Stack(
                        children: [
                        CommonKeyboardAction(
                        focusNode: textAreaNode,
                        child:
                        TextFormField(

                            onTap: () {
                              ScrollCenter(textAreaKey);
                            },
                            key: textAreaKey,
                            focusNode: textAreaNode,
                            textInputAction: TextInputAction.newline,
                            keyboardType: TextInputType.multiline,

                            maxLength: 2000,
                            maxLines: 3,
                            minLines: 3,
                            cursorColor: CommonColors.black,
                            style: areaInputText(),
                            decoration: areaInput(hintText: localization.259),
                            textAlignVertical: TextAlignVertical.top,
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
                        ),
                          Positioned(
                              right: 10.w,
                              bottom: 10.w,
                              child: Text(
                                '${contentController.text.length} / 2,000',
                                style: TextStyles.counter,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const TitleItem(title: localization.172),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: showFileAddModal,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.w),
                              child: fileInfoController.text.isNotEmpty
                                  ? SizedBox(
                                      height: 80.w,
                                      width: 80.w,
                                      child: Image.file(
                                        File(fileData['file']['url']),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      height: 80.w,
                                      width: 80.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8.w),
                                        color: CommonColors.grayF7,
                                      ),
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/images/icon/iconPlus.png',
                                        width: 16.w,
                                        height: 16.w,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                                  localization.174,
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
                        ],
                      ),
                    ),
                  ),
                  const TitleItem(title: localization.260),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.w),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            setState(() {
                              inputData['hiddenStatus'] =
                                  !inputData['hiddenStatus'];

                              validatorList['password'] = true;
                              inputData['password'] = '';
                            });
                          });
                        },
                        child: Container(
                          height: 48.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.w),
                              color: CommonColors.grayF7),
                          child: Row(
                            children: [
                              SizedBox(width: 12.w),
                              Container(
                                width: 16.w,
                                height: 16.w,
                                decoration: inputData['hiddenStatus']
                                    ? BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CommonColors.red02,
                                        border: Border.all(
                                          width: 3.w,
                                          color: CommonColors.red,
                                        ),
                                      )
                                    : BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 1.w,
                                          color: CommonColors.grayB2,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Text(
                                localization.261,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                " 비밀글",
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.red,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                localization.263,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (inputData['hiddenStatus'])
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.w),
                      sliver: SliverToBoxAdapter(
                          child: TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: passwordVisible,
                        cursorColor: CommonColors.black,
                        style: commonInputText(),
                        maxLength: null,
                        decoration: passwordInput(
                          hintText: localization.264,
                          isVisible: !passwordVisible,
                          hasString: _passwordController.text.isNotEmpty,
                          hasClear: _passwordController.text.isNotEmpty,
                          iconFunc: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                          isAllow: _passwordController.text.isNotEmpty,
                        ),
                        minLines: 1,
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            inputData['password'] = value;
                            if (value != '') {
                              validatorList['password'] = false;
                            } else {
                              validatorList['password'] = true;
                            }
                          });
                        },
                      )),
                    ),
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
                fontSize: 15,
                onPressed: () {
                  if (!isRunning) {
                    if (!validatorList['title'] && !validatorList['content']) {
                      if (inputData['hiddenStatus']) {
                        if (!validatorList['password']) {
                          createBoard();
                        }
                      } else {
                        createBoard();
                      }
                    }
                  }
                },
                text: localization.265,
                confirm: setConfirm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
