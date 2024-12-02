import 'dart:convert';

import 'package:chodan_flutter_app/core/service/api_constants.dart';
import 'package:chodan_flutter_app/core/service/api_service.dart';
import 'package:chodan_flutter_app/core/service/utils.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/chat_user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(
    apiService: ApiService(),
    firestore: FirebaseFirestore.instance,
  ),
);

class ChatRepository {
  final ApiService _apiService;
  final FirebaseFirestore _firestore;

  ChatRepository(
      {required ApiService apiService, required FirebaseFirestore firestore})
      : _apiService = apiService,
        _firestore = firestore;

  Future<Map<String, dynamic>> getChatUuid(
      String chatId, String userUuid) async {
    Map<String, dynamic> data = {};
    await _firestore
        .collection('rooms')
        .doc(chatId)
        .collection('user')
        .get()
        .then((doc) => {
              if (doc.docs.isNotEmpty)
                {
                  if (userUuid == doc.docs.first.id)
                    {
                      data = {
                        'me': doc.docs.first.id,
                        'partner': doc.docs.last.id
                      },
                    }
                  else
                    {
                      data = {
                        'me': doc.docs.last.id,
                        'partner': doc.docs.first.id
                      },
                    }
                }
            });

    return data;
  }

  Future<Map<String, dynamic>> getMessageData(
      String roomUuid, String messageUuid) async {
    Map<String, dynamic> data = {};
    await _firestore
        .collection('conversations')
        .doc(roomUuid)
        .collection('message')
        .doc(messageUuid)
        .get()
        .then((doc) => {
              {data = doc.data()!}
            });

    return data;
  }

