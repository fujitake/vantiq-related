import requests
import json
import random
import time
from typing import Final
import schedule

# 設定情報
url = "https://【VantiqのURL(FQDN)】/api/v1/resources/topics/【Topic名】"
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
schedule.every(2).seconds.do(data_post)
while True:
    schedule.run_pending()
    time.sleep(1)
