import 'package:chodan_flutter_app/features/premium/repository/premium_repository.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final premiumControllerProvider = StateNotifierProvider<PremiumController, bool>((ref) {
  final premiumRepository = ref.watch(premiumRepositoryProvider);
  return PremiumController(
    premiumRepository: premiumRepository,
    ref: ref,
  );
});

class PremiumController extends StateNotifier<bool> {
  final PremiumRepository _premiumRepository;
  final Ref _ref;

  PremiumController({
    required PremiumRepository premiumRepository, required Ref ref})
      : _premiumRepository = premiumRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getPremiumServiceList() async {
    Map<String, dynamic> params = {

    };
    ApiResultModel result = await _premiumRepository.getPremiumServiceList(params);
    return result;
  }

  Future<ApiResultModel> getPremiumService(String code) async {
    Map<String, dynamic> params = {
      "cpCode" : code
    };
    ApiResultModel result = await _premiumRepository.getPremiumService(params,code);
    return result;
  }

  Future<ApiResultModel> getPremiumMatchPaidList(int page) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : page,
      "size" : 20,
    };
    ApiResultModel result = await _premiumRepository.getPremiumMatchPaidList(params);
    return result;
  }

  Future<ApiResultModel> getPremiumHistoryModel(int page, Map<String, dynamic> filter) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : page,
      "size" : 20,
    };
    params.addAll(filter);
    ApiResultModel result = await _premiumRepository.getPremiumHistoryModel(params);
    return result;
  }





}
