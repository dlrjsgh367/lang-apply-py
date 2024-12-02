import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_media_detail_widget.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/qna_media_widget.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/features/menu/controller/menu_controller.dart';

import 'package:chodan_flutter_app/mixins/Files.dart';

class QnaDetailScreen extends ConsumerStatefulWidget {
  const QnaDetailScreen({super.key, required this.idx});

  final String idx;

  @override
  ConsumerState<QnaDetailScreen> createState() => _QnaDetailScreenState();
}

class _QnaDetailScreenState extends ConsumerState<QnaDetailScreen>
    with Alerts, Files {
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
    await Future.wait<void>([
      getNoticeDetailData(widget.idx),
      savePageLog(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  getNoticeDetailData(String idx) async {
    ApiResultModel result =
        await ref.read(menuControllerProvider.notifier).getBoardDetailData(idx);
    if (result.type == 1) {
      setState(() {
        boardDetailData = result.data;
      });
    } else if (result.status != 200) {
      showDefaultToast('데이터 통신에 실패하였습니다.');
    } else {
      if (!mounted) return null;
      showNetworkErrorAlert(context);
    }
  }

  @override
  void dispose() {
    _allAsyncTasks.whenComplete(() {});
    super.dispose();
  }

  showMediaDetailDialog(String mediaUrl, {isVideo = false}) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return QnaMediaWidget(
            mediaUrl: mediaUrl,
          );
        });
  }

  bool isImageFile(String url) {
    String fileName = url.split('/').last.toLowerCase();

    List<String> imageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    String fileExtension = fileName.split('.').last;

    return imageExtensions.contains(fileExtension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const ModalAppbar(
          title: '문의내역',
        ),
        body: isLoading
            ? const Loader()
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20.w, 20.w, 20.w, CommonSize.commonBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "문의내용",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('yyyy.MM.dd HH:mm').format(DateTime.parse(
                              boardDetailData.createdAt.replaceAll("T", " "))),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: CommonColors.gray80,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Divider(
                      height: 1.w,
                      color: CommonColors.grayF7,
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 86.w,
                          child: Text(
                            "유형",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(8.w, 2.w, 8.w, 2.w),
                          decoration: BoxDecoration(
                              color: CommonColors.red02,
                              borderRadius: BorderRadius.circular(6.w)),
                          child: Text(
                            boardDetailData.boardTypeName,
                            style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.red,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 36.w,
                    ),
                    Text(
                      "상담 제목",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CommonColors.black2b,
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                      ),
                      child: Text(
                        boardDetailData.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.black2b,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 36.w,
                    ),
                    Text(
                      "상담 내용",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CommonColors.black2b,
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12.w, 16.w, 12.w, 16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.w),
                        border: Border.all(
                          width: 1.w,
                          color: CommonColors.grayF2,
                        ),
                      ),
                      child: Text(
                        boardDetailData.content,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: CommonColors.black2b,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 36.w,
                    ),
                    Text(
                      "첨부파일",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: CommonColors.black2b,
                      ),
                    ),
                    SizedBox(
                      height: 20.w,
                    ),
                    Row(
                      children: [],
                    ),
                    boardDetailData.files.isNotEmpty &&
                            isImageFile(boardDetailData.files[0].url)
                        ? Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (boardDetailData.files.isNotEmpty) {
                                    showMediaDetailDialog(
                                        boardDetailData.files[0].url);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 120.w,
                                    height: 120.w,
                                    child: ExtendedImgWidget(
                                      imgUrl: boardDetailData.files[0].url,
                                      imgFit: BoxFit.cover,
                                      imgWidth: 120.w,
                                      imgHeight: 120.w,
                                    ),
                                  ),
                                ),
                              )
                              ],
                          )
                        : GestureDetector(
                            onTap: () {
                              if (boardDetailData.files.isNotEmpty) {
                                fileDownload(boardDetailData.files[0].url,
                                    boardDetailData.files[0].name);
                              }
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                              decoration: BoxDecoration(
                                color: CommonColors.grayF7,
                                borderRadius: BorderRadius.circular(8.w),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    flex: 8,
                                    child: Text(
                                      boardDetailData.files.isNotEmpty
                                          ? "${boardDetailData.files[0].name}"
                                          : '-',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.black2b,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (boardDetailData.files.isNotEmpty)
                                    Text(
                                      '${ConvertService.kbToMb(boardDetailData.files[0].size).toStringAsFixed(2)}MB',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: CommonColors.grayB2,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ),
                    if (boardDetailData.relatedResList != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: 36.w,
                          ),
                          Divider(
                            height: 1.w,
                            color: CommonColors.grayF7,
                          ),
                          SizedBox(
                            height: 36.w,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "문의 답변",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: CommonColors.black2b,
                                ),
                              ),
                              Text(
                                DateFormat('yyyy.MM.dd HH:mm').format(
                                    DateTime.parse(boardDetailData
                                        .relatedResList!.updatedAt
                                        .replaceAll("T", " "))),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: CommonColors.gray80,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          Container(
                            padding:
                                EdgeInsets.fromLTRB(20.w, 14.w, 20.w, 14.w),
                            decoration: BoxDecoration(
                              color: CommonColors.grayF7,
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: Text(
                              boardDetailData.boStatus == "DONE"
                                  ? boardDetailData.relatedResList!.content
                                  : '등록된 답변이 없습니다.',
                              textAlign: boardDetailData.boStatus == "DONE"
                                  ? TextAlign.left
                                  : TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 36.w,
                          ),
                          Text(
                            "첨부파일",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: CommonColors.black2b,
                            ),
                          ),
                          SizedBox(
                            height: 20.w,
                          ),
                          boardDetailData.relatedResList!.files.isNotEmpty &&
                                  isImageFile(boardDetailData
                                      .relatedResList!.files[0].url)
                              ? GestureDetector(
                                  onTap: () {
                                    if (boardDetailData
                                        .relatedResList!.files.isNotEmpty) {
                                      showMediaDetailDialog(boardDetailData
                                          .relatedResList!.files[0].url);
                                    }
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 120.w,
                                      height: 120.w,
                                      child: ExtendedImgWidget(
                                        imgUrl: boardDetailData
                                            .relatedResList!.files[0].url,
                                        imgFit: BoxFit.cover,
                                        imgWidth: 120.w,
                                        imgHeight: 120.w,
                                      ),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    if (boardDetailData
                                        .relatedResList!.files.isNotEmpty) {
                                      fileDownload(
                                          boardDetailData
                                              .relatedResList!.files[0].url,
                                          boardDetailData
                                              .relatedResList!.files[0].name);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(
                                        20.w, 14.w, 20.w, 14.w),
                                    decoration: BoxDecoration(
                                      color: CommonColors.grayF7,
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: Text(
                                      boardDetailData
                                              .relatedResList!.files.isNotEmpty
                                          ? "${boardDetailData.relatedResList!.files[0].name}"
                                          : '-',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.black2b,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                  ],
                ),
              ));
  }
}
