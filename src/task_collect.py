import os
import re
from typing import List, Tuple

import numpy as np
import pandas as pd

from task_gspread import add_multiple_rows_to_sheet, sheet


def read_doc(file_path: str) -> List[str]:
    """파일에서 라인을 읽어 리스트로 반환"""
    with open(file_path, "r", encoding="utf-8") as doc:
        return doc.readlines()


class TextFinder:
    pattern_x = re.compile(r"['\"]([^'\"]*[가-힣]+[^'\"]*)['\"]")

    pattern_y = re.compile(r"[A-Za-z0-9가-힣~!@#$%^&*()_+\-={}\[\]:\";'<>?,./\\\\]+")

    # 정규식 패턴 리스트
    exclude_patterns = [
        "\\$",
        "\\{",
        # '\\" +', '\\+ "', '\\"+', '\\+"'
    ]
    # OR 연산자로 결합된 정규식 생성
    exclude_pattern_regex = "|".join(exclude_patterns)

    def __init__(self, file_path: str):
        self.file_path = file_path
        self.extracted_results = []

    def process_korean_lines(self) -> None:
        """파일에서 한글이 포함된 라인을 추출"""
        lines = read_doc(self.file_path)
        for line in lines:
            # 주석 아닌 것만
            if re.match(r"[^//]", line.strip()):
                matches = self.pattern_x.findall(line)
                if matches:
                    phrases = [
                        " ".join(self.pattern_y.findall(match)) for match in matches
                    ]
                    for phrase in phrases:
                        self.extracted_results.append(
                            {
                                "original_line": line.strip(),
                                "korean_phrases": phrase.strip(),
                            }
                        )

    def split_results(
        self,
    ) -> Tuple[List, List]:
        """추출된 결과를 수동 및 자동 처리 리스트로 분리"""
        # 데이터프레임 초기화
        df_columns = ["Key", "Description", "en", "ko", "origin"]
        results_df = pd.DataFrame(columns=df_columns)

        # 데이터프레임 값 할당
        results_df["ko"] = [x["korean_phrases"] for x in self.extracted_results]
        results_df["origin"] = [x["original_line"] for x in self.extracted_results]

        results_df["ko"] = results_df["ko"].fillna("").astype(str)
        results_df["origin"] = results_df["origin"].fillna("").astype(str)

        # nan -> None 변환
        results_df = results_df.replace({np.nan: None})
        # results_df.to_csv(f"exam_{idx}.csv")

        # 수동 및 자동 처리 구분
        manual_entries_df = results_df[
            results_df["origin"].str.contains(self.exclude_pattern_regex, regex=True)
            & results_df["ko"].str.contains(self.exclude_pattern_regex, regex=True)
        ]
        automatic_entries_df = results_df[
            ~results_df["origin"].str.contains(self.exclude_pattern_regex, regex=True)
            & ~results_df["ko"].str.contains(self.exclude_pattern_regex, regex=True)
        ]
        # 리스트로 변환
        return manual_entries_df.values.tolist(), automatic_entries_df.values.tolist()


class KoreanTextPipeline:
    def __init__(self, directory: str):
        self.directory = directory

        self.data_manual = []
        self.data_automatic = []
        self.sheet_records = sheet.get_all_records()

    def process_files(self):
        """디렉토리의 모든 파일을 처리"""
        for folder, _, files in os.walk(self.directory):
            for file in files:
                file_path = os.path.join(folder, file)

                # 파일 처리
                processor = TextFinder(file_path)
                processor.process_korean_lines()
                manual, automatic = processor.split_results()

                self.data_manual.extend(manual)
                self.data_automatic.extend(automatic)

    def remove_duplicated(self):
        for rows in (pipeline.data_automatic, pipeline.data_manual):

            d = {row[3]: set() for row in rows}
            for row in rows:
                d[row[3]].add(row[4])

            # origin 목록의 내용을 |로 구분한다.
            for key in d:
                d[key] = "|".join(d[key])

            add_multiple_rows_to_sheet([["", "", "", k, v] for k, v in d.items()])


if __name__ == "__main__":
    path_dir = r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features"

    pipeline = KoreanTextPipeline(path_dir)
    pipeline.process_files()
