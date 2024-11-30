import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/mypage/enum/file_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/common_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AddFileWidget extends ConsumerStatefulWidget {
  const AddFileWidget({
    super.key,
    required this.fileData,
    required this.fileList,
    required this.setFileData,
    this.addDeleteFiles,
    this.isUpdate = false,
  });

  final Map<String, dynamic> fileData;
  final List fileList;
  final Function setFileData;
  final Function? addDeleteFiles;
  final bool isUpdate;

  @override
  ConsumerState<AddFileWidget> createState() => _AddFileWidgetState();
}

class _AddFileWidgetState extends ConsumerState<AddFileWidget> with Files {
  List<Map<String, dynamic>> fileList = [];
  List fileData = [];
  File file = File.empty;
  List deleteFileList = [];
  List<TextEditingController> fileNameControllers = [];

  final List<Map<String, dynamic>> categories = [
    {'category': 1, 'text': localization.portfolio},
    {'category': 2, 'text': localization.certification},
    {'category': 3, 'text': localization.document},
    {'category': 4, 'text': localization.resume},
    {'category': 5, 'text': localization.careerStatement},
    {'category': 6, 'text': localization.other},
    {'category': 7, 'text': localization.directInput},
  ];

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
                onTap: () => getAttachedPhoto('gallery'), text: localization.photoGallery),
            BottomSheetButton(
                onTap: () => getAttachedPhoto('camera'), text: localization.takePhoto),
            BottomSheetButton(onTap: () => getAttachedFile(), text: localization.fileSelect)
          ],
        );
      },
    );
  }

  void showFileType(int index) {
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
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ContentBottomSheet(
          contents: categories.map((category) {
            return BottomSheetButton(
              onTap: () {
                setState(() {
                  fileList[index]['mpfCategory'] = category['category'];
                });
                Navigator.pop(context); // 모달 닫기
              },
              text: category['text'],
            );
          }).toList(),
        );
      },
    );
  }

  addFileList(int seq) {
    fileList.add({
      'mpfSeq': seq,
      'mpfCategory': 0,
      'mpfDetail': '',
    });
  }

  void getAttachedPhoto(String type) async {
    var photo = await getPhoto(type);
    if (photo != null) {
      setState(() {
        fileData.add(photo);
        addFileList(fileData.length - 1);
        context.pop();
      });
    }
  }

  void getAttachedFile() async {
    var file = await getCustomFile();
    if (file != null) {
      setState(() {
        fileData.add(file);
        addFileList(fileData.length - 1);
        context.pop();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fileNameControllers = List.generate(5, (index) => TextEditingController());

    savePageLog();

    if (widget.fileData['file'] != null && widget.fileData['file'].isNotEmpty) {
      file = File.nonEmpty;
      fileData = [...widget.fileData['file']];
      initSetFileList();
    }
  }

  @override
  dispose() {
    for (var controller in fileNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  initSetFileList() {
    fileData = [...widget.fileData['file']];
    for (int i = 0; i < fileData.length; i++) {
      Map<String, dynamic> file = widget.fileList.firstWhere(
        (map) => map['mpfSeq'] == i,
        orElse: () => {
          'mpfSeq': i,
          'mpfCategory': 0,
          'mpfDetail': '',
        },
      );
      if (i < 5) {
        fileNameControllers[i].text = file['mpfDetail'];
        fileList.add(file);
      }
    }
  }

  String returnFileType(int index) {
    Map<String, dynamic> file = fileList.firstWhere(
      (map) => map['mpfSeq'] == index,
      orElse: () => {},
    );

    if (file.isNotEmpty) {
      Map<String, dynamic>? matchedCategory = categories.firstWhere(
        (category) => category['category'] == file['mpfCategory'],
        orElse: () => {'text': ''},
      );

      return matchedCategory['text'];
    }

    return '';
  }

  setDeleteFile(dynamic file, int index) {
    fileData.removeAt(index);
    fileList.removeAt(index);
    for (int i = index; i < fileList.length; i++) {
      fileList[i]['mpfSeq'] = fileList[i]['mpfSeq'] - 1;
    }
    if (widget.isUpdate && widget.fileData['file'] != null) {
      if (widget.fileData['file'].contains(file)) {
        deleteFileList.add(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 10;
        if (details.globalPosition.dx - details.delta.dx < 60 &&
            details.delta.dx > sensitivity) {
          // Right Swipe
          context.pop();
        }
      },
      child: Scaffold(
        appBar: const CommonAppbar(
          title: localization.attachment,
        ),
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              localization.finalStep,
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: CommonColors.black2b,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                                color: CommonColors.red02,
                                shape: BoxShape.circle),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/icon/iconFile.png',
                              width: 36.w,
                              height: 36.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 28.w),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        localization.usePhotosCertificatesPortfolioForPR,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.gray80,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 24.w),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: ProfileRadio(
                              onChanged: (value) {
                                setState(() {
                                  if (widget.isUpdate &&
                                      widget.fileData['file'] != null) {
                                    for (int i = 0; i < fileData.length; i++) {
                                      setDeleteFile(fileData[i], i);
                                    }
                                  }
                                  fileData = [];
                                  fileList = [];
                                  file = File.empty;
                                });
                              },
                              groupValue: file.value,
                              value: File.empty.value,
                              label: File.empty.label,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: ProfileRadio(
                              onChanged: (value) {
                                setState(() {
                                  if (fileData.length < 5) {
                                    file = File.nonEmpty;
                                    showFileAddModal();
                                  }
                                });
                              },
                              groupValue: file.value,
                              value: File.nonEmpty.value,
                              label: File.nonEmpty.label,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 6.w),
                    sliver: SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: () {
                          if (fileData.length < 5) {
                            if (file.value == 1) {
                              for (int i = 0; i < fileData.length; i++) {
                                if (widget.fileData['file'] != null) {
                                  if (widget.fileData['file']
                                      .contains(fileData[i])) {
                                    setDeleteFile(fileData[i], i);
                                  }
                                }
                              }
                              setState(() {
                                file = File.nonEmpty;
                                showFileAddModal();
                              });
                            } else if (file.value == 2) {
                              showFileAddModal();
                            }
                          }
                        },
                        child: Container(
                          height: 48.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.w),
                            color: fileData.length < 5
                                ? CommonColors.red02
                                : CommonColors.gray300,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                fileData.length < 5
                                    ? 'assets/images/icon/iconPlusRed.png'
                                    : 'assets/images/icon/iconPlusGray.png',
                                width: 18.w,
                                height: 18.w,
                              ),
                              SizedBox(
                                width: 6.w,
                              ),
                              Text(
                                localization.addAttachmentFile,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: fileList.length < 5
                                      ? CommonColors.red
                                      : CommonColors.grayB2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (fileData.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.w, 20.w, 0.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          childCount: fileData.length,
                          (context, index) {
                            var file = fileData[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SelectButton(
                                    onTap: () {
                                      showFileType(index);
                                    },
                                    text: returnFileType(index),
                                    hintText: localization.type,
                                  ),
                                  SizedBox(
                                    height: 6.w,
                                  ),
                                  if (fileList[index]['mpfCategory'] == 7)
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 6.w),
                                      child: TextFormField(
                                        controller: fileNameControllers[index],
                                        autocorrect: false,
                                        cursorColor: CommonColors.black,
                                        style: commonInputText(),
                                        maxLength: 20,
                                        decoration: commonInput(
                                          hintText: localization.enterTitle,
                                        ),
                                        minLines: 1,
                                        maxLines: 1,
                                        onChanged: (value) {
                                          fileList[index]['mpfDetail'] = value;
                                        },
                                        textInputAction: TextInputAction.next,
                                        onEditingComplete: () {
                                          FocusScope.of(context).nextFocus();
                                        },
                                      ),
                                    ),
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        20.w, 16.w, 20.w, 16.w),
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                              'assets/images/icon/iconFileBlack.png',
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                            SizedBox(
                                              width: 12.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                file is FileModel
                                                    ? file.name
                                                    : file['name'],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: CommonColors.gray4d,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  setDeleteFile(file, index);
                                                });
                                              },
                                              style: ButtonStyles.childBtn,
                                              child: Image.asset(
                                                'assets/images/icon/iconTrashCan.png',
                                                width: 20.w,
                                                height: 20.w,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8.w,
                                        ),
                                        Text(
                                          file is FileModel
                                              ? ProfileService.formatFileSize(
                                                  file.size)
                                              : ProfileService.formatFileSize(
                                                  file['size']),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w500,
                                            color: CommonColors.grayB2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
              child: CommonButton(
                fontSize: 15,
                confirm: (file == File.empty && fileList.isEmpty) ||
                    (file == File.nonEmpty && fileList.isNotEmpty),
                onPressed: () {
                  if ((file == File.empty && fileList.isEmpty) ||
                      (file == File.nonEmpty && fileList.isNotEmpty)) {
                    widget.setFileData(fileData, fileList, deleteFileList);
                    context.pop();
                  }
                },
                text: localization.enterData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
