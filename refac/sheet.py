import os

import gspread
from google.oauth2.service_account import Credentials


# 인증 스코프
scope = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive",
]

# 서비스 계정 JSON 파일 경로
credentials = Credentials.from_service_account_file(
    # filename=os.getenv("PATH_SERVICE_ACCOUNT_FILE"),
    filename=r"C:\Users\HAMA\workspace\tmp\lang-apply-py\auth\spreadsheets-insert-py-443103-fc89aedbd8b9.json",
    scopes=scope,
)

# gspread 클라이언트 인증
client = gspread.authorize(credentials)

# 스프레드시트 열기
spreadsheet_url = "https://docs.google.com/spreadsheets/d/1ZybrYhGOaH4OgzVJ1PDCJ3CIfkXpSYlkOnmH05SjKak/edit?usp=sharing"
spreadsheet = client.open_by_url(spreadsheet_url)

# 특정 시트 선택
sheet = spreadsheet.worksheet("시트1")


def get_sheet_records():
    return sheet.get_all_records()


def add_multiple_rows_to_sheet(rows: list):
    """
    여러 행을 한 번에 추가.
    중복된 데이터는 무시.
    Args:
        rows (list): 추가할 데이터 목록 (2D 리스트 형태).
    """
    # 현재 시트의 gotText 열 값 가져오기
    existing_texts = set(sheet.col_values(5))  # 5번 열 (gotText) 데이터

    # 중복되지 않은 데이터 필터링
    new_rows = [row for row in rows if row[4] not in existing_texts]

    if not new_rows:
        print("추가할 새로운 데이터가 없습니다.")
        return

    # 여러 행 추가
    sheet.insert_rows(new_rows, row=len(sheet.get_all_values()) + 1)  # 마지막에 삽입
    print(f"{len(new_rows)}개의 새로운 행이 추가되었습니다.")
