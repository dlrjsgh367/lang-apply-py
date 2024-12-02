import 'package:chodan_flutter_app/features/mypage/repository/mypage_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProfileListProvider = StateProvider<List<ProfileModel>>((ref) => []);

final mypageControllerProvider =
    StateNotifierProvider<MypageController, bool>((ref) {
  final mypageRepository = ref.watch(mypageRepositoryProvider);
  return MypageController(
    mypageRepository: mypageRepository,
    ref: ref,
  );
});

class MypageController extends StateNotifier<bool> {
  final MypageRepository _mypageRepository;
  final Ref _ref;

  MypageController(
      {required MypageRepository mypageRepository, required Ref ref})
      : _mypageRepository = mypageRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getMainProfileData(int key) async {
    Map<String, dynamic> params = {
      'meIdx': key,
      'mpBasic': 1,
      'mpComplete': [0, 1],
    };
    ApiResultModel? result = await _mypageRepository.getMainProfileData(params);
    return result;
  }

  Future<ApiResultModel> getProfileList(int key) async {
    Map<String, dynamic> params = {
      'meIdx': key,
      'mpBasic': [0, 1],
      'mpComplete': [0, 1],
      'mpIsDisplay': [0, 1],
      'props': ['mpBasic', 'create'], // 띄어쓰기 금지
      'dirs': ['desc', 'desc'] // 띄어쓰기 금지
    };
    ApiResultModel? result = await _mypageRepository.getProfileList(params);
    return result;
  }

  Future<ApiResultModel> getCompleteProfileList(int key) async {
    Map<String, dynamic> params = {
      'meIdx': key,
      'mpBasic': [0, 1],
      'mpComplete': [1],
      'props': 'mpBasic,create', // 띄어쓰기 금지
      'dirs': 'desc,desc' // 띄어쓰기 금지
    };
    ApiResultModel? result = await _mypageRepository.getProfileList(params);
    return result;
  }

  Future<ApiResultModel> getForbidden() async {
    ApiResultModel result = await _mypageRepository.getForbidden();
    return result;
  }

  Future<ApiResultModel> createProfile(Map<String, dynamic> params) async {
    ApiResultModel? result = await _mypageRepository.createProfile(params);
    return result;
  }

  Future<ApiResultModel> updateProfile(
      Map<String, dynamic> params, int profileKey) async {
    params['mpIdx'] = profileKey;
    ApiResultModel? result = await _mypageRepository.updateProfile(params);
    return result;
  }

  Future<ApiResultModel> checkJobSeekerPercent(int key) async {
    Map<String, dynamic> params = {
      'meIdx': key,
    };
    ApiResultModel? result =
        await _mypageRepository.checkJobSeekerPercent(params);
    return result;
  }

