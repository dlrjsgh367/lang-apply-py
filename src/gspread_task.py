import os
import gspread
from google.oauth2.service_account import Credentials

# 인증 스코프 설정
SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

# 서비스 계정 JSON 파일 경로
CREDENTIALS_PATH = os.getenv("CREDENTIALS_PATH")

# 인증 정보 생성
credentials = Credentials.from_service_account_file(
    filename=CREDENTIALS_PATH,
    scopes=SCOPES,
)

# gspread 클라이언트 생성
client = gspread.authorize(credentials)

# 스프레드시트 URL 및 시트 설정
SPREADSHEET_URL = os.getenv("SPREADSHEET_URL")

# 스프레드시트 및 시트 열기
spreadsheet = client.open_by_url(SPREADSHEET_URL)

sheet_manual = spreadsheet.worksheet("manual")
sheet_automatic = spreadsheet.worksheet("automatic")


def add_multiple_rows_to_sheet(sheet_name: str, rows: list):
    """
    시트에 여러 행을 추가합니다. 이미 존재하는 값은 무시됩니다.

    Args:
        rows (list): 추가할 데이터 목록 (2D 리스트 형태).
    """
    if sheet_name == "manual":
        sheet = sheet_manual
    elif sheet_name == "automatic":
        sheet = sheet_automatic
    else:
        ValueError("sheet_name 의 값이 올바르지 않습니다.")

    existing_texts = set(sheet.col_values(4))  # 5번 열 데이터 가져오기

    # 중복되지 않은 데이터 필터링
    new_rows = [row for row in rows if row[3] not in existing_texts]

    if not new_rows:
        print("추가할 새로운 데이터가 없습니다.")
        return

    # 새로운 행 추가 (시트의 마지막에 삽입)
    sheet.insert_rows(new_rows, row=len(sheet.get_all_values()) + 1)
    print(f"{len(new_rows)}개의 새로운 행이 추가되었습니다.")


if __name__ == "__main__":
    sample_data = [
        ["data1", "value1", "value2", "value3", "gotText1"],
        ["data2", "value1", "value2", "value3", "gotText2"],
    ]
    add_multiple_rows_to_sheet(sample_data)
