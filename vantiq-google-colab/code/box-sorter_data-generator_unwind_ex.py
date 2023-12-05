import time
import json
import random
from datetime import datetime as dt
from paho.mqtt import client as mqtt_client

# MQTTブローカー設定
mqtt_config = {
    'broker': 'public.vantiq.com'
    , 'port': 1883
    , 'topic': '/workshop/jp/yourname/boxinfo'
    , 'client_id': f'python-mqtt-{random.randint(0, 100)}'
    , 'username': ''
    , 'password': ''
}

# 送信データ設定
publish_config = {
    'interval': (3, 5)
    , 'max_item': 10
    , 'message': [
        {
            "code": "14961234567890"
            , "name": "お茶 24本"
        }, {
            "code": "14961234567892"
            , "name": "化粧水 36本"
        }, {
            "code": "14961234567893"
            , "name": "ワイン 12本"
        }
    ]
}

# MQTT Publisher 本体
def connect_mqtt():
    def on_connect(client, userdata, flags, rc):
        if rc == 0:
            print("Connected to MQTT Broker!\n")
        else:
            print("Failed to connect, return code %d\n", rc)

    client = mqtt_client.Client(mqtt_config['client_id'])
    client.username_pw_set(mqtt_config['username'], mqtt_config['password'])
    client.on_connect = on_connect
    client.connect(mqtt_config['broker'], mqtt_config['port'])
    return client

def publish(client):
    msg_length = len(publish_config['message'])
    while True:
        random_wait_time = random.uniform(publish_config['interval'][0], publish_config['interval'][1])
        time.sleep(random_wait_time)
        publish_max_item = random.randint(1, publish_config['max_item'])
        msg = None
        if publish_max_item == 1:
            msg = publish_config['message'][random.randint(0, msg_length - 1)]
        else:
            msg = {'items': [publish_config['message'][random.randint(0, msg_length - 1)] for i in range(publish_max_item)]}
        msg['time'] = dt.now().strftime('%Y-%m-%d %H:%M:%S')
        result = client.publish(mqtt_config['topic'], json.dumps(msg, ensure_ascii=False, indent=4))
        status = result[0]
        if status == 0:
            print(f"Topic: {mqtt_config['topic']}")
            print(f"{msg}")
            print(f"Published Time: {msg['time']}")
            print()
        else:
            print(f"Failed to send message to topic {mqtt_config['topic']}")

def run():
    client = connect_mqtt()
    client.loop_start()
    publish(client)

if __name__ == '__main__':
    run()
