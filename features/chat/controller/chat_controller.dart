import 'package:chodan_flutter_app/core/service/chat_user_service.dart';
import 'package:chodan_flutter_app/features/chat/repository/chat_repository.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_file_model.dart';
import 'package:chodan_flutter_app/models/chat_user_model.dart';
import 'package:chodan_flutter_app/utils/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final msgListProvider = StateProvider.autoDispose<List>((ref) => []);
final reportReasonListProvider = StateProvider.autoDispose<List>((ref) => []);
final contractDetailProvider =
    StateProvider.autoDispose<ChatFileModel?>((ref) => null);

final chatControllerProvider =
    StateNotifierProvider<ChatController, bool>((ref) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  return ChatController(
    chatRepository: chatRepository,
    ref: ref,
  );
});

class ChatController extends StateNotifier<bool> {
  final ChatRepository _chatRepository;
  final Ref _ref;

  ChatController({required ChatRepository chatRepository, required Ref ref})
      : _chatRepository = chatRepository,
        _ref = ref,
        super(false);

  Future<Map<String, dynamic>> getChatUuid(
      String chatId, String userUuid) async {
    var result = await _chatRepository.getChatUuid(chatId, userUuid);

    return result;
  }

  Future<Map<String, dynamic>> getMessageData(
      String roomUuid, String messageUuid) async {
    var result = await _chatRepository.getMessageData(roomUuid, messageUuid);

    return result;
  }

  void deleteMessage(
      String chatId, String msgId, Map<String, dynamic> users) async {
    _chatRepository.deleteMessage(chatId, msgId, users);
  }

  void outChatRoom(String chatId, String userUuid) async {
    _chatRepository.outChatRoom(chatId, userUuid);
  }

  newMessage(String chatId, String msg, ChatUserModel user,
      Map<String, dynamic> users, bool isActive) async {
    var msgId = returnUuidV4('');
    Map<String, dynamic> msgObj = {
      'created': DateTime.timestamp(),
      'updated': DateTime.timestamp(),
      'id': msgId,
      'message': msg,
      'userId': user.id,
      'userUuid': user.uuid,
      'userImg': user.profile,
      'files': [
        {
          'fileName': '',
          'fileSize': 0,
          'fileUrl': '',
        }
      ],
      'type': 'message',
      'deleted': [],
    };

    Map<String, dynamic> lastMsgObj = {
      'created': msgObj['created'],
      'lastImg': '',
      'lastMsg': msg,
      'lastName': user.name,
    };

    _chatRepository.newMessageDataToFirebase(
        chatId, msgId, msgObj, lastMsgObj, user, users, isActive);
  }

  firstMessage(String chatId, String msg, ChatUserModel user,
      Map<String, dynamic> users, bool isActive) async {
    var msgId = returnUuidV4('');
    Map<String, dynamic> msgObj = {
      'created': DateTime.timestamp(),
      'updated': DateTime.timestamp(),
      // 'docKey': 0,
      // 'docState': 0,
      'id': msgId,
      'message': msg,
      'userId': user.id,
      'userUuid': user.uuid,
      'userImg': user.profile,
      'files': [
        {
          'fileName': '',
          'fileSize': 0,
          'fileUrl': '',
        }
      ],
      'type': 'first',
      'deleted': [],
    };

    Map<String, dynamic> lastMsgObj = {
      'created': msgObj['created'],
      'lastImg': '',
      'lastMsg': msg,
      'lastName': user.name,
    };

    _chatRepository.newMessageDataToFirebase(
        chatId, msgId, msgObj, lastMsgObj, user, users, isActive);
  }

