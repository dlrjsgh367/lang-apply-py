import 'package:chodan_flutter_app/enum/event_join_type_enum.dart';
import 'package:chodan_flutter_app/features/menu/respository/menu_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/board_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventListProvider =
    StateProvider.autoDispose<List<BoardModel>>((ref) => []);

final menuControllerProvider =
    StateNotifierProvider<MenuController, bool>((ref) {
  final menuRepository = ref.watch(menuRepositoryProvider);
  return MenuController(
    menuRepository: menuRepository,
    ref: ref,
  );
});

class MenuController extends StateNotifier<bool> {
  final MenuRepository _menuRepository;
  final Ref _ref;

  MenuController({required MenuRepository menuRepository, required Ref ref})
      : _menuRepository = menuRepository,
        _ref = ref,
        super(false);

  Future<ApiResultModel> getEventList(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'evDisplay': 1,
    };
    ApiResultModel result = await _menuRepository.getEventList(params);
    return result;
  }

  Future<ApiResultModel> getEventDetail(int eventKey) async {
    Map<String, dynamic> params = {
      'evIdx': eventKey,
    };
    ApiResultModel result =
        await _menuRepository.getEventDetail(params, eventKey);
    return result;
  }

  Future<ApiResultModel> getEventDetailComment(int eventKey, int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      'props': 'create',
      'dirs': 'desc'
    };

    ApiResultModel result =
        await _menuRepository.getEventDetailComment(params, eventKey);
    return result;
  }

  Future<ApiResultModel> applyEvent(
      int eventKey, EventJoinTypeEnum eventJoinType, String? comment) async {
    Map<String, dynamic> params = {'evIdx': eventKey, 'emComment': null};
    if (eventJoinType == EventJoinTypeEnum.comment) {
      params['emComment'] = comment;
    }

    ApiResultModel result = await _menuRepository.applyEvent(params);
    return result;
  }

  Future<ApiResultModel> reportEventComment(Map<String, dynamic> params) async {
    ApiResultModel result = await _menuRepository.reportEventComment(params);
    return result;
  }

  Future<ApiResultModel> deleteEventComment(int key) async {
    Map<String, dynamic> params = {
      'emIdx': [key]
    };
    ApiResultModel result = await _menuRepository.deleteEventComment(params);
    return result;
  }

  Future<ApiResultModel> updateEventComment(int key, String comment) async {
    Map<String, dynamic> params = {'emIdx': key, 'emComment': comment};
    ApiResultModel result = await _menuRepository.updateEventComment(params);
    return result;
  }

  Future<ApiResultModel> getNoticeListData(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      "bcIdx": 1
    };
    ApiResultModel? result = await _menuRepository.getBoardListData(params);
    return result;
  }

  Future<ApiResultModel> getFaqListData(int page, int bcIdx) async {
    if (bcIdx == 0) {
      bcIdx = 16;
    }
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      "bcIdx": bcIdx
    };
    ApiResultModel? result = await _menuRepository.getBoardListData(params);
    return result;
  }

  Future<ApiResultModel> getConsultListData(int page, bool isSelf) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      "bcIdx": [4],
    };
    if (isSelf) {
      params['isSelf'] = 1;
    }
    ApiResultModel? result = await _menuRepository.getConsultListData(params);
    return result;
  }

  Future<ApiResultModel> getBoardDetailData(String idx) async {
    Map<String, dynamic> params = {'id': idx};
    ApiResultModel? result = await _menuRepository.getBoardDetailData(params);
    return result;
  }

  Future<ApiResultModel> getBoardCategoryListData(String idx) async {
    Map<String, dynamic> params = {'idx': idx};
    ApiResultModel? result =
        await _menuRepository.getBoardCategoryListData(params);
    return result;
  }

  Future<ApiResultModel> getQnaListData(int page) async {
    Map<String, dynamic> params = {
      'paging': true,
      'page': page,
      'size': 20,
      "bcIdx": 7,
      "boType": "INQUIRY",
    };
    ApiResultModel? result = await _menuRepository.getBoardListData(params);
    return result;
  }

  Future<ApiResultModel> createQna(Map<String, dynamic> inputData) async {
    Map<String, dynamic> params = {
      'bcIdx': inputData['categoryKey'],
      'boType': 'INQUIRY',
      'boTitle': inputData['title'],
      "boContent": inputData['content'],
    };
    ApiResultModel? result = await _menuRepository.createBoard(params);
    return result;
  }

  Future<ApiResultModel> createConsult(
      Map<String, dynamic> inputData, int memberType) async {
    int isHidden = inputData['hiddenStatus'] ? 1 : 0;

    Map<String, dynamic> params = {
      'bcIdx': memberType,
      'boType': 'INQUIRY',
      'boTitle': inputData['title'],
      "boContent": inputData['content'],
      "boSecret": isHidden,
    };

    if (isHidden == 1) {
      params['boPassword'] = inputData['password'];
    }
    ApiResultModel? result = await _menuRepository.createBoard(params);
    return result;
  }

  Future<ApiResultModel> updateConsult(
      String key, Map<String, dynamic> inputData) async {
    Map<String, dynamic> params = {
      'boIdx': key,
      'boTitle': inputData['title'],
      "boContent": inputData['content'],
    };
    ApiResultModel? result = await _menuRepository.updateBoard(params);
    return result;
  }

  Future<ApiResultModel> deleteBoard(String idx) async {
    Map<String, dynamic> params = {
      'boIdx': [idx]
    };
    ApiResultModel? result = await _menuRepository.deleteBoard(params);
    return result;
  }
}
