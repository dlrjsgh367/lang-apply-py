import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final workerRepositoryProvider = Provider<WorkerRepository>(
    (ref) => WorkerRepository(apiService: ApiService()));

class WorkerRepository {
  final ApiService _apiService;

  WorkerRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getWorkerLikesListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> workerLikesList = [];

      for (var list in data['result']['list']) {
        workerLikesList.add(ProfileModel.fromMyApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: workerLikesList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkerHidesListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> workerLikesList = [];
      for (var list in data['result']['list']) {
        workerLikesList.add(ProfileModel.fromMyApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: workerLikesList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkerLikesKeyList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<int> workerLikesKeyList = [];

      for (var list in data['result']['list']) {
        workerLikesKeyList.add(list['mpIdx']);
      }
      return ApiResultModel(
          type: data['code'],
          data: workerLikesKeyList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkerHidesKeyList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<int> workerHidesKeyList = [];

      for (var list in data['result']['list']) {
        workerHidesKeyList.add(list['mpIdx']);
      }
      return ApiResultModel(
          type: data['code'],
          data: workerHidesKeyList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> addHidesWorker(Map<String, dynamic> params) async {
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

  Future<ApiResultModel> deleteHidesWorker(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> addLikesWorker(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes';
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

  Future<ApiResultModel> deleteLikesWorker(Map<String, dynamic> params) async {
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

  Future<ApiResultModel> getLatestWorkerListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}profile/latest';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> workerLikesList = [];
      for (var list in data['result']['list']) {
        workerLikesList.add(ProfileModel.fromRecentApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: workerLikesList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkerListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> workerList = [];
      for (var list in data['result']['list']) {
        workerList.add(ProfileModel.fromWorkerApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: workerList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAlreadyProposeProfileKey(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/already/propose';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['list'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getRecommendWorkerList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recommend/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> workerList = [];
      for (var list in data['result']['list']) {
        workerList.add(ProfileModel.fromRecommendApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: workerList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getWorkerProfile(
      Map<String, dynamic> params, int profileKey) async {
    String url = '${ApiConstants.apiUrl}member/profile/$profileKey';
    Response response = await _apiService.get(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: ProfileModel.fromDetailApiJson(data['result']['data']),
          status: response.statusCode,
          page: data['result']['page']);
    }
    return ApiResultModel(
        type: data['code'], data: '', status: response.statusCode, page: 0);
  }

  Future<ApiResultModel> matchingKeyProfileList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/matching';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['list'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getMatchingHistory(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/jobseeker/approve';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobseekerModel> matchingHistory = [];

      for (var list in data['result']['list']) {
        matchingHistory.add(JobseekerModel.fromHistoryApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: matchingHistory,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAcceptProfile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/recruiter';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      bool exist = data['result']['list'].isNotEmpty ? true : false;

      return ApiResultModel(
          type: data['code'],
          data: exist,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobseekerEvaluate(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}evaluate/jobseeker/avg/$key';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: EvaluateModel.fromJobseekerApiJson(data['result']['data']),
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
}
