import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/posting_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import 'package:chodan_flutter_app/models/search_model.dart';

final applyRepositoryProvider = Provider<ApplyRepository>(
    (ref) => ApplyRepository(apiService: ApiService()));

class ApplyRepository {
  final ApiService _apiService;

  ApplyRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getPostingListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/jobseeker';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PostingModel> postingModel = [];

      for (var item in data['result']['list']) {
        postingModel.add(PostingModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: postingModel,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getUnReadCount(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/unread';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      int count = data['result']['data'];

      return ApiResultModel(
          type: data['code'],
          data: count,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getRecruiterPostingListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/recruiter';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PostingModel> postingModel = [];

      for (var item in data['result']['list']) {
        postingModel.add(PostingModel.fromRecruitApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: postingModel,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> changeStatusJobActivity(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/status';
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

  Future<ApiResultModel> chagnePostingOpen(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/open/all';
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

  Future<ApiResultModel> changePostingOpenSingle(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/open';
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

  Future<ApiResultModel> createHide(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides';
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

  Future<ApiResultModel> getSearchHistory(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}search-word';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<SearchModel> searchModel = [];

      for (var item in data['result']['list']) {
        searchModel.add(SearchModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: searchModel,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteSearchHistory(int key) async {
    String url = '${ApiConstants.apiUrl}search-word/$key';
    Response response = await _apiService.delete(url, {});
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

  Future<ApiResultModel> addSearchHistory(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}search-word';
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

  Future<ApiResultModel> updateActivityStatus(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/open/status';
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
}
