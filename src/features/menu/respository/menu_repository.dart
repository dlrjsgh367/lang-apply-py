import 'dart:convert';

import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_category_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:chodan_flutter_app/models/event_comment_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final menuRepositoryProvider =
    Provider<MenuRepository>((ref) => MenuRepository(apiService: ApiService()));

class MenuRepository {
  final ApiService _apiService;

  MenuRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getEventList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}event';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BoardModel> eventList = [];
      for (var list in data['result']['list']) {
        eventList.add(BoardModel.fromEventApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: eventList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getEventDetailComment(
      Map<String, dynamic> params, int eventKey) async {
    String url = '${ApiConstants.apiUrl}event/$eventKey/comment';
    // Response response = await _apiService.get(url, params);
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<EventCommentModel> eventCommentList = [];
      for (var list in data['result']['list']) {
        eventCommentList.add(EventCommentModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: eventCommentList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getEventDetail(
      Map<String, dynamic> params, int eventKey) async {
    String url = '${ApiConstants.apiUrl}event/$eventKey';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      // List<EventModel> eventList = [];
      // for(var list in data['result']['list']){
      //   eventList.add(EventModel.fromApiJson(list));
      // }

      return ApiResultModel(
          type: data['code'],
          data: BoardModel.fromEventApiDetailJson(data['result']['data']),
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> applyEvent(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}event/apply';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: null,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> reportEventComment(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}report';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['message'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteEventComment(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}event/comment';
    Response response = await _apiService.delete(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['message'],
          status: response.statusCode);
    }
    return ApiResultModel(
      type: data['code'],
      data: '',
      status: response.statusCode,
    );
  }

  Future<ApiResultModel> updateEventComment(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}event/comment';
    Response response = await _apiService.put(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['message'],
          status: response.statusCode);
    }
    return ApiResultModel(
      type: data['code'],
      data: '',
      status: response.statusCode,
    );
  }

  Future<ApiResultModel> getBoardListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BoardModel> boardList = [];
      for (var list in data['result']['list']) {
        boardList.add(BoardModel.fromApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: boardList,
          page: data['result']['page'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getConsultListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board/labor';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BoardModel> boardList = [];
      for (var list in data['result']['list']) {
        boardList.add(BoardModel.fromApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: boardList,
          page: data['result']['page'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getBoardDetailData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board/${params['id']}';
    params.remove('id');
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: BoardModel.fromApiDetailJson(data['result']['data']),
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getBoardCategoryListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board/category';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<BoardCategoryModel> boardCategoryList = [];
      for (var list in data['result']['data']) {
        boardCategoryList.add(BoardCategoryModel.fromBoardApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: boardCategoryList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createBoard(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board';
    Response response = await _apiService.post(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: data['result'], status: response.statusCode);
  }

  Future<ApiResultModel> updateBoard(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board';
    Response response = await _apiService.put(url, params);
    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);
    if (response.statusCode == 200) {
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return ApiResultModel(
        type: data['code'], data: data['result'], status: response.statusCode);
  }

  Future<ApiResultModel> deleteBoard(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return ApiResultModel(type: -1, data: {}, status: response.statusCode);
  }
}
