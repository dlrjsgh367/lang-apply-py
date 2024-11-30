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
                        localization.preDeletionInformationCheck,
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
                                    localization.personalDataAndServiceRecordsDeletedOnDeletion,
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
                                    localization.rejoiningRestrictionsForDeletedAccounts,
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
                                        localization.refundForUnusedCoinsFollowsPolicy,
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
                                              localization.noRefundForFreeCoins,
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
                                  localization.acceptAndProceedWithAccountDeletion,
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
                  text: localization.nextStep),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    widget.onCancel();
                  },
                  text: localization.cancelAction,
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
