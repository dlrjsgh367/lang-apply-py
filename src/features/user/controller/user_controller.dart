import 'package:chodan_flutter_app/features/user/repository/user_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/job_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userListProvider =
    StateProvider<List<JobseekerModel>>((ref) => []);
final userAllListProvider =
StateProvider<List<JobseekerModel>>((ref) => []);

final userClipAnnouncementListProvider = StateProvider<List>((ref) => []);

final userControllerProvider =
    StateNotifierProvider<UserController, bool>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserController(
    userRepository: userRepository,
    ref: ref,
  );
});

class UserController extends StateNotifier<bool> {
  final UserRepository _userRepository;
  final Ref _ref;

  UserController({required UserRepository userRepository, required Ref ref})
      : _userRepository = userRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getUserMatchingList(int mbIdx) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": 1,
      "size": 20,
      "meIdx": mbIdx,
      "jaRequiredStatus": 2,
      "notChat": true,
      "notShowOver30Days": true
    };
    ApiResultModel? result = await _userRepository.getUserMatchingList(params);
    return result;
  }

  Future<ApiResultModel> getUserMatchingAllList(int mbIdx, int page) async {
    Map<String, dynamic> params = {
      "paging": true,
      "page": page,
      "size": 20,
      "meIdx": mbIdx,
      "jaRequiredStatus": 2,
      "notChat": true,
      "notShowOver30Days": true
    };
    ApiResultModel? result = await _userRepository.getUserMatchingList(params);
    return result;
  }

  Future<ApiResultModel> getUserClipAnnouncementList() async {
    ApiResultModel? result =
        await _userRepository.getUserClipAnnouncementList();
    return result;
  }
}
