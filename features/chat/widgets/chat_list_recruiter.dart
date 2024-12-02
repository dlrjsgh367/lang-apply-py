import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/features/mypage/widgets/company_img_widget.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/etc/worker_default_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ChatListRecruiter extends StatelessWidget {
  ChatListRecruiter({super.key, required this.data});

  var data;

  returnLastChatDate(DateTime chatDate) {
    DateTime now = DateTime.now();

    if (DateFormat('yyyy-MM-dd').format(chatDate) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return DateFormat('HH:mm').format(chatDate);
    } else if (DateTime(now.year, now.month, now.day - 1) ==
        DateFormat('yyyy-MM-dd').format(chatDate)) {
      return '어제';
    } else {
      return DateFormat('MM-dd').format(chatDate);
    }
  }

  getDday(DateTime date) {
    // D-day 날짜 설정 (년, 월, 일)
    DateTime dDay = date;

    // 현재 날짜 가져오기
    DateTime now = DateTime.now();

    // D-day 계산 (D-day 날짜 - 현재 날짜)
    Duration difference = dDay.difference(now);

    // D-day 출력
    if (difference.isNegative) {
      return '종료';
    } else if (difference.inDays > 100000) {
      return '무제한';
    } else {
      return 'D-${difference.inDays}';
    }
  }

  checkUserProfileImage() {
    Map<String, dynamic> profile = data.partnerInfo.memberProfiles;
    return profile.isNotEmpty && profile['${data.profileKey}'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(0, 16.w, 0, 16.w),
          decoration: BoxDecoration(
              color: CommonColors.white,
              border: Border(
                  bottom: BorderSide(width: 1.w, color: CommonColors.grayF7))),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  context.push('/chat/profile/${data.profileKey}');
                },
                child: ClipOval(
                  child: checkUserProfileImage() && data.partnerInfo.profileImg['key'] != 0
                      ? SizedBox(
                          width: 64.w,
                          height: 64.w,
                          child: ExtendedImgWidget(
                            imgUrl: data.partnerInfo
                                .memberProfiles['${data.profileKey}'],
                            imgFit: BoxFit.cover,
                          ),
                        )

                          : WorkerDefaultImgWidget(
                              width: 64.w,
                              height: 64.w,
                              colorCode: data.partnerInfo.color,
                              name: data.partnerInfo.name[0],
                            ),
                ),
              ),

              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.push('/chat/detail/${data.id}');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    data.partnerInfo.isUse == 0
                                        ? '탈퇴 회원'
                                        : data.partnerInfo.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.gray4d,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8.w,
                                ),
                                if (data.endAt != null)
                                  Container(
                                    padding:
                                        EdgeInsets.fromLTRB(8.w, 0, 8.w, 0),
                                    alignment: Alignment.center,
                                    height: 18.w,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(500.w),
                                        border: Border.all(
                                            width: 1.w,
                                            color: CommonColors.red)),
                                    child: Text(
                                      getDday(data.endAt.toDate()),
                                      style: TextStyle(
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                          color: CommonColors.red),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            '${returnLastChatDate(data.updated.toDate())}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: CommonColors.grayB2,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 4.w,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              data.msg['lastMsg'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: CommonColors.gray80,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.w,
                          ),
                          if (data.count > 0)
                            Container(
                              width: 18.w,
                              height: 18.w,
                              clipBehavior: Clip.hardEdge,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CommonColors.red),
                              child: Text(
                                data.count.toString(),
                                style: TextStyle(
                                  color: CommonColors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.sp,
                                ),
                              ),
                            )
                        ],
                      ),

                      // Text(data.msg['lastMsg']),
                    ],
                  ),
                ),
              ),
              // Expanded(
              //     child: Column(
              //   crossAxisAlignment:
              //       CrossAxisAlignment.end,
              //   children: [
              //     Text(
              //         '${returnLastChatDate(data.updated.toDate())}'),
              //     if (data.count > 0)
              //       Text('${data.count}'),
              //   ],
              // )),
            ],
          ),
        ),
      ],
    );
  }
}
