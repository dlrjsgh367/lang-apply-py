# import re

# # 정규표현식 패턴: 작은따옴표 안의 문자열 추출
# pattern = r"'((?:[^']|'[^']*')*?\${.*?}.*?|(?:[^']|'[^']*')*?[가-힣].*?)'"


# def extract_text_from_file(file_path):
#     try:
#         with open(file_path, "r", encoding="utf-8") as file:
#             # 파일 내용을 읽어옵니다
#             content = file.readlines()

#         results = []
#         for line in content:
#             # 정규표현식으로 추출
#             matches = re.findall(pattern, line)

#             # 매칭된 결과를 결과 리스트에 추가
#             results.extend(matches)

#         return results
#     except FileNotFoundError:
#         print(f"Error: 파일을 찾을 수 없습니다: {file_path}")
#         return []
#     except Exception as e:
#         print(f"Error: 파일 읽기 중 문제가 발생했습니다: {e}")
#         return []


# # 실행
# if __name__ == "__main__":
#     file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage\screens\document_recruiter_screen.dart"
#     results = extract_text_from_file(file_path)
#     if results:
#         print("추출된 텍스트:")
#         for result in results:
#             print(result)
#     else:
#         print("추출된 텍스트가 없습니다.")


import re

# 정규표현식 패턴
pattern = r"'((?:[^']*?\${.*?}.*?|[^']*?[가-힣][^']*?))'"


def extract_text_from_file(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            # 파일 내용을 읽어옵니다
            content = file.readlines()

        results = []
        for line in content:
            # 정규표현식으로 추출
            matches = re.findall(pattern, line)

            # 매칭된 결과를 결과 리스트에 추가
            results.extend(matches)

        return results
    except FileNotFoundError:
        print(f"Error: 파일을 찾을 수 없습니다: {file_path}")
        return []
    except Exception as e:
        print(f"Error: 파일 읽기 중 문제가 발생했습니다: {e}")
        return []


# 실행
if __name__ == "__main__":
    file_path = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage\screens\document_recruiter_screen.dart"
    results = extract_text_from_file(file_path)
    if results:
        print("추출된 텍스트:")
        for result in results:
            print(result)
    else:
        print("추출된 텍스트가 없습니다.")
