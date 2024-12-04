import os

from text_editor import TextEditor

from gspread_task import sheet_automatic, add_multiple_rows_to_sheet


def main(target_dir, mode=None):

    if mode == "collect":
        results_manual = []
        results_automatic = []
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)

                worker = TextEditor(file=file)
                worker.collect_data()
                worker.split_collected_data()

                data_manual = worker.series_manual.tolist()
                data_automatic = worker.series_automatic.tolist()

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

        add_multiple_rows_to_sheet(sheet_name="manual", rows=results_manual)
        add_multiple_rows_to_sheet(sheet_name="automatic", rows=results_automatic)

    elif mode == "map":
        file_count = 0

        automatic_records = sheet_automatic.get_all_records()
        for folder, _, filenames in os.walk(target_dir):
            for filename in filenames:

                # 파일 경로
                file = os.path.join(folder, filename)

                worker = TextEditor(file=file)
                worker.map_data(sheet_records=automatic_records, prefix="localization")

                file_count += 1

        print(file_count, "개의 파일을 처리했습니다.")

    else:
        raise ValueError("mode 인자 값이 올바르지 않습니다.")


if __name__ == "__main__":
    target_dir = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib"
    # C:\Users\HAMA\workspace\chodan-flutter-app\lib\enum\premium_service_enum.dart
    # C:\Users\HAMA\workspace\chodan-flutter-app\lib\features\chat\widgets\dialog\attendance_select_dialog_widget.dart
    # target_dir = r"C:\Users\HAMA\workspace\chodan-flutter-app\lib\features\auth\service"
    main(target_dir=target_dir, mode="map")
