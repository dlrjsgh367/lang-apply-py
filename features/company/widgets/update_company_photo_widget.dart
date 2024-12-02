import 'dart:io';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class UpdateCompanyPhotoWidget extends ConsumerStatefulWidget {
  const UpdateCompanyPhotoWidget({
    super.key,
    required this.data,
  });

  final CompanyModel data;

  @override
  ConsumerState<UpdateCompanyPhotoWidget> createState() =>
      _UpdateCompanyPhotoWidgetState();
}

class _UpdateCompanyPhotoWidgetState
    extends ConsumerState<UpdateCompanyPhotoWidget> with Files {
  Map<String, dynamic> companyPhotoData = {
    'file': null,
  };

  List<dynamic> deleteFiles = [];

  showPhotoBottomSheet() {
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
                getCompanyPhoto('gallery');
              },
              text: localization.photoLibrary,
            ),
            BottomSheetButton(
              onTap: () {
                getCompanyPhoto('camera');
              },
              text: localization.takePhoto,
            ),
            if (companyPhotoData['file'] != null)
              BottomSheetButton(
                isRed: true,
                last: true,
                onTap: () {
                  setState(() {
                    companyPhotoData['file'] = null;
                  });
                  context.pop();
                },
                text: localization.delete,
              ),
          ],
        );
      },
    );
  }

  void getCompanyPhoto(String type) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        companyPhotoData['file'] = photo;
      });
      if (mounted) {
        context.pop();
      }
    }
  }

  customRunS3ApiDeleteFiles(List<dynamic> deleteFiles, {int index = 0}) {
    return Future<void>(() {
      List<dynamic> deleteFileIdx = [];
      for (var item in deleteFiles) {
        if (item is FileModel) {
          deleteFileIdx.add(item.key);
        }
      }
      return runS3ApiDelete(deleteFileIdx, 0);
    });
  }

  void saveFile(dynamic file, int key) async {
    List fileInfo = [
      {
        'fileType': 'COMPANY_IMAGES',
        'files': [file]
      },
    ];
    var result = await runS3FileUpload(fileInfo, key);

    if (result == true) {
      setState(() {
        companyPhotoData['file'] = null;

        if (mounted) {
          context.pop();
          showDefaultToast(localization.editCompleted);
        }
      });
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertConfirmDialog(
              alertTitle: localization.notification,
              alertContent: localization.fileUploadFailedRetry,
              alertConfirm: localization.confirm,
              confirmFunc: () {
                context.pop();
              },
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.data.files[0].key != 0) {
      companyPhotoData['file'] = widget.data.files[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppbar(
        title: localization.companyProfilePhoto,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding:
                EdgeInsets.fromLTRB(0.w, 20.w, 0.w, CommonSize.commonBottom),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Container(
                      height: 48.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        color: CommonColors.red02,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        localization.photoBoostsJobApplications,
                        style: TextStyle(
                          color: CommonColors.red,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24.w,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: GestureDetector(
                      onTap: () {
                        if (companyPhotoData['file'] != null &&
                            companyPhotoData['file'] is FileModel) {
                          deleteFiles.add(companyPhotoData['file']);
                        }
                        showPhotoBottomSheet();
                      },
                      child: companyPhotoData['file'] is FileModel // 등록 되었던 경우,
                          ? Container(
                              clipBehavior: Clip.hardEdge,
                              height: (CommonSize.vw - 40.w) / 360 * 244,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: ExtendedImgWidget(
                                imgUrl: widget.data.files[0].url,
                                imgFit: BoxFit.cover,
                                imgWidth: CommonSize.vw,
                                imgHeight: CommonSize.vh,
                              ),
                            )
                          : companyPhotoData['file'] != null // 등록 되지 않았을 경우,
                              ? Container(
                                  clipBehavior: Clip.hardEdge,
                                  height: (CommonSize.vw - 40.w) / 360 * 244,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.w),
                                  ),
                                  child: Image.file(
                                    File(companyPhotoData['file']['url']),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  clipBehavior: Clip.hardEdge,
                                  height: (CommonSize.vw - 40.w) / 360 * 244,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.w),
                                    color: CommonColors.white,
                                    border: Border.all(
                                      width: 1.w,
                                      color: CommonColors.red02,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/icon/iconCamera.png',
                                        width: 36.w,
                                        height: 36.w,
                                      ),
                                      SizedBox(
                                        height: 4.w,
                                      ),
                                      Text(
                                        localization.registerPhoto,
                                        style: TextStyle(
                                          color: CommonColors.grayD9,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 55.w, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0),
                              height: 28.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(500.w),
                                color: CommonColors.red02,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${localization.photoRegistration} Guide',
                                style: TextStyle(
                                  color: CommonColors.red,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 26.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 12.w),
                            Image.asset(
                              'assets/images/icon/IconDoubleCheck.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                localization.photoOptionalButIncreasesTrust,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 12.w),
                            Image.asset(
                              'assets/images/icon/IconDoubleCheck.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                               localization.uploadFilesUnder5MB,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 12.w),
                            Image.asset(
                              'assets/images/icon/IconDoubleCheck.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                localization.uploadWorkplaceOrLogoPhotos,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 12.w),
                            Image.asset(
                              'assets/images/icon/IconDoubleCheck.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                localization.recommendClearPhotos,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28.w),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 12.w),
                            Image.asset(
                              'assets/images/icon/IconDoubleCheck.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                localization.maskPersonalInfoInPhotos,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14.sp,
                                  color: CommonColors.black2b,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 40.w),
                        CommonButton(
                          fontSize: 15,
                          confirm: companyPhotoData['file'] != null,
                          onPressed: () async {
                            if (deleteFiles.isNotEmpty) {
                              await customRunS3ApiDeleteFiles(deleteFiles);
                            }

                            if (companyPhotoData['file'] != null) {
                              saveFile(
                                  companyPhotoData['file'], widget.data.key);
                            }
                          },
                          text: localization.edit,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
