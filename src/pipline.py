import os

from task_collect import TextFinder
from task_mapping import map_to_string
from task_gspread import add_multiple_rows_to_sheet, sheet


def pl(dir_path, mode=None):
    sheet_records = sheet.get_all_records()
    if mode == "c":

        data_manual = []
        data_automatic = []

        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)

                # 파일 처리
                processor = TextFinder(file_path)
                processor.process_korean_lines()
                manual, automatic = processor.split_results()

                data_manual.extend(manual)
                data_automatic.extend(automatic)

        for rows in (data_automatic, data_manual):
            d = {row[3]: set() for row in rows}
            for row in rows:
                d[row[3]].add(row[4])

            # origin 목록의 내용을 |로 구분한다.
            for key in d:
                d[key] = "|".join(d[key])

            add_multiple_rows_to_sheet([["", "", "", k, v] for k, v in d.items()])

    elif mode == "m":
        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)
                map_to_string(file=file_path, sheet_records=sheet_records)

    else:
        quit()


if __name__ == "__main__":
    dir_path = r"C:\Users\HAMA\workspace\lang-apply-py\features\worker"
    pl(dir_path, "m")
