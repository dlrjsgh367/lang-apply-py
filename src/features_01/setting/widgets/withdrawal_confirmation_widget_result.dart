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
                        localization.experiencingIssuesWithService,
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
                                  localization.positionProposalOffNoSuggestions,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.profilePauseForJobSearchOrRest,
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
                                  localization.accountDeletionWarningInformationLost,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.documentsAndRatingsDeletedOnAccountDeletion,
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
                                  localization.blockAndReportForInappropriateBehavior,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.blockOrReportForUnpleasantPostsOrProposals,
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
                                  localization.accountDeletionPreventsRejoining,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.rejoiningRestrictionsForUsedEmailOrSocialID,
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
                                  localization.addressOrPhoneNumberChanged,
                                  style: TextStyles.withdrawalError,
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  localization.editMemberOrCompanyInfoForAddressUpdate,
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
