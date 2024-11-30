import 'dart:io';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddProfilePhotoWidget extends ConsumerStatefulWidget {
  const AddProfilePhotoWidget({
    super.key,
    required this.profilePhotoData,
    this.addDeleteFiles,
    this.isCreate = false,
  });

  final Map<String, dynamic> profilePhotoData;
  final Function? addDeleteFiles;
  final bool isCreate;

  @override
  ConsumerState<AddProfilePhotoWidget> createState() =>
      _AddProfilePhotoWidgetState();
}

class _AddProfilePhotoWidgetState extends ConsumerState<AddProfilePhotoWidget>
    with Files {
  Map<String, dynamic> selectedProfilePhoto = {
    'file': null,
  };

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
                getProfilePhoto('gallery');
              },
              text: localization.photoGallery,
            ),
            BottomSheetButton(
              onTap: () {
                getProfilePhoto('camera');
              },
              text: localization.takePhoto,
            ),
            if (selectedProfilePhoto['file'] != null)
              BottomSheetButton(
                isRed: true,
                last: true,
                onTap: () {
                  setState(() {
                    selectedProfilePhoto['file'] = null;
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

  void getProfilePhoto(String type) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        selectedProfilePhoto['file'] = photo;
      });
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    savePageLog();

    if (widget.isCreate && widget.profilePhotoData.isNotEmpty) {
      selectedProfilePhoto = widget.profilePhotoData;
    } else {
      selectedProfilePhoto['file'] = widget.profilePhotoData['file'];
    }
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 5;

        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      child: Scaffold(
        appBar: CommonAppbar(
          backFunc: () {
            if (selectedProfilePhoto['file'] == null) {
              // context.pop(selectedProfilePhoto['file']);
              context.pop(null);
            } else {
              context.pop();
            }
          },
          title: localization.profilePhotoUpload,
        ),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          height: 48.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: CommonColors.red02,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            localization.uploadPhotoIncreasesJobProposalChances,
                            style: TextStyle(
                              color: CommonColors.red,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24.w,
                        ),
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (selectedProfilePhoto['file'] != null &&
                                    selectedProfilePhoto['file'] is FileModel) {
                                  widget.addDeleteFiles!(
                                      selectedProfilePhoto['file']);
                                }
                                showPhotoBottomSheet();
                              },
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                width: CommonSize.vw - 40.w,
                                height: CommonSize.vw - 40.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.w),
                                  color: CommonColors.white,
                                  border: Border.all(
                                    width: 1.w,
                                    color: CommonColors.red02,
                                  ),
                                ),
                                // 프로필 등록
                                child: widget.isCreate
                                    ? widget.profilePhotoData['file'] !=
                                            null // 등록 되었던 경우,
                                        ? Image.file(
                                            File(selectedProfilePhoto['file']
                                                ['url']),
                                            fit: BoxFit.cover)
                                        : Column(
                                            // 등록 되지 않았을 경우,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
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
                                                localization.clickHereToUploadPhoto,
                                                style: TextStyle(
                                                  color: CommonColors.grayD9,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          )
                                    // 프로필 수정
                                    : selectedProfilePhoto['file']
                                            is FileModel // 등록 되었던 경우,
                                        ? ExtendedImgWidget(
                                            imgUrl: widget
                                                .profilePhotoData['file'].url,
                                            imgFit: BoxFit.cover,
                                          )
                                        : selectedProfilePhoto['file'] !=
                                                null // 등록 되지 않았을 경우,
                                            ? Image.file(
                                                File(
                                                    selectedProfilePhoto['file']
                                                        ['url']),
                                                fit: BoxFit.cover,
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
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
                                                    localization.clickHereToUploadPhoto,
                                                    style: TextStyle(
                                                      color:
                                                          CommonColors.grayD9,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 55.w,
                        ),
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
                                localization.photoUploadGuide,
                                style: TextStyle(
                                  color: CommonColors.red,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 14.w, 12.w, 14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/icon/iconGuide.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  localization.photoUploadNotMandatoryButRecommended,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.black2b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 14.w, 12.w, 14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/icon/iconGuide.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  localization.allowedFileFormatsGifJpgPngUnder5MB,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.black2b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 14.w, 12.w, 14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/icon/iconGuide.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  localization.avoidPhotosWithPersonalInformation,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.black2b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 14.w, 12.w, 14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/icon/iconGuide.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  localization.recommendNeatAppearancePhotos,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.black2b),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(12.w, 14.w, 12.w, 14.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/icon/iconGuide.png',
                                width: 20.w,
                                height: 20.w,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  localization.recommendClearFrontFacePhotos,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.black2b),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const BottomPadding(
                  extra: 100,
                ),
              ],
            ),
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: CommonSize.commonBottom,
              child: Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      confirm: selectedProfilePhoto['file'] != null,
                      onPressed: () {
                        if (selectedProfilePhoto['file'] != null) {
                          context.pop(selectedProfilePhoto['file']);
                        }
                      },
                      text: localization.uploadJobPostPhoto,
                      fontSize: 15,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
