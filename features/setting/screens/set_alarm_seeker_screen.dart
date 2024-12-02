import 'package:chodan_flutter_app/core/common/loader.dart';
import 'package:chodan_flutter_app/enum/log_type_enum.dart';
import 'package:chodan_flutter_app/features/alarm/widgets/alarm_toggle_radio_button.dart';
import 'package:chodan_flutter_app/features/auth/controller/auth_controller.dart';
import 'package:chodan_flutter_app/features/log/controller/log_controller.dart';
import 'package:chodan_flutter_app/features/menu/widgets/title_menu.dart';
import 'package:chodan_flutter_app/models/api_result_model.dart';
import 'package:chodan_flutter_app/models/user_model.dart';
import 'package:chodan_flutter_app/widgets/dialog/alert_confirm_dialog.dart';
import 'package:chodan_flutter_app/widgets/etc/bottom_padding.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SetAlarmSeekerScreen extends ConsumerStatefulWidget {
  const SetAlarmSeekerScreen({super.key});

  @override
  ConsumerState<SetAlarmSeekerScreen> createState() =>
      _SetAlarmSeekerScreenState();
}

class _SetAlarmSeekerScreenState extends ConsumerState<SetAlarmSeekerScreen> {
  Map<String, dynamic> alarmData = {
    'majRecommend': false, // 추천 알바 신규 도착 알림
    'majNearNewJobposting': false, // 근처 신규 채용 공고 알림
    'majJobOffer': false, // 일자리 제안 수신 알림
    'majScrap': false, // 스크랩 공고 마감 알림
    'majNewRecruits': false, // 관심기업 신규 채용공고 알림
    'majProfile': false, // 프로필 미완성 알림
    'majJobposting': false, // 공고 지원 알림
    'majDisplayProfile': false, // 프로필 노출/비노출 알림
    'majNewRoom': false, // 새 대화창 알림
    'majMessage': false, // 대화/사진/파일 전송 알림
    'majEmployment': false, // 근로계약서 수신 알림
    'majSalary': false, // 급여내역서 수신 알림
    'majDocumentRejection': false, // 서류 수리 반려 알림
    'maQnaAlarm': false, // 노무상담답변 알림
    'maNoticeAlarm': false, // 공지 알림
    'maMarketingSms': false, // 문자 수신 알림
    'maMarketingEmail': false, // 이메일 수신 알림
    'maMarketingPush': false, // 푸시 수신 알림
    'maNightAlarm': false, // 야간 수신 동의 여부 알림
  };

  Map<String, bool> notificationStatus = {
    'employmentInfo': false,
    'jobSeeking': false,
    'chat': false,
    'etc': false,
    'marketing': false,
  };

  List employmentInfoArr = [
    {'title': '추천 알바 신규 도착 알림', 'key': 'majRecommend', 'value': false},
    {'title': '근처 신규 채용 공고 알림', 'key': 'majNearNewJobposting', 'value': false},
    {'title': '일자리 제안 수신 알림', 'key': 'majJobOffer', 'value': false},
    {'title': '스크랩 공고 마감 알림', 'key': 'majScrap', 'value': false},
    {'title': '관심기업 신규 채용공고 알림', 'key': 'majNewRecruits', 'value': false},
  ];

  List jobSeekingArr = [
    {'title': '프로필 미완성 알림', 'key': 'majProfile', 'value': false},
    {'title': '공고 지원 알림', 'key': 'majJobposting', 'value': false},
    {'title': '프로필 노출/비노출 알림', 'key': 'majDisplayProfile', 'value': false},
  ];

  List chatArr = [
    {'title': '새 대화창 알림', 'key': 'majNewRoom', 'value': false},
    {'title': '대화/사진/파일 전송 알림', 'key': 'majMessage', 'value': false},
    {'title': '근로계약서 수신 알림', 'key': 'majEmployment', 'value': false},
    {'title': '급여내역서 수신 알림', 'key': 'majSalary', 'value': false},
    {'title': '서류 수리 반려 알림', 'key': 'majDocumentRejection', 'value': false},
  ];

  List etcArr = [
    {'title': '노무상담답변 알림', 'key': 'maQnaAlarm', 'value': false},
    {'title': '공지 알림', 'key': 'maNoticeAlarm', 'value': false},
  ];

