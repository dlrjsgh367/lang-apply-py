import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/models/chat_room_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/posting_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/border_button.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_two_button_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/dot_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SeekerApplyDetailBottomAppBarWidget extends StatelessWidget {
  const SeekerApplyDetailBottomAppBarWidget({
    super.key,
    required this.isLoading,
    required this.hasChatRoom,
    required this.type,
    required this.applyData,
    required this.cancelJobPosting,
    required this.blockCompany,
    required this.deAcceptJobPosting,
    required this.acceptJobPosting,
    required this.savePageLog,
    required this.generateDocument,
    required this.profileData,
  });

  final bool isLoading;
  final bool hasChatRoom;
  final String type;
  final PostingModel applyData;
  final Function cancelJobPosting;
  final Function blockCompany;
  final Function deAcceptJobPosting;
  final Function acceptJobPosting;
  final Function savePageLog;
  final Function generateDocument;
  final ProfileModel profileData;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.white,
      child: Container(
          height: 50.w,
          color: Colors.white,
          child: !isLoading
              ? type == 'apply'
                  ? CommonButton(
                      onPressed: () {
                        if (applyData.postingRequiredStatus == 1) {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertTwoButtonDialog(
                                  alertTitle: localization.cancelProposal,
                                  alertContent: localization.confirmProposalCancellation,
                                  alertConfirm: localization.cancelProposal,
                                  alertCancel: localization.close,
                                  onConfirm: () {
                                    cancelJobPosting(applyData.key);
                                  },
                                );
                              });
                        }
                      },
                      text: localization.cancelProposal,
                      confirm: applyData.postingRequiredStatus == 1)
                  : Row(
                      children: [
                        BorderButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertTwoButtonDialog(
                                    alertTitle: localization.blockApplicant,
                                    alertContent:
                                        localization.confirmApplicantBlock,
                                    alertConfirm: localization.block,
                                    alertCancel: localization.cancel,
                                    onConfirm: () {
                                      blockCompany(applyData.profileKey);
                                      context.pop(context);
                                    },
                                  );
                                });
                          },
                          text: 'text',
                          width: applyData.postingRequiredStatus == 2
                              ? 115.w
                              : 55.w,
                          child: Text(
                            localization.block,
                            style: TextStyle(
                                fontSize: 15.w,
                                color: CommonColors.gray4d,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        if (applyData.postingRequiredStatus != 2 &&
                            applyData.postingRequiredStatus != 3)
                          Row(
                            children: [
                              SizedBox(
                                width: 5.w,
                              ),
                              BorderButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertTwoButtonDialog(
                                          alertTitle: localization.rejectApplication,
                                          alertContent: localization.confirmApplicationRejection,
                                          alertConfirm: localization.reject,
                                          alertCancel: localization.cancel,
                                          onConfirm: () {
                                            deAcceptJobPosting(applyData.key);
                                            context.pop(context);
                                          },
                                        );
                                      });
                                },
                                text: 'text',
                                width: 55.w,
                                color: false
                                    ? CommonColors.grayE6
                                    : const Color(0xffD8DCE4),
                                backColor: false
                                    ? CommonColors.grayE6
                                    : const Color(0xffffffff),
                                child: Text(
                                  localization.reject,
                                  style: TextStyle(
                                      fontSize: 15.w,
                                      color: false
                                          ? Colors.white
                                          : CommonColors.gray4d,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(
                          width: 5.w,
                        ),
                        if (applyData.postingRequiredStatus != 2)
                          Expanded(
                            child: CommonButton(
                              fontSize: 15,
                              onPressed: () {
                                if ((applyData.postingRequiredStatus == 1 ||
                                    applyData.postingRequiredStatus == 4)) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertTwoButtonDialog(
                                          alertTitle: localization.acceptApplication,
                                          alertContent: localization.confirmApplicationAcceptance,
                                          alertConfirm: localization.accept,
                                          alertCancel: localization.cancel,
                                          onConfirm: () {
                                            acceptJobPosting(applyData.key);
                                            context.pop(context);
                                          },
                                        );
                                      });
                                }
                              },
                              text: applyData.postingRequiredStatus == 3
                                  ? localization.rejected
                                  : localization.applicationAccepted,
                              confirm: (applyData.postingRequiredStatus == 1 ||
                                  applyData.postingRequiredStatus == 4),
                            ),
                          ),
                        if (applyData.postingRequiredStatus == 2)
                          Expanded(
                            child: CommonButton(
                              fontSize: 15,
                              onPressed: () {
                                if (hasChatRoom) {
                                  savePageLog();
                                  generateDocument(profileData);
                                } else {
                                  showDefaultToast(localization.chatAvailableAfterStart);
                                }
                              },
                              text: localization.resumePDF,
                              confirm: true,
                            ),
                          ),
                      ],
                    )
              : null),
    );
  }
}
