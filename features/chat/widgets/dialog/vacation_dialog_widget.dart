import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/vacation_pdf_widget.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'chat_send_email_dialog.dart';

class VacationDialogWidget extends ConsumerStatefulWidget {
  const VacationDialogWidget({
    super.key,
    required this.roomUuid,
    required this.messageUuid,
    required this.created,
  });

  final String roomUuid;
  final String messageUuid;
  final String created;

  @override
  ConsumerState<VacationDialogWidget> createState() =>
      _VacationDialogWidgetState();
}

class _VacationDialogWidgetState extends ConsumerState<VacationDialogWidget>
    with Files {
  bool isLoading = false;
  bool isAgree = false;
  bool isPdfDownload = false;
  bool isPdfDisplay = false;
  final GlobalKey _pdfKey = GlobalKey();

  @override
  void initState() {
    Future(() {
      getChatFileDetail();
    });
    super.initState();
  }

  getChatFileDetail() async {
    setState(() {
      isLoading = true;
    });
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getChatFileDetail(widget.messageUuid);

    if (result.type == 1) {
      ref
          .read(contractDetailProvider.notifier)
          .update((state) => ChatFileModel.fromJson(result.data));
    } else if (result.status != 200) {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    } else {
      if (!mounted) return null;
      showErrorAlert('알림', '데이터 통신에 실패했습니다.');
    }

    setState(() {
      isLoading = false;
    });
  }

  showErrorAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: '확인',
            alertCancel: '취소',
            onConfirm: () {
              context.pop(context);
              context.pop(context);
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  returnVacationType(int type) {
    switch (type) {
      case 1:
        return '연차';
      case 2:
        return '경조휴가';
      case 3:
        return '포상휴가';
      case 4:
        return '생리휴가';
      case 5:
        return '기타휴가';
      default:
        return '연차';
    }
  }

  updateStatus(int status) async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .updateDocumentStatus(widget.messageUuid, widget.roomUuid, status);

    if (apiUploadResult.type == 1) {
      if (status == 1) {
        showDefaultToast('동의가 완료되었습니다.');
      } else if (status == 2) {
        showDefaultToast('거절이 완료되었습니다.');
      }
      context.pop();
    } else {
      if (status == 1) {
        showDefaultToast('동의에 실패하였습니다.');
      } else if (status == 2) {
        showDefaultToast('거절에 실패하였습니다.');
      }
      return false;
    }
  }

  showSendEmailDialog(String url) {
    showModalBottomSheet<void>(
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
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomSate) {
          return ChatSendEmailDialog(url: url);
        });
      },
    );
  }

  Future<void> imgDownload(String type) async {
    try {
      if (isPdfDownload) {
        return;
      }
      setState(() {
        isPdfDownload = true;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _waitForPdfDisplay();

        if (_pdfKey.currentContext == null) {
          print("pdfKey의 currentContext가 null입니다.");
          return;
        }

        RenderRepaintBoundary? boundary = _pdfKey.currentContext!
            .findRenderObject() as RenderRepaintBoundary?;

        if (boundary == null) {
          print("RenderRepaintBoundary가 null입니다.");
          return;
        }

        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          Map<String, dynamic> tempFilePath = await _saveTempFile(pngBytes);
          await _downloadFile(tempFilePath, '휴가 신청서', type);
        }
        setState(() {
          isPdfDownload = false;
          isPdfDisplay = false;
        });
      });
    } catch (e) {
      setState(() {
        isPdfDownload = false;
        isPdfDisplay = false;
        showDefaultToast('이미지 다운로드에 실패하였습니다.');
      });
    }
  }

  Future<void> _waitForPdfDisplay() async {
    while (!isPdfDisplay) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  setPdfDisplay() {
    setState(() {
      isPdfDisplay = true;
    });
  }

  _saveTempFile(Uint8List imageBytes) async {
    var detailData = ref.watch(contractDetailProvider);
    final dir = await getApplicationDocumentsDirectory();
    final imageName =
        'captured_pdf_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File('${dir.path}/$imageName');
    await file.writeAsBytes(imageBytes);
    Map<String, dynamic> fileData = {
      "url": file.path,
      "size": 0,
      "name": '${detailData!.resignationDto.reName}휴가 신청서.png'
    };
    return fileData;
  }

  Future<void> _downloadFile(dynamic file, String fileName, String type) async {
    var result =
        await fileChatFileUploadS3(file, 'resume', widget.roomUuid, null);
    String date = DateFormat('yyMMddHHmmss').format(DateTime.now());
    if (result != null && result != false) {
      setState(() {
        isPdfDownload = false;
      });
      if (type == 'email') {
        showSendEmailDialog(result['fileUrl']);
      } else {
        String dir = (await getApplicationDocumentsDirectory()).path;
        await FlutterDownloader.enqueue(
          url: result['fileUrl'],
          savedDir: '$dir/',
          fileName: '${fileName}_$date.png',
          saveInPublicStorage: true,
        );
        showDefaultToast('휴가 신청서가 저장되었습니다.');
      }
    } else {
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast('휴가 신청서 저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    var detailData = ref.watch(contractDetailProvider);

    return isPdfDownload && detailData != null
        ? RepaintBoundary(
            key: _pdfKey,
            child: VacationPdfWidget(
                created: widget.created, detailData: detailData,
                setPdfDisplay:setPdfDisplay
            ))
        : Stack(
            children: [
              Scaffold(
                appBar: const ModalAppbar(
                  title: '휴가 신청서',
                ),
                body: isLoading || detailData == null
                    ? const Loader()
                    : SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w,
                              CommonSize.commonBottom + 100.w),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    height: 48.w,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.w,
                                            color: CommonColors.gray66),
                                      ),
                                    ),
                                    child: Text(
                                      '신청자 정보',
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.gray4d),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '이름',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detailData.vacationDto.vaWorkerName,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '연락처',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ConvertService.formatPhoneNumber(
                                              detailData
                                                  .vacationDto.vaWorkerPhone),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '소속',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detailData.vacationDto.vaDepartment ==
                                                  ''
                                              ? '-'
                                              : detailData
                                                  .vacationDto.vaDepartment,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '직위',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detailData.vacationDto.vaPosition ==
                                                  ''
                                              ? '-'
                                              : detailData
                                                  .vacationDto.vaPosition,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 24.w,
                                  ),
                                  Container(
                                    height: 48.w,
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.w,
                                            color: CommonColors.gray66),
                                      ),
                                    ),
                                    child: Text(
                                      '내용',
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: CommonColors.gray4d),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '휴가종류',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          returnVacationType(
                                              detailData.vacationDto.vaType),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '휴가기간',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${detailData.vacationDto.vaStartDate} ~ ${detailData.vacationDto.vaEndDate}',
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 12.w,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '휴가사유',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detailData.vacationDto.vaReason,
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 64.w,
                                  ),
                                  Text(
                                    '위의 사유로 휴가 신청서를\n 제출하오니 허락하여 주시기 바랍니다.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CommonColors.gray66,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.w,
                                  ),
                                  Text(
                                    widget.created,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: CommonColors.gray80,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 24.w,
                                  ),
                                  Text(
                                    '신청자: ${detailData.vacationDto.vaWorkerName}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(
                                      color: CommonColors.gray4d,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  if (user!.memberType ==
                                          MemberTypeEnum.recruiter &&
                                      detailData.caRepairStatus == 0)
                                    GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isAgree = !isAgree;
                                          });
                                        },
                                        child: ColoredBox(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              CircleCheck(
                                                onChanged: (value) {
                                                  setState(() {
                                                    isAgree = !isAgree;
                                                  });
                                                },
                                                value: isAgree,
                                                readOnly: true,
                                              ),
                                              SizedBox(
                                                width: 8.w,
                                              ),
                                              Text(
                                                '(필수)',
                                                style: TextStyle(
                                                  color: CommonColors.red,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  ' 내용에 이상이 없음을 확인하였습니다.',
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color:
                                                          CommonColors.gray80),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                ],
                              ),
                              Positioned(
                                left: 20.w,
                                right: 20.w,
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 60.w),
                                  child: Image.asset(detailData
                                              .caRepairStatus ==
                                          0
                                      ? 'assets/images/default/imgMisu.png'
                                      : detailData.caRepairStatus == 1
                                          ? 'assets/images/default/imgSuri.png'
                                          : 'assets/images/default/imgMisu.png'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              if (!isLoading &&
                  detailData != null &&
                  user?.memberType == MemberTypeEnum.recruiter &&
                  detailData.caRepairStatus == 0)
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: CommonSize.commonBottom,
                  child: Row(
                    children: [
                      BorderButton(
                        width: 96.w,
                        onPressed: () {
                          updateStatus(2);
                        },
                        text: '거절하기',
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                        child: CommonButton(
                          onPressed: () {
                            if (isAgree) {
                              updateStatus(1);
                            }
                          },
                          fontSize: 15,
                          text: '동의하기',
                          confirm: isAgree,
                        ),
                      ),
                    ],
                  ),
                ),
              if (detailData != null && detailData.caRepairStatus == 1)
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: CommonSize.commonBottom,
                  child: Row(
                    children: [
                      Expanded(
                        child: BorderButton(
                          onPressed: () async {
                            await imgDownload('download');
                          },
                          text: '휴가 신청서 다운로드',
                        ),
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                        child: CommonButton(
                          onPressed: () async {
                            await imgDownload('email');
                          },
                          text: '이메일로 전송',
                          confirm: true,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
            ],
          );
  }
}
