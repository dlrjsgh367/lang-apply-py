import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ContractAgreeService {
  static convertTime(String timeString) {
    // 시간 문자열을 DateTime 객체로 파싱
    DateTime parsedTime = DateFormat('HH:mm:ss').parse(timeString);

    // DateTime 객체를 다시 문자열로 포맷
    String formattedTime = DateFormat('HH:mm').format(parsedTime);

    return formattedTime;
  }

  static convertAddress(String address) {
    List<String> parts = address.split(' ');
    String city = parts[0]; // 시
    String district = parts[1]; // 구
    String neighborhood = parts[2]; // 동

    Map<String, dynamic> result = {
      'city': city,
      'district': district,
      'neighborhood': neighborhood
    };

    return result;
  }

  static Future<Uint8List> fetchImage(String imageUrl) async {
    // HTTP 요청을 보내서 이미지 가져오기
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // 이미지를 Uint8List로 변환하여 반환
      return response.bodyBytes;
    } else {
      // 실패한 경우 null 반환 또는 에러 처리
      throw Exception('Failed to load image');
    }
  }

  static returnParams(String type, dynamic detailData) {
    switch (type) {
      case 'STANDARD':
        Map<String, dynamic> params = {
          'ccdWorkStartDate': detailData.ccdWorkStartDate,
          'ccdWorkEndDate': detailData.ccdWorkEndDate,
          'ccdWorkplace': detailData.ccdWorkplace,
          'ccdJobDescription': detailData.ccdJobDescription,
          'ccdWorkingDays': detailData.ccdWorkingDays,
          "ccdWorkingStartTime": convertTime(detailData.ccdWorkingStartTime),
          "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
              ? ''
              : convertTime(detailData.ccdWorkingEndTime),
          "ccdBreakStartTime": detailData.ccdBreakStartTime == ''
              ? ''
              : convertTime(detailData.ccdBreakStartTime),
          "ccdBreakEndTime": detailData.ccdBreakEndTime == ''
              ? ''
              : convertTime(detailData.ccdBreakEndTime),
          'ccdSalaryType': detailData.ccdSalaryType,
          'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
          'ccdBonusExist': detailData.ccdBonusExist,
          'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
          'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
          'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
          'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
          'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
          'otherSalaryClassList': detailData.otherSalaryDto,
          'ccdEmploymentInsuranceStatus':
              detailData.ccdEmploymentInsuranceStatus,
          //고용보험
          'ccdWorkersCompensationStatus':
              detailData.ccdWorkersCompensationStatus,
          //산재보험
          'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
          //국민연금
          'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
          //건강보험
          'ccdEmployeeName': detailData.ccdEmployeeName,
          'ccdEmployeeContact': detailData.ccdEmployeeContact,
          'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
          'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
        };

        List tempHoliday = [];

        for (var data in detailData.holidayDto) {
          tempHoliday.add(data['hmDayOfWeek']);
        }

        params['holidayLists'] = tempHoliday;

        return params;

      case 'CONSTRUCTION':
        return {
          'ccdWorkStartDate': detailData.ccdWorkStartDate,
          'ccdWorkEndDate': detailData.ccdWorkEndDate,
          'ccdWorkplace': detailData.ccdWorkplace,
          'ccdJobDescription': detailData.ccdJobDescription,
          'ccdWorkingDays': detailData.ccdWorkingDays,
          "ccdWorkingStartTime": convertTime(detailData.ccdWorkingStartTime),
          "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
              ? ''
              : convertTime(detailData.ccdWorkingEndTime),
          "ccdBreakStartTime": detailData.ccdBreakStartTime == ''
              ? ''
              : convertTime(detailData.ccdBreakStartTime),
          "ccdBreakEndTime": detailData.ccdBreakEndTime == ''
              ? ''
              : convertTime(detailData.ccdBreakEndTime),
          'ccdSalaryType': detailData.ccdSalaryType,
          'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
          'ccdBonusExist': detailData.ccdBonusExist,
          'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
          'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
          'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
          'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
          'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
          'otherSalaryClassList': detailData.otherSalaryDto,
          'ccdEmploymentInsuranceStatus':
              detailData.ccdEmploymentInsuranceStatus,
          //고용보험
          'ccdWorkersCompensationStatus':
              detailData.ccdWorkersCompensationStatus,
          //산재보험
          'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
          //국민연금
          'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
          //건강보험
          'ccdEmployeeName': detailData.ccdEmployeeName,
          'ccdEmployeeContact': detailData.ccdEmployeeContact,
          'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
          'adSi': convertAddress(detailData.ccdEmployeeAddress)['city'],
          'adGu': convertAddress(detailData.ccdEmployeeAddress)['district'],
          'adDong':
              convertAddress(detailData.ccdEmployeeAddress)['neighborhood'],
          'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
        };

      case 'YOUNG':
        Map<String, dynamic> params = {
          'ccdWorkStartDate': detailData.ccdWorkStartDate,
          'ccdWorkEndDate': detailData.ccdWorkEndDate,
          'ccdWorkplace': detailData.ccdWorkplace,
          'ccdJobDescription': detailData.ccdJobDescription,
          'ccdWorkingDays': detailData.ccdWorkingDays,
          "ccdWorkingStartTime": convertTime(detailData.ccdWorkingStartTime),
          "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
              ? ''
              : convertTime(detailData.ccdWorkingEndTime),
          "ccdBreakStartTime": detailData.ccdBreakStartTime == ''
              ? ''
              : convertTime(detailData.ccdBreakStartTime),
          "ccdBreakEndTime": detailData.ccdBreakEndTime == ''
              ? ''
              : convertTime(detailData.ccdBreakEndTime),
          'ccdSalaryType': detailData.ccdSalaryType,
          'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
          'ccdBonusExist': detailData.ccdBonusExist,
          'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
          'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
          'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
          'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
          'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
          'otherSalaryClassList': detailData.otherSalaryDto,
          'ccdEmploymentInsuranceStatus':
              detailData.ccdEmploymentInsuranceStatus,
          //고용보험
          'ccdWorkersCompensationStatus':
              detailData.ccdWorkersCompensationStatus,
          //산재보험
          'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
          //국민연금
          'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
          //건강보험
          'ccdEmployeeName': detailData.ccdEmployeeName,
          'ccdEmployeeContact': detailData.ccdEmployeeContact,
          'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
          'adSi': '경기도',
          'adGu': '성남시 수정구',
          'adDong': '시흥동',
          'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
          'ccdFamilyRelationCertificate':
              detailData.ccdFamilyRelationCertificate,
          'ccdParentalConsent': detailData.ccdParentalConsent,
        };

        List tempHoliday = [];

        for (var data in detailData.holidayDto) {
          tempHoliday.add(data['hmDayOfWeek']);
        }

        params['holidayLists'] = tempHoliday;

        return params;

      case 'SHORT':
        return {
          'ccdWorkStartDate': detailData.ccdWorkStartDate,
          'ccdWorkEndDate': detailData.ccdWorkEndDate,
          'ccdWorkplace': detailData.ccdWorkplace,
          'ccdJobDescription': detailData.ccdJobDescription,
          'ccdWorkScheduleType': detailData.ccdWorkScheduleType,
          'shortWorkingClassList': detailData.shortScheduleDto,
          "ccdWorkingStartTime": detailData.ccdWorkingStartTime == '' ? '' : convertTime(detailData.ccdWorkingStartTime),
          "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
              ? ''
              : convertTime(detailData.ccdWorkingEndTime),
          "ccdBreakStartTime": detailData.ccdBreakStartTime == ''
              ? ''
              : convertTime(detailData.ccdBreakStartTime),
          "ccdBreakEndTime": detailData.ccdBreakEndTime == ''
              ? ''
              : convertTime(detailData.ccdBreakEndTime),
          'ccdSalaryType': detailData.ccdSalaryType,
          'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
          'ccdBonusExist': detailData.ccdBonusExist,
          'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
          'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
          'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
          'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
          'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
          'otherSalaryClassList': detailData.otherSalaryDto,
          'ccdEmploymentInsuranceStatus':
              detailData.ccdEmploymentInsuranceStatus,
          //고용보험
          'ccdWorkersCompensationStatus':
              detailData.ccdWorkersCompensationStatus,
          //산재보험
          'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
          //국민연금
          'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
          //건강보험
          'ccdEmployeeName': detailData.ccdEmployeeName,
          'ccdEmployeeContact': detailData.ccdEmployeeContact,
          'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
          'adSi': convertAddress(detailData.ccdEmployeeAddress)['city'],
          'adGu': convertAddress(detailData.ccdEmployeeAddress)['district'],
          'adDong':
              convertAddress(detailData.ccdEmployeeAddress)['neighborhood'],
          'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
          'ccdWageIncreaseRate': detailData.ccdWageIncreaseRate,
        };
      default:
        return {
          'ccdWorkStartDate': detailData.ccdWorkStartDate,
          'ccdWorkEndDate': detailData.ccdWorkEndDate,
          'ccdWorkplace': detailData.ccdWorkplace,
          'ccdJobDescription': detailData.ccdJobDescription,
          'ccdWorkingDays': detailData.ccdWorkingDays,
          "ccdWorkingStartTime": convertTime(detailData.ccdWorkingStartTime),
          "ccdWorkingEndTime": detailData.ccdWorkingEndTime == ''
              ? ''
              : convertTime(detailData.ccdWorkingEndTime),
          "ccdBreakStartTime": detailData.ccdBreakStartTime == ''
              ? ''
              : convertTime(detailData.ccdBreakStartTime),
          "ccdBreakEndTime": detailData.ccdBreakEndTime == ''
              ? ''
              : convertTime(detailData.ccdBreakEndTime),
          'ccdSalaryType': detailData.ccdSalaryType,
          'ccdSalaryAmount': detailData.ccdSalaryAmount.toInt(),
          'ccdBonusExist': detailData.ccdBonusExist,
          'ccdBonusAmount': detailData.ccdBonusAmount.toInt(),
          'ccdPaymentMethodType': detailData.ccdPaymentMethodType,
          'ccdPaymentCycleType': detailData.ccdPaymentCycleType,
          'ccdPaymentCycleMonth': detailData.ccdPaymentCycleMonth,
          'ccdPaymentMethodOther': detailData.ccdPaymentMethodOther,
          'otherSalaryClassList': detailData.otherSalaryDto,
          'ccdEmploymentInsuranceStatus':
              detailData.ccdEmploymentInsuranceStatus,
          //고용보험
          'ccdWorkersCompensationStatus':
              detailData.ccdWorkersCompensationStatus,
          //산재보험
          'ccdNationalPensionStatus': detailData.ccdNationalPensionStatus,
          //국민연금
          'ccdHealthInsuranceStatus': detailData.ccdHealthInsuranceStatus,
          //건강보험
          'ccdEmployeeName': detailData.ccdEmployeeName,
          'ccdEmployeeContact': detailData.ccdEmployeeContact,
          'ccdEmployeeAddress': detailData.ccdEmployeeAddress,
          'adSi': convertAddress(detailData.ccdEmployeeAddress)['city'],
          'adGu': convertAddress(detailData.ccdEmployeeAddress)['district'],
          'adDong':
              convertAddress(detailData.ccdEmployeeAddress)['neighborhood'],
          'ccdEmployeeAddressDetail': detailData.ccdEmployeeAddressDetail,
        };
    }
  }


}
