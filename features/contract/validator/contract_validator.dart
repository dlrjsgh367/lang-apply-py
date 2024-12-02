class ContractValidator {
  static bool validatePhoneNumber(String phoneNumber) {
    // 전화번호에서 하이픈을 모두 제거
    String phoneNumberWithoutHyphen = phoneNumber.replaceAll('-', '');
    return RegExp(r'^01(?:0|1|[6-9])\d{7,8}$')
        .hasMatch(phoneNumberWithoutHyphen);
  }

  static bool validateTelephoneNumber(String phoneNumber) {
// 전화번호에서 하이픈을 모두 제거
// String phoneNumberWithoutHyphen = phoneNumber.replaceAll('-', '');
    return RegExp(r'^(02|0[3-9]{1}[0-9]{1})[0-9]{3,4}[0-9]{4}$')
        .hasMatch(phoneNumber);
  }

  static bool validateDateNumber(String date) {
    RegExp dateRegex = RegExp(r'^(\d{4})(\d{2})(\d{2})$');
    if (!dateRegex.hasMatch(date)) {
      return false;
    }

    String year = date.substring(0, 4);
    String month = date.substring(4, 6);
    String day = date.substring(6, 8);
    if (!isValidDate(int.parse(year), int.parse(month), int.parse(day))) {
      return false;
    }

    return true; // yyyy-mm-dd 형식으로 반환
  }

  static bool isValidDate(int year, int month, int day) {
    if (year < 1900 || month < 1 || month > 12 || day < 1) {
      return false; // 유효하지 않은 연도, 월, 일
    }

    int daysInMonth = DateTime(year, month + 1, 0).day;
    return day <= daysInMonth; // 해당 월의 일 수를 초과하지 않는지 확인
  }
}
