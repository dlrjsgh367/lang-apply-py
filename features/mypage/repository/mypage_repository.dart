import 'dart:convert';

import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/choco_model.dart';
import 'package:chodan_flutter_app/models/company_model.dart';
import 'package:chodan_flutter_app/models/document_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:chodan_flutter_app/models/point_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:chodan_flutter_app/models/rating_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final mypageRepositoryProvider = Provider<MypageRepository>(
    (ref) => MypageRepository(apiService: ApiService()));

class MypageRepository {
  final ApiService _apiService;

  MypageRepository({
    required ApiService apiService,
  }) : _apiService = apiService;

  Future<ApiResultModel> getMainProfileData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<UserModel> mainProfileList = [];

      for (var item in data['result']['list']) {
        mainProfileList.add(UserModel.fromProfileApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: mainProfileList,
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getProfileList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> profileList = [];

      for (var list in data['result']['list']) {
        profileList.add(ProfileModel.fromApiJson(list));
      }

      return ApiResultModel(
          type: data['code'], data: profileList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getForbidden() async {
    String url = '${ApiConstants.apiUrl}forbidden';
    Response response = await _apiService.get(url, null);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ProfileModel> list = [];

      for (var item in data['result']['list']) {
        list.add(ProfileModel.fromForbiddenApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createProfile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
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
        type: data['code'], data: '', status: response.statusCode);
  }

  Future<ApiResultModel> updateProfile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
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
        type: data['code'], data: '', status: response.statusCode);
  }

  Future<ApiResultModel> checkJobSeekerPercent(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/tutorial';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: UserModel.fromPercentApiJson(data['result']['data']),
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> checkRecruiterPercent(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/tutorial';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: UserModel.fromPercentApiJson(data['result']['data']),
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getProfileInfo(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile/${params['idx']}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> writeProfileItem(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteProfile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile';
    Response response = await _apiService.delete(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> checkBoardPassword(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}board/password';
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

  Future<ApiResultModel> getCompanyLikesListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}likes/company';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<CompanyModel> companyLikesList = [];

      for (var list in data['result']['list']) {
        companyLikesList.add(CompanyModel.fromHidesLikesApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: companyLikesList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getCompanyHidesListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}hides/company';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<CompanyModel> companyHidesList = [];

      for (var list in data['result']['list']) {
        companyHidesList.add(CompanyModel.fromHidesLikesApiJson(list));
      }

      return ApiResultModel(
          type: data['code'],
          data: companyHidesList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAppliedList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}job/activity/jobseeker';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<JobpostModel> list = [];

      for (var item in data['result']['list']) {
        list.add(JobpostModel.fromAppliedJobPostApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: list,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> updateStatus(
      Map<String, dynamic> params, String type) async {
    String url = '${ApiConstants.apiUrl}member/$type';
    Response response = await _apiService.put(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChocoHistory(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}choco/history/my';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List list = [];

      for (var item in data['result']['list']) {
        list.add(item);
      }

      return ApiResultModel(
          type: data['code'],
          data: list,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChocoListData(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}choco/history/my';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ChocoModel> chocoList = [];
      for (var list in data['result']['list']) {
        chocoList.add(ChocoModel.fromApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: chocoList,
          page: data['result']['page'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChocoProductListData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}choco/product';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<ChocoModel> chocoList = [];
      for (var list in data['result']['list']) {
        chocoList.add(ChocoModel.fromProductApiJson(list));
      }
      return ApiResultModel(
          type: data['code'],
          data: chocoList,
          page: data['result']['page'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getPointList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}point/history';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<PointModel> pointList = [];

      for (var item in data['result']['list']) {
        pointList.add(PointModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: pointList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getMyTotalPoint(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}point/history/total';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getCompanyEvaluateData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/company';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<RatingModel> ratingList = [];

      for (var item in data['result']['list']) {
        ratingList.add(RatingModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: ratingList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobSeekerEvaluateData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/jobseeker';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<RatingModel> ratingList = [];

      for (var item in data['result']['list']) {
        ratingList.add(RatingModel.fromRecruiterApiJson(item));
      }

      return ApiResultModel(
          type: data['code'],
          data: ratingList,
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getCompanyRatedEvaluateDetail(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/company/${params['epIdx']}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: RatingModel.fromApiJson(data['result']['data']),
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobSeekerRatedEvaluateDetail(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/jobseeker/${params['ejIdx']}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: RatingModel.fromRecruiterApiJson(data['result']['data']),
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> companyEvaluate(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/evaluate/update';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> jobSeekerEvaluate(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/evaluate/update';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getProfileDetailData(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}member/profile/${params['mpIdx']}';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: ProfileModel.fromTutorialApiJson(data['result']['data']),
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getDocumentList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}personal/attachment';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);
      List<DocumentModel> documentList = [];

      for (var item in data['result']['list']) {
        documentList.add(DocumentModel.fromApiJson(item));
      }

      return ApiResultModel(
          type: data['code'], data: documentList, status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> giveJobSeekerPoint(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}jobseeker/point/profile';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data'],
          status: response.statusCode);
    }
    return returnHttpStatusCode(response);
  }
}