  List marketingArr = [
    {
      'title': '문자 수신',
      'key': 'maMarketingSms',
      'value': false,
      'target': '휴대폰문자'
    },
    {
      'title': '이메일 수신',
      'key': 'maMarketingEmail',
      'value': false,
      'target': '이메일'
    },
    {
      'title': '푸시 수신',
      'key': 'maMarketingPush',
      'value': false,
      'target': '앱 푸시'
    },
    {'title': '야간 수신 동의 여부', 'key': 'maNightAlarm', 'value': false},
  ];

  bool isLoading = true;

  Future<void> _getAllAsyncTasks() async {
    await Future.wait<void>([
      savePageLog(),
      getUserData(),
    ]);
  }

  savePageLog() async {
    await ref
        .read(logControllerProvider.notifier)
        .savePageLog(LogTypeEnum.other.type);
  }

  setAlarmData(String key, bool value) {
    alarmData[key] = value;
  }

  setToggle(Map<String, dynamic> data, dynamic value) {
    setState(() {
      data['value'] = !value;
      setAlarmData(data['key'], !value);

      // 마케팅 알림 전체가 OFF인 경우, 야간 수신 동의도 자동으로 OFF 처리
      if (alarmData['maMarketingSms'] == false &&
          alarmData['maMarketingEmail'] == false &&
          alarmData['maMarketingPush'] == false) {
        alarmData['maNightAlarm'] = false;

        for (var item in marketingArr) {
          if (item['key'] == 'maNightAlarm') {
            item['value'] = false;
            break;
          }
        }
      }

      updateAlarmStatus(); // 알림 설정 API
    });
  }

  toggleAllValue(String key, List<dynamic> itemList) {
    setState(() {
      bool allValue = itemList.every((item) => item['value'] == true);
      notificationStatus[key] = !allValue;

      for (var item in itemList) {
        item['value'] = notificationStatus[key];
        setAlarmData(item['key'], notificationStatus[key]!);
      }

      updateAlarmStatus(); // 알림 설정 API
    });
  }

