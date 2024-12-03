import 'dart:io';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialCompanyPhotoWidget extends ConsumerStatefulWidget {
  const TutorialCompanyPhotoWidget({
    super.key,
    required this.data,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> data;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialCompanyPhotoWidget> createState() =>
      _TutorialCompanyPhotoWidgetState();
}

class _TutorialCompanyPhotoWidgetState
    extends ConsumerState<TutorialCompanyPhotoWidget>
    with Files, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> selectedCompanyPhoto = {
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
            if (selectedCompanyPhoto['file'] != null)
              BottomSheetButton(
                isRed: true,
                last: true,
                onTap: () {
                  setState(() {
                    selectedCompanyPhoto['file'] = null;
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
        selectedCompanyPhoto['file'] = photo;
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

  @override
  void initState() {
    super.initState();

    if (widget.data['file'][0].key != 0) {
      selectedCompanyPhoto['file'] = widget.data['file'][0];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      Scaffold(
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
                          if (selectedCompanyPhoto['file'] != null &&
                              selectedCompanyPhoto['file'] is FileModel) {
                            deleteFiles.add(widget.data['file']);
                          }
                          showPhotoBottomSheet();
                        },
                        // child: SizedBox(),
                        child: selectedCompanyPhoto['file'] is FileModel
                            ? Container(
                                clipBehavior: Clip.hardEdge,
                                height: (CommonSize.vw - 40.w) / 4 * 3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.w),
                                  color: CommonColors.white,
                                  border: Border.all(
                                    width: 1.w,
                                    color: CommonColors.red02,
                                  ),
                                ),
                                child: // 등록 되었던 경우,
                                    ExtendedImgWidget(
                                  imgUrl: selectedCompanyPhoto['file'].url,
                                  imgFit: BoxFit.cover,
                                ),
                              )
                            : selectedCompanyPhoto['file'] !=
                                    null // 등록 되지 않았을 경우
                                ? Container(
                                    clipBehavior: Clip.hardEdge,
                                    height: (CommonSize.vw - 40.w) / 4 * 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    child: Image.file(
                                      File(selectedCompanyPhoto['file']['url']),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    clipBehavior: Clip.hardEdge,
                                    height: (CommonSize.vw - 40.w) / 4 * 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                      color: CommonColors.white,
                                      border: Border.all(
                                        width: 1.w,
                                        color: CommonColors.red02,
                                      ),
                                    ),
                                    child: Column(
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
                    SizedBox(
                      height: 55.w,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
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
                                  localization.42,
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
                                  '회사 로고 또는 회사를대표하는 실내·외 풍경을 권장합니다.',
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
                        ],
                      ),
                    )
                  ],
                ),
              ),
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
        child: Row(
          children: [
            BorderButton(
              onPressed: () {
                widget.onPress();
              },
              text: localization.755,
              width: 96.w,
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: CommonButton(
                onPressed: () async {
                  if (selectedCompanyPhoto['file'] != null) {
                    if (deleteFiles.isNotEmpty) {
                      await customRunS3ApiDeleteFiles(deleteFiles);
                    }
                    widget.setData('file', selectedCompanyPhoto['file']);
                    widget.writeFunc(widget.data['file']);
                  }
                },
                text: localization.next,
                fontSize: 15,
                confirm: selectedCompanyPhoto['file'] != null,
              ),
            )
          ],
        ),
      ),
    ]);
  }
}
