import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository(apiService: ApiService()));

class UserRepository {
  final ApiService _apiService;

  UserRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getUserList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/list/jobseeker';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<UserModel> userList = [];

      if (data['result'].isNotEmpty) {
        for (var item in data['result']['list']) {
          userList.add(UserModel.fromApiJson(item));
        }
      }

      return ApiResultModel(
          page: data['result']['page'],
          type: data['code'],
          data: userList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getUserMatchingList(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/recruiter';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobseekerModel> userList = [];

      if (data['result'].isNotEmpty) {
        for (var item in data['result']['list']) {
          userList.add(JobseekerModel.fromApiJson(item));
        }
      }

      return ApiResultModel(
          page: data['result']['page'],
          type: data['code'],
          data: userList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getUserClipAnnouncementList() async {
    String url = '${ApiConstants.apiUrl}jobseeker/scrap/key';
    Response response = await _apiService.get(url, {});
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List keyList = [];
      for (var key in data['result']['list']) {
        keyList.add(key['jpIdx']);
      }
      return ApiResultModel(
          page: data['result']['page'],
          type: data['code'],
          data: keyList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }
}