  Future<String> newFile(
      String chatId,
      ChatUserModel user,
      Map<String, dynamic> users,
      bool isActive,
      List<Map<String, dynamic>>? file,
      String type) async {
    var msgId = returnUuidV4('');
    String msg = '';

    if (type == 'image') {
      msg = localization.sentPhoto;
    } else if (type == 'video') {
      msg = localization.sentVideo;
    } else if (type == 'file') {
      msg = localization.sentFile;
    }

    Map<String, dynamic> msgObj = {
      'created': DateTime.timestamp(),
      'updated': DateTime.timestamp(),
      'id': msgId,
      'message': msg,
      'userId': user.id,
      'userUuid': user.uuid,
      'userImg': user.profile,
      'files': [
        {
          'fileName': '',
          'fileSize': 0,
          'fileUrl': '',
        }
      ],
      'type': type,
      'deleted': [],
    };

    if (file != null && file.isNotEmpty) {
      msgObj['files'] = file;
    }

    Map<String, dynamic> lastMsgObj = {
      'created': msgObj['created'],
      'lastImg': '',
      'lastMsg': msg,
      'lastName': user.name,
    };

    _chatRepository.newMessageDataToFirebase(
        chatId, msgId, msgObj, lastMsgObj, user, users, isActive);

    return msgId;
  }

  Future<String> newDocument(
      String chatId,
      ChatUserModel user,
      Map<String, dynamic> users,
      bool isActive,
      List<Map<String, dynamic>>? file,
      String type,
      DateTime created) async {
    var msgId = returnUuidV4('');
    String msg = '';

    if (type == 'normalContractCreate') {
      msg = localization.sentStandardLaborContract;
    } else if (type == 'shortContractCreate') {
      msg = localization.sentShortTermLaborContract;
    } else if (type == 'minorContractCreate') {
      msg = localization.sentMinorLaborContract;
    } else if (type == 'constructionContractCreate') {
      msg = localization.sentConstructionDailyLaborContract;
    } else if (type == 'salary') {
      msg = localization.sentSalaryStatement;
    } else if (type == 'consent') {
      msg = localization.sentParentalConsentForm;
    } else if (type == 'resignation') {
      msg = localization.sentResignationLetter;
    } else if (type == 'vacation') {
      msg = localization.sentLeaveRequestForm;
    } else if (type == 'attendance') {
      msg = localization.arrivedAtWork;
    } else if (type == 'leave') {
      msg = localization.leftWork;
    } else if (type == 'outside') {
      msg = localization.wentOnBusinessTrip;
    } else if (type == 'comeback') {
      msg = localization.returnedToOffice;
    }

    Map<String, dynamic> msgObj = {
      'created': DateTime.timestamp(),
      'updated': DateTime.timestamp(),
      'id': msgId,
      'message': msg,
      'userId': user.id,
      'userUuid': user.uuid,
      'userImg': user.profile,
      'files': [],
      'type': type,
      'deleted': [],
    };

    if (file != null && file.isNotEmpty) {
      msgObj['files'] = file;
    }

    Map<String, dynamic> lastMsgObj = {
      'created': msgObj['created'],
      'lastImg': '',
      'lastMsg': msg,
      'lastName': user.name,
    };

    _chatRepository.newMessageDataToFirebase(
        chatId, msgId, msgObj, lastMsgObj, user, users, isActive);

    return msgId;
  }

  Future updateDocument(
      String chatId,
      ChatUserModel user,
      Map<String, dynamic> users,
      bool isActive,
      List<Map<String, dynamic>>? file,
      String type,
      String created,
      String msgKey) async {
    var msgId = returnUuidV4('');
    String msg = '';

    String dateString = created;
    DateTime dateTime = DateTime.parse(dateString);

    String createTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);

    if (type == 'normalContractUpdate') {
      msg = localization.sentStandardLaborContract;
    } else if (type == 'shortContractUpdate') {
      msg = localization.sentShortTermLaborContract;
    } else if (type == 'minorContractUpdate') {
      msg = localization.sentMinorLaborContract;
    } else if (type == 'constructionContractUpdate') {
      msg = localization.sentConstructionDailyLaborContract;
    }

