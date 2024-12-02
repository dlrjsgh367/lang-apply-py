import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/input_style.dart';
import 'package:chodan_flutter_app/widgets/keyboard/common_keyboard_action.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInputWidget extends ConsumerStatefulWidget {
  const ChatInputWidget({
    super.key,
    required this.chatController,
    required this.setMsgValue,
    required this.getFiles,
    required this.sendMessage,
    required this.isSending,
  });

  final TextEditingController chatController;
  final Function setMsgValue;
  final Function getFiles;
  final Function sendMessage;
  final bool isSending;

  @override
  ConsumerState<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends ConsumerState<ChatInputWidget> {

  final FocusNode textAreaNode = FocusNode();
  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  @override
  Widget build(BuildContext context) {
    var roomInfo = ref.watch(chatUserRoomInfoProvider);

    return Row(
      children: [
        Expanded(
          child: CommonKeyboardAction(focusNode: textAreaNode,
          child:  TextFormField(
            focusNode: textAreaNode,
            keyboardType: TextInputType.multiline,
            // 여러 줄 입력 가능하도록 변경
            textInputAction: TextInputAction.newline,
            // 엔터 키를 새 줄로 처리
            cursorColor: CommonColors.black,
            expands: true,
            maxLines: null,
            minLines: null,
            controller: widget.chatController,
            readOnly: roomInfo!.partnerInfo?.isUse == 0,
            onChanged: (value) {
              widget.setMsgValue(value);
            },
            style: commonInputText(),
            maxLength: null,
            decoration: commonChatInput(
              hintText: '메시지를 입력해주세요',
            ),
            onFieldSubmitted: (value) {},
          ),),

        ),
        GestureDetector(
          onTap: () {
            savePageLog();

            if (widget.chatController.text.isNotEmpty) {
              widget.sendMessage();
            }
          },
          child: Image.asset(
            widget.chatController.text.isEmpty || widget.isSending
                ? 'assets/images/icon/IconChatSend.png'
                : 'assets/images/icon/IconChatSendRed.png',
            width: 48.w,
            height: 48.w,
          ),
        ),
      ],
    );
  }
}
