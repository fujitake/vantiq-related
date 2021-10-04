import ssl

import paho.mqtt.client as mqtt
import json
import time
import random
import datetime

### TODO Modify the configuration parameter
mqtt_url="<mqtt_host>.mq.ap-northeast-1.amazonaws.com"
user="<username>"
password="<password>"


sslcontext=ssl.create_default_context()


# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("$SYS/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic+" "+str(msg.payload))

# The callback for when a PUBLISH message is received from the server.
def on_publish(client, userdata, mid):
    print("mid = %s" % mid)

def on_disconnect(client, userdata, rc):
  if rc != 0:
     print("Unexpected disconnection.")


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


if __name__ == "__main__":


  client = mqtt.Client("PahoTest")
  client.on_connect = on_connect
  client.on_message = on_message
  client.on_disconnect = on_disconnect
  client.tls_set_context(context=sslcontext)

  client.username_pw_set(username=user, password=password)
  client.connect(mqtt_url, 8883, 60)

  client.loop_start()

  while True:
    '''
    TODO: Replace this block with the sensor readings
    '''
    ### block start --------------------------------
    msg=getJson(1, random.uniform(25, 35))
    client.publish("/sensor/temp", payload=msg)
    print("msg = %s " % msg)
    time.sleep(5)
