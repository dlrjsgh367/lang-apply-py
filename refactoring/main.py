import os
import itertools

from tmp import extract_text_from_file


def run(root_dir):
    got_text_list = []
    for folder, _, file_names in os.walk(root_dir):
        for file_name in file_names:

            file_path = os.path.join(folder, file_name)

            y = extract_text_from_file(file_path)
            # if y:
            #     for a in y:
            #         print(file_name, a)
            got_text_list.append(y)
    for x in set(list(itertools.chain(*got_text_list))):
        print(x)


if __name__ == "__main__":
    run(r"C:\Users\HAMA\workspace\tmp\lang-apply-py\src\features\mypage")

