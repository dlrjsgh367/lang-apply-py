import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/features/mypage/enum/file_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/profile_radio.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/file_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/button/select_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class TutorialFileWidget extends ConsumerStatefulWidget {
  const TutorialFileWidget({
    super.key,
    required this.fileData,
    required this.fileList,
    required this.setData,
    required this.writeFunc,
    required this.onPress,
  });

  final Map<String, dynamic> fileData;
  final List fileList;
  final Function setData;
  final Function writeFunc;
  final Function onPress;

  @override
  ConsumerState<TutorialFileWidget> createState() => _TutorialFileWidgetState();
}

class _TutorialFileWidgetState extends ConsumerState<TutorialFileWidget>
    with Files, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List fileData = [];
  File file = File.empty;

  List<dynamic> deleteFiles = [];

  List<TextEditingController> fileNameControllers = [];
  List<Map<String, dynamic>> fileList = [];

  final List<Map<String, dynamic>> categories = [
    {'category': 1, 'text': '포트폴리오'},
    {'category': 2, 'text': '자격증'},
    {'category': 3, 'text': '증명서'},
    {'category': 4, 'text': '이력서'},
    {'category': 5, 'text': '경력기술서'},
    {'category': 6, 'text': '기타'},
    {'category': 7, 'text': '직접입력'},
  ];

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
                onTap: () => getAttachedPhoto('gallery'), text: '사진 보관함'),
            BottomSheetButton(
                onTap: () => getAttachedPhoto('camera'), text: '사진 찍기'),
            BottomSheetButton(onTap: () => getAttachedFile(), text: '파일 선택')
          ],
        );
      },
    );
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
    if (widget.fileData['file'] != null) {
      file = File.nonEmpty;
      fileData = [...widget.fileData['file']];
      initSetFileList();
    }
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
      fileNameControllers[i].text = file['mpfDetail'];
      fileList.add(file);
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
    if (widget.fileData['file'] != null) {
      if (widget.fileData['file'].contains(file)) {
        deleteFiles.add(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 8.w),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '파일을 첨부해주세요.',
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
                            color: CommonColors.red02, shape: BoxShape.circle),
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
                    '사진, 자격증, 포트폴리오 등으로 내 자신을 PR해요!',
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
                              for (int i = 0; i < fileData.length; i++) {
                                setDeleteFile(fileData[i], i);
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
                            setDeleteFile(fileData[i], i);
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
                            '첨부파일 추가하기',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: fileData.length < 5
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
                                hintText: '타입',
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
                                      hintText: '제목을 입력해주세요',
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
                                margin: EdgeInsets.only(bottom: 8.w),
                                padding:
                                    EdgeInsets.fromLTRB(20.w, 16.w, 20.w, 16.w),
                                decoration: BoxDecoration(
                                  color: CommonColors.grayF7,
                                  borderRadius: BorderRadius.circular(12.w),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/icon/iconFileBlack.png',
                                          width: 20.w,
                                          height: 20.w,
                                        ),
                                        SizedBox(width: 12.w),
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
                                      ProfileService.formatFileSize(
                                          file is FileModel
                                              ? file.size
                                              : file['size']),
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
          bottom: CommonSize.commonBoard(context),
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
                  confirm: (file == File.empty && fileData.isEmpty) ||
                      (file == File.nonEmpty && fileData.isNotEmpty),
                  onPressed: () async {
                    if ((file == File.empty && fileData.isEmpty) ||
                        (file == File.nonEmpty && fileData.isNotEmpty)) {
                      if (deleteFiles.isNotEmpty) {
                        await customRunS3ApiDeleteFiles(deleteFiles);
                      }
                      await widget.setData(fileData, fileList, deleteFiles);
                      await widget.writeFunc(null, widget.fileData['file']);
                    }
                  },
                  text: '다음',
                  fontSize: 15,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
