import 'package:chodan_flutter_app/models/profile_model.dart';

class ProfileService {
  /* MY 페이지 */
  static int calculateAge(String birthDate) {
    List<String> parts = birthDate.split('-');
    int birthYear = int.parse(parts[0]);

    DateTime now = DateTime.now();
    int currentYear = now.year;

    int age = currentYear - birthYear;
    return age;
  }

  static String identifyGender(int genderNumber) {
    switch(genderNumber) {
      case 1:
        return localization.female;
      case 2:
        return localization.male;
      default:
        return '';
    }
  }

  /* 신규 프로필 등록 */

  static String accumulateToString(List<dynamic> profileData, Function convertFunc) {
    String result = '';

    for (int data in profileData) {
      result += '${convertFunc(data)}, ';
    }

    // 마지막 쉼표 제거
    if (result.isNotEmpty) {
      result = result.substring(0, result.length - 2);
    }

    return result;
  }


  // 희망 근무 스케줄
  static String convertWorkDay(int workDay) {
    switch(workDay) {
      case 1:
        return localization.mondayToFriday;
      case 2:
        return localization.mondayToSaturday;
      case 3:
        return localization.mondayToSunday;
      case 4:
        return localization.weekend;
      case 5:
        return localization.mondayToSaturdayAlternate;
      case 6:
        return localization.sixDaysAWeek;
      case 7:
        return localization.fiveDaysAWeek;
      case 8:
        return localization.fourDaysAWeek;
      case 9:
        return localization.threeDaysAWeek;
      case 10:
        return localization.twoDaysAWeek;
      case 11:
        return localization.oneDayAWeek;
      case 12:
        return localization.negotiableDays;
      default:
        return localization.negotiableDays;
    }
  }

  static String convertWorkTime(int workTime) {
    switch(workTime) {
      case 1:
        return localization.morning;
      case 2:
        return localization.afternoon;
      case 3:
        return localization.evening;
      case 4:
        return localization.fullDay;
      case 5:
        return localization.dawn;
      case 6:
        return localization.morningToAfternoon;
      case 7:
        return localization.afternoonToEvening;
      case 8:
        return localization.eveningToDawn;
      case 9:
        return localization.dawnToMorning;
      default:
        return localization.timeNegotiable;
    }
  }

  // 희망 근무 조건
  static String convertWorkType(int workType) { // 경력에서도 사용
    switch(workType) {
      case 1:
        return localization.fullTimePosition;
      case 2:
        return localization.partTimePosition;
      case 3:
        return localization.contractPosition;
      case 4:
        return localization.dispatchedPosition;
      case 5:
        return localization.internshipPosition;
      case 6:
        return localization.freelancePosition;
      case 7:
        return localization.other;
      default:
        return localization.other;
    }
  }

  static String convertWorkPeriod(int workPeriod) {
    switch(workPeriod) {
      case 1:
        return localization.oneDay;
      case 2:
        return localization.lessThanAWeek;
      case 3:
        return localization.oneWeekToOneMonth;
      case 4:
        return localization.oneMonthToThreeMonths;
      case 5:
        return localization.threeToSixMonths;
      case 6:
        return localization.sixMonthsToOneYear;
      case 7:
        return localization.oneYearOrMore;
      default:
        return localization.oneYearOrMore;
    }
  }

  // 학력
  static String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  static String educationTypeKeyToString(List<ProfileModel> educationTypes, int educationKey) {
    String result = '';
    for (var education in educationTypes) {
      if (education.schoolKey == educationKey) {
        result = education.schoolType;
        break;
      }
    }
    return result;
  }

  static String formatToYearMonthKorean(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String year = dateTime.year.toString();
    String month = dateTime.month.toString();
    return '$year년 $month월';
  }

  // 경력
  static String formatCareerPeriod(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    String startYearMonth = '${start.year}.${start.month.toString().padLeft(2, '0')}';
    String endYearMonth = '${end.year}.${end.month.toString().padLeft(2, '0')}';

    return '($startYearMonth ~ $endYearMonth)';
  }

  static String formatCareerPeriodCareer(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    String startYearMonth = '${start.year}.${start.month.toString().padLeft(2, '0')}';
    String endYearMonth = '${end.year}.${end.month.toString().padLeft(2, '0')}';

    return '$startYearMonth ~ $endYearMonth';
  }

  static int calculateTotalCareerMonths(String startDate, String endDate) {
    DateTime start = DateTime.parse(startDate);
    DateTime end = DateTime.parse(endDate);

    int startYear = start.year;
    int startMonth = start.month;

    int endYear = end.year;
    int endMonth = end.month;

    int totalMonths = (endYear - startYear) * 12 + (endMonth - startMonth) + 1;

    return totalMonths;
  }

  static String calculateTotalCareer(List<ProfileCareerModel> careers) {
    int totalMonths = 0;
    for (int i = 0; i < careers.length; i++) {
      totalMonths += calculateTotalCareerMonths(careers[i].workStartDate, careers[i].workEndDate);
    }

    return totalMonthsToDurationString(totalMonths);
  }


  static String totalMonthsToDurationString(int totalMonths) {
    if (totalMonths == 0) return localization.zeroMonths;

    int years = totalMonths ~/ 12;
    int months = totalMonths % 12;

    String yearsString = years > 0 ? '$years년 ' : '';
    String monthsString = months > 0 ? '$months개월' : '';

    return '$yearsString$monthsString'.trim();
  }

  // 첨부
  static String formatFileSize(int bytes) {
    double fileSizeInMB = bytes / (1024 * 1024); // 파일 크기를 MB로 변환

    if (fileSizeInMB < 1) {
      // 파일 크기가 1MB 미만인 경우 KB 단위로 변환하여 반환
      double fileSizeInKB = bytes / 1024;
      return '${fileSizeInKB.toStringAsFixed(2)} KB';
    } else {
      // 파일 크기가 1MB 이상인 경우 MB 단위로 반환
      return '${fileSizeInMB.toStringAsFixed(2)} MB';
    }
  }

}
