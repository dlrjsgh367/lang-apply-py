import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/choco_model.dart';

class PayClass {
  final ApiService _apiService = ApiService();

  PayClass();

  ApiResultModel _resultPayment(response) {
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return ApiResultModel(type: -1, data: 0, status: response.statusCode);
  }

  Future<ApiResultModel> createCart(ChocoModel itemData) async {
    List params = [{'cpIdx': itemData.key, 'caQty': 1}];

    String url = '${ApiConstants.apiUrl}cart';
    var response = await _apiService.post(url, params);

    return _resultPayment(response);
  }

  Future<ApiResultModel> createCartByOrderKey(
      List cartKey, String orUUID) async {
    Map<String, dynamic> params = {"caIdx": cartKey, "orUuid": orUUID};

    String url = '${ApiConstants.apiUrl}cart/order-number';
    var response = await _apiService.put(url, params);

    return _resultPayment(response);
  }

  Future<ApiResultModel> getOrderKey() async {
    String url = '${ApiConstants.apiUrl}order';
    var response = await _apiService.get(url, {});

    return _resultPayment(response);
  }

  Future<ApiResultModel> createOrder(String orUUID, String receiptData) async {
    Map<String, dynamic> params = {
      "orUuid": orUUID,
      "orPayment": Platform.isIOS ? "apple" : 'google',
      "paymentReceipt": {"receiptData": receiptData},
    };

    String url = '${ApiConstants.apiUrl}order';
    var response = await _apiService.post(url, params);

    return _resultPayment(response);
  }
}
