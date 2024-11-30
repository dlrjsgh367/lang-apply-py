import 'package:chodan_flutter_app/features/log/repository/log_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logControllerProvider = StateNotifierProvider<LogController, bool>((ref) {
  final logRepository = ref.watch(logRepositoryProvider);
  return LogController(
    logRepository: logRepository,
    ref: ref,
  );
});

class LogController extends StateNotifier<bool> {
  final LogRepository _logRepository;
  final Ref _ref;

  LogController({
    required LogRepository logRepository, required Ref ref})
      : _logRepository = logRepository,
        _ref = ref,
        super(false);


  Future<ApiResultModel> savePageLog(int pageType) async {
    Map<String, dynamic> params = {
      'lpType': pageType,
    };
    ApiResultModel result = await _logRepository.savePageLog(params);
    return result;
  }

  Future<ApiResultModel> saveVisitorLog(int memberType, String uuid, {int userKey = 0}) async {
    Map<String, dynamic> params = {
      'lvType': memberType,
      'deviceToken': uuid,
    };

    if (userKey > 0) { // 구직 or 구인 회원일 경우
      params['meIdx'] = userKey;
    }

    ApiResultModel result = await _logRepository.saveVisitorLog(params);
    return result;
  }

  Future<ApiResultModel> saveShareLog(int jobPostingKey) async {
    Map<String, dynamic> params = {
      'jpIdx': jobPostingKey,
    };
    ApiResultModel result = await _logRepository.saveShareLog(params);
    return result;
  }

  Future<ApiResultModel> saveInviteLog() async {
    Map<String, dynamic> params = {};
    ApiResultModel result = await _logRepository.saveInviteLog(params);
    return result;
  }

}
