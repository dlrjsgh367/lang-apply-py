import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';

import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/premium_history_model.dart';
import 'package:chodan_flutter_app/models/premium_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'dart:convert';


final premiumRepositoryProvider =
Provider<PremiumRepository>((ref) => PremiumRepository(apiService: ApiService()));

class PremiumRepository {
  final ApiService _apiService;

  PremiumRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getPremiumServiceList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}choco/premium';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PremiumModel> premiumList = [];
      for(var list in data['result']['list']){
        premiumList.add(PremiumModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: premiumList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getPremiumService(Map<String, dynamic> params, String code) async {
    String url = '${ApiConstants.apiUrl}choco/premium/$code';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'], data: PremiumModel.fromApiJson(data['result']['data']), status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getPremiumMatchPaidList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}michin-matching/my';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<PremiumModel> premiumList = [];
      for(var list in data['result']['list']){
        premiumList.add(PremiumModel.fromPaidApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: premiumList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getPremiumHistoryModel(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}premium-service/my';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<PremiumHistoryModel> premiumHistoryList = [];
      for(var list in data['result']['list']){
        premiumHistoryList.add(PremiumHistoryModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: premiumHistoryList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }



}
