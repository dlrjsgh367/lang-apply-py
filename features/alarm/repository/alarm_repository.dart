import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/alarm_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'dart:convert';


final alarmRepositoryProvider =
Provider<AlarmRepository>((ref) => AlarmRepository(apiService: ApiService()));

class AlarmRepository {
  final ApiService _apiService;

  AlarmRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> getAlarmList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}alarm';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<AlarmModel> alarmList = [];
      for(var list in data['result']['list']){
        alarmList.add(AlarmModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: alarmList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteAlarm(Map<String, dynamic> params, int alarmKey) async {
    String url = '${ApiConstants.apiUrl}alarm/$alarmKey';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> readAllAlarm(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}alarm/read';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> checkAlarmAllRead(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}alarm';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      bool isAllRead = true;

      if (data['result']['list'].isNotEmpty) {
        isAllRead = false;
      }
      return ApiResultModel(
          type: data['code'],
          data: isAllRead,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
}
