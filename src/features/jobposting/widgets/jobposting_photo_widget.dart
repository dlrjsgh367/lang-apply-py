import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class JobpostingPhotoWidget extends ConsumerStatefulWidget {
  const JobpostingPhotoWidget(
      {required this.initialPhotoList,
      required this.setSelectedJobpostingPhoto,
      this.addDeleteFiles,
      super.key});

  final List<dynamic> initialPhotoList;
  final Function setSelectedJobpostingPhoto;

  final Function? addDeleteFiles;

  @override
  ConsumerState<JobpostingPhotoWidget> createState() =>
      _JobpostingPhotoWidgetState();
}

class _JobpostingPhotoWidgetState extends ConsumerState<JobpostingPhotoWidget>
    with Files {
  bool isConfirm = false;
  List<Map<String, dynamic>> selectedJobpostingPhoto = [];

  @override
  void initState() {
    savePageLog();
    selectedJobpostingPhoto = [...widget.initialPhotoList];

    confirm();
    super.initState();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  void getJobpostingPhoto(String type, {int? photoIndex}) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        if (photoIndex != null) {
          selectedJobpostingPhoto[photoIndex] = photo;
        } else {
          selectedJobpostingPhoto.add(photo);
        }
        context.pop();
        confirm();
      });
    }
  }

  showErrorAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: '안내',
            alertContent: '공고 사진은 최대 3장까지 등록할 수 있습니다.',
            alertConfirm: '확인',
            confirmFunc: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  showPhotoBottomSheet(dynamic item, {int? photoIndex}) {
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
                  if (selectedJobpostingPhoto.length < 3) {
                    if (photoIndex != null) {
                      getJobpostingPhoto('gallery', photoIndex: photoIndex);
                    } else {
                      getJobpostingPhoto('gallery');
                    }
                  } else {
                    showErrorAlert();
                  }
                },
                text: '사진 보관함'),
            BottomSheetButton(
                onTap: () {
                  if (selectedJobpostingPhoto.length < 3) {
                    if (photoIndex != null) {
                      getJobpostingPhoto('camera', photoIndex: photoIndex);
                    } else {
                      getJobpostingPhoto('camera');
                    }
                  } else {
                    showErrorAlert();
                  }
                },
                text: '사진 촬영'),
            if (photoIndex != null)
              BottomSheetButton(
                  isRed: true,
                  last: true,
                  onTap: () {
                    setState(() {
                      selectedJobpostingPhoto.removeAt(photoIndex);
                      if (item != null && widget.addDeleteFiles != null) {
                        widget.addDeleteFiles!(item);
                      }
                    });
                    context.pop();
                  },
                  text: '삭제'),
          ],
        );
      },
    );
  }

  confirm() {
    setState(() {
      if (selectedJobpostingPhoto.isNotEmpty) {
        isConfirm = true;
      } else {
        isConfirm = false;
      }
    });
  }

  int activeIndex = 0;

  void setSwiper(data) {
    setState(() {
      activeIndex = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalLength = selectedJobpostingPhoto.length < 3
        ? selectedJobpostingPhoto.length + 1
        : selectedJobpostingPhoto.length;
    return GestureDetector(
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 15;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      child: Scaffold(
        appBar: const CommonAppbar(
          title: '공고 사진',
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 24.w),
              sliver: SliverToBoxAdapter(
                child: Container(
                  height: 48.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.w),
                    color: CommonColors.red02,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '공고 사진은 최소 1장 이상 등록해주세요!',
                    style: TextStyle(
                      color: CommonColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: selectedJobpostingPhoto.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: (CommonSize.vw * 0.9166 - 10.w) / 360 * 244 +
                              20.w,
                          child: Swiper(
                            scrollDirection: Axis.horizontal,
                            onIndexChanged: (value) {
                              setSwiper(value);
                            },
                            itemCount: totalLength,
                            viewportFraction: 0.9166,
                            scale: 1,
                            loop: false,
                            outer: true,
                            itemBuilder: (context, index) {
                              if (index == selectedJobpostingPhoto.length &&
                                  selectedJobpostingPhoto.length < 3) {
                                return Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.w, 0, 5.w, 20.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      showPhotoBottomSheet(null);
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.w),
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
                                            '사진 등록 하기',
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
                                );
                              } else {
                                var item = selectedJobpostingPhoto[index];
                                return Padding(
                                  padding:
                                      EdgeInsets.fromLTRB(5.w, 0, 5.w, 20.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      showPhotoBottomSheet(
                                        item,
                                        photoIndex: index,
                                      );
                                    },
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.w)),
                                      child: item['atIdx'] != null
                                          ? Image.network(
                                              item['url'],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                item['url'],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < totalLength; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.fromLTRB(2.w, 0, 2.w, 0),
                                width: activeIndex == i ? 20.w : 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(500.w),
                                  color: activeIndex == i
                                      ? CommonColors.black2b
                                      : CommonColors.grayF2,
                                ),
                              ),
                          ],
                        ),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: GestureDetector(
                        onTap: () {
                          showPhotoBottomSheet(null);
                        },
                        child: Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.w),
                              color: CommonColors.white,
                              border: Border.all(
                                width: 1.w,
                                color: CommonColors.red02,
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: 360 / 244,
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
                                    '사진 등록 하기',
                                    style: TextStyle(
                                      color: CommonColors.grayD9,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  20.w, 55.w, 20.w, CommonSize.commonBottom),
              sliver: SliverToBoxAdapter(
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
                            '사진 등록 Guide',
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
                            '사진 등록이 필수 사항은 아니지만 사진을 등록하면 알바님들에게 신뢰감을 줄 수 있습니다.',
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
                            '5MB 이내 gif, jpg, jpeg, png 파일만 등록할 수 있습니다.',
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
                            '근무지의 실내 외 사진 또는 근무지 간판이나 로고를 올려주세요.',
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
                            '선명하고 깨끗한 사진을 권장합니다.',
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
                            '개인정보 보호를 위해 개인정보가 포함된 이미지는 가려주세요. (발견 시 사전 동의 없이 삭제 될 수 있습니다.)',
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
                      confirm: isConfirm,
                      onPressed: () {
                        if (isConfirm) {
                          widget.setSelectedJobpostingPhoto(
                              selectedJobpostingPhoto);
                          context.pop();
                        }
                      },
                      fontSize: 15,
                      text: '사진 등록하기',
                    ),
                  ],
                ),
              ),
            ),
            // SliverToBoxAdapter(
            //   child: SizedBox(
            //       height: 100,
            //       child: selectedJobpostingPhoto.isNotEmpty
            //           ? Swiper(
            //               scrollDirection: Axis.horizontal,
            //               // axisDirection: AxisDirection.left,
            //               itemCount: selectedJobpostingPhoto.length,
            //               viewportFraction: 1,
            //               scale: 1,
            //               loop: false,
            //               outer: true,
            //               itemBuilder: (context, index) {
            //                 var item = selectedJobpostingPhoto[index];
            //                 return GestureDetector(
            //                     onTap: () {
            //                       showPhotoBottomSheet(photoIndex: index);
            //                     },
            //                     child: item['atIdx'] != null
            //                         ? SizedBox(
            //                             width: CommonSize.vw,
            //                             height: CommonSize.vh,
            //                             child: Image.network(item['url']),
            //                           )
            //                         : Image.file(
            //                             File(
            //                               item['url'],
            //                             ),
            //                             width: CommonSize.vw,
            //                             height: CommonSize.vw,
            //                           ));
            //               },
            //               // pagination: SwiperPagination(
            //               //   alignment: Alignment.bottomLeft,
            //               //   builder: DotSwiperPaginationBuilder(
            //               //     activeColor: CommonColors.black,
            //               //     color: CommonColors.red,
            //               //     activeSize: 6.0,
            //               //     size: 6.0,
            //               //     space: 5.0,
            //               //   ),
            //               // ),
            //             )
            //           : GestureDetector(
            //               onTap: () {
            //                 // showErrorAlert();
            //                 showPhotoBottomSheet();
            //               },
            //               child: Container(
            //                 color: CommonColors.red,
            //                 width: CommonSize.vw,
            //                 height: 300,
            //               ),
            //             )),
            // ),
          ],
        ),
      ),
    );
  }
}
