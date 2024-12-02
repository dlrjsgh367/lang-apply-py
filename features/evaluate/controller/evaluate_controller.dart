import 'package:chodan_flutter_app/features/evaluate/repository/evaluate_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final evaluateControllerProvider =
StateNotifierProvider<EvaluateController, bool>((ref){
  final evaluateRepository = ref.watch(evaluateRepositoryProvider);
  return EvaluateController(
    evaluateRepository: evaluateRepository,
    ref: ref,
  );
});

class EvaluateController extends StateNotifier<bool>{
  final EvaluateRepository _evaluateRepository;
  final Ref _ref;

  EvaluateController(
      {required EvaluateRepository evaluateRepository, required Ref ref}) : _evaluateRepository = evaluateRepository, _ref = ref, super(false);

  Future<ApiResultModel> postingEvaluate(Map<String, dynamic> starRate, String roomUuid, int completedType) async {
    Map<String, dynamic> params = {
      "chRoomUuid": roomUuid,
      "epWelfareSalary": starRate['epWelfareSalary'],
      "epWorkingEnvironment": starRate['epWorkingEnvironment'],
      "epCorporateCulture": starRate['epCorporateCulture'],
      "epWorkLifeBalance": starRate['epWorkLifeBalance'],
      "epPromotionOpportunity": starRate['epPromotionOpportunity'],
      "epComment": starRate['epComment'],
      "epEvaluationCompleted": completedType
    };
    ApiResultModel result = await _evaluateRepository.postingEvaluate(params);
    return result;
  }

  Future<ApiResultModel> jobseekerEvaluate(Map<String, dynamic> starRate, String roomUuid) async {
    Map<String, dynamic> params = {
      "chRoomUuid": roomUuid,
      "ejJobSkill": starRate['ejJobSkill'],
      "ejResponsibility": starRate['ejResponsibility'],
      "ejTeamwork": starRate['ejTeamwork'],
      "ejKindnessRespect": starRate['ejKindnessRespect'],
      "ejDiligenceEthics": starRate['ejDiligenceEthics'],
      "ejComment": starRate['ejComment'],
      "ejEvaluationCompleted": 1
    };
    ApiResultModel result = await _evaluateRepository.jobseekerEvaluate(params);
    return result;
  }

}