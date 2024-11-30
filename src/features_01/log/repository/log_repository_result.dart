import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final logRepositoryProvider =
Provider<LogRepository>((ref) => LogRepository(apiService: ApiService()));

class LogRepository {
  final ApiService _apiService;

  LogRepository({
    required ApiService apiService,
  }) : _apiService = apiService;


  Future<ApiResultModel> savePageLog(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}log/page/${params['lpType']}';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      return ApiResultModel(type: 1, data: null, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> saveVisitorLog(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}log/visitor/${params['lvType']}';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      return ApiResultModel(type: 1, data: null, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> saveShareLog(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}log/share/jobposting/${params['jpIdx']}';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      return ApiResultModel(type: 1, data: null, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> saveInviteLog(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}log/invite';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      return ApiResultModel(type: 1, data: null, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }
}
