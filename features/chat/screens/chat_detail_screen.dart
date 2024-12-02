import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/enum/member_type_enum.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_bottom_menu_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_contract_viewer_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_input_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_media_detail_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_msg_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_recruiter_tutorial.dart';
import 'package:chodan_flutter_app/features/chat/widgets/chat_seeker_tutorial.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/attendance_select_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/document_select_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/document_storage_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/employment_contract_select_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/extension_chat_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/media_select_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/parent_agree_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/report_reason_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/resignation_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/salary_create_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/salary_dialog_widget.dart';
import 'package:chodan_flutter_app/features/chat/widgets/dialog/vacation_dialog_widget.dart';
import 'package:chodan_flutter_app/features/commute/widgets/calendar_widget.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_jobseeker_chat_bottom_sheet.dart';
import 'package:chodan_flutter_app/features/evaluate/widgets/evaluation_recruiter_bottom_sheet.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_msg_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:chodan_flutter_app/widgets/appbar/chat_appbar.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/content_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/appbar_button.dart';
import 'package:chodan_flutter_app/widgets/button/bottom_sheet_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/chat/date_checker.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';

import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key, required this.uuid});

  final String uuid;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with Files, Alerts {
  bool showSeekerChatTutorial = true;
  bool showRecruiterChatTutorial = true;

  bool isLoading = false;
  bool isAllLoading = false;
  bool isUploadLoading = false;
  int page = 1;
  bool onMenu = false;
  bool onMsgMenu = false;

  Map<String, dynamic> chatUsers = {};
  bool isRefresh = false;
  final ScrollController _scrollController = ScrollController();
  List imageList = [];
  var fileData;

  final TextEditingController _chatController = TextEditingController();
  String enteredText = '';
  String chatValue = '';

  ScreenshotController screenshotController = ScreenshotController();
  var capturedChatImg;
  late Timer captureTimer;
  Map<String, dynamic> reportReason = {};
  ChatMsgModel? selectMsg;
  bool isCaptured = false;

  bool isSelectDelete = false;
  List deleteList = [];

  String backgroundColor = '';
  bool isSending = false;

  // -------------- 기본 메시지  전송
  sendMessage() async {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
    var userInfo = ref.watch(userProvider);
    if (userInfo != null && userInfo.blockType == 'WRITE') {
      showDefaultToast(localization.messageSendingRestricted);
      return;
    }
    if (chatUsers.isNotEmpty) {
      if (isSending) {
        return;
      }
      setState(() {
        isSending = true;
      });

      await ref.read(chatControllerProvider.notifier).newMessage(
          widget.uuid, chatValue, chatUser!, chatUsers, partnerStatus);
      setState(() {
        chatValue = '';
        enteredText = '';
        _chatController.clear();
      });
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          isSending = false;
        });
      });
    } else {
      showDefaultToast(localization.messageSendFailed);
    }
  }

  setMsgValue(String value) {
    setState(() {
      chatValue = value;
      enteredText = _chatController.text.trim();
    });
  }

  // -------------- 메시지 삭제
  deleteMessage() {
    if (chatUsers.isNotEmpty) {
      for (var msgId in deleteList) {
        ref
            .read(chatControllerProvider.notifier)
            .deleteMessage(widget.uuid, msgId, chatUsers);
      }

      setState(() {
        deleteList = [];
        isSelectDelete = false;
      });

      context.pop(context);
    } else {
      showDefaultToast(localization.messageSendFailed);
    }
  }

  // -------------- 대화방 나가기
  outChatRoom(String userUuid) {
    if (chatUsers.isNotEmpty) {
      ref
          .read(chatControllerProvider.notifier)
          .outChatRoom(widget.uuid, userUuid);
      context.pop(context);
    } else {
      showDefaultToast(localization.messageSendFailed);
    }
  }

  // -------------- 서류 및 근태 전송
  sendDocument(String type, int? docKey, int? docState) {
    var chatUser = ref.watch(chatUserAuthProvider);
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
    DateTime now = DateTime.now();

    if (chatUsers.isNotEmpty) {
      ref.read(chatControllerProvider.notifier).newDocument(
            widget.uuid,
            chatUser!,
            chatUsers,
            partnerStatus,
            [],
            type,
            now,
          );
    } else {
      showDefaultToast(localization.messageSendFailed);
    }
  }

  // -------------- 파일 및 이미지 전송
  // api/attachment 등록
  sendFile(dynamic files, String type) async {
    var msgList = ref.watch(msgListProvider);
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    if (chatUsers.isNotEmpty) {
      Map<String, dynamic> params = {
        'chRoomUuid': widget.uuid,
        'caType': type == 'file' ? 1 : 2,
        'caMessageKey': msgList[0].id,
        'caContractType': type == 'file' ? 'ETC' : 'GALLERY',
        'caReceiverMemberKey': roomInfo!.partnerKey,
      };

      var apiUploadResult = await ref
          .read(chatControllerProvider.notifier)
          .createChatMedia(params);

      if (apiUploadResult.type == 1) {
        if (type == 'file') {
          await saveFile(files, apiUploadResult.data, type, files['name']);
        } else if (type == 'video') {
          await saveVideo(files, apiUploadResult.data, type, files.name);
        } else {
          await saveImage(files, apiUploadResult.data, type, files['name']);
        }

        if (type == 'video') {
          await apiFileVideoUpload(
              files, 'ATTACHMENT_GALLERY', apiUploadResult.data);
        } else {
          await apiFileUpload(
              files,
              type == 'file' ? 'ATTACHMENT_DOCUMENT' : 'ATTACHMENT_GALLERY',
              apiUploadResult.data);
        }

        setState(() {
          isUploadLoading = false;
        });
      } else {
        setState(() {
          isUploadLoading = false;
        });
        showDefaultToast(localization.messageSendFailed);
      }
    } else {
      setState(() {
        isUploadLoading = false;
      });
      showDefaultToast(localization.messageSendFailed);
    }
  }

  // -------------- 파일 가져오기
  void getFiles() async {
    setState(() {
      isUploadLoading = true;
    });
    Map<String, dynamic> data = await getFile();

    setState(() {
      fileData = data;
    });

    if (fileData != null && fileData.isNotEmpty) {
      sendFile(data, 'file');
    } else {
      setState(() {
        isUploadLoading = false;
      });
    }
  }

  saveFile(dynamic image, int idx, String type, String fileName) async {
    var result = await fileChatFileUploadS3(
        fileData, 'ATTACHMENT_DOCUMENT', idx, fileName);

    if (result != null && result != false) {
      var chatUser = ref.watch(chatUserAuthProvider);
      var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
      var msgId = await ref.read(chatControllerProvider.notifier).newFile(
          widget.uuid, chatUser!, chatUsers, partnerStatus, [result], type);

      await updateContract(msgId, idx);
    } else {
      showDefaultToast(localization.fileUploadFailed);
    }
  }

  // -------------- 이미지 가져오기
  void getImages(String type) async {
    setState(() {
      isUploadLoading = true;
    });
    setState(() {
      imageList = [];
    });

    if (type == 'camera') {
      imageList.add(await getPhoto('camera'));
    } else if (type == 'multiple') {
      imageList = await getImageMultiple();
    }
    if (imageList.isNotEmpty) {
      for (var data in imageList) {
        sendFile(data, 'image');
      }
    }

    setState(() {
      isUploadLoading = false;
    });
  }

  // S3 업로드
  saveImage(dynamic image, int idx, String type, String fileName) async {
    var result =
        await fileChatImgUploadS3(image, 'ATTACHMENT_GALLERY', idx, fileName);

    if (result != null && result != false) {
      var chatUser = ref.watch(chatUserAuthProvider);
      var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
      var msgId = await ref.read(chatControllerProvider.notifier).newFile(
          widget.uuid, chatUser!, chatUsers, partnerStatus, [result], type);

      await updateContract(msgId, idx);
    } else {
      showDefaultToast(localization.fileUploadFailed);
    }
  }

  saveVideo(dynamic video, int idx, String type, String fileName) async {
    var result = await minioUpload(video, 'ATTACHMENT_GALLERY', idx, fileName);

    if (result != false && result != null) {
      var chatUser = ref.watch(chatUserAuthProvider);
      var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
      var msgId = await ref.read(chatControllerProvider.notifier).newFile(
          widget.uuid, chatUser!, chatUsers, partnerStatus, [result], type);

      await updateContract(msgId, idx);
    } else {
      showDefaultToast(localization.fileUploadFailed);
    }
  }

  updateContract(String msgKey, int caIdx) async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .updateChatMsgUuid(msgKey, caIdx);

    if (apiUploadResult.type == 1) {
      print(localization.transferCompleted);
    } else {
      showDefaultToast(localization.fileTransferFailed);
      return false;
    }
  }

  // -------------- 비디오 가져오기
  void getVideos() async {
    setState(() {
      isUploadLoading = true;
    });

    var data = await getVideo('gallery');

    setState(() {
      fileData = data;
    });

    if (fileData != null) {
      sendFile(data, 'video');
    } else {
      setState(() {
        isUploadLoading = false;
      });
    }
  }

  // -------------- 채팅 UUID 가져오기
  getChatUuid() async {
    chatUserService = ChatUserService(ref: ref);
    var chatUser = ref.watch(chatUserAuthProvider);

    var result = await ref
        .read(chatControllerProvider.notifier)
        .getChatUuid(widget.uuid, chatUser!.uuid);

    if (result.isNotEmpty) {
      setState(() {
        chatUsers = result;
      });
    }

    if (chatUsers['partner'] == null) {
      showChatErrorAlert();
    } else {
      chatUserService.setUserChatRoomPartnerStream(
          widget.uuid, chatUsers['partner']);
      chatUserService.enterChat(widget.uuid, chatUsers['partner']);

      ref.read(chatUserRoomStatusProvider.notifier).update(
          (state) => {'roomId': widget.uuid, 'partner': chatUsers['partner']});
    }
  }

  showChatErrorAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: localization.notification,
            alertContent: localization.conversationNotExist,
            alertConfirm: localization.confirm,
            confirmFunc: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  // -------------- msg lazyload
  loadMore() async {
    setState(() {
      page++;
    });
    chatUserService = ChatUserService(ref: ref);
    await chatUserService.getChatMsgList(widget.uuid, page);
  }

  // -------------- msg 가져오기
  Future<void> getChatMsgList() async {
    chatUserService = ChatUserService(ref: ref);

    setState(() {
      isLoading = true;
    });

    await chatUserService.getChatMsgList(widget.uuid, page);
  }

  // -------------- 채팅 init
  Future<void> initChatRoomService() async {
    var user = ref.watch(userProvider);
    chatUserService = ChatUserService(ref: ref);
    setState(() {
      isLoading = true;
    });
    try {
      await initChatService(user!, chatUserService);
      await chatUserService.setUserChatRoomStream(widget.uuid);

      int result = await roomAttendanceUpdate();
      if (result > -1) {
        await chatUserService.updateAttendanceStatus(result, widget.uuid);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('error: $e');
      context.pop();
    }
  }

  // -------------- 이미지/비디오 전송 선택 모달
  showMediaSelectDialog() {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      elevation: 0,
      builder: (BuildContext context) {
        return MediaSelectDialogWidget(
          getImages: getImages,
          getVideos: getVideos,
          uuid: widget.uuid,
        );
      },
    );
  }

  // -------------- 근태 선택 모달
  showAttendanceSelectDialog() {
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
        return AttendanceSelectDialogWidget(
          sendDocument: sendDocument,
          uuid: widget.uuid,
        );
      },
    );
  }

  // -------------- 작성 서류 선택 모달
  showDocumentSelectDialog() {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

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
        return DocumentSelectDialogWidget(
          sendDocument: sendDocument,
          uuid: widget.uuid,
          chatUsers: chatUsers,
          companyName: roomInfo!.partnerName,
        );
      },
    );
  }

  // -------------- 근로계약서 선택 모달
  showEmploymentContractSelectDialog() {
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
        return EmploymentContractSelectDialogWidget(
          sendDocument: sendDocument,
          uuid: widget.uuid,
          chatUsers: chatUsers,
        );
      },
    );
  }

  // -------------- 급여내역서 작성 모달
  showSalaryCreateDialog() {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return SalaryCreateDialogWidget(
          sendDocument: sendDocument,
          uuid: widget.uuid,
          chatUsers: chatUsers,
          partnerIdx: roomInfo!.partnerInfo!.key,
        );
      },
    );
  }

  // -------------- 메시지 신고/삭제 선택 모달
  showMsgDialog(bool isMe, dynamic msg) {
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
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return ContentBottomSheet(
            contents: [
              if (!isMe)
                BottomSheetButton(
                  onTap: () async {
                    context.pop();
                    createReportCapturedImg();
                    savePageLog(LogTypeEnum.other.type);
                  },
                  text: localization.reportMessage,
                ),
              BottomSheetButton(
                onTap: () {
                  setState(() {
                    isSelectDelete = true;
                  });
                  context.pop();
                  savePageLog(LogTypeEnum.other.type);
                },
                text: localization.deleteMessage,
                isRed: true,
              ),
            ],
          );
        });
  }

  // -------------- 메시지 삭제 모달
  showMsgDeleteAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.deleteMessage,
            alertContent: localization.deleteOnlyOnCurrentDevice,
            alertConfirm: '확인',
            alertCancel: '취소',
            onConfirm: () {
              deleteMessage();
            },
            onCancel: () {
              context.pop(context);
            },
          );
        });
  }

  // -------------- 메시지 신고 사유 선택 모달
  showReportReasonDialog() {
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
        return ReportReasonDialogWidget(
          setReportReason: setReportReason,
          showChatReportAlert: showChatReportAlert,
        );
      },
    );
  }

  // -------------- 메시지 신고 모달
  showChatReportAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.reportMessage,
          alertContent: localization.reportedMessageActionPending,
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            createChatReport(selectMsg, reportReason['key']);
          },
          onCancel: () {
            context.pop(context);
          },
        );
      },
    );
  }

  // -------------- 메시지 이미 신고된 사항 알림
  showChatReportErrorAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertTwoButtonDialog(
          alertTitle: localization.reportCompleteItem,
          alertContent: localization.itemAlreadyReported,
          alertConfirm: localization.confirm,
          alertCancel: localization.cancel,
          onConfirm: () {
            context.pop(context);
          },
          onCancel: () {
            context.pop(context);
          },
        );
      },
    );
  }

  // -------------- 신고 메시지 캡쳐
  createReportCapturedImg() {
    setState(() {
      isCaptured = true;
    });

    showDefaultToast(localization.screenCaptureIn5Seconds);

    Map<String, dynamic> file = {};

    captureTimer = Timer(const Duration(seconds: 5), () async {
      file = await screenshotController
          .capture()
          .then((Uint8List? capturedImage) async {
        if (capturedImage != null) {
          var fileDataURL = base64.encode(capturedImage);
          fileDataURL = 'data:image/png;base64,$fileDataURL';
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          Directory appDocDir = await getApplicationDocumentsDirectory();
          String appDocPath = appDocDir.path;
          String fileName = 'chat_report_$timestamp.png';

          return {
            "url": '$appDocPath/$fileName',
            "name": fileName,
            "mime": 'image/png',
            "bytes": capturedImage,
            "size": capturedImage.length,
          };
        }

        return {};
      });

      captureTimer.cancel();

      setState(() {
        capturedChatImg = file;
        isCaptured = false;
      });

      if (capturedChatImg != null) {
        showDefaultToast(localization.captureCompleted);
        showReportReasonDialog();
      }
    });
  }

  // -------------- 메시지 신고
  createChatReport(dynamic msgData, int reportKey) async {
    var chatUser = ref.watch(chatUserAuthProvider);

    Map<String, dynamic> params = {
      "roomUUID": widget.uuid,
      "messageUUID": msgData.id,
      "messageContent": msgData.msg,
      "reporterUUID": chatUser!.uuid,
      "accusedUUID": msgData.userUuid,
      "reReason": reportKey,
      "reDetail": ""
    };

    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .createChatReport(params);

    context.pop();

    if (result.status == 200 && result.type == 1) {
      var reportResult = await fileChatReportUploadS3(
          capturedChatImg, 'REPORT_CHAT', result.data['reIdx']);

      if (reportResult != false) {
        await apiFileUpload(
            capturedChatImg, 'REPORT_CHAT', result.data['reIdx']);

        showDefaultToast(localization.reportCompleted);
        context.pop();
      } else {
        showDefaultToast(localization.reportFailedRetry);
      }
    } else {
      if (result.status == 409) {
        context.pop();
        showChatReportErrorAlert(context);
      } else {
        showDefaultToast(localization.reportFailedRetry);
      }
    }
  }

  // -------------- 메시지 신고 사유 set
  setReportReason(Map<String, dynamic> value) {
    setState(() {
      if (reportReason.isNotEmpty) {
        reportReason = {};
      }
      reportReason = value;
    });
  }

  // -------------- 채팅방 나가기
  showOutChatAlert(BuildContext context, String userUuid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.exitConversation,
            alertContent: localization.exitConversationWarning,
            alertConfirm: localization.leaveConversation,
            alertCancel: localization.cancel,
            onConfirm: () {
              outChatRoom(userUuid);
              context.pop(context);
            },
            onCancel: () {
              context.pop(context);
            },
          );
        });
  }

  showExtendChatDialog() {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
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
        return ExtensionChatDialogWidget(roomInfo: roomInfo!);
      },
    );
  }

  // -------------- 서류 보관함
  showDocumentStorageDialog() {
    showDialog(
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return DocumentStorageDialogWidget(
            uuid: widget.uuid,
            chatUsers: chatUsers,
            showVacationDialog: showVacationDialog,
            showResignationDialog: showResignationDialog,
            showParentAgreeDialog: showParentAgreeDialog,
            showSalaryDialog: showSalaryDialog,
          );
        });
  }

  // -------------- 급여내역서 보기
  showSalaryDialog(String messageUuid, dynamic created) {
    String formattedDate = '';
    if (created.runtimeType == Timestamp) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = created.toDate();

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    } else if (created.runtimeType == String) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = DateTime.parse(created);

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    }
    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return SalaryDialogWidget(
            roomUuid: widget.uuid,
            messageUuid: messageUuid,
            created: formattedDate);
      },
    );
  }

  // -------------- 휴가신청서 보기
  showVacationDialog(String messageUuid, dynamic created) {
    String formattedDate = '';
    if (created.runtimeType == Timestamp) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = created.toDate();

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    } else if (created.runtimeType == String) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = DateTime.parse(created);

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    }

    showDialog<void>(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return VacationDialogWidget(
            roomUuid: widget.uuid,
            messageUuid: messageUuid,
            created: formattedDate);
      },
    );
  }

  // -------------- 사직서 보기
  showResignationDialog(
      String messageUuid, dynamic created, String? signImg) async {
    String formattedDate = '';
    String singImageUrl = '';
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    if (created.runtimeType == Timestamp) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = created.toDate();

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    } else if (created.runtimeType == String) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = DateTime.parse(created);

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    }

    if (signImg == null || signImg == '') {
      var result = await ref
          .read(chatControllerProvider.notifier)
          .getMessageData(widget.uuid, messageUuid);

      if (result.isNotEmpty) {
        singImageUrl = result['files'][0]['fileUrl'];
      }
    } else {
      singImageUrl = signImg;
    }

    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return ResignationDialogWidget(
          roomUuid: widget.uuid,
          messageUuid: messageUuid,
          created: formattedDate,
          signImg: singImageUrl,
          partnerName: roomInfo!.partnerName,
        );
      },
    );
  }

  // -------------- 친권자 동의서 보기
  showParentAgreeDialog(
      String messageUuid, dynamic created, String? signImg) async {
    String singImageUrl = '';
    String formattedDate = '';
    if (created.runtimeType == Timestamp) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = created.toDate();

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    } else if (created.runtimeType == String) {
      // Timestamp를 DateTime으로 변환
      DateTime dateTime = DateTime.parse(created);

      // DateTime을 원하는 형식의 문자열로 변환
      formattedDate = '${dateTime.year.toString().padLeft(4, '0')}년 '
          '${dateTime.month.toString().padLeft(2, '0')}월 '
          '${dateTime.day.toString().padLeft(2, '0')}일';
    }

    if (signImg == null || signImg == '') {
      var result = await ref
          .read(chatControllerProvider.notifier)
          .getMessageData(widget.uuid, messageUuid);

      if (result.isNotEmpty) {
        singImageUrl = result['files'][0]['fileUrl'];
      }
    } else {
      singImageUrl = signImg;
    }

    showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (BuildContext context) {
        return ParentAgreeDialogWidget(
          roomUuid: widget.uuid,
          messageUuid: messageUuid,
          created: formattedDate,
          signImg: singImageUrl,
        );
      },
    );
  }

  // pdf 보기
  showDocumentDetailDialog(String messageUuid, String? pdfUrl,
      ChatMsgModel msgData, int jaIdx, int jpIdx) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return ChatContractViewerWidget(
            uuid: widget.uuid,
            messageUuid: messageUuid,
            pdfUrl: pdfUrl,
            chatUsers: chatUsers,
            jaIdx: jaIdx,
            jpIdx: jpIdx,
          );
        });
  }

  // 미디어 보기
  showMediaDetailDialog(
      String type, String mediaUrl, String msgKey, Timestamp created,
      {isVideo = false}) {
    String date = created.toDate().toString();
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return ChatMediaDetailWidget(
            type: type,
            mediaUrl: mediaUrl,
            deleteChatFile: deleteChatFileAlert,
            msgKey: msgKey,
            chatUsers: chatUsers,
            uuid: widget.uuid,
            isVideo: isVideo,
            created: date,
          );
        });
  }

  deleteChatFileAlert(String msgKey) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: localization.deletePhotoVideo,
            alertContent: localization.deletePhotoVideoWarning,
            alertConfirm: localization.delete,
            alertCancel: localization.cancel,
            onConfirm: () {
              context.pop();
              deleteChatFile(msgKey);
            },
          );
        });
  }

  deleteChatFile(String msgKey) async {
    var apiUploadResult =
        await ref.read(chatControllerProvider.notifier).deleteChatFile(msgKey);

    if (apiUploadResult.type == 1) {
      await deleteSingleMessage(msgKey);
      showDefaultToast(localization.deletedSuccessfully);
      context.pop();
    } else {
      showDefaultToast(localization.deleteFailed);
      return false;
    }
  }

  deleteSingleMessage(String msgKey) {
    if (chatUsers.isNotEmpty) {
      ref
          .read(chatControllerProvider.notifier)
          .deleteMessage(widget.uuid, msgKey, chatUsers);
    } else {
      showDefaultToast(localization.messageDeleteFailed);
    }
  }

  // -------------- 상단 햄버거 메뉴
  showMenuDialog() {
    var chatUser = ref.watch(chatUserAuthProvider);
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    var user = ref.watch(userProvider);
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
        barrierColor: const Color.fromRGBO(0, 0, 0, 0.8),
        isScrollControlled: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return ContentBottomSheet(
            contents: [
              BottomSheetButton(
                  onTap: () {
                    // if (roomInfo!.contractAgree) {
                    savePageLog(LogTypeEnum.other.type); // 페이지 로그 쌓기
                    context.pop();
                    showCalendarDialog();
                    // } else {
                    //   showDefaultToast('계약서에 동의하지 않았습니다.');
                    // }
                  },
                  text: localization.attendanceLog),
              BottomSheetButton(
                  onTap: () {
                    // if (roomInfo!.contractAgree) {
                    savePageLog(LogTypeEnum.other.type); // 페이지 로그 쌓기
                    context.pop();
                    showDocumentStorageDialog();
                    // } else {
                    //   showDefaultToast('계약서에 동의하지 않았습니다.');
                    // }
                  },
                  text: localization.documentStorage),
              BottomSheetButton(
                  onTap: () {
                    context.push('/jobpost/${roomInfo!.jpIdx}');
                  },
                  text: localization.viewJobPostings),
              if (user!.memberType != MemberTypeEnum.jobSeeker)
                BottomSheetButton(
                    onTap: () {
                      savePageLog(LogTypeEnum.other.type); // 페이지 로그 쌓기
                      context.pop();
                      showExtendChatDialog();
                    },
                    text: localization.extendConversationDuration),
              if (roomInfo!.endAt!.compareTo(Timestamp.now()) < 0)
                BottomSheetButton(
                  onTap: () {
                    if (roomInfo.endAt!.compareTo(Timestamp.now()) < 0) {
                      context.pop();
                      showOutChatAlert(context, chatUser!.uuid);
                    }
                  },
                  text: localization.exitConversation,
                  isRed: true,
                ),
            ],
          );
        });
  }

  // -------------- 근태 내역 캘린더 모달
  showCalendarDialog() {
    showDialog(
        barrierColor: Colors.transparent,
        context: context,
        useSafeArea: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return CalendarWidget(uuid: widget.uuid);
          });
        });
  }

  isNotEndChat(DateTime date) {
    DateTime now = DateTime.now();

    Duration difference = date.difference(now);

    if (difference.isNegative) {
      return false;
    } else {
      return true;
    }
  }

  checkTutorial() async {
    var userInfo = ref.watch(userProvider);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (userInfo?.memberType == MemberTypeEnum.jobSeeker) {
        if (prefs.getString('hasSeekerChatTutorial') == 'true') {
          showSeekerChatTutorial = false;
        } else {
          showSeekerChatTutorial = true;
          prefs.setString('hasSeekerChatTutorial', 'true');
        }
      }

      if (userInfo?.memberType == MemberTypeEnum.recruiter) {
        if (prefs.getString('hasRecruiterChatTutorial') == 'true') {
          showRecruiterChatTutorial = false;
        } else {
          showRecruiterChatTutorial = true;
          prefs.setString('hasRecruiterChatTutorial', 'true');
        }
      }
    });
  }

  void setTutorial() async {
    setState(() {
      showSeekerChatTutorial = false;
      showRecruiterChatTutorial = false;
    });
  }

  Widget tutorialPage(userInfo) {
    return Container();
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  getUnratedEvaluateRemain() async {
    UserModel? userInfo = ref.read(userProvider);
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    if (userInfo != null) {
      ApiResultModel result = userInfo.memberType == MemberTypeEnum.jobSeeker
          ? await ref
              .read(chatControllerProvider.notifier)
              .getJobseekerEvaluateRemain(widget.uuid)
          : await ref
              .read(chatControllerProvider.notifier)
              .getJobseekerEvaluateRemain(widget.uuid);
      if (result.status == 200) {
        if (result.type == 1) {
          if (result.data == true) {
            showEvaluationModal(roomInfo!.partnerName,
                userInfo.memberType == MemberTypeEnum.jobSeeker);
          }
        }
      }
    }
  }

  setChatBackground() async {
    await chatUserService.setChatBackground(widget.uuid);
  }

  void showEvaluationModal(String partnerName, bool type) {
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
        if (type == false) {
          return EvaluationRecruiterBottomSheet(
            company: partnerName,
            roomUuid: widget.uuid,
          );
        } else {
          return EvaluationJobseekerChatBottomSheet(
            company: partnerName,
            roomUuid: widget.uuid,
          );
        }
      },
    );
  }

  @override
  void initState() {
    Future(() {
      checkTutorial();
      setChatBackground();
      initChatRoomService();
      savePageLog(LogTypeEnum.chat.type);
      getChatMsgList();
      getChatUuid();
      getUnratedEvaluateRemain();
    });

    // 스크롤 리스너 추가
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent <=
          _scrollController.position.pixels) {
        loadMore();
      }
    });

    setState(() {
      isLoading = false;
    });
    super.initState();
  }

  Future<int> roomAttendanceUpdate() async {
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getAttendance(widget.uuid);
    if (result.status == 200) {
      return result.data;
    }
    return -1;
  }

  savePageLog(int logType) async {
    await ref.read(logControllerProvider.notifier).savePageLog(logType);
  }

  @override
  void dispose() {
    // ref.read(chatUserRoomStatusProvider.notifier).update((state) => {});
    disposeChatRoomService();

    _handleAsyncTasks();

    super.dispose();
  }

  void _handleAsyncTasks() async {
    chatUserService = ChatUserService(ref: ref);
    await chatUserService.outChat(widget.uuid);
  }

  void handleMessageTap(ChatMsgModel data, String chatUserUuid) {
    final Set<String> nonDeletableTypes = {
      'salary',
      'vacation',
      'normalContractCreate',
      'normalContractUpdate',
      'shortContractCreate',
      'shortContractUpdate',
      'minorContractCreate',
      'minorContractUpdate',
      'constructionContractCreate',
      'constructionContractUpdate',
      'resignation',
      'consent'
    };
    if (isSelectDelete) {
      if (!nonDeletableTypes.contains(data.msgType)) {
        handleDeleteSelection(data.id);
      }
    } else if (!data.deleted.contains(chatUserUuid)) {
      showAppropriateDialog(data);
    }
  }

  void handleDeleteSelection(String dataId) {
    setState(() {
      if (deleteList.contains(dataId)) {
        deleteList.remove(dataId);
      } else {
        deleteList.add(dataId);
      }
    });
  }

  void showAppropriateDialog(ChatMsgModel data) {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    switch (data.msgType) {
      case 'salary':
        showSalaryDialog(data.id, data.created);
        break;
      case 'vacation':
        showVacationDialog(data.id, data.created);
        break;
      case 'resignation':
        showResignationDialog(data.id, data.created, data.file[0]['fileUrl']);
        break;
      case 'consent':
        showParentAgreeDialog(data.id, data.created, data.file[0]['fileUrl']);
        break;
      case 'video':
        showMediaDetailDialog(
            'video', data.file[0]['fileUrl'], data.id, data.created,
            isVideo: true);
        break;
      case 'image':
        showMediaDetailDialog(
            'photo', data.file[0]['fileUrl'], data.id, data.created);
        break;
      case 'normalContractCreate':
      case 'normalContractUpdate':
      case 'shortContractCreate':
      case 'shortContractUpdate':
      case 'minorContractCreate':
      case 'minorContractUpdate':
      case 'constructionContractCreate':
      case 'constructionContractUpdate':
        if (roomInfo != null) {
          showDocumentDetailDialog(data.id, data.file[0]['fileUrl'], data,
              roomInfo.jaIdx, roomInfo.jpIdx);
        }
        break;
      default:
        print('Unhandled message type: ${data.msgType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatUser = ref.watch(chatUserAuthProvider);
    var msgList = ref.watch(msgListProvider);
    var roomInfo = ref.watch(chatUserRoomInfoProvider);
    var userInfo = ref.watch(userProvider);

    return userInfo?.memberType == MemberTypeEnum.jobSeeker &&
            showSeekerChatTutorial
        ? ChatSeekerTutorial(
            setTutorial: () {
              setTutorial();
            },
          )
        : userInfo?.memberType == MemberTypeEnum.recruiter &&
                showRecruiterChatTutorial
            ? ChatRecruiterTutorial(
                setTutorial: () {
                  setTutorial();
                },
              )
            : PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) async {
                      if (MediaQuery.of(context).viewInsets.bottom > 0) {
                        FocusScope.of(context).unfocus();
                      } else {
                        if (!didPop) {
                          if (isSelectDelete) {
                            setState(() {
                              deleteList = [];
                              isSelectDelete = false;
                            });
                          } else {
                            if (!isUploadLoading) {
                              ref
                                  .read(chatUserRoomStatusProvider.notifier)
                                  .update((state) => {});
                              context.pop();
                            }
                          }
                        }
                      }
                    },
                  );
                },
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) async {
                    int sensitivity = 15;
                    if (details.globalPosition.dx - details.delta.dx < 60 &&
                        details.delta.dx > sensitivity) {
                      if (isSelectDelete) {
                        setState(() {
                          deleteList = [];
                          isSelectDelete = false;
                        });
                      } else {
                        if (!isUploadLoading) {
                          context.pop();
                        }
                      }
                    }
                  },
                  onTap: () {
                    FocusManager.instance.primaryFocus
                        ?.unfocus(); // keyboard hide
                  },
                  child: roomInfo == null || isLoading
                      ? ColoredBox(color: Colors.white, child: const Loader())
                      : Stack(
                          children: [
                            Scaffold(
                              appBar: ChatAppbar(
                                  title: roomInfo.partnerInfo?.isUse == 0
                                      ? localization.withdrawnMember
                                      : roomInfo.partnerName,
                                  infoKey: userInfo!.memberType ==
                                          MemberTypeEnum.jobSeeker
                                      ? roomInfo.partnerInfo!.key
                                      : roomInfo.profileKey,
                                  actions: [
                                    AppbarButton(
                                        onPressed: () {
                                          savePageLog(LogTypeEnum.other.type);
                                          showMenuDialog();
                                        },
                                        imgUrl: 'iconKebab.png'),
                                  ],
                                  backFunc: () {
                                    if (isSelectDelete) {
                                      setState(() {
                                        deleteList = [];
                                        isSelectDelete = false;
                                      });
                                    } else {
                                      context.pop();
                                    }
                                  }),
                              body: Screenshot(
                                controller: screenshotController,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                                width: 1.w,
                                                color: CommonColors.grayF2),
                                          ),
                                          color: hexToColor(
                                              roomInfo.backgroundColor),
                                        ),
                                        child: ListView.builder(
                                            padding: const EdgeInsets.only(
                                                bottom: 30),
                                            reverse: true,
                                            controller: _scrollController,
                                            shrinkWrap: true,
                                            itemCount: msgList.length,
                                            itemBuilder: (context, index) {
                                              var data = msgList[index];
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  if (index + 1 <
                                                              msgList.length &&
                                                          DateFormat('yyyy.MM.dd')
                                                                  .format(msgList[
                                                                          index +
                                                                              1]
                                                                      .created
                                                                      .toDate()) !=
                                                              DateFormat(
                                                                      'yyyy.MM.dd')
                                                                  .format(data
                                                                      .created
                                                                      .toDate()) ||
                                                      index ==
                                                          msgList.length - 1)
                                                    DateChecker(
                                                        date: DateFormat(
                                                                'yyyy.MM.dd')
                                                            .format(data.created
                                                                .toDate())),
                                                  if (data.msgType != 'first')
                                                    GestureDetector(
                                                      onTap: () {
                                                        handleMessageTap(data,
                                                            chatUser!.uuid);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          selectMsg = data;
                                                          showMsgDialog(
                                                              chatUser!.id ==
                                                                  data.userId,
                                                              data);
                                                        });
                                                      },
                                                      child: ChatMsgWidget(
                                                        isSelectDelete:
                                                            isSelectDelete,
                                                        deleteList: deleteList,
                                                        data: data,
                                                        index: index,
                                                      ),
                                                    ),
                                                ],
                                              );
                                            }),
                                      ),
                                    ),
                                    if (isNotEndChat(roomInfo.endAt!.toDate()))
                                      KeyboardVisibilityBuilder(builder:
                                          (context, isKeyboardVisible) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: CommonColors.white,
                                            border: Border(
                                              top: BorderSide(
                                                width: 1.w,
                                                color: isSelectDelete
                                                    ? Colors.transparent
                                                    : CommonColors.grayF2,
                                              ),
                                            ),
                                          ),
                                          padding: EdgeInsets.only(
                                            top: 12.w,
                                            bottom: 12.w +
                                                CommonSize.keyboardBottom(
                                                    context) +
                                                (isKeyboardVisible &&
                                                        Platform.isIOS
                                                    ? 44
                                                    : 0),
                                          ),
                                          child: isSelectDelete
                                              ? Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20.w, 0, 20.w, 0),
                                                  child: CommonButton(
                                                    confirm:
                                                        deleteList.isNotEmpty,
                                                    onPressed: () {
                                                      if (deleteList
                                                          .isNotEmpty) {
                                                        showMsgDeleteAlert(
                                                            context);
                                                      }
                                                    },
                                                    text: localization.deleteItems(deleteList.length),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              if (roomInfo
                                                                      .partnerInfo
                                                                      ?.isUse !=
                                                                  0) {
                                                                onMenu =
                                                                    !onMenu;
                                                              }
                                                            });
                                                          },
                                                          child: Image.asset(
                                                            onMenu
                                                                ? 'assets/images/icon/iconChatX.png'
                                                                : 'assets/images/icon/IconChatPlus.png',
                                                            width: 48.w,
                                                            height: 48.w,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: ChatInputWidget(
                                                              chatController:
                                                                  _chatController,
                                                              setMsgValue:
                                                                  setMsgValue,
                                                              getFiles:
                                                                  getFiles,
                                                              sendMessage:
                                                                  sendMessage,
                                                              isSending:
                                                                  isSending),
                                                        ),
                                                      ],
                                                    ),
                                                    if (onMenu)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 12.w),
                                                        child:
                                                            ChatBottomMenuWidget(
                                                          getFiles: getFiles,
                                                          showMediaSelectDialog:
                                                              showMediaSelectDialog,
                                                          showSalaryCreateDialog:
                                                              showSalaryCreateDialog,
                                                          showEmploymentContractSelectDialog:
                                                              showEmploymentContractSelectDialog,
                                                          showDocumentSelectDialog:
                                                              showDocumentSelectDialog,
                                                          showAttendanceSelectDialog:
                                                              showAttendanceSelectDialog,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                        );
                                      }),
                                  ],
                                ),
                              ),
                            ),
                            if (isUploadLoading || isCaptured) const Loader(),
                          ],
                        ),
                ),
              );
  }
}
