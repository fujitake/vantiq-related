import requests
import json
import random
import time
from typing import Final

# Configuration section
url = "https://dev.vantiq.com/api/v1/resources/services/com.example.BoxSorter/ReceiveBoxInfo"
accesstoken = "[Your Vantiq Access Token]"

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

# Access token
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

# Periodic execution
while True:
    data_post()
    time.sleep(1)
