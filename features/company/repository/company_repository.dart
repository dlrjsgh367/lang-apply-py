import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/evaluate_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'dart:convert';


final companyRepositoryProvider =
Provider<CompanyRepository>((ref) => CompanyRepository(apiService: ApiService()));

class CompanyRepository {
  final ApiService _apiService;

  CompanyRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> getCompanyLikesKeyList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes/company';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<int> companyLikesKeyList = [];

      for (var list in data['result']['list']) {
        companyLikesKeyList.add(list['mcIdx']);
      }


      return ApiResultModel(type: data['code'],
          data: companyLikesKeyList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getCompanyHidesKeyList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides/company';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<int> companyHidesKeyList = [];

      for(var list in data['result']['list']){
        companyHidesKeyList.add(list['jpIdx']);
      }
      return ApiResultModel(type: data['code'], data: companyHidesKeyList, status: response.statusCode,page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> addHidesCompany(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: data['result']['data'], status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteHidesCompany(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> addLikesCompany(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: data['result']['data'], status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteLikesCompany(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: '', status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }


  Future<ApiResultModel> getCompanyEvaluate(Map<String, dynamic> params, int key) async {
    String url = '${ApiConstants.apiUrl}evaluate/company/avg/detail/$key';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: EvaluateModel.fromApiJson(data['result']['data']), status: response.statusCode,page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
  Future<ApiResultModel> getCompanyInfo(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/list/recruiter/${params['idx']}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      List<UserModel> list = [];
      for(var item in data['result']['list']){
        list.add(UserModel.fromRecruiterProfileApiJson(item));
      }

      return ApiResultModel(type: data['code'], data: list[0], status: response.statusCode,page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }


  Future<ApiResultModel> updateCompanyInfo(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/${params['type']}';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(type: data['code'], data: data['result']['data'], status: response.statusCode,page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }




}
