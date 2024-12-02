import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final recommendRepositoryProvider = Provider<RecommendRepository>(
    (ref) => RecommendRepository(apiService: ApiService()));

class RecommendRepository {
  final ApiService _apiService;

  RecommendRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getRecommend(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recommend/jobposting';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List userList = [];

      if (data['result'].isNotEmpty) {
        for (var item in data['result']['list']) {
          userList.add(JobpostRecommendModel.fromApiJson(item));
        }
      }

      return ApiResultModel(
          type: data['code'],
          data: userList,
          status: response.statusCode,
      );
    }
    return returnHttpStatusCode(response);
  }
}
