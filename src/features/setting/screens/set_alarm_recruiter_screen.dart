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

class SetAlarmRecruiterScreen extends ConsumerStatefulWidget {
  const SetAlarmRecruiterScreen({super.key});

  @override
  ConsumerState<SetAlarmRecruiterScreen> createState() => _SetAlarmRecruiterScreenState();
}

class _SetAlarmRecruiterScreenState extends ConsumerState<SetAlarmRecruiterScreen> {
  Map<String, dynamic> alarmData = {
    'marJobpostingState': false, // 공고 상태 알림 도착 알림
    'marJobpostingDisplay': false, // 공고 노출 처리 알림

    'marCompanyIncomplete': false, // 회사정보 미완성 알림
    'marNewRecommend': false, // 추천 인재 신규 도착 알림
    'marNewApplicant': false, // 신규 지원자 알림
    'marOfferAllow': false, // 제안 수락/거절 알림
    'marTalent': false, // 관심인재 알림

    'marMessage': false, // 대화/사진/파일 전송 알림
    'marEmployment': false, // 근로계약서 체결 알림
    'marAttendance': false, // 근태 알림
    'marDocument': false, // 서류 도착 알림

    'marChoco': false, // 초단코인 안내
    'marRegionPriority': false, // 지역별 상위 노출 안내
    'marMessageEnd': false, // 대화 만료 안내
    'marMadMatching': false, // 미친매칭 안내
    'marBrandTheme': false, // 브랜드테마관 안내

    'maQnaAlarm': false, // 노무상담답변 알림
    'maNoticeAlarm': false, // 공지 알림

    'maMarketingSms': false, // 문자 수신 알림
    'maMarketingEmail': false, // 이메일 수신 알림
    'maMarketingPush': false, // 푸시 수신 알림
    'maNightAlarm': false, // 야간 수신 동의 여부 알림
  };

  Map<String, bool> notificationStatus = {
    'post': false,
    'recruitment': false,
    'chat': false,
    'premium': false,
    'etc': false,
    'marketing': false,
  };

  List postArr = [
    {'title': '공고 상태 알림 (게제, 마감, 보류)', 'key': 'marJobpostingState', 'value': false},
    {'title': '공고 노출 처리 알림 (노출, 비노출)', 'key': 'marJobpostingDisplay', 'value': false},
  ];

  List recruitmentArr = [
    {'title': '회사정보 미완성 알림', 'key': 'marCompanyIncomplete', 'value': false},
    {'title': '추천 인재 신규 도착 알림', 'key': 'marNewRecommend', 'value': false},
    {'title': '신규 지원자 알림', 'key': 'marNewApplicant', 'value': false},
    {'title': '제안 수락/거절 알림', 'key': 'marOfferAllow', 'value': false},
    {'title': '관심인재 알림', 'key': 'marTalent', 'value': false},
  ];

  List chatArr = [
    {'title': '대화/사진/파일 전송 알림', 'key': 'marMessage', 'value': false},
    {'title': '근로계약서 체결 알림', 'key': 'marEmployment', 'value': false},
    {'title': '근태 알림', 'key': 'marAttendance', 'value': false},
    {'title': '서류 도착 알림', 'key': 'marDocument', 'value': false},
  ];

  List premiumArr = [
    {'title': '초단코인 안내', 'key': 'marChoco', 'value': false},
    {'title': '지역별 상위 노출 안내', 'key': 'marRegionPriority', 'value': false},
    {'title': '대화 만료 안내', 'key': 'marMessageEnd', 'value': false},
    {'title': '미친매칭 안내', 'key': 'marMadMatching', 'value': false},
    {'title': '브랜드 테마관 안내', 'key': 'marBrandTheme', 'value': false},
  ];

  List etcArr = [
    {'title': '노무상담답변 알림', 'key': 'maQnaAlarm', 'value': false},
    {'title': '공지 알림', 'key': 'maNoticeAlarm', 'value': false},
  ];

  List marketingArr = [
    {'title': localization.687, 'key': 'maMarketingSms', 'value': false, 'target': localization.688},
    {'title': localization.689, 'key': 'maMarketingEmail', 'value': false, 'target': localization.email},
    {'title': localization.691, 'key': 'maMarketingPush', 'value': false, 'target': localization.692},
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
    await ref.read(logControllerProvider.notifier).savePageLog(LogTypeEnum.other.type);
  }

  setAlarmData(String key, bool value) {
    alarmData[key] = value;
  }

