import 'dart:async';
import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_agree_service.dart';
import 'package:chodan_flutter_app/features/contract/service/contract_template.dart';
import 'package:chodan_flutter_app/features/contract/service/pdf_api.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/construction_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/minor_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/normal_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/send_email_dialog.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/short_contract_dialog_widget.dart';
import 'package:chodan_flutter_app/features/contract/widgets/dialog/sign_dialog.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/models/chat_msg_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/appbar/modal_appbar.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/pdf_contract.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';

class ChatContractViewerWidget extends ConsumerStatefulWidget {
  const ChatContractViewerWidget({
    super.key,
    required this.uuid,
    required this.messageUuid,
    this.pdfUrl,
    this.chatUsers,
    required this.jaIdx,
    required this.jpIdx,
  });

  final String uuid;
  final String messageUuid;
  final String? pdfUrl;
  final Map<String, dynamic>? chatUsers;
  final int jaIdx;
  final int jpIdx;

  @override
  ConsumerState<ChatContractViewerWidget> createState() =>
      _ChatContractViewerWidgetState();
}

class _ChatContractViewerWidgetState
    extends ConsumerState<ChatContractViewerWidget> with Files {
  final int initialPage = 1;
  bool isLoading = false;
  Map<String, dynamic> params = {};
  ChatMsgModel? msgData;

  String errorMessage = '';
  String pdfUrl = '';
  File? pdfFile;
  File? savePdfFile;
  Uint8List? signImgData;
  File? signImgFile;
  String fileName = '';
  Map<String, dynamic> pdfFileMap = {};
  Map<String, dynamic> signFileMap = {};
  bool isAgree = false;
  bool isRunning = false;
  bool isEmptySign = true;
  bool isLastDoc = false;

  SignatureController signController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  getFileFromUrl(String url) async {
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/" + fileName + ".pdf");
      File urlFile = await file.writeAsBytes(bytes);


      setState((){

        savePdfFile = urlFile;
      });
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  Future<Uint8List> getFileData(String fileUrl) async {
    final response = await http.get(Uri.parse(fileUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load file');
    }
  }

  setFileName(ChatFileModel file) {
    String type = returnTypeContractTitle(file.caContractType);
    fileName =
        '${type}_${file.contractDetailDto.ccdEmployeeName}_${file.chatRecruiterDto.mcName}_${DateFormat('yyyyMMdd').format(DateTime.parse(file.caEditedDate))}.pdf';
  }

  static returnTypeContractTitle(String type) {
    switch (type) {
      case 'STANDARD':
        return '표준 근로 계약서';
      case 'SHORT':
        return '단기간 근로자 계약서';
      case 'YOUNG':
        return '연소 근로자 계약서';
      case 'CONSTRUCTION':
        return '건설일용 근로자 계약서';
      default:
        return '표준 근로 계약서';
    }
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

      setState(() {
        var detailData = ref.watch(contractDetailProvider)!;
        getLastChatFile(detailData.caIdx);
        params = ContractAgreeService.returnParams(
            detailData.caContractType, detailData.contractDetailDto);

        setFileName(detailData);
      });

      if (widget.pdfUrl == null) {
        await getMessageData();
      } else {
        setState(() {
          pdfUrl = widget.pdfUrl!;
        });
      }
      getFileFromUrl(pdfUrl);

      msgData =
          await chatUserService.getChatMsgData(widget.uuid, widget.messageUuid);
    } else if (result.status == 500) {
      if (!mounted) return null;
      showErrorAlert('알림', '수정 전 계약서는 서류 보관함에서 확인할 수 있습니다.');
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

  returnTitle(String type) {
    switch (type) {
      case 'STANDARD':
        return '표준 근로 계약서';
      case 'SHORT':
        return '단기간 근로자 계약서';
      case 'YOUNG':
        return '연소 근로자 계약서';
      case 'CONSTRUCTION':
        return '건설일용 근로자 계약서';
      default:
        return '표준 근로 계약서';
    }
  }

  getMessageData() async {
    var result = await ref
        .read(chatControllerProvider.notifier)
        .getMessageData(widget.uuid, widget.messageUuid);

    if (result.isNotEmpty) {
      setState(() {
        pdfUrl = result['files'][0]['fileUrl'];
      });
    }
  }

  updateStatus(int status) async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .updateDocumentStatus(widget.messageUuid, widget.uuid, status);

    if (apiUploadResult.type == 1) {
      if (status == 1) {
        chatUserService = ChatUserService(ref: ref);
        chatUserService.updateContractAgreeStatus(true, widget.uuid);

        sendMessage('계약서에 서명했습니다.');
        showDefaultToast('동의가 완료되었습니다.');
        await getChatFileDetail();
      } else if (status == 2) {
        sendMessage(' 계약서 서명을 거절했습니다.');
        showDefaultToast('거절이 완료되었습니다.');
      }
      setState(() {
        isRunning = false;
      });
      context.pop();
    } else {
      if (status == 1) {
        showDefaultToast('동의에 실패하였습니다.');
      } else if (status == 2) {
        showDefaultToast('거절에 실패하였습니다.');
      }
      setState(() {
        isRunning = false;
      });
      return false;
    }
  }

  showSignDialog() {
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
      isDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter bottomState) {
          return SignDialog(
            signFunc: () async {
              if (isRunning) {
                return;
              }
              setState(() {
                isRunning = true;
              });
              if (signController.isNotEmpty) {
                signImgData = await signController.toPngBytes();

                final Directory directory = await getTemporaryDirectory();

                String filePath =
                    '${directory.path}/signImage.png'; // 저장될 파일 경로

                File file = uint8ListToFile(signImgData!, filePath);

                setState(() {
                  signImgFile = file;
                });
                var detailData = ref.watch(contractDetailProvider);
                createPdf(detailData!.caContractType, params,
                    msgData!.file[1]['fileUrl'], detailData);
              }
            },
            signController: signController,
          );
        });
      },
    );
  }

  void requestStoragePermission() async {
    var detailData = ref.watch(contractDetailProvider);

    if (Platform.isIOS) {
      createPdf(detailData!.caContractType, params, msgData!.file[1]['fileUrl'],
          detailData);
      return;
    } else if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
        // openAppSettings();
      }
      if (status.isGranted) {
        createPdf(detailData!.caContractType, params,
            msgData!.file[1]['fileUrl'], detailData);
      } else {
        showDefaultToast('권한 허용이 필요합니다.');
      }
    }
  }

  createPdf(String type, dynamic params, String recruiterSignUrl,
      dynamic detailData) async {
    var chatUser = ref.watch(chatUserAuthProvider);

    final pdfFirstColumn = await ContractTemplate.returnNormalFistContract(
        params,
        chatUser,
        signImgData!,
        await fetchImage(recruiterSignUrl),
        true,
        type,
        detailData);

    final tempFile = await PdfApi.generateNormal(fileName, pdfFirstColumn);

    setState(() {
      pdfFile = tempFile;
    });

    await updateContract();
  }

  static Future<Uint8List> fetchImage(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  updateContract() async {
    var detailData = ref.watch(contractDetailProvider);

    await uploadSingImg();
    await uploadPdfFile(detailData!.caIdx);

    if (pdfFileMap.isNotEmpty && signFileMap.isNotEmpty) {
      await chatUserService.updateChatMsgData(
          widget.uuid, widget.messageUuid, pdfFileMap, signFileMap);
      await updateStatus(1);
    }
  }

  sendMessage(String msg) async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
    var userInfo = ref.watch(userProvider);
    if (userInfo != null && userInfo.blockType == 'WRITE') {
      showDefaultToast('메시지 전송이 제한되었습니다.');
      return;
    }

    if (widget.chatUsers != null && widget.chatUsers!.isNotEmpty) {
      await ref.read(chatControllerProvider.notifier).newMessage(
          widget.uuid, msg, chatUser!, widget.chatUsers!, partnerStatus);
    } else {
      showDefaultToast('메시지 전송에 실패했습니다.');
    }
  }

  File uint8ListToFile(Uint8List data, String filePath) {
    File file = File(filePath);
    file.writeAsBytesSync(data);
    return file;
  }

  uploadPdfFile(
    int key,
  ) async {
    var detailData = ref.watch(contractDetailProvider);
    var deleteResult = await s3ApiDelete(detailData!.file?['atIdx']);
    var result = await fileInfoUploadS3(pdfFile, 'ATTACHMENT_DOCUMENT', key);

    if (result != null && result != false) {
      setState(() {
        pdfFileMap = result;
      });
    } else {
      showDefaultToast('파일 업로드에 실패했습니다.');
    }
  }

  uploadSingImg() async {
    var result =
        await fileChatUploadS3(signImgFile, 'JOBSEEKER_SIGNATURE', widget.uuid);

    if (result != null && result != false) {
      setState(() {
        signFileMap = result;
      });
    } else {
      showDefaultToast('서명 이미지 업로드에 실패했습니다.');
    }
  }

  showSendEmailDialog() {
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
          return SendEmailDialog(
            updateAt:
                DateFormat('yyyy-MM-dd').format(msgData!.updated.toDate()),
            jpIdx: widget.jpIdx,
          );
        });
      },
    );
  }

  showUpdateDialog(String type) {
    var detailData = ref.watch(contractDetailProvider);

    showDialog<void>(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        switch (type) {
          case 'STANDARD':
            return NormalContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers!,
              msgKey: widget.messageUuid,
              detailData: detailData,
            );
          case 'SHORT':
            return ShortContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers!,
              msgKey: widget.messageUuid,
              detailData: detailData,
            );
          case 'YOUNG':
            return MinorContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers!,
              msgKey: widget.messageUuid,
              detailData: detailData,
            );
          case 'CONSTRUCTION':
            return ConstructionContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers!,
              msgKey: widget.messageUuid,
              detailData: detailData,
            );
          default:
            return NormalContractDialogWidget(
              uuid: widget.uuid,
              chatUsers: widget.chatUsers!,
              msgKey: widget.messageUuid,
              detailData: detailData,
            );
        }
      },
    );
  }

  getLastChatFile(int key) async {
    ApiResultModel result =
        await ref.read(chatControllerProvider.notifier).getLastChatFile(key);

    setState(() {
      isLastDoc = result.data;
    });
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      savePageLog();
      getChatFileDetail();
    });
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  void dispose() {
    signController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var user = ref.watch(userProvider);
    var detailData = ref.watch(contractDetailProvider);

    return Scaffold(
      appBar: ModalAppbar(
        title: detailData != null ? returnTitle(detailData.caContractType) : '',
      ),
      body: isLoading || detailData == null || savePdfFile == null
          ? const Loader()
          : Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.w, 8.w, 20.w, CommonSize.commonBottom),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if(savePdfFile != null)
                        PdfContract(savePdfFile: savePdfFile!,
                          detailData:detailData
                        ),
                        if (user!.memberType != MemberTypeEnum.recruiter &&
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
                                            color: CommonColors.gray80),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        SizedBox(
                          height: 10.w,
                        ),
                        if (isLastDoc)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (user.memberType == MemberTypeEnum.recruiter &&
                                  detailData.caRepairStatus == 0)
                                CommonButton(
                                  onPressed: () {
                                    showUpdateDialog(detailData.caContractType);
                                  },
                                  text: '수정하기',
                                  confirm: true,
                                  fontSize: 15,
                                ),
                              if (user.memberType != MemberTypeEnum.recruiter &&
                                  detailData.caRepairStatus == 0)
                                Row(
                                  children: [
                                    BorderButton(
                                      width: 96.w,
                                      backColor: isAgree
                                          ? Colors.black12
                                          : Colors.white,
                                      textColor: isAgree
                                          ? Colors.white
                                          : CommonColors.gray4d,
                                      onPressed: () {
                                        if (!isAgree) {
                                          updateStatus(2);
                                        }
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
                                            showSignDialog();
                                          }
                                        },
                                        fontSize: 15,
                                        text: '동의하기',
                                        confirm: isAgree,
                                      ),
                                    ),
                                  ],
                                ),
                              if (detailData.caRepairStatus == 1)
                                Row(
                                  children: [
                                    Expanded(
                                      child: BorderButton(
                                        onPressed: () {
                                          fileDownload(pdfUrl, fileName);
                                        },
                                        text: 'PDF 다운로드',
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8.w,
                                    ),
                                    Expanded(
                                      child: CommonButton(
                                        onPressed: () {
                                          showSendEmailDialog();
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
