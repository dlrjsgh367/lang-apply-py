import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/posting_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chodan_flutter_app/features/apply/repository/apply_repository.dart';

final applyPostListProvider = StateProvider<List<PostingModel>>((ref) => []);

final applyControllerProvider = StateNotifierProvider<ApplyController, bool>((ref) {
  final applyRepository = ref.watch(applyRepositoryProvider);
  return ApplyController(
    applyRepository: applyRepository,
    ref: ref,
  );
});

class ApplyController extends StateNotifier<bool> {
  final ApplyRepository _applyRepository;
  final Ref _ref;

  ApplyController({
    required ApplyRepository applyRepository, required Ref ref})
      : _applyRepository = applyRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getPostingListData(int page,String keyword,int type) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
      "jaType":type,
    };
    if(keyword != ""){
      params['keyword'] = keyword;
    }
    ApiResultModel? result = await _applyRepository.getPostingListData(params);
    return result;
  }

  Future<ApiResultModel> getApplyPostDetail(int jpIdx, int type) async {
    Map<String, dynamic> params = {
      "jaType": type,
      "jpIdx": jpIdx,
    };
    ApiResultModel? result = await _applyRepository.getPostingListData(params);
    return result;
  }

  Future<ApiResultModel> getUnReadCount() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _applyRepository.getUnReadCount(params);
    return result;
  }
  Future<ApiResultModel> getRecruiterPostingListData(int page,String keyword,int type) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
      "jaType":type,
    };
    if(keyword != ""){
      params['keyword'] = keyword;
    }
    ApiResultModel? result = await _applyRepository.getRecruiterPostingListData(params);
    return result;
  }

  Future<ApiResultModel> getApplyRecruiterPostDetail(int jpIdx, int mpIdx, int type) async {
    Map<String, dynamic> params = {
      "jaType": type,
      "mpIdx": mpIdx,
      "jpIdx": jpIdx,
    };
    ApiResultModel? result = await _applyRepository.getRecruiterPostingListData(params);
    return result;
  }

  Future<ApiResultModel> getAlreadyProposeList(int mpIdx) async {
    Map<String, dynamic> params = {
      "paging": false,
      "mpIdx": mpIdx,
    };
    ApiResultModel? result = await _applyRepository.getRecruiterPostingListData(params);
    return result;
  }

  Future<ApiResultModel> chagnePostingOpen() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _applyRepository.chagnePostingOpen(params);
    return result;
  }

  Future<ApiResultModel> changePostingOpenSingle(int key) async {
    Map<String, dynamic> params = {
      "jaIdxs": [key],
    };
    ApiResultModel? result = await _applyRepository.changePostingOpenSingle(params);
    return result;
  }

  Future<ApiResultModel> changeStatusJobActivity(int key,int type) async {
    Map<String, dynamic> params = {
      "jaIdx": [key],
      "jaRequiredStatus": type,
    };
    ApiResultModel? result = await _applyRepository.changeStatusJobActivity(params);
    return result;
  }

  Future<ApiResultModel> createHide(int key,int type) async {
    Map<String, dynamic> params = {
      "hiIndex": key,
      "hiType": type,
    };
    ApiResultModel? result = await _applyRepository.createHide(params);
    return result;
  }

  Future<ApiResultModel> getSearchHistory(String? swDevice) async {
    Map<String, dynamic> params = {
      "page": 1,
      "size": 10,
    };

    if (swDevice != null) {
      params['swDevice'] = swDevice;
    }

    ApiResultModel? result = await _applyRepository.getSearchHistory(params);
    return result;
  }

  Future<ApiResultModel> deleteSearchHistory(int key) async {
    ApiResultModel? result = await _applyRepository.deleteSearchHistory(key);
    return result;
  }

  Future<ApiResultModel> addSearchHistory(String text, String? swDevice) async {
    Map<String, dynamic> params = {
      "swWord": text,
    };

    if (swDevice != null) {
      params['swDevice'] = swDevice;
    }

    ApiResultModel? result = await _applyRepository.addSearchHistory(params);
    return result;
  }

  Future<ApiResultModel> updateActivityStatus(String type, int key) async {
    Map<String, dynamic> params = {
      "jaIdx": key,
      "jaType":type,
    };

    ApiResultModel? result = await _applyRepository.updateActivityStatus(params);
    return result;
  }
}