  Future<ApiResultModel> checkRecruiterPercent() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result =
        await _mypageRepository.checkRecruiterPercent(params);
    return result;
  }

  Future<ApiResultModel> getProfileInfo(int idx) async {
    Map<String, dynamic> params = {
      'type': 'profile',
      'mpComplete': [0, 1],
      'mpBasic': [0, 1],
      'idx': idx,
    };
    ApiResultModel? result = await _mypageRepository.getProfileInfo(params);
    return result;
  }

  Future<ApiResultModel> writeProfileItem(
      Map<String, dynamic> data, String type, int key, int profileKey) async {
    Map<String, dynamic> params = {...data};

    params['type'] = type;
    params['meIdx'] = key;
    params['mpIdx'] = profileKey;

    ApiResultModel? result = await _mypageRepository.writeProfileItem(params);
    return result;
  }

  Future<ApiResultModel> deleteProfile(int key, int profileKey) async {
    Map<String, dynamic> params = {
      'type': 'profile',
      'meIdx': key,
      'mpIdx': profileKey,
    };
    ApiResultModel? result = await _mypageRepository.deleteProfile(params);
    return result;
  }

  Future<ApiResultModel> checkBoardPassword(int idx, String password) async {
    Map<String, dynamic> params = {
      'boPassword': password,
      'boIdx': idx,
    };
    ApiResultModel? result = await _mypageRepository.checkBoardPassword(params);
    return result;
  }

  //getCompanyListListData

  Future<ApiResultModel> getCompanyLikesListData(int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
    };
    ApiResultModel? result =
        await _mypageRepository.getCompanyLikesListData(params);
    return result;
  }

  Future<ApiResultModel> getCompanyHidesListData(int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
    };
    ApiResultModel? result =
        await _mypageRepository.getCompanyHidesListData(params);
    return result;
  }

  Future<ApiResultModel> getAppliedList(int page, int key) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'props': 'create',
      'dirs': 'desc',
      'meIdx': key,
      'jaType': 1, // 1: 지원한 공고, 2: 받은 제안
    };
    ApiResultModel? result = await _mypageRepository.getAppliedList(params);
    return result;
  }

  Future<ApiResultModel> updateStatus(int statusKey, int key) async {
    Map<String, dynamic> params = {
      'type': 'status',
      'msIdx': statusKey,
      'meIdx': key,
    };
    ApiResultModel? result =
        await _mypageRepository.updateStatus(params, 'status');
    return result;
  }

  Future<ApiResultModel> getChocoHistory(int page, int key) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
      "props": "create",
      "dirs": "desc",
      "meIdx": key
    };
    ApiResultModel? result = await _mypageRepository.getChocoHistory(params);
    return result;
  }

  Future<ApiResultModel> getChocoListData(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
    };
    ApiResultModel? result = await _mypageRepository.getChocoListData(params);
    return result;
  }

  Future<ApiResultModel> getMyChoco() async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': 1,
      'size': 1,
    };
    ApiResultModel? result = await _mypageRepository.getChocoListData(params);
    return result;
  }

  Future<ApiResultModel> getChocoProductListData(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
    };
    ApiResultModel? result =
        await _mypageRepository.getChocoProductListData(params);
    return result;
  }

  Future<ApiResultModel> getPointList(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'props': 'create',
      'dirs': 'desc',
    };
    ApiResultModel? result = await _mypageRepository.getPointList(params);
    return result;
  }

  Future<ApiResultModel> getMyTotalPoint() async {
    Map<String, dynamic> params = {};
    ApiResultModel? result = await _mypageRepository.getMyTotalPoint(params);
    return result;
  }

  Future<ApiResultModel> getCompanyEvaluateData(
      int page, int key, String status) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'meIdx': key,
      'epIsReflections': [0, 1, 2],
      'epEvaluationCompleted': 0,
    };

    if (status == 'rated') {
      params['epEvaluationCompleted'] = 1;
    }

    ApiResultModel? result =
        await _mypageRepository.getCompanyEvaluateData(params);
    return result;
  }

  Future<ApiResultModel> getJobSeekerEvaluateData(
      int page, int key, String status) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'ownerIdx': key,
      'ejIsReflections': [0, 1, 2],
      'ejEvaluationCompleted': 0,
    };

    if (status == 'rated') {
      params['ejEvaluationCompleted'] = 1;
    }

    ApiResultModel? result =
        await _mypageRepository.getJobSeekerEvaluateData(params);
    return result;
  }

  Future<ApiResultModel> getCompanyRatedEvaluateDetail(
      int key, int ratingKey) async {
    Map<String, dynamic> params = {
      'meIdx': key,
      'epIdx': ratingKey,
      'epIsReflections': [0,1,2],
      "epEvaluationCompleted": 1,
    };

    ApiResultModel? result =
        await _mypageRepository.getCompanyRatedEvaluateDetail(params);
    return result;
  }

  Future<ApiResultModel> getJobSeekerRatedEvaluateDetail(
      int key, int ratingKey) async {
    Map<String, dynamic> params = {
      'ownerIdx': key,
      'ejIdx': ratingKey,
      'ejIsReflections': [0, 1, 2],
    };

    ApiResultModel? result =
        await _mypageRepository.getJobSeekerRatedEvaluateDetail(params);
    return result;
  }

  Future<ApiResultModel> companyEvaluate(
      Map<String, dynamic> starRate, int key, int completedType) async {
    Map<String, dynamic> params = {
      'epIdx': key,
      'epWelfareSalary': starRate['epWelfareSalary'],
      'epWorkingEnvironment': starRate['epWorkingEnvironment'],
      'epCorporateCulture': starRate['epCorporateCulture'],
      'epWorkLifeBalance': starRate['epWorkLifeBalance'],
      'epPromotionOpportunity': starRate['epPromotionOpportunity'],
      'epComment': starRate['epComment'],
      'epEvaluationCompleted': completedType,
    };
    ApiResultModel result = await _mypageRepository.companyEvaluate(params);
    return result;
  }

  Future<ApiResultModel> jobSeekerEvaluate(
      Map<String, dynamic> starRate, int key, int completedType) async {
    Map<String, dynamic> params = {
      'ejIdx': key,
      'ejJobSkill': starRate['ejJobSkill'],
      'ejResponsibility': starRate['ejResponsibility'],
      'ejTeamwork': starRate['ejTeamwork'],
      'ejKindnessRespect': starRate['ejKindnessRespect'],
      'ejDiligenceEthics': starRate['ejDiligenceEthics'],
      'ejComment': starRate['ejComment'],
      'ejEvaluationCompleted': completedType,
    };
    ApiResultModel result = await _mypageRepository.jobSeekerEvaluate(params);
    return result;
  }

  Future<ApiResultModel> getProfileDetailData(int profileKey) async {
    Map<String, dynamic> params = {
      'type': 'profile',
      'mpIdx': profileKey,
      'mpBasic': [0, 1],
      'mpComplete': [0, 1],
    };
    ApiResultModel? result =
        await _mypageRepository.getProfileDetailData(params);
    return result;
  }

  Future<ApiResultModel> getContractList(
      int page, String type, int userKey) async {
    Map<String, dynamic> params = {
      type: userKey,
      'paging': true,
      'page': page,
      'size': 20,
      'caContractType': ['STANDARD', 'CONSTRUCTION', 'YOUNG', 'SHORT'],
    };
    ApiResultModel? result = await _mypageRepository.getDocumentList(params);
    return result;
  }

  Future<ApiResultModel> getResignationLetterList(
      int page, String type, int userKey) async {
    Map<String, dynamic> params = {
      type: userKey,
      'paging': true,
      'page': page,
      'size': 20,
      'caContractType': ['RESIGNATION'],
    };
    ApiResultModel? result = await _mypageRepository.getDocumentList(params);
    return result;
  }

  Future<ApiResultModel> giveJobSeekerPoint() async {
    Map<String, dynamic> params = {
      'poDefine': 'PROFILE_JOBSEEKER',
    };
    ApiResultModel? result = await _mypageRepository.giveJobSeekerPoint(params);
    return result;
  }
}
