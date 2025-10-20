import requests
import json
import random
import time
from typing import Final

# Configuration section
url = "https://dev.vantiq.com/api/v1/resources/services/com.example.BoxSorter/ReceiveBoxInfo"
endpoints = [
    {'url': url, 'token': ''}
    , {'url': url, 'token': ''}
]

# Dummy data
dummy_data = [
    {
        "code": "14961234567890",
        "name": "Green Tea, 24 bottles"
    }, {
        "code": "14961234567892",
        "name": "Skincare Lotion, 36 bottles"
    }, {
        "code": "14961234567893",
        "name": "Wine, 12 bottles"
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

# Periodic execution
while True:
    data_post()
    time.sleep(1)