  showMarketingConfirmAlert(bool isAgree, String target) {
    DateTime now = DateTime.now();
    String agreeString = isAgree ? '동의' : '거부';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertConfirmDialog(
          alertTitle: '정보 수신 $agreeString 안내',
          alertContent:
              '${DateFormat('yyyy년 MM월 dd일').format(now)}\n 마케팅 정보 수신 $agreeString($target) 처리되었어요.',
          alertConfirm: '확인',
          confirmFunc: () {
            context.pop();
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _getAllAsyncTasks().then((_) {
      for (var item in employmentInfoArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in jobSeekingArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in chatArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in etcArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in marketingArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  getUserData() async {
    ApiResultModel result =
        await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.data != null) {
        alarmData['majRecommend'] = result.data.jobSeekerAlarm['majRecommend'];
        alarmData['majNearNewJobposting'] =
            result.data.jobSeekerAlarm['majNearNewJobposting'];
        alarmData['majJobOffer'] = result.data.jobSeekerAlarm['majJobOffer'];
        alarmData['majScrap'] = result.data.jobSeekerAlarm['majScrap'];
        alarmData['majNewRecruits'] =
            result.data.jobSeekerAlarm['majNewRecruits'];
        alarmData['majProfile'] = result.data.jobSeekerAlarm['majProfile'];
        alarmData['majJobposting'] =
            result.data.jobSeekerAlarm['majJobposting'];
        alarmData['majDisplayProfile'] =
            result.data.jobSeekerAlarm['majDisplayProfile'];
        alarmData['majNewRoom'] = result.data.jobSeekerAlarm['majNewRoom'];
        alarmData['majMessage'] = result.data.jobSeekerAlarm['majMessage'];
        alarmData['majEmployment'] =
            result.data.jobSeekerAlarm['majEmployment'];
        alarmData['majSalary'] = result.data.jobSeekerAlarm['majSalary'];
        alarmData['majDocumentRejection'] =
            result.data.jobSeekerAlarm['majDocumentRejection'];
        alarmData['maQnaAlarm'] = result.data.marketingAlarm['maQnaAlarm'];
        alarmData['maNoticeAlarm'] =
            result.data.marketingAlarm['maNoticeAlarm'];

        alarmData['maMarketingSms'] =
            result.data.marketingAlarm['maMarketingSms'];
        alarmData['maMarketingEmail'] =
            result.data.marketingAlarm['maMarketingEmail'];
        alarmData['maMarketingPush'] =
            result.data.marketingAlarm['maMarketingPush'];
        alarmData['maNightAlarm'] = result.data.marketingAlarm['maNightAlarm'];
      }
    } else {
      showErrorAlert('회원정보', '회원정보를 가져오기에 실패하였습니다.');
    }
  }

  showErrorAlert(String title, String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertConfirmDialog(
            alertTitle: title,
            alertContent: content,
            alertConfirm: '확인',
            confirmFunc: () {
              context.pop(context);
              context.pop(context);
            },
          );
        });
  }

  updateAlarmStatus() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref
          .read(authControllerProvider.notifier)
          .updateUserInfo(alarmData, 'jobseeker', userInfo.key);
      if (result.status == 200) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 16.w, 0, 8.w),
                sliver: TitleMenu(title: '채용정보 알림'),
              ),
              AlarmToggleRadioButton(
                text: '채용정보 알림 전체',
                isTop: true,
                onChanged: (value) {
                  toggleAllValue('employmentInfo', employmentInfoArr);
                },
                groupValue: true,
                value: employmentInfoArr.every((item) => item['value'] == true),
              ),
              for (var i = 0; i < employmentInfoArr.length; i++)
                AlarmToggleRadioButton(
                  text: employmentInfoArr[i]['title'],
                  onChanged: (value) {
                    setToggle(employmentInfoArr[i], value);
                  },
                  groupValue: true,
                  value: employmentInfoArr[i]['value'],
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
                sliver: TitleMenu(title: '구직활동 알림'),
              ),
              AlarmToggleRadioButton(
                text: '구직 활동 알림 전체',
                isTop: true,
                onChanged: (value) {
                  toggleAllValue('jobSeeking', jobSeekingArr);
                },
                groupValue: true,
                value: jobSeekingArr.every((item) => item['value'] == true),
              ),
              for (var i = 0; i < jobSeekingArr.length; i++)
                AlarmToggleRadioButton(
                  text: jobSeekingArr[i]['title'],
                  onChanged: (value) {
                    setToggle(jobSeekingArr[i], value);
                  },
                  groupValue: true,
                  value: jobSeekingArr[i]['value'],
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
                sliver: TitleMenu(title: '매칭/대화 알림'),
              ),
              AlarmToggleRadioButton(
                text: '매칭/대화 알림 전체',
                isTop: true,
                onChanged: (value) {
                  toggleAllValue('chat', chatArr);
                },
                groupValue: true,
                value: chatArr.every((item) => item['value'] == true),
              ),
              for (var i = 0; i < chatArr.length; i++)
                AlarmToggleRadioButton(
                  text: chatArr[i]['title'],
                  onChanged: (value) {
                    setToggle(chatArr[i], value);
                  },
                  groupValue: true,
                  value: chatArr[i]['value'],
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
                sliver: TitleMenu(title: '기타 알림'),
              ),
              AlarmToggleRadioButton(
                text: '기타 알림 전체',
                isTop: true,
                onChanged: (value) {
                  toggleAllValue('etc', etcArr);
                },
                groupValue: true,
                value: etcArr.every((item) => item['value'] == true),
              ),
              for (var i = 0; i < etcArr.length; i++)
                AlarmToggleRadioButton(
                  text: etcArr[i]['title'],
                  onChanged: (value) {
                    setToggle(etcArr[i], value);
                  },
                  groupValue: true,
                  value: etcArr[i]['value'],
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
                sliver: TitleMenu(title: '마케팅 알림'),
              ),
              AlarmToggleRadioButton(
                text: '마케팅 알림 전체',
                isTop: true,
                onChanged: (value) {
                  toggleAllValue('marketing', marketingArr);
                  showMarketingConfirmAlert(
                      notificationStatus['marketing']!, '전체');
                },
                groupValue: true,
                value: marketingArr.every((item) => item['value'] == true),
              ),
              for (var i = 0; i < marketingArr.length; i++)
                AlarmToggleRadioButton(
                  text: marketingArr[i]['title'],
                  caption: i == marketingArr.length - 1
                      ? '오후 9시부터 다음날 오전 8시까지 마케팅 정보를 받습니다.'
                      : null,
                  onChanged: (value) {
                    setToggle(marketingArr[i], value);

                    if (marketingArr[i]['target'] != null) {
                      // 야간 수신 동의는 제외
                      showMarketingConfirmAlert(
                          marketingArr[i]['value'], marketingArr[i]['target']);
                    }
                  },
                  groupValue: true,
                  value: marketingArr[i]['value'],
                ),
              const BottomPadding(),
            ],
          )
        : const Loader();
  }
}
