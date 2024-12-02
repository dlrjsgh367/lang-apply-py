import 'dart:convert';
import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/terms_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

import 'package:chodan_flutter_app/models/board_model.dart';

final termsRepositoryProvider = Provider<TermsRepository>(
        (ref) => TermsRepository(apiService : ApiService()));


class TermsRepository {
  final ApiService _apiService;

  TermsRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> getCategory(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board/category';
    Response response = await _apiService.get(url,params);
    if(response.statusCode == 200){
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list'] : data['result']['data'];

      return ApiResultModel(type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getTerms(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}terms';
    Response response = await _apiService.get(url,params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: TermsModel.fromApiJson(data['result']['data']), status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getBoardListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BoardModel> boardList = [];
      for(var list in data['result']['list']){
        boardList.add(BoardModel.fromApiJson(list));
      }
      return ApiResultModel(type: data['code'], data: boardList, page: data['result']['page'], status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }
}