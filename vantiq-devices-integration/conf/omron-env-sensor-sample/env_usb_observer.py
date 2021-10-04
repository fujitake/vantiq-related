# -*- coding: utf-8 -*-
'''
For 2JCIE-BU01 (USB type environmental sensor)
'''

from bluepy import btle
import struct
import requests
import json
import time
import datetime

# Vantiq
VANTIQ_ENDPOINT = 'your vantiq endpoint'
VANTIQ_ACCESS_TOKEN = 'your token'

# Env sensor
ENV_SENSOR_MAC_ADDRESS = 'your env sensor mac address'
ENV_SENSOR_ID = 'env_sensor1'
PUBLISH_INTERVAL_SEC = 60

def publish_event(data):
    headers = {
        'Authorization': 'Bearer ' + VANTIQ_ACCESS_TOKEN,
        'content-type': 'application/json'        
    }
    response = requests.post(VANTIQ_ENDPOINT, headers=headers, data=json.dumps(data))
    print('Published Event: ' + datetime.datetime.fromtimestamp(time.time()).strftime('%Y/%m/%d %H:%M:%S'))

def get_env_sensor_data():
    peripheral = btle.Peripheral(ENV_SENSOR_MAC_ADDRESS, addrType=btle.ADDR_TYPE_RANDOM)
    characteristic = peripheral.readCharacteristic(0x0059)
    seq, temp, humid, light, press, noise, etvoc, eco2 = struct.unpack('<Bhhhlhhh', characteristic)
    data = {
            'env_sensor_id': ENV_SENSOR_ID,
            'temperature': temp / 100, # 温度
            'humidity': humid / 100, # 湿度
            'light': light, # 照度
            'pressure': press / 1000, # 気圧
            'noise': noise / 100, # 騒音
            'etvoc': etvoc, # 総揮発性有機化合物濃度
            'eco2': eco2 # 二酸化炭素濃度
        }
    return data


def main():
    while True:    
        try:
            data = get_env_sensor_data()
            publish_event(data)
            print(data)
        except KeyboardInterrupt:
            break
        except btle.BTLEDisconnectError:
            print('Disconnected: ' + datetime.datetime.fromtimestamp(time.time()).strftime('%Y/%m/%d %H:%M:%S'))
        time.sleep(PUBLISH_INTERVAL_SEC)

if __name__ == '__main__':
    main()