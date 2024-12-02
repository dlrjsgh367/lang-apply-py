import 'package:chodan_flutter_app/utils/app_localizations.dart';

class CompanyService {

  static String convertIntToString(int checkNumber){
    switch (checkNumber){
      case 0:
        return localization.pendingCertification;
      case 1:
        return localization.certificationCompleted;
      default:
        return localization.pendingCertification;
    }
  }

}
