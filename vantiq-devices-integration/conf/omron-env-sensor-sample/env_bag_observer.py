# -*- coding: utf-8 -*-
'''
For 2JCIE-BL01 (Bag type environmental sensor)
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
    characteristic = peripheral.readCharacteristic(0x0019)
    seq, temp, humid, light, uv, press, noise, discom, heatstr, batt = struct.unpack('<Bhhhhhhhhh', characteristic)
    data = {
            'env_sensor_id': ENV_SENSOR_ID,
            'temperature': temp / 100,  # 温度
            'humidity': humid / 100, # 湿度
            'light': light, # 照度
            'uv_index': uv / 100, # UV Index
            'pressure': press / 10, # 気圧
            'noise': noise / 100, # 騒音
            'discomfort_index': discom / 100, # 不快指数
            'heatstroke': heatstr / 100, # 熱中症危険度
            'batt': batt # 電池電圧
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
