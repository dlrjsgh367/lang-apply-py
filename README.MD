해당 코드는 파이썬 3.10.x 로 작성되었습니다.
1. 라이브러리 설치
```
pip install -r requirements.txt
```
2. .env 파일 수정
```
CREDENTIALS_PATH: 서비스 계정 경로(json)
SPREADSHEET_URL: 스프레드시트 url
```
3. main.py 실행
- "collect" 인자: 폴더에 있는 문자열 수집 후, 스프레드시트에 적재합니다.
- "map": 스프레드시트에 있는 데이터를 .dart 파일에 매핑합니다.
