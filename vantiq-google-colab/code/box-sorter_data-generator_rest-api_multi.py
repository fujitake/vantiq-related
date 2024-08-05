import requests
import json
import random
import time
from typing import Final

# 設定情報
url = "https://dev.vantiq.com/api/v1/resources/services/com.example.BoxSorter/ReceiveBoxInfo"
endpoints = [
    {'url': url, 'token': ''}
    , {'url': url, 'token': ''}
]

# ダミーデータ
dummy_data = [
    {
        "code": "14961234567890",
        "name": "お茶 24本"
    }, {
        "code": "14961234567892",
        "name": "化粧水 36本"
    }, {
        "code": "14961234567893",
        "name": "ワイン 12本"
    }
]

# HTTP POST
def data_post():
    for endpoint in endpoints:
        headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + endpoint['token']
        }
        payload = json.dumps(dummy_data[random.randint(0, 2)])
        response = requests.request("POST", endpoint['url'], headers=headers, data=payload)
        print(response.text)
        time.sleep(0.1)

# 定期実行
while True:
    data_post()
    time.sleep(1)
