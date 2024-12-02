import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/features/define/repository/define_repository.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/day_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final defineListProvider = StateProvider<List<DefineModel>>((ref) => []);

final industryListProvider = StateProvider<List<DefineModel>>((ref) => []);
final jobListProvider = StateProvider<List<DefineModel>>((ref) => []);
final areaListProvider = StateProvider<List<AddressModel>>((ref) => []);
final workTypeListProvider = StateProvider<List<ProfileModel>>((ref) => []);
final workPeriodListProvider = StateProvider<List<ProfileModel>>((ref) => []);
final appMenuListProvider = StateProvider<List<AppMenuModel>>((ref) => []);
final searchDefineListProvider =
    StateProvider.autoDispose<List<DefineModel>>((ref) => []);
final searchAddressListProvider =
    StateProvider.autoDispose<List<AddressModel>>((ref) => []);

final dayListProvider = StateProvider.autoDispose<List<DayModel>>((ref) => []);
final workTypesListProvider =
    StateProvider.autoDispose<List<ProfileModel>>((ref) => []);
final workPeriodProvider =
    StateProvider.autoDispose<List<ProfileModel>>((ref) => []);

final defineControllerProvider =
    StateNotifierProvider<DefineController, bool>((ref) {
  final defineRepository = ref.watch(defineRepositoryProvider);
  return DefineController(
    defineRepository: defineRepository,
    ref: ref,
  );
});

class DefineController extends StateNotifier<bool> {
  final DefineRepository _defineRepository;
  final Ref _ref;

  DefineController(
      {required DefineRepository defineRepository, required Ref ref})
      : _defineRepository = defineRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getWorkPeriodList() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _defineRepository.getWorkPeriodList(params);
    return result;
  }

  Future<ApiResultModel> getWorkTypes() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _defineRepository.getWorkTypes(params);
    return result;
  }

  Future<ApiResultModel> getWorkTimes() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _defineRepository.getWorkTimes(params);
    return result;
  }

  Future<ApiResultModel> getWorkDays(String type) async {
    Map<String, dynamic> params = {'role': type};
    ApiResultModel? result = await _defineRepository.getWorkDays(params);
    return result;
  }

  Future<ApiResultModel> getReportReasonList() async {
    ApiResultModel result = await _defineRepository.getReportReason();
    return result;
  }

  Future<ApiResultModel> getKeywords(int page) async {
    Map<String, dynamic> params = {
      'paging': 1,
      'page': page,
      'size': 20,
    };
    ApiResultModel result = await _defineRepository.getKeywords(params);
    return result;
  }

  Future<ApiResultModel> getJobList() async {
    ApiResultModel result = await _defineRepository.getJobList({});
    return result;
  }

  Future<ApiResultModel> getDefineList(DefineEnum defineTypeEnum) async {
    Map<String, dynamic> params = defineTypeEnum.listApiParams;
    ApiResultModel? result =
        await _defineRepository.getDefine(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getWorkDayJobpostingList() async {
    Map<String, dynamic> params = {'role': 'JOBPOSTING'};
    ApiResultModel result = await _defineRepository.getWorkDayList(params);
    return result;
  }

  Future<ApiResultModel> getAreaList(DefineEnum defineTypeEnum) async {
    Map<String, dynamic> params = defineTypeEnum.listApiParams;
    ApiResultModel? result =
        await _defineRepository.getArea(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getThreeDepthList(
      DefineEnum defineTypeEnum, int parentKey) async {
    Map<String, dynamic> params = {
      "adParent": [parentKey],
      "adChild": 1,
      "props": "adGu",
      "dirs": "asc",
    };
    ApiResultModel? result =
        await _defineRepository.getArea(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getAreaChildList(
      DefineEnum defineTypeEnum, int parentKey) async {
    Map<String, dynamic> params = {
      "adIdx": parentKey,
      "adChild": 1,
      "props": 'adGu',
      "dirs": "asc",
    };
    ApiResultModel? result =
        await _defineRepository.getAreaChildList(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getAreaGuList(DefineEnum defineTypeEnum) async {
    Map<String, dynamic> params = {
      "adGuOnly": 1,
      "paging": false,
      "props": "adGu",
      "dirs": "asc",
    };
    ApiResultModel? result =
        await _defineRepository.getArea(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getAreaCode(Map<String, dynamic> code) async {
    Map<String, dynamic> params = {
      'adAdministCode': code['hCode'],
      'adLegalCode': code['bCode'],
      "paging": false,
    };
    ApiResultModel? result = await _defineRepository.getAreaCode(params);
    return result;
  }

  Future<ApiResultModel> getAreaKeyList(List parentKey) async {
    Map<String, dynamic> params = {
      "adIdxs": parentKey,
      "paging": false,
    };
    ApiResultModel? result = await _defineRepository.getAreaKeyList(params);
    return result;
  }

  Future<ApiResultModel> getJobKeyList(List parentKey) async {
    Map<String, dynamic> params = {
      "joIdx": parentKey,
      "paging": false,
    };
    ApiResultModel? result = await _defineRepository.getJobKeyList(params);
    return result;
  }

  Future<ApiResultModel> searchDefine(
      DefineEnum defineTypeEnum, String keyword) async {
    Map<String, dynamic> params = {
      'paging': true,
      "page": 1,
      "size": 10,
    };
    params[defineTypeEnum.searchParam] = keyword;

    ApiResultModel? result =
        await _defineRepository.getDefine(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> searchArea(
      DefineEnum defineTypeEnum, String keyword, int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      "page": page,
      "size": 10,
    };

    params[defineTypeEnum.searchParam] = keyword;

    ApiResultModel? result =
        await _defineRepository.getArea(params, defineTypeEnum);
    return result;
  }

  Future<ApiResultModel> getSchoolType() async {
    Map<String, dynamic> params = {};

    ApiResultModel? result = await _defineRepository.getSchoolType(params);
    return result;
  }

  Future<ApiResultModel> getJobDepthDetailData(List jobKeyList) async {
    Map<String, dynamic> params = {
      'joIdx': jobKeyList,
    };

    ApiResultModel? result =
        await _defineRepository.getJobDepthDetailData(params);
    return result;
  }

  Future<ApiResultModel> checkForbiddenWord(String content) async {
    Map<String, dynamic> params = {
      "content": content,
    };
    ApiResultModel? result = await _defineRepository.checkForbiddenWord(params);
    return result;
  }

  Future<ApiResultModel> getStatusList(String type) async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _defineRepository.getStatusList(params, type);
    return result;
  }

  Future<ApiResultModel> getWithdrawalReasonCategoryList() async {
    Map<String, dynamic> params = {
      "mocType": 1,
    };
    ApiResultModel? result =
        await _defineRepository.getWithdrawalReasonCategoryList(params);
    return result;
  }

  Future<ApiResultModel> getDefineAppMenuList() async {
    Map<String, dynamic> params = {
      'paging': false,
      'onlyParent': false,
    };
    ApiResultModel? result =
        await _defineRepository.getDefineAppMenuList(params);
    return result;
  }
}
