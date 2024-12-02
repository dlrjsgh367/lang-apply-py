import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/preferential_condition_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:http/http.dart';

final jobpostingRepositoryProvider = Provider<JobpostingRepository>(
    (ref) => JobpostingRepository(apiService: ApiService()));

class JobpostingRepository {
  final ApiService _apiService;

  JobpostingRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getPreferentialConditionGroup(
      Map<String, dynamic> params) async {
    String url =
        '${ApiConstants.apiUrl}jobposting/preferential-condition/group';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PreferentialConditionModel> preferentialConditionList = [];
      for (var list in data['result']['list']) {
        preferentialConditionList
            .add(PreferentialConditionModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: preferentialConditionList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getPreferentialConditionList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/preferential-condition/list';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PreferentialConditionModel> preferentialConditionList = [];
      for (var list in data['result']['list']) {
        preferentialConditionList
            .add(PreferentialConditionModel.fromListApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: preferentialConditionList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createJobposting(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: data['result'], status: response.statusCode);
  }

  Future<ApiResultModel> updateJobposting(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting';
    Response response = await _apiService.put(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: data['result'], status: response.statusCode);
  }

  Future<ApiResultModel> createScrapJobseeker(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/scrap';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteScrapJobseeker(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/scrap';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> jobpostList = [];
      for (var list in data['result']['list']) {
        jobpostList.add(JobpostModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: jobpostList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingLinkWithMatch(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/link/michinmatching';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> jobpostList = [];
      for (var list in data['result']['list']) {
        jobpostList.add(JobpostModel.fromPremiumApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: jobpostList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingLinkWithAreaTop(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/link/areatop';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> jobpostList = [];
      for (var list in data['result']['list']) {
        jobpostList.add(JobpostModel.fromPremiumApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: jobpostList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteJobposting(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> closeJobposting(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/state';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> applyMatchJobposting(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}michin-matching';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    return ApiResultModel(
        type: data['code'], data: data['result'], status: response.statusCode);
  }

  Future<ApiResultModel> applyAreaTopJobposting(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}area-top-jobposting';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: '', status: response.statusCode);
  }

  Future<ApiResultModel> applyJobposting(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/apply';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getScrappedJobpost(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/scrap';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> scrappedJobpostList = [];

      for (var list in data['result']['list']) {
        scrappedJobpostList.add(JobpostModel.fromTapApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: scrappedJobpostList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getLatestJobpost(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/latest';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> latestJobpostList = [];

      for (var list in data['result']['list']) {
        latestJobpostList.add(JobpostModel.fromTapApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: latestJobpostList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getScrappedKeyList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/scrap/key';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<int> scrappedKeyList = [];

      for (Map<String, dynamic> item in data['result']['list']) {
        scrappedKeyList.add(item['jpIdx']);
      }

      return ApiResultModel(
          type: data['code'],
          data: scrappedKeyList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> addScrappedJobposting(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteScrappedCompany(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingDetail(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}jobposting/$key';
    Response response = await _apiService.get(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'] != null
              ? JobpostModel.fromDetailApiJson(data['result']['data'])
              : null,
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: null, status: response.statusCode);
  }

  Future<ApiResultModel> getJobpostingDetailForUpdate(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}jobposting/$key';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingOpenSearch(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}openSearch/search';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobpostingOpenSearchScroll(
      Map<String, dynamic> params, String path) async {
    String url = '${ApiConstants.apiUrl}$path';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> clearScrollId(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}openSearch/scroll/id/clear';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createJobpostingOpenSearch(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}openSearch';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> proposeJobpost(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/propose';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'], data: data['hits'], status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: '', status: response.statusCode);
  }

  Future<ApiResultModel> reRegisterJobposting(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobposting/reregister';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getApplyOrProposedJobpostKey(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/already/apply';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> indexingOpenSearch(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}openSearch';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
        type: data['code'],
        data: null,
        status: response.statusCode,
      );
    }
    return returnHttpStatusCode(response);
  }
}
