import 'package:chodan_flutter_app/core/utils/convert_service.dart';
import 'package:chodan_flutter_app/core/utils/toast_utils.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/style/color_style.dart';
import 'package:chodan_flutter_app/widgets/etc/dot_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkerProfileBottomWidget extends StatelessWidget {
  const WorkerProfileBottomWidget({
    super.key,
    required this.profileData,
    required this.downloadFile,
    required this.hasChatRoom,
  });

  final ProfileModel profileData;
  final Function downloadFile;
  final bool hasChatRoom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.w),
        if (profileData.profileEducations.isNotEmpty ||
            profileData.profileCareers.isNotEmpty)
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 28.w),
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
                if (profileData.profileEducations.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localization.educationLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CommonColors.black,
                        ),
                      ),
                      SizedBox(height: 16.w),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: CommonColors.gray100,
                        ),
                        padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0;
                                i < profileData.profileEducations.length;
                                i++)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 108.w,
                                    child: Text(
                                      profileData
                                          .profileEducations[i].schoolType,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: CommonColors.gray66,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      ' ${profileData.profileEducations[i].schoolName} (${profileData.profileEducations[i].graduationStatus})',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.black2b),
                                    ),
                                  ),
                                  if (i !=
                                      profileData.profileEducations.length - 1)
                                    SizedBox(height: 16.w),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (profileData.profileEducations.isNotEmpty &&
                    profileData.profileCareers.isNotEmpty)
                  SizedBox(
                    height: 36.w,
                  ),
                if (profileData.profileCareers.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Text(
                          localization.experienced,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: CommonColors.black,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          ProfileService.calculateTotalCareer(
                              profileData.profileCareers),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: CommonColors.black2b,
                          ),
                        )
                      ]),
                      SizedBox(height: 16.w),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8.w,
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 9.5.w,
                              top: 45.w,
                              bottom: 50.w,
                              child: DottedLine(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var i = 0;
                                    i < profileData.profileCareers.length;
                                    i++)
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: i == 0 ? 0 : 16.w),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18.w,
                                          height: 18.w,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: CommonColors.white,
                                            border: Border.all(
                                                width: 1.w,
                                                color: const Color.fromRGBO(
                                                    239, 44, 68, 0.5)),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 4.w,
                                                color: const Color.fromRGBO(
                                                    0, 0, 0, 0.16),
                                              )
                                            ],
                                          ),
                                          child: Container(
                                            width: 10.w,
                                            height: 10.w,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: CommonColors.red,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 25.w,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                ProfileService
                                                    .formatCareerPeriodCareer(
                                                        profileData
                                                            .profileCareers[i]
                                                            .workStartDate,
                                                        profileData
                                                            .profileCareers[i]
                                                            .workEndDate),
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: CommonColors.grayB2,
                                                ),
                                              ),
                                              Text(
                                                profileData.profileCareers[i]
                                                    .companyName,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.black2b,
                                                ),
                                              ),
                                              Text(
                                                profileData.profileCareers[i]
                                                    .workContent,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  color: CommonColors.gray66,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
        SizedBox(height: 16.w),
        Container(
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.fromLTRB(20.w, 28.w, 20.w, 28.w),
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
              Text(
                localization.849,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CommonColors.black,
                ),
              ),
              SizedBox(height: 16.w),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0.w),
                  color: CommonColors.gray100,
                ),
                padding: EdgeInsets.fromLTRB(16.w, 20.w, 16.w, 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.813,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.4.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileAreas.length;
                                  i++)
                                Text(
                                  profileData.profileAreas[i].areaInfo.dongName,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.294,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileJobs.length;
                                  i++)
                                Text(
                                  profileData.profileJobs[i].name,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.817,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileWorkType.length;
                                  i++)
                                Text(
                                  profileData.profileWorkType[i].workTypeName,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.workDuration,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileWorkPeriod.length;
                                  i++)
                                Text(
                                  profileData
                                      .profileWorkPeriod[i].workPeriodName,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.workingDays,
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.4.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileWorkDays.length;
                                  i++)
                                Text(
                                  profileData.profileWorkDays[i].workDayName,
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.w),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            localization.workingHours2,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: CommonColors.gray66,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (int i = 0;
                                  i < profileData.profileWorkTimes.length;
                                  i++)
                                Text(
                                  '${profileData.profileWorkTimes[i].workTimeName} ${ConvertService.setWorkHour(profileData.profileWorkTimes[i].workTimeStartTime, profileData.profileWorkTimes[i].workTimeEndTime)}',
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: CommonColors.black2b),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 36.w),
              Text(
                localization.850,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: CommonColors.black,
                ),
              ),
              SizedBox(height: 16.w),
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    color: CommonColors.grayE6,
                    width: 1.w,
                  ),
                ),
                child: profileData.introduce != '' ||
                        profileData.profileKeywords.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (profileData.introduce != '')
                            Text(
                              profileData.introduce,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4.sp,
                                color: CommonColors.gray66,
                              ),
                            ),
                          if (profileData.introduce != '' &&
                              profileData.profileKeywords.isNotEmpty)
                            SizedBox(height: 20.w),
                          if (profileData.profileKeywords.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (int i = 0;
                                    i < profileData.profileKeywords.length;
                                    i++)
                                  Container(
                                    padding: EdgeInsets.fromLTRB(
                                        12.w, 6.w, 12.w, 6.w),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4.0.w),
                                      color: CommonColors.gray100,
                                    ),
                                    child: Text(
                                      profileData
                                          .profileKeywords[i].keywordName,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        height: 1.4.sp,
                                        color: CommonColors.gray66,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      )
                    : Text(
                        '-',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: CommonColors.gray80,
                        ),
                      ),
              ),
              if (profileData.files[0].key > 0)
                Padding(
                  padding: EdgeInsets.only(top: 36.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        localization.172,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: CommonColors.black,
                        ),
                      ),
                      SizedBox(height: 16.w),
                      for (int i = 0; i < profileData.files.length; i++)
                        Column(children: [
                          GestureDetector(
                            onTap: () {
                              if (hasChatRoom) {
                                downloadFile(profileData.files[i].url,
                                    profileData.files[i].name);
                              } else {
                                showDefaultToast(localization.836);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0.w),
                                color: CommonColors.gray100,
                              ),
                              padding:
                                  EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 20.w),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/icon/iconFile.png',
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (profileData.profileFileInfo.length >
                                              i &&
                                          profileData.profileFileInfo[i]
                                                  .categoryName !=
                                              '')
                                        Text(
                                          '[${profileData.profileFileInfo[i].categoryName}]',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: CommonColors.gray4d,
                                          ),
                                        ),
                                      Text(
                                        profileData.files[i].name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: CommonColors.gray4d,
                                        ),
                                      ),
                                    ],
                                  )),
                                  Text(
                                    ProfileService.formatFileSize(
                                        profileData.files[i].size),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: CommonColors.grayB2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10.w),
                        ]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