  Future<void> newMessageDataToFirebase(
      String chatId,
      String msgId,
      Map<String, dynamic> msgObj,
      Map<String, dynamic> lastMsgObj,
      ChatUserModel user,
      Map<String, dynamic> users,
      bool isActive,
      ) async {
    // 트랜잭션을 사용하여 카운트 업데이트
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // 파트너의 메시지 카운트 문서 참조
      DocumentReference partnerCountRef = FirebaseFirestore.instance
          .collection('userMsgCnt')
          .doc(users['partner']);

      // 트랜잭션 내에서 문서 읽기
      DocumentSnapshot partnerCountDoc = await transaction.get(partnerCountRef);

      int partnerCount = partnerCountDoc.exists ? (partnerCountDoc.data() as Map<String, dynamic>)['count'] ?? 0 : 0;

      if (!isActive) {
        partnerCount++;
        // 트랜잭션 내에서 문서 업데이트
        transaction.update(partnerCountRef, {'count': partnerCount});
      }

      // 메시지 저장
      transaction.set(
        FirebaseFirestore.instance
            .collection('conversations')
            .doc(chatId)
            .collection('message')
            .doc(msgId),
        msgObj,
        SetOptions(merge: true),
      );

      // 채팅방 정보 업데이트
      transaction.update(
        FirebaseFirestore.instance.collection('rooms').doc(chatId),
        {
          'msg': lastMsgObj,
          'updated': msgObj['updated'],
        },
      );

      // 내 채팅방 목록 업데이트
      transaction.update(
        FirebaseFirestore.instance
            .collection('users')
            .doc(users['me'])
            .collection('rooms')
            .doc(chatId),
        {
          'updated': msgObj['updated'],
        },
      );

      // 파트너의 채팅방 목록 업데이트
      transaction.update(
        FirebaseFirestore.instance
            .collection('users')
            .doc(users['partner'])
            .collection('rooms')
            .doc(chatId),
        {
          'updated': msgObj['updated'],
          'count': isActive ? 0 : partnerCount,
          'isOut': false,
        },
      );
    });
  }



  updateFiles(String roomUuid, String messageUuid, dynamic file) async {
    await _firestore
        .collection('conversations')
        .doc(roomUuid)
        .collection('message')
        .doc(messageUuid)
        .update({
      'files': file,
    });
  }

  deleteMessage(
    String chatId,
    String msgId,
    Map<String, dynamic> users,
  ) async {
    await _firestore
        .collection('conversations')
        .doc(chatId)
        .collection('message')
        .doc(msgId)
        .update({
      'deleted': FieldValue.arrayUnion([users['me']]),
    });
  }

  outChatRoom(String chatId, String userUuid) async {
    await _firestore
        .collection('users')
        .doc(userUuid)
        .collection('rooms')
        .doc(chatId)
        .update({
      'isOut': true,
    });
  }

  Future<ApiResultModel> createChatReport(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}report/chat';
    Response response = await _apiService.post(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createChatFile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}chat/attachment';
    Response response = await _apiService.post(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> updateChatFile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/chat/attachment/update';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> updateChatMsgUuid(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}chat/attachment/message/update';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> updateDocumentStatus(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}chat/attachment/status/update';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChatFileList(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}chat/attachment';
    Response response = await _apiService.get(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'],
          data: list,
          status: response.statusCode,
          page: data['result']['page']);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChatFileDetail(Map<String, dynamic> params) async {
    String url =
        '${ApiConstants.apiUrl}chat/attachment/${params['messageUuid']}';
    Response response = await _apiService.get(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getLastChatFile(Map<String, dynamic> params) async {
    String url =
        '${ApiConstants.apiUrl}chat/attachment/latest/${params['caIdx']}';
    Response response = await _apiService.get(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> deleteChatFile(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}chat/gallery/delete';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> createChatRoom(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/chat';
    Response response = await _apiService.post(url, params);

    var body = jsonDecode(response.body);
    Map<String, dynamic> data = getHttpResponseData(body);

    if (response.statusCode == 200) {
      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    } else {
      return ApiResultModel(
          type: data['code'],
          data: data['result'],
          status: response.statusCode);
    }
  }

  Future<ApiResultModel> payChocoChat(Map<String, dynamic> params) async {
    String url =
        '${ApiConstants.apiUrl}choco/premium/chat-open/${params['jaIdx']}';
    Response response = await _apiService.post(url, params);

    var body = jsonDecode(response.body);

    dynamic list = body['result'];
    if (body['code'] == 1) {
      return ApiResultModel(
          type: body['code'], data: list['data'], status: response.statusCode);
    } else {
      return ApiResultModel(
          type: body['code'],
          data: body['message'],
          status: response.statusCode);
    }
  }

  Future<ApiResultModel> payChocoExtensionChat(
      Map<String, dynamic> params) async {
    String url =
        '${ApiConstants.apiUrl}choco/premium/chat-extension/${params['jaIdx']}';
    Response response = await _apiService.post(url, params);

    var body = jsonDecode(response.body);

    dynamic list = body['result'];
    if (body['code'] == 1) {
      return ApiResultModel(
          type: body['code'], data: list['data'], status: response.statusCode);
    } else {
      return ApiResultModel(
          type: body['code'],
          data: body['message'],
          status: response.statusCode);
    }
  }

  Future<ApiResultModel> getPremiumService(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}choco/premium/${params['cpCode']}';
    Response response = await _apiService.get(url, {});

    var body = jsonDecode(response.body);

    dynamic list = body['result'];
    if (body['code'] == 1) {
      return ApiResultModel(
          type: body['code'], data: list['data'], status: response.statusCode);
    } else {
      return ApiResultModel(
          type: body['code'],
          data: body['message'],
          status: response.statusCode);
    }
  }

  Future<ApiResultModel> sendEmail(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}mail';
    Response response = await _apiService.post(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> autoExtendChatRoom(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/chat/extend';
    Response response = await _apiService.put(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getChatDetail(Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}recruiter/chat/detail';
    Response response = await _apiService.get(url, params);

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getAttendance(String uuid) async {
    String url = '${ApiConstants.apiUrl}attendance/status/$uuid';
    Response response = await _apiService.get(url, {});

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      dynamic list = data['result'].containsKey('list')
          ? data['result']['list']
          : data['result']['data'];

      return ApiResultModel(
          type: data['code'], data: list, status: response.statusCode);
    }

    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getCompanyEvaluateRemain(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/company/remain';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['remain'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }

  Future<ApiResultModel> getJobseekerEvaluateRemain(
      Map<String, dynamic> params) async {
    String url = '${ApiConstants.apiUrl}evaluate/jobseeker/remain';
    Response response = await _apiService.get(url, params);
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      Map<String, dynamic> data = getHttpResponseData(body);

      return ApiResultModel(
          type: data['code'],
          data: data['result']['data']['remain'],
          status: response.statusCode,
          page: data['result']['page']);
    }
    return returnHttpStatusCode(response);
  }
}
