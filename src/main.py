import os
import itertools
from task_gspread import add_multiple_rows_to_sheet
from text_collector import TextCollector


def main(target_dir, mode=None):

    # collect
    if mode == "c":
        results = []
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)
                text_collector = TextCollector(file=file)
                text_collector.run()
                texts = text_collector.results
                results.append(texts)

        # 2차원 리스트 -> 1차원 리스트
        results = list(itertools.chain(*results))
        results = set(results)
        results = [[result] for result in results]
        add_multiple_rows_to_sheet(results)

    # mapping
    elif mode == "m":
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)
    else:
        raise ValueError("mode 인자 값이 올바르지 않습니다.")


if __name__ == "__main__":
    target_dir = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib"
    main(target_dir=target_dir, mode="c")
