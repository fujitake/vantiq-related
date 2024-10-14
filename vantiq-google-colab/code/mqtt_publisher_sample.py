import time
import json
import random
from datetime import datetime as dt
from paho.mqtt import client as mqtt_client

# MQTTブローカー設定
mqtt_config = {
    'broker': 'broker.hivemq.com'
    , 'port': 1883
    , 'topic': '/topic_name'
    , 'client_id': f'python-mqtt-{random.randint(0, 100)}'
    , 'username': ''
    , 'password': ''
}

# 送信データ設定
publish_config = {
    'interval': 2
    , 'message': [
        {
            'name': 'シナモン'
            , 'birthday': '3月6日'
        }
        , {
            'name': 'カプチーノ'
            , 'birthday': '6月27日'
        }
        , {
            'name': 'モカ'
            , 'birthday': '2月20日'
        }
        , {
            'name': 'シフォン'
            , 'birthday': '1月14日'
        }
        , {
            'name': 'エスプレッソ'
            , 'birthday': '12月4日'
        }
        , {
            'name': 'みるく'
            , 'birthday': '2月4日'
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
    client = mqtt_client.Client(client_id=mqtt_config['client_id'])
    client.username_pw_set(mqtt_config['username'], mqtt_config['password'])
    client.on_connect = on_connect
    client.connect(mqtt_config['broker'], mqtt_config['port'])
    return client

def publish(client):
    msg_length = len(publish_config['message'])
    while True:
        time.sleep(publish_config['interval'])
        msg = publish_config['message'][random.randint(0, msg_length - 1)]
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
