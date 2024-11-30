import 'package:chodan_flutter_app/enum/premium_service_enum.dart';
import 'package:chodan_flutter_app/features/jobposting/service/jobposting_constants.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';

class JobpostingService{
  static String returnProbationPeriod(int probationPeriod){
    return probationPeriod == 0 ? JobpostingConstants.noProbationPeriod : '$probationPeriod개월';
  }

  static mergeJobString(List<ProfileJobModel> data){
    String result = '';
    for(int i = 0; i<data.length; i++){
      if(i != data.length-1){
        result += '${data[i].name}/ ';
      }else{
        result += data[i].name;
      }
    }
    return result;
  }

  static String applyPremiumItem({required List michinMatching, required List areaTop}){
    List<String> result = [];
    String joinedString = localization.notExists;
    if(michinMatching.isNotEmpty){
      result.add(PremiumServiceEnum.match.label);
    }
    if(areaTop.isNotEmpty){
      result.add(PremiumServiceEnum.areaTop.label);
    }
    if(result.isNotEmpty){
      joinedString = result.join(' / ');
    }
    return joinedString;
  }

}