import 'package:chodan_flutter_app/features/recommend/repository/recommend_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recommendControllerProvider =
    StateNotifierProvider<RecommendController, bool>((ref) {
  final recommendRepository = ref.watch(recommendRepositoryProvider);
  return RecommendController(
    recommendRepository: recommendRepository,
    ref: ref,
  );
});

class RecommendController extends StateNotifier<bool> {
  final RecommendRepository _recommendRepository;
  final Ref _ref;

  RecommendController(
      {required RecommendRepository recommendRepository, required Ref ref})
      : _recommendRepository = recommendRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getRecommend(Map<String, dynamic> params) async {
    ApiResultModel? result = await _recommendRepository.getRecommend(params);
    return result;
  }
}
