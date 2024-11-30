import 'package:chodan_flutter_app/features/theme/repository/theme_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final themeControllerProvider =
StateNotifierProvider<ThemeController, bool>((ref){
  final themeRepository = ref.watch(themeRepositoryProvider);
  return ThemeController(
    themeRepository: themeRepository,
    ref: ref,
  );
});

class ThemeController extends StateNotifier<bool>{
  final ThemeRepository _termRepository;
  final Ref _ref;

  ThemeController(
      {required ThemeRepository themeRepository, required Ref ref}) : _termRepository = themeRepository, _ref = ref, super(false);

  Future<ApiResultModel> getTheme(Map<String, dynamic> params) async {
    ApiResultModel? result = await _termRepository.getTheme(params);
    return result;
  }
  Future<ApiResultModel> getThemeDetail(int key) async {
    ApiResultModel? result = await _termRepository.getThemeDetail(key);
    return result;
  }
  Future<ApiResultModel> getThemeDetailList(Map<String,dynamic> params, int key) async {
    ApiResultModel? result = await _termRepository.getThemeDetailList(params,key);
    return result;
  }

  Future<ApiResultModel> getthemeSettingList(Map<String, dynamic> params, int key,String type) async {
    ApiResultModel? result = await _termRepository.getThemeSttingList(params,key,type);
    return result;
  }
  Future<ApiResultModel> getThemeJobposting(Map<String, dynamic> params, int key) async {
    ApiResultModel? result = await _termRepository.getThemeJobposting(params,key);
    return result;
  }
  Future<ApiResultModel> getMiddleAgeJobPosting(Map<String, dynamic> params, int key) async {
    ApiResultModel? result = await _termRepository.getMiddleAgeJobPosting(params,key);
    return result;
  }
}