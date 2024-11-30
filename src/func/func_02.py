import os
import re
import copy
from typing import List, Dict, Callable

from sheet_task import get_sheet_records


def extract_variable(text: str):
    """
    텍스트에서 인자를 추출하여 반환.
    """
    matches = re.findall(r"\$\{[^}]+\}|\$\w+", text)  # ${...} 내부 내용 추출
    return matches


def extract_value_from_variables(text: str):
    """
    Extract variables inside ${...} and $... from the text.
    - ${...}: Extracts English and special characters inside the brackets.
    - $...: Extracts English and special characters only, ignoring Korean characters.
    - Extract specific patterns like 'yyyy년 MM월 dd일'.
    Args:
        text (str): Input text containing ${...} or $...
    Returns:
        list: A list of extracted variable names.
    """
    # Extract ${...}, $... patterns, and text inside DateFormat()
    matches = re.findall(
        r"\$\{([a-zA-Z0-9_!.\(\)\[\]'\s]+)\}|\$([a-zA-Z0-9_!.\(\)\[\]]+)", text
    )
    # Flatten the list and remove None values
    variables = [match[0] if match[0] else match[1] for match in matches]

    # Extract specific patterns inside DateFormat('...')
    date_formats = re.findall(r"DateFormat\('([^']+)'\)", text)
    variables.extend(date_formats)

    return variables


def process_duplicates(data):
    unique_texts = {}  # 중복 제거 및 라인 정보 저장

    for match in data["matches"]:
        got_text = match["gotText"]
        line = match["line"]

        # 중복된 gotText에 라인 번호 추가
        if got_text in unique_texts:
            unique_texts[got_text]["lines"].append(line)
        else:
            unique_texts[got_text] = {"lines": [line]}

    # 결과 정리
    result = {
        "filename": data["filename"],
        "matches": [
            {"gotText": text, "lines": info["lines"]}
            for text, info in unique_texts.items()
        ],
    }

    return result


def process_line(
    line: str,
    sheet_records: List[Dict],
    contain_check_func: Callable,
    prefix: str = "localization",
):
    """
    한 줄의 텍스트를 처리하여 변환.
    """
    # 조건에 맞지 않으면 그대로 반환
    if not contain_check_func(line):
        return line

    # 작은 따옴표, 큰 따옴표 안의 텍스트 추출
    matches = re.findall(r"['\"]([^'\"]*?[가-힣][^'\"]*?)['\"]", line)
    for match in matches:

        for sheet_record in sheet_records:
            if match == sheet_record.get("gotText"):

                variables = extract_variable(match)
                variable_names = [
                    extract_value_from_variables(string)[0] for string in variables
                ]

                # 리스트 뒤집기
                variable_names.reverse()  # <- 플러터 제너레이터로 만들어지는 메서드의 인자 순서에 맞추기

                if variable_names:
                    if len(variable_names) == 1:
                        replacement = (
                            f"{prefix}.{sheet_record.get('Key')}({variable_names[0]})"
                        )
                    else:
                        replacement = f"{prefix}.{sheet_record.get('Key')}(({', '.join([f'{var}' for var in variable_names])}))"
                else:
                    replacement = f"{prefix}.{sheet_record.get('Key')}"

                if "'" in line:
                    line = line.replace(f"'{match}'", replacement)
                else:
                    line = line.replace(f'"{match}"', replacement)
    return line


def map_string(
    file: str, output_file: str, sheet_records: List[Dict], contain_check_func: Callable
):
    results = []  # 최종 결과 저장

    with open(file, "r", encoding="utf-8") as doc:
        for line in doc:
            processed_line = process_line(
                line=line,
                sheet_records=sheet_records,
                contain_check_func=contain_check_func,
            )
            results.append(processed_line)

    print(output_file)
    # 결과 파일에 저장
    with open(output_file, "w", encoding="utf-8") as output:
        output.writelines(results)


if __name__ == "__main__":
    path_dir = "src/features"
    is_copy = True

    def contains_korean(string):
        """
        문자열에 한국어 포함되어 있는지 탐지.
        """
        search = re.search(r"[가-힣]", string)
        return bool(search)

    sheet_records = get_sheet_records()
    for folder, _, file_names in os.walk(path_dir):
        for file_name in file_names:
            if file_name.endswith(".dart"):
                file = os.path.join(folder, file_name).replace("\\", "/")

                if is_copy:
                    basename, extension = os.path.splitext(file_name)
                    output_name = f"{basename}_result{extension}"
                    output_file = os.path.join(folder, output_name)
                else:
                    output_file = copy.copy(file)

            map_string(
                file=file,
                output_file=output_file,
                sheet_records=sheet_records,
                contain_check_func=contains_korean,
            )
            quit()
