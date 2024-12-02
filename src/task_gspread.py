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
    filename=r"auth/spreadsheets-insert-py-443103-5e33c277f11a.json",
    scopes=scope,
)

# gspread 클라이언트 인증
client = gspread.authorize(credentials)

# 스프레드시트 열기
spreadsheet_url = "https://docs.google.com/spreadsheets/d/1ZybrYhGOaH4OgzVJ1PDCJ3CIfkXpSYlkOnmH05SjKak/edit?usp=sharing"
spreadsheet = client.open_by_url(spreadsheet_url)

# 특정 시트 선택
sheet = spreadsheet.worksheet("시트1")
