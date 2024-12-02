import 'dart:convert';

import 'package:chodan_flutter_app/enum/jobposting_manage_tap_enum.dart';
import 'package:chodan_flutter_app/features/jobposting/repository/jobposting_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/jobpost_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastJobpostProvider = StateProvider<List<JobpostModel>>((ref) => []);
final applyOrProposedJobpostKeyListProvider =
    StateProvider<List<int>>((ref) => []);

final jobpostingControllerProvider =
    StateNotifierProvider<JobpostingController, bool>((ref) {
  final jobpostingRepository = ref.watch(jobpostingRepositoryProvider);
  return JobpostingController(
    jobpostingRepository: jobpostingRepository,
    ref: ref,
  );
});

class JobpostingController extends StateNotifier<bool> {
  final JobpostingRepository _jobpostingRepository;
  final Ref _ref;

  JobpostingController(
      {required JobpostingRepository jobpostingRepository, required Ref ref})
      : _jobpostingRepository = jobpostingRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getPreferentialConditionGroup() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getPreferentialConditionGroup(params);
    return result;
  }

  Future<ApiResultModel> getPreferentialConditionList() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getPreferentialConditionList(params);
    return result;
  }

  Future<ApiResultModel> createJobposting(Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.createJobposting(params);
    return result;
  }

  Future<ApiResultModel> updateJobposting(Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.updateJobposting(params);
    return result;
  }

  Future<ApiResultModel> createScrapJobseeker(
      Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.createScrapJobseeker(params);
    return result;
  }

  Future<ApiResultModel> deleteScrapJobseeker(
      Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.deleteScrapJobseeker(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingListData(
      int page, Map<String, dynamic> listApiParams) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'premiumOpt': 1,
    };
    params.addAll(listApiParams);
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingListData(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingPublishingListData(int userKey) async {
    Map<String, dynamic> params = {
      'ownerIdx': userKey,
      'jpPostState': ['PUBLISHING'],
      'premiumOpt': 1,
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingListData(params);
    return result;
  }
  Future<ApiResultModel> getJobpostingAllListData(int userKey) async {
    Map<String, dynamic> params = {
      'ownerIdx': userKey,
      // 'jpPostState': ['PUBLISHING','CLOSED','PENDING','UNEXPOSED'],
      'premiumOpt': 1,
      'paging':false,
    };
    ApiResultModel? result =
    await _jobpostingRepository.getJobpostingListData(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingLinkWithMatch(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'jpPostState': ['PUBLISHING'],
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingLinkWithMatch(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingLinkWithAreaTop(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      // 'premiumOpt': 1,
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingLinkWithAreaTop(params);
    return result;
  }

  Future<ApiResultModel> deleteJobposting(int jobpostingKey) async {
    Map<String, dynamic> params = {
      "jpIdx": jobpostingKey,
    };
    ApiResultModel? result =
        await _jobpostingRepository.deleteJobposting(params);
    return result;
  }

  Future<ApiResultModel> closeJobposting(int jobpostingKey) async {
    Map<String, dynamic> params = {
      "jpIdx": jobpostingKey,
      "jpPostState": JobpostingManageTapEnum.closed.param
    };
    ApiResultModel? result =
        await _jobpostingRepository.closeJobposting(params);
    return result;
  }

  //applyMatchJobposting

  Future<ApiResultModel> applyMatchJobposting(
      Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.applyMatchJobposting(params);
    return result;
  }

  //applyAreaTopJobposting

  Future<ApiResultModel> applyAreaTopJobposting(
      Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.applyAreaTopJobposting(params);
    return result;
  }

  Future<ApiResultModel> applyJobposting(Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.applyJobposting(params);
    return result;
  }

  Future<ApiResultModel> getScrappedJobpost(int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
    };
    ApiResultModel? result =
        await _jobpostingRepository.getScrappedJobpost(params);
    return result;
  }

  Future<ApiResultModel> getLatestJobpost(int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
    };
    ApiResultModel? result =
        await _jobpostingRepository.getLatestJobpost(params);
    return result;
  }

  Future<ApiResultModel> getScrappedKeyList() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getScrappedKeyList(params);
    return result;
  }

  Future<ApiResultModel> addScrappedJobposting(int key) async {
    Map<String, dynamic> params = {
      'liType': 1,
      'liIndex': key,
    };
    ApiResultModel? result =
        await _jobpostingRepository.addScrappedJobposting(params);
    return result;
  }

  Future<ApiResultModel> deleteScrappedCompany(int key) async {
    Map<String, dynamic> params = {'liIdx': key};
    ApiResultModel? result =
        await _jobpostingRepository.deleteScrappedCompany(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingDetail(int key) async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingDetail(params, key);
    return result;
  }

  Future<ApiResultModel> getJobpostingDetailForUpdate(int key) async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingDetailForUpdate(params, key);
    return result;
  }

  Future<ApiResultModel> getCompanyJobpostingList(int key, int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'premiumOpt': 1,
      'mcIdx': key,
      'jpPostState': ['PUBLISHING']
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingListData(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingOpenSearch(
      Map<String, dynamic> query) async {
    Map<String, dynamic> params = {
      'body': query,
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingOpenSearch(params);
    return result;
  }

  Future<ApiResultModel> getJobpostingOpenSearchScroll(
      Map<String, dynamic> query, String id) async {
    Map<String, dynamic> params = {
      "jsonString": jsonEncode(query),
      "size": "500",
      "scroll":"60s"
    };
    String path = 'openSearch/scroll';
    if (id != '') {
      path = 'openSearch/scroll/id';
      params = {
        "scrollIdBody": jsonEncode({
          "scroll_id": id,
          "scroll": '1s',
        })
      };
    }
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingOpenSearchScroll(params, path);
    return result;
  }

  Future<ApiResultModel> clearScrollId(String id) async {
    Map<String, dynamic> params = {"scrollId": id};
    ApiResultModel? result = await _jobpostingRepository.clearScrollId(params);
    return result;
  }

  Future<ApiResultModel> createJobpostingOpenSearch(int key) async {
    Map<String, dynamic> params = {
      'osType': 'job-posting',
      'osKey': key,
    };
    ApiResultModel? result =
        await _jobpostingRepository.createJobpostingOpenSearch(params);
    return result;
  }

  Future<ApiResultModel> getMyJobpostingList(int key, int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'ownerIdx': key,
      'jpIsPermission': [1],
      'jpPostState': ['PUBLISHING'],
    };
    ApiResultModel? result =
        await _jobpostingRepository.getJobpostingListData(params);
    return result;
  }

  Future<ApiResultModel> proposeJobpost(Map<String, dynamic> params) async {
    ApiResultModel? result = await _jobpostingRepository.proposeJobpost(params);
    return result;
  }

  Future<ApiResultModel> reRegisterJobposting(
      Map<String, dynamic> params) async {
    ApiResultModel? result =
        await _jobpostingRepository.reRegisterJobposting(params);
    return result;
  }

  Future<ApiResultModel> getApplyOrProposedJobpostKey() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _jobpostingRepository.getApplyOrProposedJobpostKey(params);
    return result;
  }

  Future<ApiResultModel> indexingOpenSearch(int key) async {
    Map<String, dynamic> params = {"osType": "job-posting", "osKey": key,};
    ApiResultModel? result = await _jobpostingRepository.indexingOpenSearch(params);
    return result;
  }
}
