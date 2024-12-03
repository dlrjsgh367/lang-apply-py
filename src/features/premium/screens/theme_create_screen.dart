import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/enum/premium_price_enum.dart';
import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';
import 'package:chodan_flutter_app/features/premium/controller/premium_controller.dart';
import 'package:chodan_flutter_app/features/premium/widgets/apply_title.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ThemeCreateScreen extends ConsumerStatefulWidget {
  const ThemeCreateScreen({super.key});

  @override
  ConsumerState<ThemeCreateScreen> createState() => _ThemeCreateScreenState();
}

class _ThemeCreateScreenState extends ConsumerState<ThemeCreateScreen>
    with Alerts, Files {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  final fileInfoController = TextEditingController();

  final contentFocus = FocusNode();

  String premiumCode = PremiumServiceEnum.theme.code;

  PremiumModel? premiumData;

  bool isLoading = true;

  Map<String, dynamic> fileData = {'file': null};

  Map<String, dynamic> inputData = {
    'categoryKey': 50,
    'title': '',
    'content': '',
    'isInfoStatus': false,
  };

  Map<String, dynamic> validatorList = {
    'title': true,
    'content': true,
    'isInfoStatus': true,
  };

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      inputData['isInfoStatus'] = value;
      validatorList['isInfoStatus'] = !value;
    });
  }

  initData() {
    setState(() {
      inputData = {
        'categoryKey': 50,
        'title': '',
        'content': '',
        'isInfoStatus': false,
      };
      // validatorList = {
      //   'categoryKey': true,
      //   'title': true,
      //   'content': true,
      //   'isInfoStatus': true,
      // };
      fileData = {'file': null};
      titleController.clear();
      contentController.clear();
      fileInfoController.clear();
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
      // setState(() {
      //   fileData['file'] = null;
      // });
      isLoading = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertContent: '문의가 접수되었습니다.\n상담사가 1~2일 후 연락드릴 예정입니다.',
            alertConfirm: localization.confirm,
            confirmFunc: () {
              initData();
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

  createQna() async {
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
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertContent: '문의가 접수되었습니다.\n상담사가 1~2일 후 연락드릴 예정입니다.',
              alertConfirm: localization.confirm,
              confirmFunc: () {
                initData();
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
            alertContent: "금칙어 '" + keyword + "'가 포함되어 테마관 등록이 불가능합니다.",
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
            },
          );
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
                text: localization.photoLibrary),
            BottomSheetButton(
                onTap: () {
                  getProfilePhoto('camera');
                },
                text: localization.156),
            BottomSheetButton(
                onTap: () {
                  getProfileFile();
                },
                text: localization.157),
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

  checkUser() {
    var user = ref.read(userProvider);
    switch (user?.memberType) {
      case MemberTypeEnum.jobSeeker:
        return 1;
      case MemberTypeEnum.recruiter:
        return 2;
      case null:
        return 1;
    }
  }

  late Future<void> _allAsyncTasks;

  getPremiumServiceTheme() async {
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
      getPremiumServiceTheme(),
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
          setState(() {
            isLoading = false;
          });
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: CommonAppbar(
          title: localization.brandThemeSection,
        ),
        body: !isLoading
            ? Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20.w, 4.w, 20.w, 20.w),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        localization.615,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.gray4d,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 4.w,
                                      ),
                                      Text(
                                        localization.616,
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
                                      localization.567,
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
                                      '${premiumData!.expireDay}일',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: CommonColors.gray80,
                                      ),
                                    ),
                                    Text(
                                      localization.597,
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
                            text: localization.617,
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              localization.618,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 8.w),
                          sliver: SliverToBoxAdapter(
                              child: TextFormField(
                            controller: titleController,
                            cursorColor: Colors.black,
                            decoration: commonInput(hintText: localization.619),
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
                            onEditingComplete: () {
                              if (titleController.text.isNotEmpty) {
                                FocusScope.of(context)
                                    .requestFocus(contentFocus);
                              } else {
                                FocusManager.instance.primaryFocus?.unfocus();
                              }
                            },
                          )),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 8.w),
                          sliver: SliverToBoxAdapter(
                            child: Stack(
                              children: [
                                TextFormField(
                                  cursorColor: Colors.black,
                                  controller: contentController,
                                  focusNode: contentFocus,
                                  maxLines: 3,
                                  minLines: 3,
                                  maxLength: 2000,
                                  textAlignVertical: TextAlignVertical.top,
                                  decoration:
                                      areaInput(hintText: localization.620),
                                  style: areaInputText(),
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
                                ),
                                Positioned(
                                    right: 10.w,
                                    bottom: 10.w,
                                    child: Text(
                                      '${contentController.text.length} / 2000',
                                      style: TextStyles.counter,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Flexible(
                                  child: GestureDetector(
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
                                                borderRadius:
                                                    BorderRadius.circular(8.w),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 4.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
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
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 8.w),
                          sliver: SliverToBoxAdapter(
                            child: Row(
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
                                    localization.621,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: CommonColors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(20.w, 48.w, 20.w, 0),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TermsItemWidget(
                                  isRequired: true,
                                  arrowNone: true,
                                  text: localization.622,
                                  status: inputData['isInfoStatus'],
                                  checkString: 'isInfoStatus',
                                  termsType: checkUser(),
                                  termsDataIdx: 50,
                                  updateStatus: updateTermsStatus,
                                  requireText: localization.176,
                                  // isDetail: true,
                                ),
                                SizedBox(
                                  height: 32.w,
                                ),
                                CommonButton(
                                  confirm: !validatorList['title'] &&
                                      !validatorList['content'] &&
                                      !validatorList['isInfoStatus'],
                                  onPressed: () {
                                    if (!validatorList['title'] &&
                                        !validatorList['content'] &&
                                        !validatorList['isInfoStatus']) {
                                      createQna();
                                    }
                                  },
                                  text: localization.178,
                                )
                              ],
                            ),
                          ),
                        ),
                        const BottomPadding(),
                      ],
                    ),
                  ),
                ],
              )
            : const Loader(),
      ),
    );
  }
}
