import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/service/auth_service.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/parent_agree_pdf_widget.dart';
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

class ParentAgreeDialogWidget extends ConsumerStatefulWidget {
  const ParentAgreeDialogWidget({
    super.key,
    required this.roomUuid,
    required this.messageUuid,
    required this.created,
    required this.signImg,
  });

  final String roomUuid;
  final String messageUuid;
  final String created;
  final String signImg;

  @override
  ConsumerState<ParentAgreeDialogWidget> createState() =>
      _ParentAgreeDialogWidgetState();
}

class _ParentAgreeDialogWidgetState
    extends ConsumerState<ParentAgreeDialogWidget> with Files {
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

  returnParentType(int value) {
    switch (value) {
      case 1:
        return '부';
      case 2:
        return '모';
      case 3:
        return '법정대리인';
      default:
        return '부';
    }
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

        // 이미지 캡처
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null) {
          Uint8List pngBytes = byteData.buffer.asUint8List();
          Map<String, dynamic> tempFilePath = await _saveTempFile(pngBytes);
          await _downloadFile(tempFilePath, '친권자 동의서', type);
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
      "name": '${detailData!.resignationDto.reName}친권자동의서.png'
    };
    return fileData;
  }

  Future<void> _downloadFile(dynamic file, String fileName, String type) async {
    var result =
        await fileChatFileUploadS3(file, 'parentAgree', widget.roomUuid, null);
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
        showDefaultToast('친권자 동의서가 저장되었습니다.');
      }
    } else {
      setState(() {
        isPdfDownload = false;
      });
      showDefaultToast('친권자 동의서 저장에 실패했습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    var detailData = ref.watch(contractDetailProvider);

    return isPdfDownload && detailData != null
        ? RepaintBoundary(
            key: _pdfKey,
            child: ParentAgreePdfWidget(
                detailData: detailData,
                signImg: widget.signImg,
                created: widget.created,
                setPdfDisplay: setPdfDisplay),
          )
        : Scaffold(
            appBar: const ModalAppbar(
              title: '친권자 동의서',
            ),
            body: isLoading || detailData == null
                ? const Loader()
                : Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(20.w, 16.w, 20.w,
                              CommonSize.commonBottom + 100.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
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
                                          '친권자 정보',
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
                                              detailData
                                                  .parentAgreeDto.paParentName,
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
                                            '생년월일',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              AuthService.convertBirthday(
                                                  detailData.parentAgreeDto
                                                      .paParentBirth),
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
                                                  detailData.parentAgreeDto
                                                      .paParentPhone),
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
                                            '근로자와의 관계',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              returnParentType(detailData
                                                  .parentAgreeDto.paType),
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
                                            '주소',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${detailData.parentAgreeDto.paParentAddress} ${detailData.parentAgreeDto.paParentAddressDetail}',
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
                                          '근로자 정보',
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
                                              detailData
                                                  .parentAgreeDto.paWorkerName,
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
                                            '생년월일',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              AuthService.convertBirthday(
                                                  detailData.parentAgreeDto
                                                      .paWorkerBirth),
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
                                                  detailData.parentAgreeDto
                                                      .paWorkerPhone),
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
                                            '주소',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${detailData.parentAgreeDto.paWorkerAddress} ${detailData.parentAgreeDto.paWorkerAddressDetail}',
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
                                          '사업장 정보',
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
                                            '회사명',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              detailData
                                                  .parentAgreeDto.paCompanyName,
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
                                            '전화번호',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              ConvertService.formatPhoneNumber(
                                                  detailData.parentAgreeDto
                                                      .paCompanyPhone),
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
                                            '주소',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.gray80,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              detailData.parentAgreeDto
                                                  .paCompanyAddress,
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
                                        '본인은 위 근로자  ${detailData.parentAgreeDto.paWorkerName} (이)가 위 사업장에서\n근로를 하는 것에 대하여 동의합니다.',
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '친권자: ${detailData.parentAgreeDto.paParentName}',
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
                                          ? 'assets/images/default/imgMisu.png'
                                          : detailData.caRepairStatus == 1
                                              ? 'assets/images/default/imgSuri.png'
                                              : 'assets/images/default/imgMisu.png'),
                                    ),
                                  ),
                                ],
                              ),
                              if (user!.memberType ==
                                      MemberTypeEnum.recruiter &&
                                  detailData.caRepairStatus == 0)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 20.w,
                                    ),
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
                                              onChanged: (value) {},
                                              readOnly: true,
                                              value: isAgree,
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
                                                    color: CommonColors.gray80),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20.w,
                                    ),
                                    Row(
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
                                  ],
                                ),
                              SizedBox(
                                height: 10.w,
                              ),
                              if (detailData.caRepairStatus == 1)
                                Row(
                                  children: [
                                    Expanded(
                                      child: BorderButton(
                                        onPressed: () async {
                                          await imgDownload('download');
                                        },
                                        text: '친권자 동의서 다운로드',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                      child: CommonButton(
                                        onPressed: () {
                                          imgDownload('email');
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
                        ),
                      ),
                    ],
                  ),
          );
  }
}
