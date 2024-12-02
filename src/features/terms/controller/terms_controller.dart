import 'package:chodan_flutter_app/features/terms/repository/terms_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final termsControllerProvider =
StateNotifierProvider<TermsController, bool>((ref){
  final termsRepository = ref.watch(termsRepositoryProvider);
  return TermsController(
    termsRepository: termsRepository,
    ref: ref,
  );
});

class TermsController extends StateNotifier<bool>{
  final TermsRepository _termRepository;
  final Ref _ref;

  TermsController(
      {required TermsRepository termsRepository, required Ref ref}) : _termRepository = termsRepository, _ref = ref, super(false);

  Future<ApiResultModel> getCategory(int key) async {
    Map<String, dynamic> params = {
      'idx': key,
    };
    ApiResultModel? result = await _termRepository.getCategory(params);
    return result;
  }

  Future<ApiResultModel> getTerms(int key, int userType) async {
    Map<String, dynamic> params = {
      'bcIdx': key,
      'type': userType,
    };
    ApiResultModel? result = await _termRepository.getTerms(params);
    return result;
  }
  Future<ApiResultModel> getTermsList(int termsType, int userType) async {
    Map<String, dynamic> params = {
      'bcIdx': termsType,
      'boTerms': userType,
      'paging':false,
    };
    ApiResultModel? result = await _termRepository.getBoardListData(params);
    return result;
  }
}