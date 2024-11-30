import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:intl/intl.dart';

class RecommendFilterService{



  static List<Map<String, dynamic>> ageFilter = [
  {
    'key' : 0,
    'label' : '연령 무관',
  },
    {
      'key' : 1,
      'label' : '10대',
    },
    {
      'key' : 2,
      'label' : '20대',
    },
    {
      'key' : 3,
      'label' : '30대',
    },
    {
      'key' : 4,
      'label' : '40대',
    },
    {
      'key' : 5,
      'label' : '50대',
    },
    {
      'key' : 6,
      'label' : '60대',
    },
    {
      'key' : 7,
      'label' : '70대',
    },
  ];

  static List<Map<String, dynamic>> careerFilter = [
    {
      'key' : 0,
      'label' : '경력무관',
    },
    {
      'key' : 1,
      'label' : '신입',
    },
    {
      'key' : 2,
      'label' : '경력',
    },
  ];


  static Map<String, dynamic> returnAgeFilterParam(int key){
    switch(key){
      case 0:
        return {
          "jpAgeMin" : null,
          "jpAgeMax" : null,
        };
      case 1:
        return {
          "jpAgeMin" :10,
          "jpAgeMax" : 19,
        };
      case 2:
        return {
          "jpAgeMin" : 20,
          "jpAgeMax" : 29,
        };
      case 3:
        return {
          "jpAgeMin" : 30,
          "jpAgeMax" : 39,
        };
      case 4:
        return {
          "jpAgeMin" : 40,
          "jpAgeMax" : 49,
        };
      case 5:
        return {
          "jpAgeMin" : 50,
          "jpAgeMax" : 59,
        };
      case 6:
        return {
          "jpAgeMin" :60,
          "jpAgeMax" : 69,
        };
      case 7:
        return {
          "jpAgeMin" : 70,
          "jpAgeMax" : 79,
        };
      default:
        return {
          "jpAgeMin" : null,
          "jpAgeMax" : null,
        };
    }

  }

  static List<Map<String, dynamic>> periodFilter = [
    {
      'key' : 0,
      'label' : '3개월',
    },
    {
      'key' : 1,
      'label' : '6개월',
    },
    {
      'key' : 2,
      'label' : '1년',
    },
    {
      'key' : 3,
      'label' : '2년',
    },
    {
      'key' : 4,
      'label' : '직접 입력',
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
      'label' : '전체',
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