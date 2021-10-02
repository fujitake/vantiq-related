import random

import websocket
import json
import datetime

try:
    import thread
except ImportError:
    import _thread as thread
import time

### TODO Modify the configuration parameter
vantiq_websocket_uri = "wss://<vantiq_server_host>/api/v1/wsock/websocket"
access_token = "<access token>"
topic_name = "/python/websocket/1"  # change the topic name as appropriate


'''
   message used for authentication.
'''
authenticate = {
    "op": "validate",
    "resourceName": "system.credentials",
    "object": access_token,  # access token
    "parameters": {"requestId": "validateFromClient"}
}


def getJson(id, temp):
    '''
       utility function to generate the payload for sending data.
    '''
    message = {
        "id": id,
        "temp": temp,
        "timestamp": datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    }

    send_message_template = {
        "op": "publish",
        "resourceName": "topics",
        "resourceId": topic_name,
        "object": message,
        "parameters": {"requestId": "publishFromClient"}
    }
    return json.dumps(send_message_template)


def on_message(ws, message):
    '''
       Invoked when the message is received from WebSocket connection
    '''
    recv = json.loads(message)
    # response from vantiq
    if recv['headers']['X-Request-Id'].find('publishFromClient') >= 0:
        print("Response: %s" % recv)

    # subscribed message
    else:
        print("Subscribed: %s" % recv)


def on_error(ws, error):
    print(error)


def on_close(ws, a, b):
    ws.close()
    print("### closed ###")


def on_open(ws):
    '''
       Invoked when the websocket session has been established.
    '''
    def run(*args):
        while True:

            '''
            TODO: Replace this block with the sensor readings
            '''
            ### block start --------------------------------
            for i in range(10):
                time.sleep(1)
                ws.send(getJson(1, random.uniform(25, 35)))
            time.sleep(10)
            ### block end --------------------------------

    # authenticate
    senddata = json.dumps(authenticate)
    ws.send(senddata)

    # start send data continuously
    thread.start_new_thread(run, ())


if __name__ == "__main__":
    #    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(vantiq_websocket_uri,
                                on_open=on_open,
                                on_message=on_message,
                                on_error=on_error,
                                on_close=on_close)

    ws.run_forever()
