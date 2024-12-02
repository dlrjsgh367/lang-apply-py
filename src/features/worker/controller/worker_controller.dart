import 'package:chodan_flutter_app/features/worker/repository/worker_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';


final workerLikesKeyListProvider = StateProvider<List<int>>((ref) => []);
final workerHidesKeyListProvider = StateProvider<List<int>>((ref) => []);
final matchingKeyListProvider = StateProvider<List<int>>((ref) => []);


final workerControllerProvider =
StateNotifierProvider<WorkerController, bool>((ref) {
  final workerRepository = ref.watch(workerRepositoryProvider);
  return WorkerController(
    workerRepository: workerRepository,
    ref: ref,
  );
});

class WorkerController extends StateNotifier<bool> {
  final WorkerRepository _workerRepository;
  final Ref _ref;

  WorkerController({required WorkerRepository workerRepository, required Ref ref})
      : _workerRepository = workerRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getWorkerLikesListData(int page) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : page,
      "size" : 20,
    };
    ApiResultModel? result = await _workerRepository.getWorkerLikesListData(params);
    return result;
  }

  Future<ApiResultModel> getWorkerHidesListData(int page) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : page,
      "size" : 20,
    };
    ApiResultModel? result = await _workerRepository.getWorkerHidesListData(params);
    return result;
  }


  Future<ApiResultModel> getWorkerLikesKeyList() async {
    Map<String, dynamic> params = {
    };
    ApiResultModel? result = await _workerRepository.getWorkerLikesKeyList(params);
    return result;
  }

  Future<ApiResultModel> getWorkerHidesKeyList() async {
    Map<String, dynamic> params = {
    };
    ApiResultModel? result = await _workerRepository.getWorkerHidesKeyList(params);
    return result;
  }

  Future<ApiResultModel> addLikesWorker(int key) async {
    Map<String, dynamic> params = {
      'liType' : 2,
      'liIndex' : key,
    };
    ApiResultModel? result = await _workerRepository.addLikesWorker(params);
    return result;
  }

  Future<ApiResultModel> deleteLikesWorker(int key) async {
    Map<String, dynamic> params = {
      'liType' : 2,
      'liIndex' : key
    };
    ApiResultModel? result = await _workerRepository.deleteLikesWorker(params);
    return result;
  }

  Future<ApiResultModel> addHidesWorker(int key) async {
    Map<String, dynamic> params = {
      'hiType' : 2,
      'hiIndex' : key,
    };
    ApiResultModel? result = await _workerRepository.addHidesWorker(params);
    return result;
  }

  Future<ApiResultModel> deleteHidesWorker(int key) async {
    Map<String, dynamic> params = {
      'hiType': 2,
      'hiIndex' : key
    };
    ApiResultModel? result = await _workerRepository.deleteHidesWorker(params);
    return result;
  }

  Future<ApiResultModel> getLatestWorkerListData(int page) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : 1,
      'size' : 20
    };
    ApiResultModel? result = await _workerRepository.getLatestWorkerListData(params);
    return result;
  }

  Future<ApiResultModel> getWorkerListData(int page, Map<String, dynamic> filter) async {
    Map<String, dynamic> params = {
      "paging" : true,
      "page" : page,
      'size' : 20,
      'type' : ['profile'],
      'mpIsBlock' : 0,
      //노출여부
      'mpIsDisplay' : 1,
      'mpComplete' : 1,
      "mpBasic" : [1],
      "props" : "distance",
      "dirs": "asc",
    };
    params.addAll(filter);
    ApiResultModel? result = await _workerRepository.getWorkerListData(params);
    return result;
  }

  Future<ApiResultModel> getAlreadyProposeProfileKey() async {
    Map<String, dynamic> params = {
    };
    ApiResultModel? result = await _workerRepository.getAlreadyProposeProfileKey(params);
    return result;
  }

  Future<ApiResultModel> getRecommendWorkerList() async {
    Map<String, dynamic> params = {
      'size' : 5,
    };
    ApiResultModel? result = await _workerRepository.getRecommendWorkerList(params);
    return result;
  }

  Future<ApiResultModel> getWorkerProfile(int profileKey) async {
    Map<String, dynamic> params = {
      'type': 'profile',
      'mpComplete': [1],
      'idx': profileKey,
    };
    ApiResultModel? result = await _workerRepository.getWorkerProfile(params, profileKey);
    return result;
  }

  Future<ApiResultModel> getMatchingHistory(int profileKey) async {
    Map<String, dynamic> params = {
      'meIdx': profileKey,
      'paging':false,
    };
    ApiResultModel? result = await _workerRepository.getMatchingHistory(params);
    return result;
  }

  Future<ApiResultModel> getAcceptProfile(int profileKey) async {
    Map<String, dynamic> params = {
      'mpIdx': profileKey,
    };
    ApiResultModel? result = await _workerRepository.getAcceptProfile(params);
    return result;
  }

  Future<ApiResultModel> matchingKeyProfileList() async {
    Map<String, dynamic> params = {
    };
    ApiResultModel? result = await _workerRepository.matchingKeyProfileList(params);
    return result;
  }

  Future<ApiResultModel> getJobseekerEvaluate(int key) async {
    Map<String, dynamic> params = {
      "ejIsReflections" : [0],
      "meIdx" : key,
      "ejEvaluationCompleted" : 1,
    };
    ApiResultModel? result = await _workerRepository.getJobseekerEvaluate(params,key);
    return result;
  }




}
