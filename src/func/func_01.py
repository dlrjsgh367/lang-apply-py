import os
import re

import pandas as pd


class Find:
    pattern = r"['\"]([^'\"]*[가-힣][^'\"]*)['\"]"

    def __init__(self, path_dir):
        self.paths_file = []
        for folder, _, file_names in os.walk(path_dir):
            for file_name in file_names:
                path_file = os.path.join(folder, file_name)
                self.paths_file.append(path_file)

        self.__results: list[dict] = []

        for path_file in self.paths_file:
            self.extract_korean_text_from_document(path_file)

    @property
    def results(self):
        return self.__results

    def extract_korean_text_from_document(self, path_file):
        result = {"filename": os.path.basename(path_file), "data": []}

        doc = self.read_document(path_file)
        for line_num, line_text in enumerate(doc, start=1):

            if self.contains_korean(line_text):

                # // 로 시작하는 문자열 제외
                if line_text.strip()[:2] == "//":
                    continue

                matches = re.findall(self.pattern, line_text)
                if not matches:
                    continue

                for match in matches:
                    row = {"lineNum": line_num, "gotText": match}
                    # result["data"].append(row)

                row = {"lineNum": line_num, "gotText": matches[0]}
                if len(matches) > 1:
                    # 일부로 $ 로 join 하기
                    row = {"lineNum": line_num, "gotText": "$".join(matches)}
                    # row = {"lineNum": line_num, "gotText": line_text}

                result["data"].append(row)

        self.__results.append(result)

    def contains_korean(self, string):
        """
        문자열에 한국어 포함되어 있는지 탐지.
        """
        search = re.search(r"[가-힣]", string)
        return bool(search)

    def read_document(self, path_file):
        with open(path_file, "r", encoding="utf-8") as doc:
            return doc.readlines()


if __name__ == "__main__":
    find = Find("src/features")

    columns = ["gotText", "filename", "lineNum"]
    rows = []
    for results in find.results:
        filename = results["filename"]
        for data in results["data"]:
            line_num = data.get("lineNum")
            got_text = data.get("gotText")

            row = [got_text, filename, line_num]
            rows.append(row)

    df = pd.DataFrame(columns=columns, data=rows).to_csv(
        "C:\\Users\\HAMA\\workspace\\tmp\\lang-apply-py\\src\\exam_01.csv", index=False
    )

    ignore_keywords = ["$", "{", "}", "(" ")"]
    filtered = df[
        ~df["gotText"].str.contains(
            "|".join(map(re.escape, ignore_keywords)), regex=True
        )
    ]
