import os
import re
import copy

import pandas as pd

from func import Find, map_string
from sheet_task import add_multiple_rows_to_sheet, get_sheet_records


def run(path_dir, append=None):
    # if append:
    pass


# if __name__ == "__main__":

#     find = Find(path_dir=r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features")
#     # print(find.results)

#     columns = ["key", "descriptions", "en", "ko", "gotText", "filename", "lineNum"]
#     rows = []
#     for results in find.results:
#         filename = results["filename"]
#         for data in results["data"]:
#             key = ""
#             descriptions = ""
#             got_text = data.get("gotText")
#             en = copy.copy(got_text)
#             ko = copy.copy(got_text)
#             line_num = data.get("lineNum")

#             row = [key, descriptions, en, ko, got_text, filename, line_num]
#             rows.append(row)

#     df = pd.DataFrame(columns=columns, data=rows)
#     # .to_csv(
#     #     "C:\\Users\\HAMA\\workspace\\tmp\\lang-apply-py\\src\\exam_01.csv", index=False
#     # )

#     ignore_keywords = ["$", "{", "}", "(" ")"]
#     df_automatic = df[
#         ~df["gotText"].str.contains(
#             "|".join(map(re.escape, ignore_keywords)), regex=True
#         )
#     ]
#     # print(df_automatic.shape)
#     # df_automatic_unique = df_automatic.drop_duplicates(subset="gotText", keep="first")
#     # print(df_automatic_unique.shape)
#     # rows = df_automatic_unique.values.tolist()

#     df_manual = df[
#         df["gotText"].str.contains(
#             "|".join(map(re.escape, ignore_keywords)), regex=True
#         )
#     ]
#     df_manual.reset_index()
#     df_manual.to_excel("exam_01.xlsx")
#     print(df_manual.shape)
#     # df_manual_unique = df_manual.drop_duplicates(subset="gotText", keep="first")
#     df_manual_unique = df_manual
#     print(df_manual_unique.shape)
#     # rows = df_manual_unique.values.tolist()
#     # add_multiple_rows_to_sheet(rows)

if __name__ == "__main__":
    path_dir = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib\features"
    is_copy = False

    def contains_korean(string):
        """
        문자열에 한국어 포함되어 있는지 탐지.
        """
        search = re.search(r"[가-힣]", string)
        return bool(search)

    sheet_records = get_sheet_records()

    for folder, _, file_names in os.walk(path_dir):
        for file_name in file_names:
            if file_name.endswith(".dart"):
                file = os.path.join(folder, file_name).replace("\\", "/")

                if is_copy:
                    basename, extension = os.path.splitext(file_name)
                    output_name = f"{basename}_result{extension}"
                    output_file = os.path.join(folder, output_name)
                else:
                    output_file = copy.copy(file)

            map_string(
                file=file,
                output_file=output_file,
                sheet_records=sheet_records,
                contain_check_func=contains_korean,
            )
