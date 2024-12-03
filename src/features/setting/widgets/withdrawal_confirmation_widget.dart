import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawalConfirmationWidget extends StatefulWidget {
  const WithdrawalConfirmationWidget({
    super.key,
    required this.onPress,
    required this.onCancel,
  });

  final Function onPress;
  final Function onCancel;

  @override
  State<WithdrawalConfirmationWidget> createState() =>
      _WithdrawalConfirmationWidgetState();
}

class _WithdrawalConfirmationWidgetState
    extends State<WithdrawalConfirmationWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 32.w, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '초단알바를 이용하시는데\n불편함이 있으셨나요?',
                        style: TextStyles.withdrawalTitle,
                      ),
                      SizedBox(
                        height: 33.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.w),
                            child: Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  localization.725,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.726,
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.w),
                            child: Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  localization.727,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.728,
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.w),
                            child: Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  localization.729,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  '차단을 하면 상습적으로 제안을 하는 사장님, 매번 습관적으로 지원하는 알바님을 차단할 수 있어요.\n마음 상하게 하는 게시물에 대해서는 신고할 수 있어요.',
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.w),
                            child: Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  '계정을 삭제 하면  재가입이 어려워져요.',
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.732,
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.w, top: 2.w),
                            child: Image.asset(
                              'assets/images/icon/iconImp.png',
                              width: 16.w,
                              height: 16.w,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  localization.733,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  '회원정보 수정 또는 기업정보 수정에서 주소와 전화번호를 변경할 수 있어요.\n굳이 탈퇴하시고 재가입 할 필요 없어요.',
                                  style: TextStyle(
                                    color: CommonColors.gray4d,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 28.w,
                      ),
                      Row(
                        children: [
                          BorderButton(
                              width: 96.w,
                              onPressed: () {
                                widget.onPress();
                              },
                              text: localization.next),
                          SizedBox(
                            width: 8.w,
                          ),
                          Expanded(
                            child: CommonButton(
                              onPressed: () {
                                widget.onCancel();
                              },
                              text: localization.736,
                              confirm: true,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const BottomPadding(),
            ],
          ),
        ),
      ],
    );
  }
}
