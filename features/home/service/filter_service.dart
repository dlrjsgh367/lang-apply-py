import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:intl/intl.dart';

class FilterService{



  static List<Map<String, dynamic>> ageFilter = [
  {
    'key' : 0,
    'label' : localization.ageNotSpecified,
  },
    {
      'key' : 1,
      'label' : localization.ageGroup(10),
    },
    {
      'key' : 2,
      'label' : localization.ageGroup(20),
    },
    {
      'key' : 3,
      'label' : localization.ageGroup(30),
    },
    {
      'key' : 4,
      'label' : localization.ageGroup(40),
    },
    {
      'key' : 5,
      'label' : localization.ageGroup(50),
    },
    {
      'key' : 6,
      'label' : localization.ageGroup(60),
    },
    {
      'key' : 7,
      'label' : localization.ageGroup(70),
    },
  ];
  static List<Map<String, dynamic>> ageElasticFilter = [
    {
      'key' : 0,
      'label' : localization.ageNotSpecified,
    },
    {
      'key' : 10,
      'label' : localization.ageGroup(10),
    },
    {
      'key' : 20,
      'label' : localization.ageGroup(20),
    },
    {
      'key' : 30,
      'label' : localization.ageGroup(30),
    },
    {
      'key' : 40,
      'label' : localization.ageGroup(40),
    },
    {
      'key' : 50,
      'label' : localization.ageGroup(50),
    },
    {
      'key' : 60,
      'label' : localization.ageGroup(60),
    },
    {
      'key' : 70,
      'label' : localization.ageGroup(70),
    },
  ];
  static List<Map<String, dynamic>> careerFilter = [
    {
      'key' : 0,
      'label' : localization.noExperienceRequired,
    },
    {
      'key' : 1,
      'label' : localization.newGraduate,
    },
    {
      'key' : 2,
      'label' : localization.experienced,
    },
  ];
  static Map<String, dynamic> returnCareerFilterParam(int key){
    switch(key){
      case 0:
        return {
          "mpHaveCareer" : null,
        };
      case 1:
        return {
          "mpHaveCareer" :0,
        };
      case 2:
        return {
          "mpHaveCareer" : 1,
        };
      default:
        return {
          "mpHaveCareer" : null,
        };
    }

  }


  static Map<String, dynamic> returnAgeFilterParam(int key){
    switch(key){
      case 0:
        return {
          "meAgeMin" : null,
          "meAgeMax" : null,
        };
      case 1:
        return {
          "meAgeMin" :10,
          "meAgeMax" : 19,
        };
      case 2:
        return {
          "meAgeMin" : 20,
          "meAgeMax" : 29,
        };
      case 3:
        return {
          "meAgeMin" : 30,
          "meAgeMax" : 39,
        };
      case 4:
        return {
          "meAgeMin" : 40,
          "meAgeMax" : 49,
        };
      case 5:
        return {
          "meAgeMin" : 50,
          "meAgeMax" : 59,
        };
      case 6:
        return {
          "meAgeMin" :60,
          "meAgeMax" : 69,
        };
      case 7:
        return {
          "meAgeMin" : 70,
          "meAgeMax" : 79,
        };
      default:
        return {
          "meAgeMin" : null,
          "meAgeMax" : null,
        };
    }

  }

  static List<Map<String, dynamic>> periodFilter = [
    {
      'key' : 0,
      'label' : localization.months(3),
    },
    {
      'key' : 1,
      'label' : localization.months(6),
    },
    {
      'key' : 2,
      'label' : localization.years(1),
    },
    {
      'key' : 3,
      'label' : localization.years(2),
    },
    {
      'key' : 4,
      'label' : localization.manualInput,
    },
  ];

  static Map<String, dynamic> returnPeriodFilterParam(int key){
    DateTime now = DateTime.now();
    String formattedTodayDate = DateFormat('yyyy-MM-dd').format(now);
    switch(key){
      //3개월
      case 0:
        return {
          "crsd" : DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30 * 3))),
          "cred" : formattedTodayDate,
        };
        //6개월
      case 1:
        return {
          "crsd" : DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 30 * 6))),
          "cred" : formattedTodayDate,
        };
        //1년
      case 2:
        return {
          "crsd" : DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 365))),
          "cred" : formattedTodayDate,
        };
        //2년
      case 3:
        return {
          "crsd" : DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 730))),
          "cred" : formattedTodayDate,
        };
        //직접입력
      case 4:
        return {
          "crsd" : null,
          "cred" : null,
        };
      default:
        return {
          "crsd" : null,
          "cred" : null,
        };
    }

  }

  static List<Map<String, dynamic>> premiumServiceFilter = [
    {
      'key' : 0,
      'label' : localization.all,
    },
    {
      'key' : PremiumServiceEnum.areaTop.param,
      'label' : PremiumServiceEnum.areaTop.label,
    },
    {
      'key' : PremiumServiceEnum.match.param,
      'label' : PremiumServiceEnum.match.label,
    },
    {
      'key' : PremiumServiceEnum.theme.param,
      'label' : PremiumServiceEnum.theme.label,
    },
  ];

  static Map<String, dynamic> returnPremiumServiceFilterParam(int key){
    switch(key){

      case 0:
        return {
          "psType" : []
        };
      case 1:
        return {
        };
      case 2:
        return {


        };
      case 3:
        return {


        };
      case 4:
        return {


        };
      default:
        return {


        };
    }

  }

}