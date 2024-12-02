import 'dart:math';

import 'package:chodan_flutter_app/core/common/extended_img_widget.dart';
import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkerProfileWidget extends StatelessWidget {
  const WorkerProfileWidget({
    super.key,
    required this.widgetKey,
    required this.profileData,
    required this.matchedStatus,
    required this.hasChatRoom,
    required this.showAttachment,
    required this.showBottomEvaluate,
    required this.evaluateData,
    required this.currentPosition,
  });

  final GlobalKey widgetKey;
  final ProfileModel profileData;
  final bool matchedStatus;
  final bool hasChatRoom;
  final Function showAttachment;
  final Function showBottomEvaluate;
  final EvaluateModel? evaluateData;
  final Map<String, dynamic> currentPosition;

  double distanceBetween(double endLatitude, double endLongitude) {
    const double radius = 6371000.0;
    double degreesToRadians(degrees) {
      return degrees * (pi / 180);
    }

    double deltaLatitude =
        degreesToRadians(endLatitude - currentPosition['lat']);
    double deltaLongitude =
        degreesToRadians(endLongitude - currentPosition['lng']);
    double a = sin(deltaLatitude / 2) * sin(deltaLatitude / 2) +
        cos(degreesToRadians(currentPosition['lat'])) *
            cos(degreesToRadians(endLatitude)) *
            sin(deltaLongitude / 2) *
            sin(deltaLongitude / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c / 1000;
    return double.parse(distance.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0.w),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: CommonColors.grayF2,
            offset: Offset(0, 2.w),
            blurRadius: 16.w,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                width: double.infinity,
                child: AspectRatio(
                  key: widgetKey,
                  aspectRatio: 1 / 1,
                  child:
                  profileData.profileImg!.key != 0
                      ? ExtendedImgWidget(
                          imgUrl: profileData.profileImg!.url,
                          imgFit: BoxFit.cover,
                        )
                      : Container(
                          color: Color(
                            ConvertService.returnBgColor(
                              profileData.userInfo.color,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Image.asset(
                            // 'assets/images/icon/iconPersonJob.png',
                            'assets/images/icon/imgProfileSeeker.png',
                            width: 150.w,
                            height: 150.w,
                          ),
                        ),
                ),
              ),
              Positioned(
                  top: 12.w,
                  right: 12.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CommonColors.red,
                      borderRadius: BorderRadius.circular(100.w),
                      border: Border.all(
                        width: 1.w,
                        color: CommonColors.red,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(8.w, 3.w, 8.w, 3.w),
                    child: Text(
                      textAlign: TextAlign.center,
                      profileData.userInfo.jobSeekingStatus,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: CommonColors.white,
                      ),
                    ),
                  )),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.w),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${ConvertService.returnMaskingSiGuDong(matchedStatus, profileData.userInfo.si, profileData.userInfo.gu, profileData.userInfo.dongName)} ${distanceBetween(profileData.userInfo.lat, profileData.userInfo.long)}km',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: CommonColors.gray80,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (matchedStatus) {
                          showBottomEvaluate(evaluateData!);
                        }
                      },
                      child: Image.asset(
                        'assets/images/icon/IconRoundStarActive.png',
                        width: 20.w,
                        height: 20.w,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${profileData.profileScore}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: CommonColors.gray80,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.w),
                Row(
                  children: [
                    Text(
                      ConvertService.returnMaskingName(
                          matchedStatus, profileData.userInfo.name),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.gray4d,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      '(${ConvertService.calculateAge(profileData.userInfo.birth)}세, ${returnConditionGenderNameFromParam(profileData.userInfo.gender)})',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: CommonColors.gray4d,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/icon/IconAddress.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        '주소',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray80,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        ConvertService.returnMaskingAddress(
                            matchedStatus,
                            profileData.userInfo.si,
                            profileData.userInfo.gu,
                            profileData.userInfo.address,
                            profileData.userInfo.addressDetail),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: CommonColors.black2b,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 14.w),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/IconCall.png',
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        '연락처',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray80,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        ConvertService.formatPhoneNumber(
                            ConvertService.returnMaskingHp(matchedStatus,
                                profileData.userInfo.phoneNumber)),
                        style: TextStyle(
                          fontSize: 15.sp,
                          height: 1.4.sp,
                          color: CommonColors.black2b,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 14.w),
                Row(
                  children: [
                    Image.asset(
                      'assets/images/icon/IconEmail.png',
                      fit: BoxFit.cover,
                      width: 20.w,
                      height: 20.w,
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 60.w,
                      child: Text(
                        '이메일',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray80,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        // profileData!.userInfo.userId,
                        ConvertService.returnMaskingEmail(
                            matchedStatus, profileData.userInfo.userId),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: CommonColors.black2b,
                        ),
                      ),
                    )
                  ],
                ),
                if (profileData.files[0].key > 0)
                  Padding(
                    padding: EdgeInsets.only(
                      top: 14.w,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/icon/iconFileBlack.png',
                          fit: BoxFit.cover,
                          width: 20.w,
                          height: 20.w,
                        ),
                        SizedBox(width: 4.w),
                        SizedBox(
                          width: 60.w,
                          child: Text(
                            '첨부파일',
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.4.sp,
                              fontWeight: FontWeight.w500,
                              color: CommonColors.gray80,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${profileData.files[0].name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.4.sp,
                                    fontWeight: FontWeight.w500,
                                    color: CommonColors.gray80,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              GestureDetector(
                                onTap: () {
                                  if (hasChatRoom) {
                                    showAttachment(
                                        name: profileData.files[0].name,
                                        files: profileData.files);
                                  } else {
                                    showDefaultToast('대화가 시작 된 후 확인 가능합니다.');
                                  }
                                },
                                child: Row(
                                  children: [
                                    if (profileData.files.length > 1)
                                      Text(
                                        '외 ${profileData.files.length - 1}개',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          height: 1.4.sp,
                                          color: CommonColors.black2b,
                                        ),
                                      ),
                                    SizedBox(width: 4.w),
                                    Image.asset(
                                      'assets/images/icon/iconArrowRight.png',
                                      width: 16.w,
                                      height: 16.w,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                SizedBox(height: 24.w),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (int i = 0; i < profileData.profileKeywords.length; i++)
                      Container(
                        padding: EdgeInsets.fromLTRB(12.w, 6.w, 12.w, 6.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0.w),
                          color: CommonColors.gray100,
                        ),
                        child: Text(
                          profileData.profileKeywords[i].keywordName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: CommonColors.gray66,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 24.w),
                Divider(
                    height: 1.w, thickness: 1.w, color: CommonColors.grayF2),
                SizedBox(height: 12.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon/IconEducationSeeker.png',
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Text(
                                  '학력',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8.w,
                            ),
                            profileData.profileEducations.isNotEmpty
                                ? Wrap(
                                    children: [
                                      for (var i = 0;
                                          i <
                                              profileData
                                                  .profileEducations.length;
                                          i++)
                                        Padding(
                                          padding: EdgeInsets.only(right: 4.w),
                                          child: Text(
                                            '${profileData.profileEducations[i].schoolType} ${profileData.profileEducations[i].graduationStatus}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Text(
                                    '미기재',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon/IconCareerSeeker.png',
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Text(
                                  '경력',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8.w,
                            ),
                            profileData.profileCareers.isNotEmpty
                                ? Text(
                                    ProfileService.calculateTotalCareer(
                                        profileData.profileCareers),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  )
                                : Text(
                                    '신입',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(children: [
                              Image.asset(
                                'assets/images/icon/IconDateSeeker.png',
                                width: 18.w,
                                height: 16.w,
                              ),
                              SizedBox(
                                width: 4.w,
                              ),
                              Text(
                                '요일',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: CommonColors.gray80,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: 8.w,
                            ),
                            profileData.profileWorkDays.isNotEmpty
                                ? Wrap(
                                    children: [
                                      for (int i = 0;
                                          i <
                                              profileData
                                                  .profileWorkDays.length;
                                          i++)
                                        Padding(
                                          padding: EdgeInsets.only(right: 4.w),
                                          child: Text(
                                            profileData
                                                .profileWorkDays[i].workDayName,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: CommonColors.black2b,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 14.w, 0, 14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/icon/IconTimeSeeker.png',
                                  width: 18.w,
                                  height: 18.w,
                                ),
                                SizedBox(
                                  width: 4.w,
                                ),
                                Text(
                                  '시간',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: CommonColors.gray80,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8.w,
                            ),
                            profileData.profileWorkTimes.isNotEmpty
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      for (int i = 0;
                                          i <
                                              profileData
                                                  .profileWorkTimes.length;
                                          i++)
                                        Text(
                                          '${profileData.profileWorkTimes[i].workTimeName} ${ConvertService.setWorkHour(profileData.profileWorkTimes[i].workTimeStartTime, profileData.profileWorkTimes[i].workTimeEndTime)}',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.black2b,
                                          ),
                                        ),
                                    ],
                                  )
                                : Text(
                                    '-',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
