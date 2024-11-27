import os
import re
from typing import Callable

# 정규표현식: 작은 따옴표 안의 텍스트 추출
pattern = r"'([^']*?[가-힣][^']*?)'"


# 조건 필터링 함수
def should_extract(text):
    return re.search(r"[가-힣]", text) is not None


# 파일 처리 함수
def parse_document(file_path, extract_func: Callable):
    results = {"filename": os.path.basename(file_path), "matches": []}

    with open(file_path, "r", encoding="utf-8") as document:
        for line, text in enumerate(document, start=1):
            if extract_func(text):  # 한국어 포함 여부 확인
                matches = re.findall(pattern, text)  # 작은 따옴표 안의 텍스트 추출
                if matches:
                    results["matches"].append({"line": line, "text": matches[0]})
    return results


# 실행
if __name__ == "__main__":
    result = parse_document(
        "src/data/jobposting_apply_detail_screen.dart", should_extract
    )
    print(result)