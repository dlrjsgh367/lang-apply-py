from typing import List
import re
import pandas as pd
from util import read_file, save_file


class TextEditor:
    # 정규식 패턴 정의
    non_comment_pattern = re.compile(r"^(?!\/\/).*")  # 주석이 아닌 줄만 매칭
    inside_quotes_pattern = re.compile(r'(["\'])(.*?)\1')  # 따옴표 안 텍스트 추출
    korean_only_pattern = re.compile(r"[가-힣]")  # 한글만 매칭
    variable_pattern = re.compile(r"\$\{?")  # $ 또는 ${
    plus_wrapped_pattern = re.compile(r"\+(.*?)\+")  # +로 양쪽이 감싸진 텍스트를 탐지

    def __init__(self, file: str):
        self.__file = file
        self.__list: List[str] = []  # 수집된 텍스트 리스트
        self.__series = pd.Series(dtype="object")  # 전체 Series
        self.__series_manual = pd.Series(dtype="object")  # 수동 매칭 데이터
        self.__series_automatic = pd.Series(dtype="object")  # 자동 매칭 데이터

    @property
    def list(self) -> List[str]:
        return self.__list

    @property
    def series_manual(self) -> pd.Series:
        return self.__series_manual

    @property
    def series_automatic(self) -> pd.Series:
        return self.__series_automatic

    def collect_data(self) -> None:
        """파일에서 텍스트 데이터를 수집하고 필터링"""
        try:
            lines = read_file(self.__file)
        except Exception as e:
            raise FileNotFoundError(f"파일을 읽는 데 실패했습니다: {e}")

        for line in lines:
            stripped_line = line.strip()

            match_non_comment = self.non_comment_pattern.match(stripped_line)
            match_variable = self.variable_pattern.search(stripped_line)
            match_only_korean = self.korean_only_pattern.search(stripped_line)
            match_plus_wrapped = self.plus_wrapped_pattern.search(stripped_line)

            # 주석
            if not match_non_comment:
                continue

            if (
                match_variable  # $ 또는 ${
                and match_only_korean  # 한국어
                or (match_only_korean and match_plus_wrapped)  # 한국어, + 로 감싼
            ):
                self.__list.append(stripped_line)
                continue

            # 따옴표 내부의 텍스트 추출
            matches = self.inside_quotes_pattern.findall(line)
            if matches:
                # 한글이 포함된 텍스트만 추가
                korean_texts = [
                    text for _, text in matches if self.korean_only_pattern.search(text)
                ]
                self.__list.extend(korean_texts)

    def map_data(self, sheet_records: dict, prefix: str = "localization") -> None:
        """파일에서 텍스트 데이터를 수집하고 필터링"""
        try:
            lines = read_file(self.__file)
        except Exception as e:
            raise FileNotFoundError(f"파일을 읽는 데 실패했습니다: {e}")

        for line in lines:
            stripped_line = line.strip()

            match_non_comment = self.non_comment_pattern.match(stripped_line)
            match_variable = self.variable_pattern.search(stripped_line)
            match_only_korean = self.korean_only_pattern.search(stripped_line)
            match_plus_wrapped = self.plus_wrapped_pattern.search(stripped_line)

            # //로 시작하는 line
            if not match_non_comment:
                self.__list.append(line)
                continue
            # 한국어가 포함되지 않은 line
            elif not match_only_korean:
                self.__list.append(line)
                continue
            # 문자열에 변수가 존재하는 line
            elif match_variable:
                self.__list.append(line)
                continue
            # +로 감싸있는 텍스트가 존재하는 line
            elif match_plus_wrapped:
                self.__list.append(line)
                continue

            # 따옴표 내부의 텍스트 추출
            matches = self.inside_quotes_pattern.findall(line)
            if matches:
                # 한글이 포함된 텍스트만 추가
                korean_texts = [
                    text for _, text in matches if self.korean_only_pattern.search(text)
                ]
                for korean_text in korean_texts:
                    for sheet_record in sheet_records:
                        key = sheet_record.get("key")
                        ko = sheet_record.get("ko")

                        if korean_text == ko:
                            replacement = f"{prefix}.{key}"

                            if "'" in line:
                                line = line.replace(f"'{korean_text}'", replacement)
                            elif '"' in line:
                                line = line.replace(f'"{korean_text}"', replacement)

                            self.__list.append(line)
                            break
            else:
                self.__list.append(line)

        try:
            lines = save_file(self.__file, self.__list)
        except Exception as e:
            raise FileNotFoundError(f"파일을 저장하는 데 실패했습니다: {e}")

    def split_collected_data(self) -> None:
        """수집된 데이터를 $ 또는 ${ 포함 여부로 분리"""
        self.__series = pd.Series(self.__list, dtype="object")

        self.__series_manual = self.__series[
            self.__series.str.contains(r"\$\{?|\+(?:.*?)\+", regex=True, na=False)
        ]

        # 나머지 데이터
        self.__series_automatic = self.__series[
            ~self.__series.str.contains(r"\$\{?|\+(?:.*?)\+", regex=True, na=False)
        ]


if __name__ == "__main__":
    # 실제 파일 경로에 맞게 변경
    file = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib\features\mypage\screens\my_consult_create_screen.dart"
    tc = TextEditor(file=file)

    # 데이터 수집 및 출력
    tc.collect_data()
    print("Collected Data:")
    print(tc.list)

    # 데이터 분리 및 출력
    tc.split_collected_data()
    print("\nManual Series:")
    print(tc.series_manual)
    print("\nAutomatic Series:")
    print(tc.series_automatic)
