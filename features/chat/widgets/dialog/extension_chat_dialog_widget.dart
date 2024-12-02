import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/auth/widgets/terms_item_widget.dart';
import 'package:chodan_flutter_app/features/chat/controller/chat_controller.dart';
import 'package:chodan_flutter_app/mixins/alert_mixin.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_room_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/bottom_sheet/title_bottom_sheet.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/radio/toggle_radio_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExtensionChatDialogWidget extends ConsumerStatefulWidget {
  const ExtensionChatDialogWidget({
    super.key,
    required this.roomInfo,
  });

  final ChatRoomModel roomInfo;

  @override
  ConsumerState<ExtensionChatDialogWidget> createState() =>
      _ExtensionChatDialogWidgetState();
}

class _ExtensionChatDialogWidgetState
    extends ConsumerState<ExtensionChatDialogWidget> with Alerts {
  int remainChoco = 0;
  int isAutoExtend = 0;
  PremiumModel? item;
  bool isAgree = false;

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      isAgree = value;
    });
  }

  String extractUuid(String input) {
    final regex = RegExp(r'([0-9a-fA-F-]+)');
    final match = regex.firstMatch(input);
    if (match != null) {
      return match.group(0) ?? '';
    } else {
      return '';
    }
  }

  getPremiumService() async {
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getPremiumService('PS02');
    if (result.status == 200) {
      if (result.type == 1 && result.data != {}) {
        setState(() {
          item = PremiumModel.fromApiJson(result.data);
        });
      } else {
        showDefaultToast('아이템 정보를 가져오지 못했습니다.');
        context.pop();
      }
    }
  }

  showLessChoco() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: '초코 부족!',
            alertContent: '보유한 초단 코인이 부족해요.\n지금 바로 충전 하시겠어요?',
            alertConfirm: '충전하기',
            alertCancel: '취소',
            onConfirm: () {
              context.pop(context);
              context.push('/my/choco').then((_) async {
                await getUserData();
              });
            },
            onCancel: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.type == 1) {
        ref.read(userProvider.notifier).update((state) => result.data);
      }
    }
  }

  getChatDetail() async {
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getChatDetail(widget.roomInfo.id);
    if (result.status == 200) {
      if (result.type == 1 && result.data != {}) {
        setState(() {
          isAutoExtend = result.data['chAutoExtend'];
        });
      } else {
        showDefaultToast('아이템 정보를 가져오지 못했습니다.');
        context.pop();
      }
    }
  }

  returnEndTime() {
    String formattedDate = '';
    if (widget.roomInfo.endAt != null) {
      DateTime dateTime = widget.roomInfo.endAt!.toDate();
      DateFormat dateFormat = DateFormat('yyyy.MM.dd');

      formattedDate = dateFormat.format(dateTime);
    }
    return formattedDate;
  }

  autoExtendChatRoom(int autoExtend) async {
    var apiUploadResult = await ref
        .read(chatControllerProvider.notifier)
        .autoExtendChatRoom(widget.roomInfo.id, autoExtend);

    if (apiUploadResult.type == 1) {
      String msg =
          autoExtend == 1 ? '대화방 자동 연장이 설정되었습니다.' : '대화방 자동 연장이 해제되었습니다.';
      showDefaultToast(msg);
    } else {
      String msg =
          autoExtend == 1 ? '대화방 자동 연장 설정에 실패하였습니다.' : '대화방 자동 연장 해제에 실패하였습니다.';
      showDefaultToast(msg);
      return false;
    }
  }

  payChocoChat() async {
    var result = await ref
        .read(chatControllerProvider.notifier)
        .payChocoExtensionChat(widget.roomInfo.jaIdx);
    if (result.type == 1) {
      showDefaultToast('대화기간이 연장되었습니다.');
      getUserData();
      context.pop();
    } else if (result.type == -1706 || result.type == -1705) {
      showLessChoco();
    } else {
      showDefaultToast('대화기간 연장에 실패했습니다.\n다시 시도해주세요.');
    }
  }

  @override
  void initState() {
    Future(() {
      getChatDetail();
      getUserData();
      getPremiumService();
    });
    super.initState();
  }

  returnExpireDate() {
    String day = '';
    if (item!.expireDay > 0) {
      day = '${item!.expireDay}일';
    } else {
      day = '평생';
    }
    return day;
  }

  @override
  Widget build(BuildContext context) {
    UserModel? userInfo = ref.read(userProvider);
    return item == null
        ? const SizedBox(
            height: 450,
            child: Loader(),
          )
        : Padding(
            padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleBottomSheet(title: '대화기간 연장하기'),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '현재 ${returnEndTime()}까지 대화 가능 해요\n대화 기간을 더 연장 하시겠어요?\n${ConvertService.returnStringWithCommaFormat(item!.finalPrice)}초코 결제시 ${returnExpireDate()} 더 대화할 수 있어요.',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: CommonColors.gray4d,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 16.w),
                        Row(
                          children: [
                            SizedBox(width: 8.w),
                            Image.asset(
                              'assets/images/default/imgChoco.png',
                              width: 32.w,
                              height: 32.w,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            Expanded(
                              child: Text(
                                '보유 초단코인',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.brown,
                                ),
                              ),
                            ),
                            Text(
                              '${ConvertService.returnStringWithCommaFormat(userInfo!.choco)} 초코',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: CommonColors.red),
                            ),
                            SizedBox(width: 12.w),
                          ],
                        ),
                        SizedBox(height: 32.w),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '대화기간 자동연장',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: CommonColors.gray4d,
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  isAutoExtend == 0 ? 'OFF' : 'ON',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isAutoExtend == 0
                                        ? CommonColors.gray80
                                        : CommonColors.red,
                                  ),
                                ),
                              ],
                            ),
                            ToggleRadioButton(
                              onChanged: (value) {
                                setState(() {
                                  isAutoExtend = isAutoExtend == 0 ? 1 : 0;
                                  autoExtendChatRoom(isAutoExtend);
                                });
                              },
                              groupValue: 1,
                              value: isAutoExtend,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          '대화기간 종료 전 초단코인 잔액 한도내에서 ${item!.price}초코가 자동 결제 되어 대화기간을 연장합니다.',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                            color: CommonColors.gray80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 0),
                  child: TermsItemWidget(
                    isRequired: true,
                    isDetail: true,
                    requireText: '(필수)',
                    text: '서비스 이용약관',
                    status: isAgree,
                    checkString: 'isServiceStatus',
                    termsType: 2,
                    termsDataIdx: 26,
                    updateStatus: updateTermsStatus,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 30.w, 20.w, 0),
                  child: Row(
                    children: [
                      BorderButton(
                        onPressed: () {
                          context.pop();
                        },
                        text: '취소',
                        width: 120.w,
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Expanded(
                        child: CommonButton(
                          onPressed: () {
                            if (isAgree) {
                              setState(() {
                                payChocoChat();
                              });
                            }
                          },
                          text: '결제하기',
                          fontSize: 15,
                          confirm: isAgree,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
