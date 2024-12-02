import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/chat_send_email_dialog.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/resignation_pdf_widget.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_recruiter_bottom_sheet.dart';
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

class ResignationDialogWidget extends ConsumerStatefulWidget {
  const ResignationDialogWidget({
    super.key,
    required this.roomUuid,
    required this.messageUuid,
    required this.created,
    required this.signImg,
    required this.partnerName,
  });

  final String roomUuid;
  final String messageUuid;
  final String created;
  final String signImg;
  final String partnerName;

  @override
  ConsumerState<ResignationDialogWidget> createState() =>
      _ResignationDialogWidgetState();
}

class _ResignationDialogWidgetState
    extends ConsumerState<ResignationDialogWidget> with Files {
  bool isLoading = false;
  bool isAgree = false;
  bool isRunning = false;
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

  updateStatus(int status) async {
    if (isRunning) {
      return;
    }
    setState(() {
      isRunning = true;
    });
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .updateDocumentStatus(widget.messageUuid, widget.roomUuid, status);

    if (apiUploadResult.type == 1) {
      if (status == 1) {
        showDefaultToast('동의가 완료되었습니다.');
        chatUserService = ChatUserService(ref: ref);
        chatUserService.updateContractAgreeStatus(false, widget.roomUuid);
        context.pop();
        showEvaluationModal();
        setState(() {
          isRunning = false;
        });
      } else if (status == 2) {
        context.pop();
        showDefaultToast('거절이 완료되었습니다.');
        setState(() {
          isRunning = false;
        });
      }
    } else {
      setState(() {
        isRunning = false;
      });
      if (status == 1) {
        showDefaultToast('동의에 실패하였습니다.');
      } else if (status == 2) {
        showDefaultToast('거절에 실패하였습니다.');
      }
    }
  }

  void showEvaluationModal() {
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
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.5),
      isScrollControlled: true,
      // isDismissible:false,
      useSafeArea: true,
      // enableDrag: false,
      builder: (BuildContext context) {
        return EvaluationRecruiterBottomSheet(
          company: widget.partnerName,
          roomUuid: widget.roomUuid,
        );
      },
    );
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
          await _downloadFile(tempFilePath, '사직서',type);
        }
        setState(() {
          isPdfDownload = false;
        });
      });
    } catch (e) {
      setState(() {
        isPdfDownload = false;
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
      "name": '${detailData!.resignationDto.reName}사직서.png'
    };
    return fileData;
  }

  Future<void> _downloadFile(dynamic file, String fileName,String type) async {
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

        showDefaultToast('사직서가 저장되었습니다.');
      }
    } else {
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast('사직서 저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    var detailData = ref.watch(contractDetailProvider);
    return isPdfDownload && detailData != null
        ? RepaintBoundary(
            key: _pdfKey,
            child: ResignationPdfWidget(
                detailData: detailData,
                signImg: widget.signImg,
                created: widget.created,
                setPdfDisplay:setPdfDisplay
            ),
          )
        : Scaffold(
            appBar: const ModalAppbar(
              title: '사직서',
            ),
            body: isLoading || detailData == null
                ? const Loader()
                : Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                              20.w, 16.w, 20.w, CommonSize.commonBottom),
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
                                          detailData.resignationDto.reName,
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
                                        '입사일자',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AuthService.convertBirthday(detailData
                                              .resignationDto.reStartDate),
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
                                          detailData.resignationDto
                                                      .rePosition ==
                                                  ''
                                              ? '-'
                                              : detailData
                                                  .resignationDto.rePosition,
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
                                        '퇴사일자',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AuthService.convertBirthday(detailData
                                              .resignationDto
                                              .reResignationDate),
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
                                        '퇴사사유',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray80,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          detailData.resignationDto.reReason,
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
                                    '위의 사유로 사직서를\n 제출하오니 허락하여 주시기 바랍니다.',
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '신청자: ${detailData.resignationDto.reName}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: CommonColors.gray4d,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30.w,
                                        height: 30.w,
                                        child: ExtendedImgWidget(
                                          imgFit: BoxFit.contain,
                                          imgUrl: widget.signImg,
                                          imgWidth: 30.w,
                                          imgHeight: 30.w,
                                        ),
                                      ),
                                    ],
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
                                                value: isAgree,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isAgree = !isAgree;
                                                  });
                                                },
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
                                  SizedBox(
                                    height: 20.w,
                                  ),
                                  if (user.memberType ==
                                          MemberTypeEnum.recruiter &&
                                      detailData.caRepairStatus == 0)
                                    CommonButton(
                                      onPressed: () {
                                        if (isAgree) {
                                          updateStatus(1);
                                        }
                                      },
                                      fontSize: 15,
                                      text: '동의하기',
                                      confirm: isAgree,
                                    ),
                                  if (detailData.caRepairStatus == 1)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: BorderButton(
                                            onPressed: () async {
                                              await imgDownload('download');
                                            },
                                            text: '사직서 다운로드',
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
                                      ? 'assets/images/default/imgMi.png'
                                      : detailData.caRepairStatus == 1
                                          ? 'assets/images/default/imgDong.png'
                                          : 'assets/images/default/imgGeo.png'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
  }
}
