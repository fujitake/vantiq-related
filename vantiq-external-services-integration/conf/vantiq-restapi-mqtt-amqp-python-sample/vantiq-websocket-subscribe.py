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
vantiq_websocket_uri = "wss://internal.vantiq.com/api/v1/wsock/websocket"
access_token = "<access token>"
topic_name = "/python/websocket/2"  # change the topic name as appropriate


'''
   message used for authentication.
'''
authenticate = {
    "op": "validate",
    "resourceName": "system.credentials",
    "object": access_token,    # access token
    "parameters": {"requestId": "validateFromClient"}
    }

'''
   message used for subscribing a topic.
'''
subscribe = {
    "op": "subscribe",
    "resourceName": "events",
    "resourceId": "/topics/" + topic_name,
    "parameters": {
        "requestId": "subscribeFromClient"
    }
}

def on_message(ws, message):
    '''
       Invoked when the message is received from WebSocket connection
    '''

    recv = json.loads(message)
    # response from vantiq
    if recv['headers']['X-Request-Id'].find('publishFromClient') >= 0 || recv['headers']['X-Request-Id'].find('validateFromClient'):
        print ("Response: %s" % recv)

    # subscribed message
    else:
        '''
        TODO: Replace this block to implement the behavior
        '''
        ### block start --------------------------------
        print ("Subscribed: %s" % recv)
        ### block end ----------------------------------

def on_error(ws, error):
    print(error)

def on_close(ws, a, b):
    ws.close()
    print("### closed ###")

def on_open(ws):

    # authenticate
    senddata = json.dumps(authenticate)
    ws.send(senddata)

    # susscribe
    senddata = json.dumps(subscribe)
    ws.send(senddata)




if __name__ == "__main__":
#    websocket.enableTrace(True)
    ws = websocket.WebSocketApp(vantiq_websocket_uri,
                              on_open = on_open,
                              on_message = on_message,
                              on_error = on_error,
                              on_close = on_close)

    ws.run_forever()
