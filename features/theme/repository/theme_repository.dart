import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/theme_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final themeRepositoryProvider = Provider<ThemeRepository>(
    (ref) => ThemeRepository(apiService: ApiService()));

class ThemeRepository {
  final ApiService _apiService;

  ThemeRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getTheme(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}theme/setting';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      List themeList = [];
      for (var theme in list) {
        themeList.add(ThemeModel.fromApiJson(theme));
      }
      return ApiResultModel(
          page: data['result']['page'],
          type: data['code'],
          data: themeList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getThemeDetail(int key) async {
    String url = '${ApiConstants.apiUrl}theme/$key';
    Response response = await _apiService.get(url, {});
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      return ApiResultModel(
          page: data['result']['page'],
          type: data['code'],
          data: ThemeSettingModel.fromApiJson(list),
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getThemeDetailList(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}theme/setting/$key/type';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getThemeSttingList(
      Map<String, dynamic> params, int key, String type) async {
    String url = '${ApiConstants.apiUrl}theme/setting/$key/type';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List theme = [];
      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      if (response.statusCode == 200) {
        for (var job in list) {
          if (type == 'theme') {
            theme.add(ThemeSettingModel.fromApiJson(job));
          } else {
            theme.add(ThemeSettingModel.fromBannerApiJson(job));
          }
        }
      }
      return ApiResultModel(
          type: data['code'], data: theme, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getThemeJobposting(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}theme/$key/jobposting';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List jobposting = [];
      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      if (response.statusCode == 200) {
        for (var job in list) {
          jobposting.add(JobpostModel.fromApiJson(job));
        }
      }
      return ApiResultModel(
          type: data['code'],
          data: jobposting,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
  Future<ApiResultModel> getMiddleAgeJobPosting(
      Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}jobposting';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List jobposting = [];
      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];
      if (response.statusCode == 200) {
        for (var job in list) {
          jobposting.add(JobpostModel.fromApiJson(job));
        }
      }
      return ApiResultModel(
          type: data['code'],
          data: jobposting,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
}
