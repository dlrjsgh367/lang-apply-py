import re
from util import read_file


class TextCollector:

    non_comment_pattern = re.compile(r"^(?!\/\/).*")
    inside_quotes_pattern = re.compile(r'(["\'])(.*?)\1')
    korean_only_pattern = re.compile(r"[가-힣]")

    def __init__(self, file: str):
        self.__file = file
        self.__results = []

    @property
    def file(self):
        return self.__file

    @property
    def results(self):
        return self.__results

    def run(self):

        lines = read_file(self.__file)
        for line in lines:

            stripped_line = line.strip()
            if not self.non_comment_pattern.match(stripped_line):
                continue

            matches = self.inside_quotes_pattern.findall(line)
            if not matches:
                continue

            extracted_texts = [match[1] for match in matches]

            korean_texts = [
                text
                for text in extracted_texts
                # if self.korean_only_pattern.search(text)
            ]

            self.__results.extend(korean_texts)


if __name__ == "__main__":
    file = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib\features\mypage\screens\my_consult_create_screen.dart"
    tc = TextCollector(file=file)

    tc.run()

    print(tc.results)
