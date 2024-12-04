from typing import List


def read_file(file: str) -> List:
    with open(file, "r", encoding="utf-8") as f:
        lines = f.readlines()
    return lines


def save_file(file: str, lines: List) -> None:
    with open(file, "w", encoding="utf-8") as f:
        f.writelines(lines)