    /*if (type == 'normalContractUpdate') {
      msg = '[긴급] $createTime 최초 작성된 표준 근로 계약서가 수정 되었습니다.\n내용 확인 후 동의 바랍니다.';
    } else if (type == 'shortContractUpdate') {
      msg = '[긴급] $createTime 최초 작성된 단기간 근로자 계약서가 수정 되었습니다.\n내용 확인 후 동의 바랍니다.';
    } else if (type == 'minorContractUpdate') {
      msg = '[긴급] $createTime 최초 작성된 연소 근로 계약서가 수정 되었습니다.\n내용 확인 후 동의 바랍니다.';
    } else if (type == 'constructionContractUpdate') {
      msg = '[긴급] $createTime 최초 작성된 건설 일용 근로 계약서가 수정 되었습니다.\n내용 확인 후 동의 바랍니다.';
    }*/

    Map<String, dynamic> msgObj = {
      'created': DateTime.timestamp(),
      'updated': DateTime.timestamp(),
      'updateMessageUuid': msgKey,
      'id': msgId,
      'message': msg,
      'userId': user.id,
      'userUuid': user.uuid,
      'userImg': user.profile,
      'files': [],
      'type': type,
      'deleted': [],
    };

    if (file != null && file.isNotEmpty) {
      msgObj['files'] = file;
    }

    Map<String, dynamic> lastMsgObj = {
      'created': msgObj['created'],
      'lastImg': '',
      'lastMsg': msg,
      'lastName': user.name,
    };

    _chatRepository.newMessageDataToFirebase(
        chatId, msgId, msgObj, lastMsgObj, user, users, isActive);

