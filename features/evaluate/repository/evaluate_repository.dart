import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final evaluateRepositoryProvider = Provider<EvaluateRepository>(
        (ref) => EvaluateRepository(apiService : ApiService()));


class EvaluateRepository {
  final ApiService _apiService;

  EvaluateRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> postingEvaluate(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/evaluate';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);

    if (response.statusCode == 200) {

      dynamic list = data['result'].containsKey('list') ? data['result']['list'] : data['result']['data'];
      return ApiResultModel(type: data['code'], data: list, status: response.statusCode);
    }else{
      return ApiResultModel(type: data['code'], data: null, status: response.statusCode);
    }
  }

  Future<ApiResultModel> jobseekerEvaluate(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/evaluate';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);

    if (response.statusCode == 200) {
      dynamic list = data['result'].containsKey('list')
          ? data['result']['list'] : data['result']['data'];

      return ApiResultModel(type: data['code'], data: list, status: response.statusCode);
    }else{
      return ApiResultModel(type: data['code'], data: null, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }
}