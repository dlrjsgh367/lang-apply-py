import os

from task_mapping import map_to_string
from task_gspread import sheet


def pl(dir_path, mode=None):
    if mode == "c":
        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)

    elif mode == "m":
        sheet_records = sheet.get_all_records()

        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)
                map_to_string(file=file_path, sheet_records=sheet_records)
                # print(file_path, sheet_records)

    else:
        quit()


if __name__ == "__main__":
    dir_path = r"C:\Users\HAMA\workspace\lang-apply-py\features\worker"
    pl(dir_path, "m")
