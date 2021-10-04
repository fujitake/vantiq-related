# Python Code samples

### Interacting with Vantiq directly
Sample code that can be used to interact with Vantiq from external system or devices.
- `vantiq-restapi-post.py` - sample for sending events to a Vantiq topic via HTTPS REST API
- `vantiq-websocket-publish.py` - sample for sending events to a Vantiq topic via WebSocket API
- `vantiq-websocket-subscribe.py` - sample for subscribing to a Vantiq topic via WebSocket API

### Interacting with Message Brokers
Sample code that can be used to interact with Brokers from external system or devices.
- `amqp-publish.py` - sample code to interact with Azure EventHubs via AMQP protocol
- `mqtt-publish.py`- sample code to interact with Amazon MQ via MQTT protocol


### Vantiq Side implementation Sample to Ingest from Above Data Sources
- [Vantiq Project](./conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - MQTT Source
  - AMQP Source
  - Topic – Websocket subscribe
  - Topic – Websocket publish
  - Topic - REST
