import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/enum/define_enum.dart';
import 'package:chodan_flutter_app/models/address_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/app_menu_model.dart';
import 'package:chodan_flutter_app/models/day_model.dart';
import 'package:chodan_flutter_app/models/define_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/report_model.dart';
import 'package:http/http.dart';

final defineRepositoryProvider = Provider<DefineRepository>(
    (ref) => DefineRepository(apiService: ApiService()));

class DefineRepository {
  final ApiService _apiService;

  DefineRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getReportReason() async {
    String url = '${ApiConstants.apiUrl}define/report/reason';
    Response response = await _apiService.get(url, null);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ReportModel> list = [];

      for (var item in data['result']['data']) {
        list.add(ReportModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkDays(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/work/days';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> list = [];

      for (var item in data['result']['list']) {
        list.add(ProfileModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkTimes(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/work/hour';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> list = [];

      for (var item in data['result']['list']) {
        list.add(ProfileModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkTypes(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/work/type';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> list = [];

      for (var item in data['result']['list']) {
        list.add(ProfileModel.fromApiJson(item));
      }
      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkPeriodList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/work/period';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> list = [];

      for (var item in data['result']['list']) {
        list.add(ProfileModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/job';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobModel> jobList = [];

      return ApiResultModel(
          type: data['code'],
          data: jobList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getKeywords(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/profile/keyword';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> keywords = [];
      for (var list in data['result']['list']) {
        keywords.add(ProfileModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: keywords,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getDefine(
      Map<String, dynamic> params, DefineEnum defineTypeEnum) async {
    String url = '${ApiConstants.apiUrl}define/${defineTypeEnum.url}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      List<DefineModel> defineList = [];
      for (var list in originList) {
        defineList.add(defineTypeEnum.apiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: defineList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getArea(
      Map<String, dynamic> params, DefineEnum defineTypeEnum) async {
    String url = '${ApiConstants.apiUrl}define/${defineTypeEnum.url}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      List<AddressModel> areaList = [];
      for (var list in originList) {
        areaList.add(defineTypeEnum.apiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: areaList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAreaChildList(
      Map<String, dynamic> params, DefineEnum defineTypeEnum) async {
    String url = '${ApiConstants.apiUrl}define/${defineTypeEnum.url}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      List<AddressModel> areaList = [];
      if (originList.isNotEmpty && originList[0]['adChild'] != null) {
        for (var list in originList[0]['adChild']) {
          areaList.add(defineTypeEnum.apiJson(list));
        }
      }

      return ApiResultModel(
          type: data['code'],
          data: areaList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkDayList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/work/days';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      List<DayModel> dayList = [];
      for (var list in originList) {
        dayList.add(DayModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: dayList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getSchoolType(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/school/type';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<ProfileModel> schoolTypeList = [];
      for (var list in data['result']['list']) {
        schoolTypeList.add(ProfileModel.fromApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: schoolTypeList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> checkForbiddenWord(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}forbidden/check';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    } else if (response.statusCode == 401) {
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getStatusList(
      Map<String, dynamic> params, String type) async {
    String url = '${ApiConstants.apiUrl}define/member/status/$type';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<UserModel> statusList = [];
      for (var item in data['result']['list']) {
        statusList.add(UserModel.fromStatusApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: statusList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWithdrawalReasonCategoryList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/member/out';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<DefineModel> categoryList = [];
      for (var item in data['result']['list']) {
        categoryList.add(DefineModel.fromApiWithdrawalJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: categoryList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getDefineAppMenuList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/app/all/menu';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<AppMenuModel> menuList = [];
      for (var item in data['result']['list']) {
        menuList.add(AppMenuModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: menuList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobDepthDetailData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/job';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['list'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAreaCode(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/area';
    Response response = await _apiService.get(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      if (originList.isNotEmpty) {
        return ApiResultModel(
            type: data['code'],
            data: AddressModel.fromApiJson(originList[0]),
            status: response.statusCode);
      }
    }
    return ApiResultModel(
      type: data['code'],
      data: null,
      status: response.statusCode,
    );
  }

  Future<ApiResultModel> getAreaKeyList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/area/all';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      Set areaSet = {};
      for (var area in originList) {
        areaSet.addAll(area['adIdxList']!);
      }
      List areaList = areaSet.toList();

      return ApiResultModel(
          type: data['code'],
          data: areaList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobKeyList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}define/job/all';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic originList = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'],
          data: originList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
}