    return msgId;
  }

  Future<ApiResultModel> createChatReport(Map<String, dynamic> params) async {
    ApiResultModel result = await _chatRepository.createChatReport(params);
    return result;
  }

  Future<ApiResultModel> createChatMedia(Map<String, dynamic> params) async {
    ApiResultModel result = await _chatRepository.createChatFile(params);
    return result;
  }

  Future<ApiResultModel> createContract(String uuid, String contractType,
      Map<String, dynamic> preParams, int type) async {
    Map<String, dynamic> params = {
      'contractDto': preParams,
      'chRoomUuid': uuid,
      'caType': 1,
      'caContractType': contractType,
      'type': type,
    };
    ApiResultModel result = await _chatRepository.createChatFile(params);
    return result;
  }

  Future<ApiResultModel> updateContract(
      String uuid, String msgKey, Map<String, dynamic> preParams) async {
    Map<String, dynamic> params = preParams;
    params['chRoomUuid'] = uuid;
    params['caMessageKey'] = msgKey;
    params['statusUpdateReq'] = {'caRepairStatus': 0};

    ApiResultModel result = await _chatRepository.updateChatFile(params);
    return result;
  }

  Future<ApiResultModel> createDocument(
      String uuid, String type, Map<String, dynamic> preParams) async {
    Map<String, dynamic> params = {
      'chRoomUuid': uuid,
      'caType': 1,
      'caContractType': type,
    };

    if (type == 'VACATION') {
      params['vacationDto'] = preParams;
    } else if (type == 'RESIGNATION') {
      params['resignationDto'] = preParams;
    } else if (type == 'PARENT') {
      params['parentAgreeDto'] = preParams;
    } else if (type == 'SALARY') {
      params['salaryStatementDto'] = preParams['salaryStatementDto'];
      params['salaryPaymentDto'] = preParams['salaryPaymentDto'];
      params['salaryDeductionDto'] = preParams['salaryDeductionDto'];
    }
    ApiResultModel result = await _chatRepository.createChatFile(params);
    return result;
  }

  Future<ApiResultModel> updateChatMsgUuid(String msgKey, int caIdx) async {
    Map<String, dynamic> params = {
      'caMessageKey': msgKey,
      'caIdx': caIdx,
    };
    ApiResultModel result = await _chatRepository.updateChatMsgUuid(params);
    return result;
  }

  Future<ApiResultModel> updateDocumentStatus(
      String msgKey, String chRoomUuid, int status) async {
    Map<String, dynamic> params = {
      'caMessageKey': msgKey,
      'chRoomUuid': chRoomUuid,
      'statusUpdateReq': {
        'caRepairStatus': status,
      }
    };
    ApiResultModel result = await _chatRepository.updateDocumentStatus(params);
    return result;
  }

  Future<ApiResultModel> getChatFileList(String uuid, String memberType) async {
    Map<String, dynamic> params = {
      "chRoomUuid": uuid,
      "caType": 1,
      "memberType": memberType,
      'dirs': 'desc',
    };
    ApiResultModel result = await _chatRepository.getChatFileList(params);
    return result;
  }

  Future<ApiResultModel> getChatFileDetail(String messageUuid) async {
    Map<String, dynamic> params = {
      "messageUuid": messageUuid,
    };

    ApiResultModel result = await _chatRepository.getChatFileDetail(params);
    return result;
  }

  Future<ApiResultModel> getLastChatFile(int key) async {
    Map<String, dynamic> params = {
      "caIdx": key,
    };

    ApiResultModel result = await _chatRepository.getLastChatFile(params);
    return result;
  }

  Future<ApiResultModel> getChatMediaList(
      String uuid, String memberType, int page) async {
    Map<String, dynamic> params = {
      "page": page,
      "size": 20,
      "chRoomUuid": uuid,
      "caType": 2,
      "memberType": memberType,
      'dirs': 'desc',
      'props': 'create',
    };

    ApiResultModel result = await _chatRepository.getChatFileList(params);
    return result;
  }

  Future<ApiResultModel> createChatRoom(Map<String, dynamic> params) async {
    ApiResultModel result = await _chatRepository.createChatRoom(params);
    return result;
  }

  Future<ApiResultModel> getPremiumService(String code) async {
    Map<String, dynamic> params = {'cpCode': code};
    ApiResultModel result = await _chatRepository.getPremiumService(params);
    return result;
  }

  Future<ApiResultModel> payChocoChat(int jaIdx) async {
    Map<String, dynamic> params = {'jaIdx': jaIdx};
    ApiResultModel result = await _chatRepository.payChocoChat(params);
    return result;
  }

  Future<ApiResultModel> payChocoExtensionChat(int jaIdx) async {
    Map<String, dynamic> params = {'jaIdx': jaIdx};
    ApiResultModel result = await _chatRepository.payChocoExtensionChat(params);
    return result;
  }

  Future<ApiResultModel> deleteChatFile(String msgKey) async {
    Map<String, dynamic> params = {
      'caMessageKey': msgKey,
    };
    ApiResultModel result = await _chatRepository.deleteChatFile(params);
    return result;
  }

  Future<ApiResultModel> sendEmail(Map<String, dynamic> params) async {
    ApiResultModel result = await _chatRepository.sendEmail(params);
    return result;
  }

  Future<ApiResultModel> autoExtendChatRoom(
      String roomUuid, int autoExtend) async {
    Map<String, dynamic> params = {
      'chRoomUuid': roomUuid,
      'chAutoExtend': autoExtend,
    };
    ApiResultModel result = await _chatRepository.autoExtendChatRoom(params);
    return result;
  }

  Future<ApiResultModel> getChatDetail(String roomUuid) async {
    Map<String, dynamic> params = {
      'chRoomUuid': roomUuid,
    };
    ApiResultModel result = await _chatRepository.getChatDetail(params);
    return result;
  }

  Future<ApiResultModel> getAttendance(String roomUuid) async {
    ApiResultModel result = await _chatRepository.getAttendance(roomUuid);
    return result;
  }

  Future<ApiResultModel> getCompanyEvaluateRemain(String roomKey) async {
    Map<String, dynamic> params = {'chRoomUuid': roomKey};

    ApiResultModel? result =
        await _chatRepository.getCompanyEvaluateRemain(params);
    return result;
  }

  Future<ApiResultModel> getJobseekerEvaluateRemain(String roomKey) async {
    Map<String, dynamic> params = {'chRoomUuid': roomKey};

    ApiResultModel? result =
    await _chatRepository.getJobseekerEvaluateRemain(params);
    return result;
  }
}
