import 'package:chodan_flutter_app/enum/condition_gender_enum.dart';
import 'package:chodan_flutter_app/features/mypage/service/profile_service.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static createProfilePdf(ProfileModel profileData) async {
    final pdf = pw.Document();
    final customFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansKR-Medium.ttf'));
    final imageData =
        await rootBundle.load('assets/images/appbar/logoChodan.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());
    pw.ImageProvider profileImage;
    if (profileData.profileImg != null &&
        profileData.profileImg!.url.isNotEmpty) {
      final provider =
          await flutterImageProvider(NetworkImage(profileData.profileImg!.url));
      profileImage = provider;
    } else {
      final profileImageData =
          await rootBundle.load('assets/images/default/imgDefault3.png');
      profileImage = pw.MemoryImage(profileImageData.buffer.asUint8List());
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(20, 20, 20, 20),
        build: (context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  localization.804,
                  style: pw.TextStyle(font: customFont, fontSize: 20),
                ),
                pw.SizedBox(
                  height: 15,
                ),
                buildProfileRow(
                    localization.805,
                    CommonProfileText(
                      profileData.profileTitle,
                      customFont,
                    ),
                    customFont),
                buildProfileRow(
                    localization.749,
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 80,
                          height: 80,
                          child: pw.Image(
                            profileImage,
                            fit: pw.BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    customFont),

                buildProfileRow(
                    localization.701,
                    CommonProfileText(profileData.userInfo.name, customFont),
                    customFont),
                buildProfileRow(
                    localization.gender,
                    CommonProfileText(
                      returnConditionGenderNameFromParam(
                        profileData.userInfo.gender,
                      ),
                      customFont,
                    ),
                    customFont),
                //
                // calculateAge
                buildProfileRow(
                    localization.age,
                    CommonProfileText(
                      '만 ${calculateAge(profileData.userInfo.birth)}세',
                      customFont,
                    ),
                    customFont),
                //
                buildProfileRow(
                  localization.806,
                  CommonProfileText(
                    '${profileData.profileScore}',
                    customFont,
                  ),
                  customFont,
                ),
                //
                buildProfileRow(
                  localization.address,
                  CommonProfileText(
                    '${profileData.userInfo.address} ${profileData.userInfo.addressDetail}',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.233,
                  CommonProfileText(
                    profileData.userInfo.phoneNumber,
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.email,
                  CommonProfileText(
                    profileData.userInfo.userId,
                    customFont,
                  ),
                  customFont,
                ),
                //
                buildProfileRow(
                  localization.807,
                  CommonProfileText(
                    profileData.profileEducations.isNotEmpty
                        ? profileData.profileEducations
                            .map((edu) {
                            return '${edu.schoolType} ${edu.graduationStatus} ${edu.schoolName.isNotEmpty ? '(${edu.schoolName})' : ''} / ${edu.graduationDate}';
                          }).join('\n')
                        : localization.206,
                    customFont,
                  ),
                  customFont,
                ),

                buildProfileRow(
                  localization.experienced,
                  profileData.profileCareers.isNotEmpty
                      ? pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: profileData.profileCareers.map((care) {
                            return pw.Container(
                              margin: pw.EdgeInsets.only(bottom: 4),
                              padding: pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#eeeeee'),
                                ),
                              ),
                              child: pw.Column(
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.stretch,
                                children: [
                                  pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Row(
                                          children: [
                                            CommonProfileText(
                                              '기간 : ',
                                              customFont,
                                            ),
                                            pw.Expanded(
                                              child: CommonProfileText(
                                                '${care.workStartDate} ~ ${care.workEndDate}',
                                                customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Row(
                                          children: [
                                            CommonProfileText(
                                              '직종 : ',
                                              customFont,
                                            ),
                                            pw.Expanded(
                                              child: CommonProfileText(
                                                '${care.jobName}',
                                                customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Row(
                                          children: [
                                            CommonProfileText(
                                              '회사명 : ',
                                              customFont,
                                            ),
                                            pw.Expanded(
                                              child: CommonProfileText(
                                                '${care.companyName}',
                                                customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Row(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Expanded(
                                        child: pw.Row(
                                          children: [
                                            CommonProfileText(
                                              '근무형태 : ',
                                              customFont,
                                            ),
                                            pw.Expanded(
                                              child: CommonProfileText(
                                                '${care.workType}',
                                                customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.Row(
                                          children: [
                                            CommonProfileText(
                                              '담당업무 : ',
                                              customFont,
                                            ),
                                            pw.Expanded(
                                              child: CommonProfileText(
                                                '${care.workContent}',
                                                customFont,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      pw.Expanded(
                                        child: pw.SizedBox(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        )
                      : CommonProfileText(
                          localization.newGraduate,
                          customFont,
                        ),
                  customFont,
                ),
                buildProfileRow(
                  localization.813,
                  CommonProfileText(
                    profileData.profileAreas.isNotEmpty
                        ? profileData.profileAreas.map((area) {
                            return area.areaInfo.dongName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),

                buildProfileRow(
                  localization.294,
                  CommonProfileText(
                    profileData.profileJobs.isNotEmpty
                        ? profileData.profileJobs.map((jobs) {
                            return jobs.name;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.814,
                  CommonProfileText(
                    profileData.profileWorkPeriod.isNotEmpty
                        ? profileData.profileWorkPeriod.map((period) {
                            return period.workPeriodName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.815,
                  CommonProfileText(
                    profileData.profileWorkDays.isNotEmpty
                        ? profileData.profileWorkDays.map((days) {
                            return days.workDayName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.816,
                  CommonProfileText(
                    profileData.profileWorkTimes.isNotEmpty
                        ? profileData.profileWorkTimes.map((time) {
                            return time.workTimeName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.817,
                  CommonProfileText(
                    profileData.profileWorkType.isNotEmpty
                        ? profileData.profileWorkType.map((type) {
                            return type.workTypeName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),

                buildProfileRow(
                  localization.300,
                  CommonProfileText(
                    profileData.introduce.isNotEmpty
                        ? profileData.introduce
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
                buildProfileRow(
                  localization.172,
                  profileData.files.isNotEmpty
                      ? pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: profileData.files.map((file) {
                            return pw.Container(
                              margin: pw.EdgeInsets.only(bottom: 4),
                              padding: pw.EdgeInsets.all(5),
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(4),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#eeeeee'),
                                ),
                              ),
                              child:
                              pw.UrlLink(
                                destination: file.url, // 클릭할 때 열릴 URL
                                child:   CommonProfileText(
                                  '${file.url}',
                                  customFont,
                                ),
                              ),


                            );
                          }).toList(),
                        )
                      : CommonProfileText(
                          '-',
                          customFont,
                        ),
                  customFont,
                ),
                buildProfileRow(
                  localization.818,
                  CommonProfileText(
                    profileData.profileKeywords.isNotEmpty
                        ? profileData.profileKeywords.map((keyword) {
                            return keyword.keywordName;
                          }).join(' / ')
                        : '-',
                    customFont,
                  ),
                  customFont,
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf;
  }

  static pw.Widget buildProfileRow(
      String title, pw.Widget content, pw.Font customFont) {
    return pw.Table(
      columnWidths: {
        0: pw.FixedColumnWidth(80.0), // fixed to 100 width
        1: pw.FlexColumnWidth(),
      },
      border: pw.TableBorder.all(
        color: PdfColor.fromHex('#eeeeee'),
        width: 1,
      ),
      children: [
        pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.full,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              color: PdfColor.fromHex('#eeeeee'),
              alignment: pw.Alignment.center,
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 8,
                  font: customFont,
                ),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              child: content,
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget CommonProfileText(String text, pw.Font customFont) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 8,
        font: customFont,
      ),
    );
  }
}

int calculateAge(String antiDate) {
  DateTime birthDate = DateTime.parse(antiDate);

  DateTime today = DateTime.now();
  int age = today.year - birthDate.year;

  // 생일이 지나지 않았다면 나이에서 1을 뺍니다.
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }

  return age;
}


