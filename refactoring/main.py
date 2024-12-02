# import re

# from tmp import read_doc

# if __name__ == "__main__":
#     # text = """
#     # 'key': "안녕하세요"
#     # "key": "안녕하세요 $asd('1')"
#     # '${dateTime.month.toString().padLeft(2, '0')}월 '
#     # tabTitleArr: const ['계약서', '사직서'],
#     # showDefaultToast('데이터 통신에 실패하였습니다.');
#     # '${ConditionCareerEnum.experienced.label} $minCareer ~ $maxCareer 년';
#     # """.split(
#     #     "\n"
#     # )
#     # file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\jobposting\screens\jobposting_apply_detail_screen.dart"
#     file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage\screens\document_jobseeker_screen.dart"
#     text = read_doc(file_path)

#     # 따옴표 안의 내용을 매칭하는 패턴 (한글이 포함된 경우만)
#     pattern = re.compile(r"['\"]([^'\"]*?[가-힣]+[^'\"]*?)['\"]")

#     # 한글만 추출하는 패턴
#     hangul_only_pattern = re.compile(r"[가-힣]+")

#     # 결과를 담을 리스트
#     results = []

#     # 각 줄을 처리
#     for line in text:
#         matches = pattern.findall(line)  # 따옴표 안에서 한글이 포함된 내용 추출
#         hangul_extracted = [
#             " ".join(hangul_only_pattern.findall(match)) for match in matches
#         ]  # 각 매칭된 내용에서 한글만 추출
#         results.append(
#             {
#                 "line": line.strip(),
#                 "has_hangul": bool(matches),
#                 "extracted_hangul": hangul_extracted,
#             }
#         )

#     # 결과 출력
#     for result in results:

#         has_hangul = result["has_hangul"]
#         if has_hangul:

#             print(f"Line: {result['line']}")
#             print(f"Contains Hangul: {result['has_hangul']}")
#             print(f"Extracted Hangul: {result['extracted_hangul']}")
#             print("---")
