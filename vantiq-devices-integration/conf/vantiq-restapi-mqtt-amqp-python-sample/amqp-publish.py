import asyncio
import random

from azure.eventhub.aio import EventHubProducerClient
from azure.eventhub import EventData
import datetime
import json
import time

### TODO Modify the configuration parameter
connection_string="Endpoint=sb://<eventhubsname>.servicebus.windows.net/;SharedAccessKeyName=<access_policy_name>;SharedAccessKey=<primary_key>;EntityPath=python-amqp-test"
eventhub_name="<eventhub name>"

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


async def run():
    # Create a producer client to send messages to the event hub.
    # Specify a connection string to your event hubs namespace and
    # the event hub name.
    producer = EventHubProducerClient.from_connection_string(conn_str=connection_string, eventhub_name=eventhub_name)
    async with producer:

        while True:

            '''
            TODO: Modify this block to implement the sensor reading and send data to broker
            '''
            ### block start --------------------------------
            # Create a batch.
            event_data_batch = await producer.create_batch()

            # Add events to the batch.
            senddata = getJson(1, random.uniform(25, 35))
            event_data_batch.add(EventData(senddata))

            # Send the batch of events to the event hub.
            await producer.send_batch(event_data_batch)
            print(senddata)

            await asyncio.sleep(1)

            ### block end -----------------------------------

loop = asyncio.get_event_loop()
loop.run_until_complete(run())
