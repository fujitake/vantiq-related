import requests
import json
import random
import time
from typing import Final

# 設定情報
url = "https://dev.vantiq.com/api/v1/resources/services/com.example.BoxSorter/ReceiveBoxInfo"
accesstoken = "【Vantiqのアクセストークン】"

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

# アクセストークン
authorization = "Bearer" + " " + accesstoken

# HTTP POST
def data_post():
    headers = {
      'Content-Type': 'application/json',
      'Authorization': authorization
    }
    payload = json.dumps(dummy_data[random.randint(0, 2)])
    response = requests.request("POST", url, headers=headers, data=payload)
    print(response.text)

# 定期実行
while True:
    data_post()
    time.sleep(1)