  setToggle(Map<String, dynamic> data, dynamic value){
    setState(() {
      data['value'] = !value;
      setAlarmData(data['key'], !value);

      // 마케팅 알림 전체가 OFF인 경우, 야간 수신 동의도 자동으로 OFF 처리
      if (alarmData['maMarketingSms'] == false && alarmData['maMarketingEmail'] == false && alarmData['maMarketingPush'] == false) {
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
    String agreeString = isAgree ? localization.671 : localization.672;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertConfirmDialog(
          alertTitle: '정보 수신 $agreeString 안내',
          alertContent: '${DateFormat(localization.239).format(now)}\n 마케팅 정보 수신 $agreeString($target) 처리되었어요.',
          alertConfirm: localization.confirm,
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
      for (var item in postArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in recruitmentArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in chatArr) {
        item['value'] = alarmData[item['key']] ?? false;
      }

      for (var item in premiumArr) {
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
    ApiResultModel result = await ref.read(authControllerProvider.notifier).getUserData();
    if (result.status == 200) {
      if (result.data != null) {
        alarmData['marJobpostingState'] = result.data.recruiterAlarm['marJobpostingState'];
        alarmData['marJobpostingDisplay'] = result.data.recruiterAlarm['marJobpostingDisplay'];

        alarmData['marCompanyIncomplete'] = result.data.recruiterAlarm['marCompanyIncomplete'];
        alarmData['marNewRecommend'] = result.data.recruiterAlarm['marNewRecommend'];
        alarmData['marNewApplicant'] = result.data.recruiterAlarm['marNewApplicant'];
        alarmData['marOfferAllow'] = result.data.recruiterAlarm['marOfferAllow'];
        alarmData['marTalent'] = result.data.recruiterAlarm['marTalent'];

        alarmData['marMessage'] = result.data.recruiterAlarm['marMessage'];
        alarmData['marEmployment'] = result.data.recruiterAlarm['marEmployment'];
        alarmData['marAttendance'] = result.data.recruiterAlarm['marAttendance'];
        alarmData['marDocument'] = result.data.recruiterAlarm['marDocument'];

        alarmData['marChoco'] = result.data.recruiterAlarm['marChoco'];
        alarmData['marRegionPriority'] = result.data.recruiterAlarm['marRegionPriority'];
        alarmData['marMessageEnd'] = result.data.recruiterAlarm['marMessageEnd'];
        alarmData['marMadMatching'] = result.data.recruiterAlarm['marMadMatching'];
        alarmData['marBrandTheme'] = result.data.recruiterAlarm['marBrandTheme'];

        alarmData['maQnaAlarm'] = result.data.marketingAlarm['maQnaAlarm'];
        alarmData['maNoticeAlarm'] = result.data.marketingAlarm['maNoticeAlarm'];

        alarmData['maMarketingSms'] = result.data.marketingAlarm['maMarketingSms'];
        alarmData['maMarketingEmail'] = result.data.marketingAlarm['maMarketingEmail'];
        alarmData['maMarketingPush'] = result.data.marketingAlarm['maMarketingPush'];
        alarmData['maNightAlarm'] = result.data.marketingAlarm['maNightAlarm'];
      }
    }
  }

  updateAlarmStatus() async {
    UserModel? userInfo = ref.read(userProvider);
    if (userInfo != null) {
      ApiResultModel result = await ref.read(authControllerProvider.notifier).updateUserInfo(alarmData, 'recruiter', userInfo.key);
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
            sliver: TitleMenu(title: localization.673),
          ),
          AlarmToggleRadioButton(
            text: localization.674,
            isTop: true,
            onChanged: (value) {
              toggleAllValue('post', postArr);
            },
            groupValue: true,
            value: postArr.every((item) => item['value'] == true),
          ),
          for (var i = 0; i < postArr.length; i++)
            AlarmToggleRadioButton(
              text: postArr[i]['title'],
              onChanged: (value) {
                setToggle(postArr[i], value);
              },
              groupValue: true,
              value: postArr[i]['value'],
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
            sliver: TitleMenu(title: localization.675),
          ),
          AlarmToggleRadioButton(
            text: localization.676,
            isTop: true,
            onChanged: (value) {
              toggleAllValue('recruitment', recruitmentArr);
            },
            groupValue: true,
            value: recruitmentArr.every((item) => item['value'] == true),
          ),
          for (var i = 0; i < recruitmentArr.length; i++)
            AlarmToggleRadioButton(
              text: recruitmentArr[i]['title'],
              onChanged: (value) {
                setToggle(recruitmentArr[i], value);
              },
              groupValue: true,
              value: recruitmentArr[i]['value'],
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
            sliver: TitleMenu(title: localization.677),
          ),
          AlarmToggleRadioButton(
            text: localization.678,
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
            sliver: TitleMenu(title: localization.679),
          ),
          AlarmToggleRadioButton(
            text: localization.680,
            isTop: true,
            onChanged: (value) {
              toggleAllValue('premium', premiumArr);
            },
            groupValue: true,
            value: premiumArr.every((item) => item['value'] == true),
          ),
          for (var i = 0; i < premiumArr.length; i++)
            AlarmToggleRadioButton(
              text: premiumArr[i]['title'],
              onChanged: (value) {
                setToggle(premiumArr[i], value);
              },
              groupValue: true,
              value: premiumArr[i]['value'],
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, 42.w, 0, 8.w),
            sliver: TitleMenu(title: localization.681),
          ),
          AlarmToggleRadioButton(
            text: localization.682,
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
            sliver: TitleMenu(title: localization.683),
          ),
          AlarmToggleRadioButton(
            text: localization.684,
            isTop: true,
            onChanged: (value) {
              toggleAllValue('marketing', marketingArr);
            },
            groupValue: true,
            value: marketingArr.every((item) => item['value'] == true),
          ),
          for (var i = 0; i < marketingArr.length; i++)
            AlarmToggleRadioButton(
              text: marketingArr[i]['title'],
              caption: i == marketingArr.length - 1
                  ? localization.685
                  : null,
              onChanged: (value) {
                setToggle(marketingArr[i], value);

                if (marketingArr[i]['target'] != null) { // 야간 수신 동의는 제외
                  showMarketingConfirmAlert(marketingArr[i]['value'], marketingArr[i]['target']);
                }
              },
              groupValue: true,
              value: marketingArr[i]['value'],
            ),
          const BottomPadding(),
        ],
      ) : const Loader();
  }
}
