import 'package:chodan_flutter_app/utils/app_localizations.dart';

class ContractService {
  static List<Map<String, dynamic>> workDropdownList = [
    {'day': localization.daysPerWeek(1), 'key': 1},
    {'day': localization.daysPerWeek(2), 'key': 2},
    {'day': localization.daysPerWeek(3), 'key': 3},
    {'day': localization.daysPerWeek(4), 'key': 4},
    {'day': localization.daysPerWeek(5), 'key': 5},
    {'day': localization.daysPerWeek(6), 'key': 6},
    {'day': localization.daysPerWeek(7), 'key': 7},
  ];

  static List<Map<String, dynamic>> restList = [
    {'weekday': localization.monday, 'key': 1},
    {'weekday': localization.tuesday, 'key': 2},
    {'weekday': localization.wednesday, 'key': 3},
    {'weekday': localization.thursday, 'key': 4},
    {'weekday': localization.friday, 'key': 5},
    {'weekday': localization.saturday, 'key': 6},
    {'weekday': localization.sunday, 'key': 7},
  ];

  static List<Map<String, dynamic>> workWeekdayList = [
    {
      'ssDayOfWeek': 1,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 2,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 3,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 4,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 5,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 6,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
    {
      'ssDayOfWeek': 7,
      'ssStartTime': '',
      'ssEndTime': '',
      'ssBreakStartTime': '',
      'ssBreakEndTime': ''
    },
  ];

  static List<String> workTimeList = [
    '00:00',
    '00:30',
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
    '24:00',
  ];

  static List<String> restTimeList = [
    '01:00',
    '01:30',
    '02:00',
    '02:30',
    '03:00',
    '03:30',
    '04:00',
    '04:30',
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
    '22:30',
    '23:00',
    '23:30',
    '24:00',
  ];

  static returnWeekday(int value) {
    switch (value) {
      case 1:
        return localization.monday;
      case 2:
        return localization.tuesday;
      case 3:
        return localization.wednesday;
      case 4:
        return localization.thursday;
      case 5:
        return localization.friday;
      case 6:
        return localization.saturday;
      case 7:
        return localization.sunday;
      default:
        return localization.monday;
    }
  }

  static returnSalaryType(String value) {
    switch (value) {
      case 'HOUR':
        return localization.hourlyRate;
      case 'DAY':
        return localization.dailyRate;
      case 'MONTH':
        return localization.monthlySalary;
      default:
        return localization.hourlyRate;
    }
  }

  static returnPaymentType(String value) {
    switch (value) {
      case 'ACCOUNT':
        return localization.depositToBankAccount;
      case 'SELF':
        return localization.directPayment;
      default:
        return localization.depositToBankAccount;
    }
  }

  static returnPaymentCycleType(String value) {
    switch (value) {
      case 'EVERY':
        return localization.daily;
      case 'WEEK':
        return localization.weekly;
      case 'MONTH':
        return localization.monthly;
      default:
        return localization.daily;
    }
  }
}
