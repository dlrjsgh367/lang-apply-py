import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'dart:convert';


final bannerRepositoryProvider =
Provider<BannerRepository>((ref) => BannerRepository(apiService: ApiService()));

class BannerRepository {
  final ApiService _apiService;

  BannerRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> getPopupBanner(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}popup';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BannerModel> popupBannerList = [];
      for(var list in data['result']['list']){
        popupBannerList.add(BannerModel.fromPopupBannerApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: popupBannerList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }


  Future<ApiResultModel> getBanner(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}banner';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BannerModel> mainBannerList = [];
      for(var list in data['result']['list']){
        mainBannerList.add(BannerModel.fromBannerApiJson(list));
      }
      return ApiResultModel(
          type: data['code'], data: mainBannerList, status: response.statusCode, page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }




}
