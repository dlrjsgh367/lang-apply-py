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
        return localization.female2;
      case 2:
        return localization.male2;
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
        return localization.451;
      case 2:
        return localization.452;
      case 3:
        return localization.453;
      case 4:
        return localization.454;
      case 5:
        return localization.455;
      case 6:
        return localization.456;
      case 7:
        return localization.457;
      case 8:
        return localization.458;
      case 9:
        return localization.459;
      case 10:
        return localization.460;
      case 11:
        return localization.461;
      case 12:
        return localization.462;
      default:
        return localization.462;
    }
  }

  static String convertWorkTime(int workTime) {
    switch(workTime) {
      case 1:
        return localization.463;
      case 2:
        return localization.464;
      case 3:
        return localization.465;
      case 4:
        return localization.466;
      case 5:
        return localization.467;
      case 6:
        return localization.468;
      case 7:
        return localization.469;
      case 8:
        return localization.470;
      case 9:
        return localization.471;
      default:
        return localization.472;
    }
  }

  // 희망 근무 조건
  static String convertWorkType(int workType) { // 경력에서도 사용
    switch(workType) {
      case 1:
        return localization.473;
      case 2:
        return localization.474;
      case 3:
        return localization.475;
      case 4:
        return localization.476;
      case 5:
        return localization.477;
      case 6:
        return localization.478;
      case 7:
        return localization.others;
      default:
        return localization.others;
    }
  }

  static String convertWorkPeriod(int workPeriod) {
    switch(workPeriod) {
      case 1:
        return localization.480;
      case 2:
        return localization.481;
      case 3:
        return localization.482;
      case 4:
        return localization.483;
      case 5:
        return localization.484;
      case 6:
        return localization.485;
      case 7:
        return localization.486;
      default:
        return localization.486;
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
    if (totalMonths == 0) return localization.487;

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
