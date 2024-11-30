import 'package:chodan_flutter_app/core/common/size_unit.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/style/text_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/checkbox/circle_checkbox.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WithdrawalNoticeWidget extends StatefulWidget {
  const WithdrawalNoticeWidget({
    super.key,
    required this.onPress,
    required this.onCancel,
  });

  final Function onPress;
  final Function onCancel;

  @override
  State<WithdrawalNoticeWidget> createState() => _WithdrawalNoticeWidgetState();
}

class _WithdrawalNoticeWidgetState extends State<WithdrawalNoticeWidget> {
  bool isChecked = false;

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
                        '회원탈퇴전, 다음 내용을 확인해주세요',
                        style: TextStyles.withdrawalTitle,
                      ),
                      SizedBox(
                        height: 16.w,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.w),
                            color: CommonColors.grayF7),
                        padding: EdgeInsets.fromLTRB(10.w, 20.w, 10.w, 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(9.w),
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '탈퇴시 기존 개인정보 및 서비스 이용 기록이 삭제돼요',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(9.w),
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '회원탈퇴시 재가입에 제한이 있을 수 있어요.',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: CommonColors.gray66,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 12.w,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.all(9.w),
                                  width: 3.w,
                                  height: 3.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: CommonColors.gray66,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        '기업회원(구인회원)은 탈퇴시 보유중인 초단코인 환불요청을 할경우 환불 규정에 따라 환불돼요',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: CommonColors.gray66,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.w,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/images/icon/iconNoticeRed.png',
                                            width: 16.w,
                                            height: 16.w,
                                          ),
                                          SizedBox(
                                            width: 2.w,
                                          ),
                                          Expanded(
                                            child: Text(
                                              '무료지급된 초단 코인 환불 불가, 약관의 환불 규정 적용',
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w500,
                                                color: CommonColors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isChecked = !isChecked;
                          });
                        },
                        child: Container(
                          height: 48.w,
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              CircleCheck(
                                onChanged: (value) {},
                                value: isChecked,
                                readOnly: true,
                              ),
                              SizedBox(
                                width: 8.w,
                              ),
                              Expanded(
                                child: Text(
                                  '유의사항을 모두 확인했으며 회원을 탈퇴약관에 동의합니다.',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const BottomPadding(),
            ],
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: CommonSize.commonBottom,
          child: Row(
            children: [
              BorderButton(
                  width: 96.w,
                  onPressed: () {
                    if (isChecked) {
                      widget.onPress();
                    }
                  },
                  text: '다음'),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    widget.onCancel();
                  },
                  text: '취소하기',
                  confirm: true,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
