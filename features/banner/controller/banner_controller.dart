import 'package:chodan_flutter_app/features/banner/repository/banner_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/banner_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final popupBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);
final popupBeltBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);
final menuBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);
final jobPostingBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);
final jobSeekerBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);
final themeBannerListProvider = StateProvider<List<BannerModel>>((ref) => []);



final bannerControllerProvider = StateNotifierProvider<BannerController, bool>((ref) {
  final bannerRepository = ref.watch(bannerRepositoryProvider);
  return BannerController(
    bannerRepository: bannerRepository,
    ref: ref,
  );
});

class BannerController extends StateNotifier<bool> {
  final BannerRepository _bannerRepository;
  final Ref _ref;

  BannerController({
    required BannerRepository bannerRepository, required Ref ref})
      : _bannerRepository = bannerRepository,
        _ref = ref,
        super(false);


  Future<ApiResultModel> getPopupBanner(int type) async {
    Map<String, dynamic> params = {
      'pbDisplay' : 1,
      'pbType' : type,
      'pbStatus' : 1
    };
    ApiResultModel result = await _bannerRepository.getPopupBanner(params);
    return result;
  }

  Future<ApiResultModel> getJobPostBanner(int page) async {
    Map<String, dynamic> params = {
      'paging':false,
      'baDisplay' : 1,
      'baStatus': 1,
      'baType' : 2,
      'page': page,
      "props": "blSeq",
      "dirs": "asc"
    };
    ApiResultModel result = await _bannerRepository.getBanner(params);
    return result;
  }

  Future<ApiResultModel> getBanner(int bannerType) async {
    Map<String, dynamic> params = {
      //노출 상태
      'baDisplay' : 1,
      'baType' : bannerType,
      'baStatus' : 1,
      "props": "blSeq",
      "dirs": "asc",
      'paging':false
    };
    ApiResultModel result = await _bannerRepository.getBanner(params);
    return result;
  }
}
