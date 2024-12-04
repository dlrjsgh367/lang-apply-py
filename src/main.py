import os
import itertools

from text_collector import TextCollector
from text_mapper import map_to_string
from gspread_task import sheet, add_multiple_rows_to_sheet


def main(target_dir, mode=None):

    if mode == "collect":
        results_manual = []
        results_automatic = []
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)

                text_collector = TextCollector(file=file)
                text_collector.collect_data()
                text_collector.split_collected_data()

                data_manual = text_collector.series_manual.tolist()
                data_automatic = text_collector.series_automatic.tolist()

                results_manual.extend(data_manual)
                results_automatic.extend(data_automatic)

        results_manual = set(results_manual)
        results_automatic = set(results_automatic)

        results_manual = [
            [f"manual{index}", "", "", result]
            for index, result in enumerate(results_manual)
        ]
        results_automatic = [
            [f"automatic{index}", "", "", result]
            for index, result in enumerate(results_automatic)
        ]

        add_multiple_rows_to_sheet(results_automatic)
        add_multiple_rows_to_sheet(results_manual)

    elif mode == "map":
        sheet_records = sheet.get_all_records()
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)

                map_to_string(file=file, sheet_records=sheet_records)

    else:
        raise ValueError("mode 인자 값이 올바르지 않습니다.")


if __name__ == "__main__":
    target_dir = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib"
    main(target_dir=target_dir, mode="map")
