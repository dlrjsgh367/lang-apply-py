import 'package:chodan_flutter_app/features/alarm/repository/alarm_repository.dart';
import 'package:chodan_flutter_app/models/alarm_model.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final alarmListProvider = StateProvider.autoDispose<List<AlarmModel>>((ref) => []);


final alarmControllerProvider = StateNotifierProvider<AlarmController, bool>((ref) {
  final alarmRepository = ref.watch(alarmRepositoryProvider);
  return AlarmController(
    alarmRepository: alarmRepository,
    ref: ref,
  );
});

class AlarmController extends StateNotifier<bool> {
  final AlarmRepository _alarmRepository;
  final Ref _ref;

  AlarmController({
    required AlarmRepository alarmRepository, required Ref ref})
      : _alarmRepository = alarmRepository,
        _ref = ref,
        super(false);


  Future<ApiResultModel> getAlarmList(int page, int memberKey) async {
    Map<String, dynamic> params = {
      'paging' : 1,
      'page' : page,
      'size' : 20,
      'meIdx' : memberKey,
    };
    ApiResultModel result = await _alarmRepository.getAlarmList(params);
    return result;
  }

  Future<ApiResultModel> deleteAlarm(int alarmKey) async {
    Map<String, dynamic> params = {
      'alarmIdx': alarmKey,
    };
    ApiResultModel result = await _alarmRepository.deleteAlarm(params, alarmKey);
    return result;
  }

  Future<ApiResultModel> readAllAlarm() async {
    Map<String, dynamic> params = {

    };
    ApiResultModel result = await _alarmRepository.readAllAlarm(params);
    return result;
  }

  Future<ApiResultModel> checkAlarmAllRead(int memberKey) async {
    Map<String, dynamic> params = {
      'size' : 1,
      'meIdx' : memberKey,
      'ahIsRead' : false,
    };
    ApiResultModel result = await _alarmRepository.checkAlarmAllRead(params);
    return result;
  }



}
