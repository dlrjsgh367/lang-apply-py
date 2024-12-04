import os

from task_collect import TextFinder
from task_mapping import map_to_string
from gspread_task import add_multiple_rows_to_sheet, sheet

index = -1


def get_index():
    global index
    index += 1
    return "i" + str(index)


def pl(dir_path, mode=None):
    global index
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

        index = 0
        for rows in (data_automatic, data_manual):
            d = {row[3]: set() for row in rows}
            for row in rows:
                d[row[3]].add(row[4])

            # origin 목록의 내용을 |로 구분한다.
            for key in d:
                d[key] = "|".join(d[key])

            rows = [[get_index(), "", "", k, v] for k, v in d.items()]
            add_multiple_rows_to_sheet(rows)

    elif mode == "m":
        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)
                map_to_string(file=file_path, sheet_records=sheet_records)

    else:
        quit()


if __name__ == "__main__":
    # dir_path = r"C:\Users\HAMA\workspace\lang-apply-py\src\features"
    dir_path = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib"
    pl(dir_path, "m")
