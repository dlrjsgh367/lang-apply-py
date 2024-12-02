import re


def map_to_string(file, sheet_records):

    with open(file, "r", encoding="utf-8") as doc:
        lines = doc.readlines()

    results = []
    for line in lines:
        result = process_line(line, file, sheet_records)
        results.append(result)
        # print(line)

    with open(file, "w", encoding="utf-8") as output:
        output.writelines(results)


def process_line(line, output, sheet_records, basename="localization.{}"):
    pattern_x = re.compile(r"['\"]([^'\"]*?[가-힣]+[^'\"]*?)['\"]")

    matches = pattern_x.findall(line)
    if not matches:
        return line
    for match in matches:
        for sheet_record in sheet_records:
            if match == sheet_record.get("ko"):
                key = sheet_record.get("key")
                replacement = basename.format(key)

                if "'" in line:
                    line = line.replace(f"'{match}'", replacement)
                elif '"' in line:
                    line = line.replace(f'"{match}"', replacement)
    return line
