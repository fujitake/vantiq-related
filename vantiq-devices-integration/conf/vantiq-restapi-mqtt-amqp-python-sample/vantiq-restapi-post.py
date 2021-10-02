import random

import requests
import datetime
import json
import time

### TODO Modify the configuration parameter
vantiq_rest_uri = "https://<vantiq_server_host>/api/v1/resources"
access_token = "<access token>"
topic_name = "/topics//python/rest/1"  # change the topic name as appropriate

def getJson(id, temp):
    '''
       utility function to generate the payload for sending data.
    '''
    message = {
        "id": id,
        "temp": temp,
        "timestamp": datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    }

    return json.dumps(message)

def getHeader():
    headers = {
        'content-type': 'application/json',
        'Authorization' : "Bearer " + access_token
    }
    return headers

if __name__ == "__main__":

    while True:
        '''
        TODO: Replace this block with the sensor readings
        '''
        ### block start --------------------------------
        res = requests.post(url=vantiq_rest_uri + topic_name, \
            headers=getHeader(), data=getJson(1, random.uniform(25, 35)))
        print(res.text)
        time.sleep(1)
        ### block end --------------------------------
