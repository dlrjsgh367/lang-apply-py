import 'package:chodan_flutter_app/features/contract/service/contract_service.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ContractTemplate {
  static returnTypeContractTitle(String type) {
    switch (type) {
      case 'STANDARD':
        return localization.standardLaborContract;
      case 'SHORT':
        return localization.shortTermEmployeeContract;
      case 'YOUNG':
        return localization.minorEmployeeContract;
      case 'CONSTRUCTION':
        return localization.constructionDailyEmployeeContract;
      default:
        return localization.standardLaborContract;
    }
  }

  static returnTime(String time, String type) {
    if (time.length > 0) {
      if (type == 'hour') {
        return time.substring(0, 2);
      } else if (type == 'min') {
        return time.substring(3, 5);
      }
    }
    return '';
  }

  static Future<List<pw.Widget>> returnNormalFistContract(
      dynamic params,
      dynamic recruiterInfo,
      Uint8List signImgData,
      dynamic recruiterSignUrl,
      bool isJobseekerAgree,
      String type,
      dynamic detailData) async {
    final customFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/NotoSansKR-Medium.ttf'));
    final imageData =
        await rootBundle.load('assets/images/appbar/logoChodan.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());
    return [
      pw.Image(image, height: 30),
      pw.Container(
          margin: const pw.EdgeInsets.fromLTRB(0, 10, 0, 15),
          height: 1,
          color: PdfColor.fromHex('#ededed')),
      pw.Text(
        returnTypeContractTitle(type),
        style: pw.TextStyle(font: customFont, fontSize: 12),
      ),
      pw.SizedBox(height: 15),   
      pw.DecoratedBox(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            width: 1,
            color: PdfColor.fromHex('#cbcbcb'),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(2),
                          border: pw.Border.all(
                            width: 1,
                            color: PdfColor.fromHex('#e2e2e2'),
                          ),
                        ),
                        width: 120,
                        padding: const pw.EdgeInsets.all(5),
                        margin: const pw.EdgeInsets.only(right: 5),
                        child: pw.Text(
                          isJobseekerAgree
                              ? detailData.chatRecruiterDto.meName
                              : recruiterInfo.name,
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        localization.contractTarget1,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(2),
                          border: pw.Border.all(
                            width: 1,
                            color: PdfColor.fromHex('#e2e2e2'),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        margin: const pw.EdgeInsets.only(right: 5),
                        child: pw.Text(
                          '${params['ccdEmployeeName']}',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        localization.contractTarget2,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(
                      '1. ${localization.laborContractPeriod}:',
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(2),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#e2e2e2'),
                      ),
                    ),
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      DateFormat('yyyy')
                          .format(DateTime.parse(params['ccdWorkStartDate'])),
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                    child: pw.Text(
                      localization.year,
                      style: pw.TextStyle(
                        font: customFont,
                        fontSize: 9,
                        color: PdfColor.fromHex('#cbcbcb'),
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(2),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#e2e2e2'),
                      ),
                    ),
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      DateFormat('MM')
                          .format(DateTime.parse(params['ccdWorkStartDate'])),
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                    child: pw.Text(
                      localization.month,
                      style: pw.TextStyle(
                        font: customFont,
                        fontSize: 9,
                        color: PdfColor.fromHex('#cbcbcb'),
                      ),
                    ),
                  ),
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(2),
                      border: pw.Border.all(
                        width: 1,
                        color: PdfColor.fromHex('#e2e2e2'),
                      ),
                    ),
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.Text(
                      DateFormat('dd')
                          .format(DateTime.parse(params['ccdWorkStartDate'])),
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.fromLTRB(3, 0, 10, 0),
                    child: pw.Text(
                      localization.dayStart,
                      style: pw.TextStyle(
                        font: customFont,
                        fontSize: 9,
                        color: PdfColor.fromHex('#cbcbcb'),
                      ),
                    ),
                  ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        DateFormat('yyyy')
                            .format(DateTime.parse(params['ccdWorkEndDate'])),
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                    ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                      child: pw.Text(
                        localization.year,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                    ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        DateFormat('MM')
                            .format(DateTime.parse(params['ccdWorkEndDate'])),
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                    ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                      child: pw.Text(
                        localization.month,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                    ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        DateFormat('dd')
                            .format(DateTime.parse(params['ccdWorkEndDate'])),
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                    ),
                  if (params['ccdWorkEndDate'] != '')
                    pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                      child: pw.Text(
                        localization.dayEnd,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(
                      '2. ${localization.workplace}:',
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        '${params['ccdWorkplace']}',
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(
                      '3. ${localization.jobDescription}:',
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(2),
                        border: pw.Border.all(
                          width: 1,
                          color: PdfColor.fromHex('#e2e2e2'),
                        ),
                      ),
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        '${params['ccdJobDescription']}',
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(
                      '4. ${localization.workingHours}:',
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  params['ccdWorkScheduleType'] == 2
                      ? pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              for (var data in params['shortWorkingClassList'])
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.stretch,
                                  children: [
                                    pw.Row(
                                      children: [
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            borderRadius:
                                                pw.BorderRadius.circular(2),
                                            border: pw.Border.all(
                                              width: 1,
                                              color:
                                                  PdfColor.fromHex('#e2e2e2'),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(5),
                                          child: pw.Text(
                                            '${returnTime(data['ssStartTime'], 'hour')}',
                                            style: pw.TextStyle(
                                                font: customFont, fontSize: 9),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.fromLTRB(
                                              3, 0, 5, 0),
                                          child: pw.Text(
                                            localization.hour2,
                                            style: pw.TextStyle(
                                              font: customFont,
                                              fontSize: 9,
                                              color:
                                                  PdfColor.fromHex('#cbcbcb'),
                                            ),
                                          ),
                                        ),
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            borderRadius:
                                                pw.BorderRadius.circular(2),
                                            border: pw.Border.all(
                                              width: 1,
                                              color:
                                                  PdfColor.fromHex('#e2e2e2'),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(5),
                                          child: pw.Text(
                                            '${returnTime(data['ssStartTime'], 'min')}',
                                            style: pw.TextStyle(
                                                font: customFont, fontSize: 9),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.fromLTRB(
                                              3, 0, 10, 0),
                                          child: pw.Text(
                                            localization.minuteStart,
                                            style: pw.TextStyle(
                                              font: customFont,
                                              fontSize: 9,
                                              color:
                                                  PdfColor.fromHex('#cbcbcb'),
                                            ),
                                          ),
                                        ),
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            borderRadius:
                                                pw.BorderRadius.circular(2),
                                            border: pw.Border.all(
                                              width: 1,
                                              color:
                                                  PdfColor.fromHex('#e2e2e2'),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(5),
                                          child: pw.Text(
                                            '${returnTime(data['ssEndTime'], 'hour')}',
                                            style: pw.TextStyle(
                                                font: customFont, fontSize: 9),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.fromLTRB(
                                              3, 0, 5, 0),
                                          child: pw.Text(
                                            localization.hour2,
                                            style: pw.TextStyle(
                                              font: customFont,
                                              fontSize: 9,
                                              color:
                                                  PdfColor.fromHex('#cbcbcb'),
                                            ),
                                          ),
                                        ),
                                        pw.Container(
                                          decoration: pw.BoxDecoration(
                                            borderRadius:
                                                pw.BorderRadius.circular(2),
                                            border: pw.Border.all(
                                              width: 1,
                                              color:
                                                  PdfColor.fromHex('#e2e2e2'),
                                            ),
                                          ),
                                          padding: const pw.EdgeInsets.all(5),
                                          child: pw.Text(
                                            '${returnTime(data['ssEndTime'], 'min')}',
                                            style: pw.TextStyle(
                                                font: customFont, fontSize: 9),
                                          ),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.fromLTRB(
                                              3, 0, 10, 0),
                                          child: pw.Text(
                                            localization.minuteEnd,
                                            style: pw.TextStyle(
                                              font: customFont,
                                              fontSize: 9,
                                              color:
                                                  PdfColor.fromHex('#cbcbcb'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 5),
                                    pw.Row(
                                      children: [
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.fromLTRB(
                                              3, 0, 5, 0),
                                          child: pw.Text(
                                            localization.breakTimeProvided(data['ssRestHour']),
                                            style: pw.TextStyle(
                                              font: customFont,
                                              fontSize: 9,
                                              color:
                                                  PdfColor.fromHex('#cbcbcb'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 5),
                                  ],
                                ),
                            ],
                          ),
                        )
                      : pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                            children: [
                              pw.Row(
                                children: [
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      '${returnTime(params['ccdWorkingStartTime'], 'hour')}',
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 5, 0),
                                    child: pw.Text(
                                      localization.hour2,
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      '${returnTime(params['ccdWorkingStartTime'], 'min')}',
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 10, 0),
                                    child: pw.Text(
                                      localization.minuteStart,
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      '${returnTime(params['ccdWorkingEndTime'], 'hour')}',
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 5, 0),
                                    child: pw.Text(
                                      localization.hour2,
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
                                      ),
                                    ),
                                  ),
                                  pw.Container(
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      '${returnTime(params['ccdWorkingEndTime'], 'min')}',
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 10, 0),
                                    child: pw.Text(
                                      localization.minuteEnd,
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              pw.SizedBox(height: 5),
                              pw.Row(
                                children: [
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 5, 0),
                                    child: pw.Text(
                                      localization.breakTimeProvided(params['ccdRestHour']),
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
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
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(
                      '5. ${localization.workDaysOff}:',
                      style: pw.TextStyle(font: customFont, fontSize: 9),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Row(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.weekly,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Container(
                              width: 120,
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(2),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#e2e2e2'),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                '${params['ccdWorkingDays'] ?? ''}',
                                style:
                                    pw.TextStyle(font: customFont, fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.workScheduleDailyOrSpecific,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                        pw.Row(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.weeklyRestDay,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            if (params['holidayLists'] != null &&
                                params['holidayLists'].isNotEmpty)
                              pw.Container(
                                width: 120,
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Row(
                                  children: [
                                    for (var weekday in params['holidayLists'])
                                      pw.Text(
                                        '${ContractService.returnWeekday(weekday)}',
                                        style: pw.TextStyle(
                                            font: customFont, fontSize: 9),
                                      ),
                                  ],
                                ),
                              ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.dayOfWeek,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
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
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    '6. ${localization.wage}:',
                    style: pw.TextStyle(font: customFont, fontSize: 9),
                  ),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 5),
                        width: 115,
                        child: pw.Text(
                          '- ${ContractService.returnSalaryType(params['ccdSalaryType'])}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(2),
                          border: pw.Border.all(
                            width: 1,
                            color: PdfColor.fromHex('#e2e2e2'),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '${params['ccdSalaryAmount'].toInt()}원',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.won,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 5),
                        width: 115,
                        child: pw.Text(
                          '- ${localization.bonus}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.exists,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(right: 10),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdBonusExist'] == 1
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(2),
                          border: pw.Border.all(
                            width: 1,
                            color: PdfColor.fromHex('#e2e2e2'),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          params['ccdBonusAmount'].toString().isNotEmpty
                              ? params['ccdBonusAmount'].toString()
                              : '',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 10, 0),
                        child: pw.Text(
                          localization.won,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.notExists,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdBonusExist'] == 1
                              ? PdfColors.white
                              : PdfColors.black,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 5),
                        width: 115,
                        child: pw.Text(
                          '- ${localization.otherAllowances}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.exists,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(right: 10),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['otherSalaryClassList'].isNotEmpty
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.notExists,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['otherSalaryClassList'].isNotEmpty
                              ? PdfColors.white
                              : PdfColors.black,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                    ],
                  ),
                  if (params['otherSalaryClassList'].isNotEmpty)
                    pw.Padding(
                      padding: pw.EdgeInsets.only(top: 5),
                      child: pw.Row(children: [
                        pw.SizedBox(
                          width: 115,
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            for (var data in params['otherSalaryClassList'])
                              pw.Row(
                                children: [
                                  pw.Container(
                                    width: 60,
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      data['osName'],
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Container(
                                    width: 120,
                                    decoration: pw.BoxDecoration(
                                      borderRadius: pw.BorderRadius.circular(2),
                                      border: pw.Border.all(
                                        width: 1,
                                        color: PdfColor.fromHex('#e2e2e2'),
                                      ),
                                    ),
                                    padding: const pw.EdgeInsets.all(5),
                                    child: pw.Text(
                                      data['osAmount'].toString(),
                                      style: pw.TextStyle(
                                          font: customFont, fontSize: 9),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: const pw.EdgeInsets.fromLTRB(
                                        3, 0, 10, 0),
                                    child: pw.Text(
                                      localization.won,
                                      style: pw.TextStyle(
                                        font: customFont,
                                        fontSize: 9,
                                        color: PdfColor.fromHex('#cbcbcb'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ]),
                    ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 5),
                        width: 115,
                        child: pw.Text(
                          '- ${localization.wagePaymentDate}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          '${ContractService.returnPaymentCycleType(params['ccdPaymentCycleType'])}',
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 120,
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(2),
                          border: pw.Border.all(
                            width: 1,
                            color: PdfColor.fromHex('#e2e2e2'),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          params['ccdPaymentCycleType'] == 'MONTH'
                              ? '${params['ccdPaymentCycleMonth']}'
                              : '',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 10, 0),
                        child: pw.Text(
                          localization.paymentDay,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.only(left: 5),
                        width: 115,
                        child: pw.Text(
                          '- ${localization.paymentMethod}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                        child: pw.Text(
                          localization.directPaymentToWorker,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(right: 10),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdPaymentMethodType'] == 'SELF'
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(3, 0, 10, 0),
                        child: pw.Text(
                          localization.depositToWorkerAccount,
                          style: pw.TextStyle(
                            font: customFont,
                            fontSize: 9,
                            color: PdfColor.fromHex('#cbcbcb'),
                          ),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(right: 10),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdPaymentMethodType'] == 'ACCOUNT'
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    '7. ${localization.annualPaidLeave}:',
                    style: pw.TextStyle(font: customFont, fontSize: 9),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 5, top: 5),
                    child: pw.Text(
                      '- ${localization.annualLeaveGrantedByLaborStandardsAct}',
                      style: pw.TextStyle(
                        font: customFont,
                        fontSize: 9,
                        color: PdfColor.fromHex('#cbcbcb'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    '8. ${localization.socialInsuranceEligibility}:',
                    style: pw.TextStyle(font: customFont, fontSize: 9),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 5, top: 5),
                    child: pw.Row(children: [
                      pw.Text(
                        localization.employmentInsurance,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(left: 5, right: 5),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdEmploymentInsuranceStatus'] == 1
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Text(
                        localization.industrialInsurance,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(left: 5, right: 5),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdWorkersCompensationStatus'] == 1
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Text(
                        localization.nationalPension,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(left: 5, right: 5),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdNationalPensionStatus'] == 1
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                      pw.Text(
                        localization.healthInsurance,
                        style: pw.TextStyle(
                          font: customFont,
                          fontSize: 9,
                          color: PdfColor.fromHex('#cbcbcb'),
                        ),
                      ),
                      pw.Container(
                        width: 10,
                        height: 10,
                        margin: pw.EdgeInsets.only(left: 5, right: 5),
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(
                          color: params['ccdHealthInsuranceStatus'] == 1
                              ? PdfColors.black
                              : PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(1),
                          border:
                              pw.Border.all(width: 1, color: PdfColors.black),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    width: 1,
                    color: PdfColor.fromHex('#eeeeee'),
                  ),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    '9. ${localization.contractDelivery}:',
                    style: pw.TextStyle(font: customFont, fontSize: 9),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 5, top: 5),
                    child: pw.Text(
                      '- ${localization.contractDeliveryContent}',
                      style: pw.TextStyle(
                        font: customFont,
                        fontSize: 9,
                        color: PdfColor.fromHex('#cbcbcb'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //
            //
            //
            if (type == 'YOUNG')
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    width: 1,
                    color: PdfColor.fromHex('#cbcbcb'),
                  ),
                ),
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 1,
                        color: PdfColor.fromHex('#eeeeee'),
                      ),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Text(
                        '10. ${localization.requiredDocuments}:',
                        style: pw.TextStyle(font: customFont, fontSize: 9),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 5, top: 5),
                        child: pw.Row(
                          children: [
                            pw.Text(
                              localization.familyRelationCertificate,
                              style: pw.TextStyle(
                                font: customFont,
                                fontSize: 9,
                                color: PdfColor.fromHex('#cbcbcb'),
                              ),
                            ),
                            pw.Container(
                              width: 10,
                              height: 10,
                              margin: pw.EdgeInsets.only(left: 5, right: 5),
                              alignment: pw.Alignment.center,
                              decoration: pw.BoxDecoration(
                                color:
                                    params['ccdFamilyRelationCertificate'] == 1
                                        ? PdfColors.black
                                        : PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(1),
                                border: pw.Border.all(
                                    width: 1, color: PdfColors.black),
                              ),
                            ),
                            pw.Text(
                              localization.guardianConsentForm,
                              style: pw.TextStyle(
                                font: customFont,
                                fontSize: 9,
                                color: PdfColor.fromHex('#cbcbcb'),
                              ),
                            ),
                            pw.Container(
                              width: 10,
                              height: 10,
                              margin: pw.EdgeInsets.only(left: 5, right: 5),
                              alignment: pw.Alignment.center,
                              decoration: pw.BoxDecoration(
                                color: params['ccdParentalConsent'] == 1
                                    ? PdfColors.black
                                    : PdfColors.white,
                                borderRadius: pw.BorderRadius.circular(1),
                                border: pw.Border.all(
                                    width: 1, color: PdfColors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            //
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  width: 1,
                  color: PdfColor.fromHex('#cbcbcb'),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Text(
                          type == 'STANDARD' || type == 'CONSTRUCTION'
                              ? '10. ${localization.obligationToComplyWithContractAndRules}:'
                              : '11. ${localization.obligationToComplyWithContractAndRules}:',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 5, top: 5),
                          child: pw.Text(
                            '- ${localization.obligationToComplyWithContractAndRulesContent}',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 9,
                              color: PdfColor.fromHex('#cbcbcb'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          width: 1,
                          color: PdfColor.fromHex('#eeeeee'),
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                      children: [
                        pw.Text(
                          type == 'STANDARD' || type == 'CONSTRUCTION'
                              ? '11. ${localization.others}'
                              : '12. ${localization.others}',
                          style: pw.TextStyle(font: customFont, fontSize: 9),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(
                              left: 5, top: 5, bottom: 10),
                          child: pw.Text(
                            '- ${localization.contractTermsFallback}',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 9,
                              color: PdfColor.fromHex('#cbcbcb'),
                            ),
                          ),
                        ),
                        pw.Row(
                          children: [
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(2),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#e2e2e2'),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                DateFormat('yyyy').format(
                                  DateTime.now(),
                                ),
                                style:
                                    pw.TextStyle(font: customFont, fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.year,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(2),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#e2e2e2'),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                DateFormat('MM').format(
                                  DateTime.now(),
                                ),
                                style:
                                    pw.TextStyle(font: customFont, fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.fromLTRB(3, 0, 5, 0),
                              child: pw.Text(
                                localization.month,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Container(
                              decoration: pw.BoxDecoration(
                                borderRadius: pw.BorderRadius.circular(2),
                                border: pw.Border.all(
                                  width: 1,
                                  color: PdfColor.fromHex('#e2e2e2'),
                                ),
                              ),
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                DateFormat('dd').format(
                                  DateTime.now(),
                                ),
                                style:
                                    pw.TextStyle(font: customFont, fontSize: 9),
                              ),
                            ),
                            pw.Padding(
                              padding:
                                  const pw.EdgeInsets.fromLTRB(3, 0, 20, 0),
                              child: pw.Text(
                                localization.day,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '(${localization.employer})',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.businessName}:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  isJobseekerAgree
                                      ? detailData.chatRecruiterDto.mcName
                                      : recruiterInfo.companyInfo.name,
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                localization.phone,
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  isJobseekerAgree
                                      ? detailData.chatRecruiterDto.meHp
                                      : recruiterInfo.phoneNumber,
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.address}]:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  '${isJobseekerAgree ? detailData.chatRecruiterDto.mcAddress : recruiterInfo.companyInfo.address} ${isJobseekerAgree ? detailData.chatRecruiterDto.mcAddressDetail : recruiterInfo.companyInfo.addressDetail}',
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.representative}:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  isJobseekerAgree
                                      ? detailData.chatRecruiterDto.meName
                                      : recruiterInfo.name,
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '(${localization.signature})',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.SizedBox(
                                width: 100.0,
                                child: pw.Image(
                                  fit: pw.BoxFit.contain,
                                  pw.MemoryImage(isJobseekerAgree
                                      ? recruiterSignUrl
                                      : signImgData),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '(${localization.employee})',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.address}:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  '${params['ccdEmployeeAddress']} ${params['ccdEmployeeAddressDetail']}',
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.contactNumber}:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 3,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  '${params['ccdEmployeeContact']}',
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '${localization.fullName}:',
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(
                                decoration: pw.BoxDecoration(
                                  borderRadius: pw.BorderRadius.circular(2),
                                  border: pw.Border.all(
                                    width: 1,
                                    color: PdfColor.fromHex('#e2e2e2'),
                                  ),
                                ),
                                padding: const pw.EdgeInsets.all(5),
                                margin: const pw.EdgeInsets.only(right: 5),
                                child: pw.Text(
                                  '${params['ccdEmployeeName']}',
                                  style: pw.TextStyle(
                                      font: customFont, fontSize: 9),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text(
                                '(${localization.signature})',
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                  font: customFont,
                                  fontSize: 9,
                                  // color: PdfColor.fromHex('#cbcbcb'),
                                ),
                              ),
                            ),
                            isJobseekerAgree
                                ? pw.Expanded(
                                    flex: 1,
                                    child: pw.SizedBox(
                                      width: 100.0,
                                      child: pw.Image(
                                        fit: pw.BoxFit.contain,
                                        pw.MemoryImage(signImgData),
                                      ),
                                    ),
                                  )
                                : pw.Expanded(
                                    flex: 1,
                                    child: pw.SizedBox(),
                                  ),
                          ],
                        ),
                        pw.SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),

                  //end
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 5, top: 10, bottom: 5),
              child: pw.Text(
                '- ${localization.contractContent1}',
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 9,
                  color: PdfColor.fromHex('#000000'),
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 5, bottom: 10),
              child: pw.Text(
                '- ${localization.contractContent2} ',
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 9,
                  color: PdfColor.fromHex('#000000'),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
