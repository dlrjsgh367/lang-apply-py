import re


def map_to_string(file, sheet_records):

    with open(file, "r", encoding="utf-8") as doc:
        lines = doc.readlines()

    results = [
        "import 'package:chodan_flutter_app/utils/app_localizations.dart';'",
        "\n",
    ]
    for line in lines:
        result = process_line(line, file, sheet_records)
        results.append(result)
        # print(line)

    with open(file, "w", encoding="utf-8") as output:
        output.writelines(results)


def process_line(line, output, sheet_records, basename="localization.{}"):
    pattern_x = re.compile(r"['\"]([^'\"]*[가-힣]+[^'\"]*)['\"]")

    matches = pattern_x.findall(line)
    if not matches:
        return line
    for match in matches:
        for sheet_record in sheet_records:
            if match.strip() == sheet_record.get("ko"):
                key = sheet_record.get("key")
                replacement = basename.format(key)

                if "'" in line:
                    line = line.replace(f"'{match}'", replacement)
                elif '"' in line:
                    line = line.replace(f'"{match}"', replacement)
    return line


# - {}년 {}월 {}일
# - 가입된 아이디는 총 {}개 있어요.
# - 본인은 위 근로자 {}(이)가 위 사업장에서\n
# - 친권자 : {}
# - 현재 위치는 근무지와의 거리가 초과했어요.\n해당 주소로 외근하고 계신지 확인하세요.\n{}
# - {}일
# - 현재 {}까지 대화 가능 해요\n대화 기간을 더 연장 하시겠어요?\n${}초코 결제시 ${} 더 대화할 수 있어요.
# - {} 초코
# - 대화기간 종료 전 초단코인 잔액 한도내에서 {}초코가 자동 결제 되어 대화기간을 연장합니다.
# - {}친권자동의서
# - 본인은 위 근로자  {} (이)가 위 사업장에서\n근로를 하는 것에 대하여 동의합니다.
# - 친권자: {}
# - {}사직서
# - 신청자: {}
# - {}님과의 대화창을 열었습니다. 이제 톡으로 직접 소통해요!
# - ※ 대화기간 {}일, 추가결제를 통해 대화 기간 연장 가능
# - 대화를 시작하려면 {}초코가 필요해요.\n결제후 대화를 시작하시겠어요?
# - 충전되어 있는 초코 잔액 한도 내에서 30일마다 자동으로 {}초코를 결제하고 대화 기간을 연장 해요.  
# - {}휴가 신청서
# - {}명
# - {} 원
# - (}세
# - {}원
# - {}분
# - {}개월
# - 금칙어
# - {}억
# - {}억+
# - {}만
# - {}만+
# - 댓글 ({})
# - 총 {}건
# - ({}세, {})
# - {} 님의 취업활동 결과입니다.
# - {} 님은 {} 부터 {} 까지\n
# - 총 {}년 {}개월
# - {} 전체
# - 사직일 {}
# - +{} 초코
# - {}년 {}월
# - {}년 
# - {}건
# - {} 등록에 성공했습니다.
# - 테마관내 등록된 동고 : {}개
# - 거절사유 : {}
# - {} 신청 내역
# - {}월
# - {} 신청하기
# - {} 신청 기록이 없어요.
# - {} 신청
# - {} / 요일 협의
# - {} / 시간 협의
# - 정보 수신 {} 안내
# - {} 상태 변경
# - {} 상태
# - {}% 완료
# - {}이력서
# - 만 {}세
# - 외 {}개