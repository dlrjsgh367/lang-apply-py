import os

from task_mapping import map_to_string


def pl(dir_path, mode=None):
    if mode == "c":
        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)

    elif mode == "m":
        for folder, _, file_names in os.walk(dir_path):
            for file_name in file_names:
                file_path = os.path.join(folder, file_name)
                map_to_string()
    else:
        quit()


if __name__ == "__main__":
    dir_path = r"C:\Users\HAMA\workspace\lang-apply-py\features"
    pl(dir_path, "m")
