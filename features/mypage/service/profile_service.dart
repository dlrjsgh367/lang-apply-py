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
        return '여자';
      case 2:
        return '남자';
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
        return '월~금';
      case 2:
        return '월~토';
      case 3:
        return '월~일';
      case 4:
        return '주말';
      case 5:
        return '월~토(격주)';
      case 6:
        return '주 6일';
      case 7:
        return '주 5일';
      case 8:
        return '주 4일';
      case 9:
        return '주 3일';
      case 10:
        return '주 2일';
      case 11:
        return '주 1일';
      case 12:
        return '요일 협의';
      default:
        return '요일 협의';
    }
  }

  static String convertWorkTime(int workTime) {
    switch(workTime) {
      case 1:
        return '오전';
      case 2:
        return '오후';
      case 3:
        return '저녁';
      case 4:
        return '종일';
      case 5:
        return '새벽';
      case 6:
        return '오전~오후';
      case 7:
        return '오후~저녁';
      case 8:
        return '저녁~새벽';
      case 9:
        return '새벽~오전';
      default:
        return '시간 협의';
    }
  }

  // 희망 근무 조건
  static String convertWorkType(int workType) { // 경력에서도 사용
    switch(workType) {
      case 1:
        return '정규직';
      case 2:
        return '아르바이트';
      case 3:
        return '계약직';
      case 4:
        return '파견직';
      case 5:
        return '인턴직';
      case 6:
        return '프리랜서';
      case 7:
        return '기타';
      default:
        return '기타';
    }
  }

  static String convertWorkPeriod(int workPeriod) {
    switch(workPeriod) {
      case 1:
        return '하루(1일)';
      case 2:
        return '1주일 이하';
      case 3:
        return '1주일 ~ 1개월';
      case 4:
        return '1개월 ~ 3개월';
      case 5:
        return '3개월 ~ 6개월';
      case 6:
        return '6개월 ~ 1년';
      case 7:
        return '1년 이상';
      default:
        return '1년 이상';
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
    if (totalMonths == 0) return '0개월';

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
