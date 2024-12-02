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

class StartChatDialogWidget extends ConsumerStatefulWidget {
  const StartChatDialogWidget(
      {super.key,
      required this.partnerUuid,
      required this.data,
      this.meIdx,
      this.meName,
      this.isMichinMatching = false});

  final String partnerUuid;
  final dynamic data;

  final int? meIdx;
  final String? meName;

  final bool isMichinMatching;

  @override
  ConsumerState<StartChatDialogWidget> createState() =>
      _StartChatDialogWidgetState();
}

class _StartChatDialogWidgetState extends ConsumerState<StartChatDialogWidget>
    with Alerts {
  int remainChoco = 0;
  int isAutoExtend = 0;
  PremiumModel? item;
  PremiumModel? keepItem;
  bool isAgree = false;

  updateTermsStatus(bool value, String checkString, bool required, bool isAll) {
    setState(() {
      isAgree = value;
    });
  }

  payChocoChat(dynamic data, dynamic chatUser) async {
    var roomUuid = await chatUserService.checkUserRoomData(data.jaIdx, context);
    if (roomUuid != '') {
      showMoveChatAlert(roomUuid);
      return;
    }
    var result = await ref
        .read(chatControllerProvider.notifier)
        .payChocoChat(data.jaIdx);

    if (result.type == 1) {
      createChatRoom(data, chatUser, result.data);
    } else if (result.type == -1706 || result.type == -1705) {
      showLessChoco();
    } else {
      showDefaultToast('채팅 생성에 실패했습니다.\n다시 시도해주세요.');
    }
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

  createChatRoom(dynamic data, dynamic chatUser, int? payKey) async {
    var partnerStatus = ref.watch(chatPartnerRoomInfoProvider);
    var chatUsers;
    var chatUser = ref.watch(chatUserAuthProvider);
    int day = 30;
    if (item!.expireDay > 0) {
      day = item!.expireDay;
    } else {
      day = 365 * 1000;
    }
    UserModel? userInfo = ref.read(userProvider);
    int companyKey = userInfo?.companyInfo!.key ?? 0;
    var roomUuid = await chatUserService.createUserRoomData(
        widget.partnerUuid,
        data.meIdx == -1 && widget.meIdx != null ? widget.meIdx : data.meIdx,
        data.meName == '' && widget.meName != null
            ? widget.meName
            : data.meName,
        chatUser!.companyName,
        data.jaIdx,
        data.jpIdx,
        data.mpIdx,
        day,
        companyKey,
        context);

    Map<String, dynamic> params = {
      'chRoomUuid': roomUuid,
      'jaIdx': data.jaIdx,
      'chAutoExtend': isAutoExtend, // 자동연장 여부 0: 미승인, 1: 승인
    };

    if (payKey != null) {
      params['cphIdx'] = payKey;
    }

    DateTime today = DateTime.now();

    if (item!.expireDay > 0) {
      today.add(Duration(days: item!.expireDay));
    } else {
      today.add(const Duration(days: 365 * 1000));
    }
    if (widget.isMichinMatching) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(today);
      DateTime dateTime = DateTime.parse(formattedDate);

      params['chExpireDate'] = dateTime.toIso8601String();
    }
    var result =
        await ref.read(chatControllerProvider.notifier).createChatRoom(params);

    if (result.type == 1) {
      var chatUserInfo = await ref
          .read(chatControllerProvider.notifier)
          .getChatUuid(roomUuid, chatUser.uuid);

      if (chatUserInfo.isNotEmpty) {
        setState(() {
          chatUsers = chatUserInfo;
        });

        if (chatUsers.isNotEmpty) {
          await ref.read(chatControllerProvider.notifier).firstMessage(
              roomUuid,
              '${chatUser.companyName}님과의 대화창을 열었습니다. 이제 톡으로 직접 소통해요!',
              chatUser,
              chatUsers,
              partnerStatus);

          context.pop();

          context.push('/chat/detail/$roomUuid');
        } else {
          showDefaultToast('메시지 전송에 실패했습니다.');
        }
      } else {
        return false;
      }
    } else if (result.type == -1401) {
      showMoveChatAlert(extractUuid(result.data));
    } else if (result.type == -101) {
      showErrorAlert(context, '알림', '존재하지 않는 공고에 지원한 지원자입니다.');
    } else {
      showErrorAlert(context, '알림', '채팅 생성에 실패했습니다.\n다시 시도해주세요.');
    }
  }

  showMoveChatAlert(String roomUuid) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertTwoButtonDialog(
            alertTitle: '알림',
            alertContent: '이미 대화방이 생성된 회원입니다.',
            alertConfirm: '확인',
            alertCancel: '취소',
            onConfirm: () {
              context.pop(context);
              context.push('/chat/detail/$roomUuid');
            },
            onCancel: () {
              context.pop(context);
            },
          );
        });
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

  getPremiumService() async {
    String itemCode = 'PS01';
    if (widget.isMichinMatching) {
      itemCode = 'PS03';
    }
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getPremiumService(itemCode);
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

  getPremiumKeepService() async {
    ApiResultModel result = await ref
        .read(chatControllerProvider.notifier)
        .getPremiumService('PS02');
    if (result.status == 200) {
      if (result.type == 1 && result.data != {}) {
        setState(() {
          keepItem = PremiumModel.fromApiJson(result.data);
        });
      } else {
        showDefaultToast('아이템 정보를 가져오지 못했습니다.');
        context.pop();
      }
    }
  }

  returnExpireDate() {
    String day = '';
    if (item!.expireDay > 0) {
      day = '※ 대화기간 ${item!.expireDay}일, 추가결제를 통해 대화 기간 연장 가능';
    } else {
      day = '※ 대화기간 무제한';
    }
    return day;
  }

  @override
  void initState() {
    Future(() {
      getUserData();
      getPremiumService();
      getPremiumKeepService();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var chatUser = ref.watch(chatUserAuthProvider);
    UserModel? userInfo = ref.read(userProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.w, 0, CommonSize.commonBottom),
      child: item == null || keepItem == null
          ? const SizedBox(
              height: 450,
              child: Loader(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const TitleBottomSheet(title: '대화 시작하기'),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 24.w, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          widget.isMichinMatching
                              ? '미친 매칭의 경우 무료로 대화가 가능합니다.\n대화를 시작하시겠어요?'
                              : '대화를 시작하려면 ${ConvertService.returnStringWithCommaFormat(item!.finalPrice)}초코가 필요해요.\n결제후 대화를 시작하시겠어요?',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: CommonColors.gray4d,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          '${returnExpireDate()} ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13.sp,
                            color: CommonColors.gray80,
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
                                });
                              },
                              groupValue: 1,
                              value: isAutoExtend,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.w),
                        Text(
                          '충전되어 있는 초코 잔액 한도 내에서 30일마다 자동으로 ${ConvertService.returnStringWithCommaFormat(keepItem!.finalPrice)}초코를 결제하고 대화 기간을 연장 해요.  ',
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
                              if (widget.isMichinMatching) {
                                createChatRoom(widget.data, chatUser, null);
                              } else {
                                payChocoChat(widget.data, chatUser);
                              }
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
