import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final commuteRepositoryProvider = Provider<CommuteRepository>(
        (ref) => CommuteRepository(apiService : ApiService()));


class CommuteRepository {
  final ApiService _apiService;

  CommuteRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> getAttendance(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}attendance';
    Response response = await _apiService.get(url,params);
    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(type: data['code'], data: data['result'], status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAttendanceDetail(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}attendance/detail';
    Response response = await _apiService.get(url,params);
    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(type: data['code'], data: data['result'], status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createAttendance(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/attendance';
    Response response = await _apiService.post(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list'] : data['result']['data'];

      return ApiResultModel(type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }
}