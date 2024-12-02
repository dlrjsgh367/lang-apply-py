import os
import re
from typing import List, Tuple

import numpy as np
import pandas as pd

from task_sheet import add_multiple_rows_to_sheet

# 따옴표 안의 내용을 매칭하는 패턴 (한글이 포함된 경우만)
quoted_text_with_korean_pattern = re.compile(r"['\"]([^'\"]*?[가-힣]+[^'\"]*?)['\"]")

# 한글, 영어, 숫자, 특수문자를 포함한 패턴
korean_characters_pattern = re.compile(
    r"[A-Za-z0-9가-힣~!@#$%^&*()_+\-={}\[\]:\";'<>?,./]+"
)

 
def read_doc(file_path):
    with open(file_path, "r", encoding="utf-8") as doc:
        doc = doc.readlines()
    return doc


def process_korean_lines(file_path: str) -> list:
    extracted_results = []  # 결과를 저장하는 리스트

    lines = read_doc(file_path)  # 파일에서 읽은 모든 줄
    for line in lines:
        korean_matches = quoted_text_with_korean_pattern.findall(
            line
        )  # 한글이 포함된 내용 추출

        if korean_matches:
            extracted_korean_phrases = [
                " ".join(korean_characters_pattern.findall(match))
                for match in korean_matches
            ]  # 추출된 내용에서 한글만 필터링

            for korean_phrase in extracted_korean_phrases:
                extracted_results.append(
                    {
                        "original_line": line.replace("\n", ""),
                        "korean_phrases": korean_phrase.replace("\n", ""),
                    }
                )

    return extracted_results


def split_extracted_results(parsed_data) -> Tuple[List]:
    # Default dataframe structure
    df_columns = ["Key", "Description", "en", "ko", "origin"]
    results_df = pd.DataFrame(columns=df_columns)

    # Assign values
    results_df["ko"] = [x["korean_phrases"] for x in parsed_data]
    results_df["origin"] = [x["original_line"] for x in parsed_data]

    #
    results_df["origin"] = results_df["origin"].fillna("").astype(str)
    results_df = results_df.replace({np.nan: ""})

    # Patterns to exclude
    exclude_patterns = [r"\$\{", r"\{"]  # `${` or `{` pattern
    exclude_pattern_regex = "|".join(exclude_patterns)  # Join patterns with OR

    # Split into manual and automatic dataframes
    manual_entries_df = results_df[
        results_df["origin"].str.contains(exclude_pattern_regex, regex=True)
    ]
    automatic_entries_df = results_df[
        ~results_df["origin"].str.contains(exclude_pattern_regex, regex=True)
    ]

    # Convert to lists
    manual_entries_list = manual_entries_df.values.tolist()
    automatic_entries_list = automatic_entries_df.values.tolist()

    return manual_entries_list, automatic_entries_list


if __name__ == "__main__":
    path_dir = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage\screens"

    data_manual = []
    data_automatic = []
    for folder, _, name_files in os.walk(path_dir):
        for name_file in name_files:
            path_file = os.path.join(folder, name_file)

            extracted_results = process_korean_lines(path_file)

            manual_entries_list, automatic_entries_list = split_extracted_results(
                extracted_results
            )

            data_manual.append(manual_entries_list)
            data_automatic.append(automatic_entries_list)

    import itertools

    add_multiple_rows_to_sheet(itertools.chain(*data_automatic))
    add_multiple_rows_to_sheet(itertools.chain(*data_manual))
