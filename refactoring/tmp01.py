import re

# 정규표현식: 바깥쪽 작은따옴표 기준으로 텍스트 추출
pattern = r"'([^']*(?:'[^']*'[^']*)*)'"


def extract_outermost_strings(text_list):
    results = []
    for text in text_list:
        # 정규표현식을 이용해 매칭
        matches = re.findall(pattern, text, flags=re.DOTALL)

        # 작은따옴표를 포함한 결과 추가
        results.extend([f"'{match}'" for match in matches])
    return results


# # 테스트 데이터
# text_list = [
#     "'안녕하세요? '아아아' 끄으응'",
#     "'이건 작은따옴표 안에 작은따옴표를 가진 텍스트'",
#     "'그냥 일반 텍스트'",
#     "'${ProfileService.educationTypeKeyToString(schoolTypes, profileData['educationList'][i]['stIdx'])} ${profileData['educationList'][i]['mpeStatus']}'",
# ]

# # 실행
# results = extract_outermost_strings(text_list)
# print("추출된 텍스트:")
# for result in results:
#     print(result)
# file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage\screens\document_recruiter_screen.dart"
file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features_01\mypage\screens\my_profile_create_screen.dart"
with open(file_path, "r", encoding="utf-8") as file:
    # 파일 내용을 읽어옵니다
    content = file.readlines()
    # 실행
    results = extract_outermost_strings(content)
    print("추출된 텍스트:")
    for result in results:
        print(result)

1. 위 정규표현식으로 ${}, $ <- 뽑기
2. 인자 필요 없는 경우