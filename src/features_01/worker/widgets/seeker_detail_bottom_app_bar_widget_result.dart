import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/models/chat_room_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/button_style.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/button/common_button.dart';
import 'package:chodan_flutter_app/widgets/etc/dot_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeekerDetailBottomAppBarWidget extends StatelessWidget {
  const SeekerDetailBottomAppBarWidget({
    super.key,
    required this.profileData,
    required this.savePageLog,
    required this.matchedStatus,
    required this.isLoading,
    required this.workerLikesKeyList,
    required this.hasChatRoom,
    required this.showBottomSuggestJobposting,
    required this.toggleLikesWorker,
    required this.generateDocument,
    required this.matchingData,
    required this.isMichinMatching,
    required this.chatRoomData,
    required this.showJobseekerMenuDialog,
  });

  final ProfileModel profileData;
  final Function savePageLog;
  final Function showBottomSuggestJobposting;
  final Function toggleLikesWorker;
  final Function showJobseekerMenuDialog;
  final bool hasChatRoom;
  final bool matchedStatus;
  final ChatRoomModel? chatRoomData;
  final bool isLoading;
  final bool isMichinMatching;
  final List workerLikesKeyList;
  final Function generateDocument;
  final List matchingData;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.white,
      child: Container(
          height: 50.w,
          color: Colors.white,
          child: !isLoading
              ? matchedStatus
                  ? Row(
                      children: [
                        ElevatedButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            fixedSize: Size.fromHeight(50.w),
                            backgroundColor: CommonColors.white,
                            side: BorderSide(
                              color: CommonColors.gray100,
                              width: 1.w,
                            ),
                          ).copyWith(
                            overlayColor: ButtonStyles.overlayNone,
                          ),
                          onPressed: () => {},
                          child: Container(
                            width: 115.w,
                            height: 48.w,
                            padding: EdgeInsets.fromLTRB(10.w, 0.w, 10.w, 0.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              color: CommonColors.white,
                            ),
                            child: CommonButton(
                              confirm: true,
                              backColor: CommonColors.white,
                              textColor: CommonColors.black,
                              onPressed: () {
                                if (hasChatRoom) {
                                  savePageLog();
                                  generateDocument(profileData);
                                } else {
                                  showDefaultToast(localization.chatAvailableAfterStart);
                                }
                              },
                              text: localization.resumePDF,
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: CommonButton(
                            confirm: true,
                            onPressed: () {
                              showJobseekerMenuDialog(
                                  matchingData[0],
                                  profileData.userInfo,
                                  hasChatRoom,
                                  chatRoomData,
                                  isMichinMatching);
                            },
                            text: localization.startConversation,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        ElevatedButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            fixedSize: Size.fromHeight(50.w),
                            backgroundColor: CommonColors.white,
                            side: BorderSide(
                              color: CommonColors.gray100,
                              width: 1.w,
                            ),
                          ).copyWith(
                            overlayColor: ButtonStyles.overlayNone,
                          ),
                          onPressed: () => {
                            toggleLikesWorker(
                                workerLikesKeyList, profileData.key)
                          },
                          child: Container(
                            width: 115.w,
                            height: 48.w,
                            padding: EdgeInsets.fromLTRB(10.w, 0.w, 10.w, 0.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.w),
                              color: CommonColors.white,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  workerLikesKeyList.contains(profileData.key)
                                      ? 'assets/images/icon/iconHeartActive.png'
                                      : 'assets/images/icon/iconRedHeart.png',
                                  width: 20.w,
                                  height: 20.w,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  localization.favoriteCandidate,
                                  style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4.sp,
                                      color: CommonColors.gray4d),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Expanded(
                          child: CommonButton(
                            confirm: true,
                            onPressed: () {
                              showBottomSuggestJobposting(profileData.key);
                            },
                            text: localization.makeJobProposal,
                          ),
                        ),
                      ],
                    )
              : null),
    );
  }
}
