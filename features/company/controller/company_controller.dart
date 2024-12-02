import 'package:chodan_flutter_app/features/company/repository/company_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final companyLikesKeyListProvider = StateProvider<List<int>>((ref) => []);
final companyHidesKeyListProvider = StateProvider<List<int>>((ref) => []);

final companyControllerProvider = StateNotifierProvider<CompanyController, bool>((ref) {
  final companyRepository = ref.watch(companyRepositoryProvider);
  return CompanyController(
    companyRepository: companyRepository,
    ref: ref,
  );
});

class CompanyController extends StateNotifier<bool> {
  final CompanyRepository _companyRepository;
  final Ref _ref;

  CompanyController({
    required CompanyRepository companyRepository, required Ref ref})
      : _companyRepository = companyRepository,
        _ref = ref,
        super(false);


  Future<ApiResultModel> getCompanyLikesKeyList() async {
    Map<String, dynamic> params = {
    };
    ApiResultModel? result = await _companyRepository.getCompanyLikesKeyList(params);
    return result;
  }

  Future<ApiResultModel> getCompanyHidesKeyList() async {
    Map<String, dynamic> params = {

    };
    ApiResultModel? result = await _companyRepository.getCompanyHidesKeyList(params);
    return result;
  }

  Future<ApiResultModel> addHidesCompany(int key) async {
    Map<String, dynamic> params = {
      'hiType' : 1,
      'hiIndex' : key,
    };
    ApiResultModel? result = await _companyRepository.addHidesCompany(params);
    return result;
  }

  Future<ApiResultModel> deleteHidesCompany(int key) async {
    Map<String, dynamic> params = {
      'hiType': 1,
      'hiIndex' : key
    };
    ApiResultModel? result = await _companyRepository.deleteHidesCompany(params);
    return result;
  }

  Future<ApiResultModel> addLikesCompany(int key) async {
    Map<String, dynamic> params = {
      'liType' : 1,
      'liIndex' : key,
    };
    ApiResultModel? result = await _companyRepository.addLikesCompany(params);
    return result;
  }

  Future<ApiResultModel> deleteLikesCompany(int key) async {
    Map<String, dynamic> params = {
      'liType' : 1,
      'liIndex' : key
    };
    ApiResultModel? result = await _companyRepository.deleteLikesCompany(params);
    return result;
  }

  Future<ApiResultModel> getCompanyEvaluate(int key) async {
    Map<String, dynamic> params = {
      "epIsReflections" : [1]
    };
    ApiResultModel result = await _companyRepository.getCompanyEvaluate(params, key);
    return result;
  }

  Future<ApiResultModel> getCompanyInfo(int key) async {
    Map<String, dynamic> params = {
      'type' : 'recruiter',
      'idx' : 'self',
    };
    ApiResultModel result = await _companyRepository.getCompanyInfo(params);
    return result;
  }

  Future<ApiResultModel> updateCompanyInfo(Map<String, dynamic> data, int key) async {
    Map<String, dynamic> params = {
      ...data,
    };

    params['type'] = 'company';
    params['meIdx'] = key;

    ApiResultModel? result = await _companyRepository.updateCompanyInfo(params);
    return result;
  }


}
