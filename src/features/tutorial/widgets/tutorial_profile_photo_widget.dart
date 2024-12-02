import 'dart:io';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialProfilePhotoWidget extends ConsumerStatefulWidget {
  const TutorialProfilePhotoWidget({
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
  ConsumerState<TutorialProfilePhotoWidget> createState() =>
      _TutorialProfilePhotoWidgetState();
}

class _TutorialProfilePhotoWidgetState
    extends ConsumerState<TutorialProfilePhotoWidget>
    with Files, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic> selectedProfilePhoto = {
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
                getProfilePhoto('gallery');
              },
              text: '사진 보관함',
            ),
            BottomSheetButton(
              onTap: () {
                getProfilePhoto('camera');
              },
              text: '사진 촬영',
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
                text: '삭제',
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

  void saveFile(dynamic file, int key) async {
    List fileInfo = [
      {
        'fileType': 'PROFILE_IMAGE',
        'files': [file]
      },
    ];
    var result = await runS3FileUpload(fileInfo, key);

    if (result == true) {
      setState(() {
        if (mounted) {
          widget.onPress();
        }
      });
    } else {
      if (mounted) {
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

    if (widget.data['file'] != null) {
      selectedProfilePhoto['file'] = widget.data['file'];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(children: [
      SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: CustomScrollView(
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
                        '사진을 등록하면 일자리 제안 받을 확률이 올라가요!',
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
                    GestureDetector(
                      onTap: () {
                        if (selectedProfilePhoto['file'] != null &&
                            selectedProfilePhoto['file'] is FileModel) {
                          deleteFiles.add(widget.data['file']);
                        }
                        showPhotoBottomSheet();
                      },
                      child: Container(
                          clipBehavior: Clip.hardEdge,
                          width: CommonSize.vw - 40.w,
                          height: (CommonSize.vw - 40.w) / 360 * 244,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.w),
                            color: CommonColors.white,
                            border: Border.all(
                              width: 1.w,
                              color: CommonColors.red02,
                            ),
                          ),
                          child: selectedProfilePhoto['file']
                                  is FileModel // 등록 되었던 경우,
                              ? ExtendedImgWidget(
                                  imgUrl: widget.data['file'].url,
                                  imgFit: BoxFit.cover)
                              : selectedProfilePhoto['file'] !=
                                      null // 등록 되지 않았을 경우,
                                  ? Image.file(
                                      File(selectedProfilePhoto['file']['url']),
                                      fit: BoxFit.cover)
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
                                          '여기를 눌러 사진 업로드',
                                          style: TextStyle(
                                            color: CommonColors.grayD9,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    )),
                    ),
                    SizedBox(
                      height: 77.w,
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
                            '사진 등록 Guide',
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
                              '사진 등록이 필수 사항은 아니지만 사진을 등록하면 사장님들에게 신뢰감을 줄 수 있습니다.',
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
                              '5MB 이내 gif, jpg, jpeg, png 파일만 등록할 수 있습니다.',
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
                              '개인정보 보호를 위해 개인정보가 포함된 이미지는 가려주세요. (발견시 사전 동의 없이 삭제 될 수 있습니다.)',
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
                              '단정한 모습의 사진을 권장합니다.',
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
                              '정면에서 얼굴을 알아볼 수 있는 선명한 사진을 권장합니다.',
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
      ),
      Positioned(
        left: 20.w,
        right: 20.w,
        bottom: CommonSize.commonBottom,
        child: Row(
          children: [
            BorderButton(
              onPressed: () {
                widget.onPress();
              },
              text: '건너뛰기',
              width: 96.w,
            ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: CommonButton(
                onPressed: () async {
                  if (selectedProfilePhoto['file'] != null) {
                    if (deleteFiles.isNotEmpty) {
                      await customRunS3ApiDeleteFiles(deleteFiles);
                    }
                    await widget.setData('file', selectedProfilePhoto['file']);
                    await widget.writeFunc(widget.data['file'], null);
                  }
                },
                text: '다음',
                fontSize: 15,
                confirm: selectedProfilePhoto['file'] != null,
              ),
            )
          ],
        ),
      ),
    ]);
  }
}
