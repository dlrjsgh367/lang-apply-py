import 'package:chodan_flutter_app/features/commute/repository/commute_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceListProvider = StateProvider.autoDispose<List<Map<String, dynamic>>>((ref) => []);

final commuteControllerProvider =
StateNotifierProvider<CommuteController, bool>((ref){
  final commuteRepository = ref.watch(commuteRepositoryProvider);
  return CommuteController(
    commuteRepository: commuteRepository,
    ref: ref,
  );
});

class CommuteController extends StateNotifier<bool>{
  final CommuteRepository _commuteRepository;
  final Ref _ref;

  CommuteController(
      {required CommuteRepository commuteRepository, required Ref ref}) : _commuteRepository = commuteRepository, _ref = ref, super(false);

  Future<ApiResultModel> getAttendance(String uuid, Map<String, dynamic> date) async {
    Map<String, dynamic> params = {
      "paging": false,
      // "page": 1,
      // "size": 20,
      "props": "create",
      "dirs": "desc",
      // "caIdx": 1,
      "chRoomUuid": uuid,
      "crsd": date['st'],
      "cred": date['ed'],
    };
    ApiResultModel? result = await _commuteRepository.getAttendance(params);
    return result;
  }

  Future<ApiResultModel> getAttendanceDetail(String uuid, String date) async {
    Map<String, dynamic> params = {
      'chRoomUuid': uuid,
      'crsd': date,
      'cred': date,
    };
    ApiResultModel? result = await _commuteRepository.getAttendanceDetail(params);
    return result;
  }

  Future<ApiResultModel> createAttendance(Map<String, dynamic> params) async {
    ApiResultModel result = await _commuteRepository.createAttendance(params);
    return result;
  }

}