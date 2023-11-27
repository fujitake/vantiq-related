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

# MQTT Subscriber 本体
def connect_mqtt() -> mqtt_client:
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

def subscribe(client: mqtt_client):
    def on_message(client, userdata, msg):
        print(f"Topic: {msg.topic}")
        print(f"{msg.payload.decode()}")
        print(f"Subscribed Time: {dt.now()}")
        print()
    client.subscribe(mqtt_config['topic'])
    client.on_message = on_message

def run():
    client = connect_mqtt()
    subscribe(client)
    client.loop_forever()

if __name__ == '__main__':
    run()
