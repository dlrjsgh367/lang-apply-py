import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/mixins/Files.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_my_file.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_my_image.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_my_message.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_other_file.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_other_image.dart';
import 'package:chodan_flutter_app/widgets/chat/chat_other_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatMsgWidget extends ConsumerStatefulWidget {
  const ChatMsgWidget({
    super.key,
    required this.isSelectDelete,
    required this.deleteList,
    required this.data,
    required this.index,
  });

  final bool isSelectDelete;
  final List deleteList;
  final dynamic data;
  final int index;

  @override
  ConsumerState<ChatMsgWidget> createState() => _ChatMsgWidgetState();
}

class _ChatMsgWidgetState extends ConsumerState<ChatMsgWidget> with Files {
  String returnFileSize(int byte) {
    const units = ['byte', 'kb', 'mb', 'gb'];
    var i = 0;
    double size = byte.toDouble();
    while (size >= 1000 && i < units.length - 1) {
      size /= 1000;
      i++;
    }
    return '${size.toStringAsFixed(2)}${units[i]}';
  }

  Future<void> savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  String returnFileMsg(String type) {
    const msgMap = {
      'normalContractCreate': '표준 근로 계약서',
      'shortContractCreate': '단기간 근로자 계약서',
      'minorContractCreate': '연소 근로 계약서',
      'constructionContractCreate': '건설일용 근로 계약서',
      'normalContractUpdate': '표준 근로 계약서',
      'shortContractUpdate': '단기간 근로자 계약서',
      'minorContractUpdate': '연소 근로 계약서',
      'constructionContractUpdate': '건설일용 근로 계약서',
      'salary': '급여 내역서',
      'consent': '친권자 동의서',
      'resignation': '사직서',
      'vacation': '휴가 신청서',
      'attendance': '출근 체크',
      'leave': '퇴근 체크',
      'outside': '외근 체크',
      'comeback': '복귀 체크',
    };
    return msgMap[type] ?? '';
  }

  bool get isFileType {
    const fileTypes = [
      'file',
      'attendance',
      'leave',
      'outside',
      'comeback',
      'salary',
      'vacation',
      'resignation',
      'consent',
      'normalContractCreate',
      'shortContractCreate',
      'minorContractCreate',
      'constructionContractCreate',
      'normalContractUpdate',
      'shortContractUpdate',
      'minorContractUpdate',
      'constructionContractUpdate',
      'video'
    ];
    return fileTypes.contains(widget.data.msgType);
  }

  bool isOneMonthPassed() {
    DateTime now = DateTime.now();
    String date =
        DateFormat('yyyy-MM-dd hh:mm').format(widget.data.created.toDate());
    DateTime createDate = DateTime.parse(date);
    DateTime oneMonthLater = DateTime(createDate.year, createDate.month + 1,
        createDate.day, createDate.hour, createDate.minute);
    return now.isAfter(oneMonthLater);
  }

  returnIsAttendance() {
    if (widget.data.msgType == 'attendance' || widget.data.msgType == 'leave') {
      return 'attendance';
    } else if (widget.data.msgType == 'outside' ||
        widget.data.msgType == 'comeback') {
      return 'outside';
    } else {
      return 'file';
    }
  }

  Widget buildChatWidget(bool isMyMessage, String chatUserId) {
    final isDeletedMessage = widget.data.deleted.contains(chatUserId);
    final message = isDeletedMessage
        ? '메시지가 삭제되었습니다.'
        : isFileType
            ? (widget.data.msgType == 'file' || widget.data.msgType == 'video'
                ? widget.data.file[0]['fileName']
                : returnFileMsg(widget.data.msgType))
            : widget.data.msgType == 'image'
                ? widget.data.file[0]['fileUrl']
                : widget.data.msg;

    final time = DateFormat('HH:mm').format(widget.data.created.toDate());
    final isDeleteSelect = widget.deleteList.contains(widget.data.id);

    if (isFileType) {
      return isMyMessage
          ? ChatMyFile(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              writedDate: DateFormat('yyyy-MM-dd HH:mm')
                  .format(widget.data.created.toDate()),
              isDeleteSelect: isDeleteSelect,
              msgType: widget.data.msgType,
              read: ref.watch(chatPartnerMsgCountProvider) < widget.index + 1,
              isDeletedMessage: isDeletedMessage,
              isAttendance: returnIsAttendance(),
            )
          : ChatOtherFile(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              writedDate: DateFormat('yyyy-MM-dd HH:mm')
                  .format(widget.data.created.toDate()),
              isDeleteSelect: isDeleteSelect,
              msgType: widget.data.msgType,
              isDeletedMessage: isDeletedMessage,
              isAttendance: returnIsAttendance(),
            );
    } else if (widget.data.msgType == 'image') {
      return isMyMessage
          ? ChatMyImage(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              isDeleteSelect: isDeleteSelect,
              read: ref.watch(chatPartnerMsgCountProvider) < widget.index + 1,
              isDeletedMessage: isDeletedMessage,
            )
          : ChatOtherImage(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              isDeleteSelect: isDeleteSelect,
              isDeletedMessage: isDeletedMessage,
            );
    } else {
      return isMyMessage
          ? ChatMyMessage(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              isDeleteSelect: isDeleteSelect,
              read: ref.watch(chatPartnerMsgCountProvider) < widget.index + 1,
              isDeletedMessage: isDeletedMessage,
            )
          : ChatOtherMessage(
              message: message,
              time: time,
              delete: widget.isSelectDelete,
              isDeleteSelect: isDeleteSelect,
              isDeletedMessage: isDeletedMessage,
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatUser = ref.watch(chatUserAuthProvider);
    final isMyMessage = chatUser!.id == widget.data.userId;

    return GestureDetector(
      onTap: !widget.isSelectDelete &&
          widget.data.msgType == 'file' &&
          !widget.data.deleted.contains(chatUser.uuid)
          ? () {
        if (isOneMonthPassed()) {
          showDefaultToast('다운로드 기간이 만료되었습니다.');
        } else {
          fileDownload(
              widget.data.file[0]['fileUrl'], widget.data.file[0]['fileName']);
        }
      }
          : null,
      child: buildChatWidget(isMyMessage, chatUser.uuid),
    );
  }
}
