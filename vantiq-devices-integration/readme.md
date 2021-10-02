# Vantiqとデバイスとの連携

## 目的
この記事では、センサー/デバイスからVantiqまでのデータ連携パターンと、それぞれの接続コードサンプルを説明します。この記事を正しく表示するには、[mermaid プラグイン](https://github.com/BackMarket/github-mermaid-extension) が必要です。

## Edge ~ Vantiq構成パターン / Integration Map

![integration_map](./imgs/device-to-vantiq/integration_map.png)


### Dataflow Patterns
ゲートウェイからRESTでVantiq Topicに送るパターン。
```mermaid
graph LR
A(Device)
B[Gateway]
E[Vantiq Cloud]

A -->|PAN| B
B -->|REST API| E
```
ゲートウェイからMQTT Brokerを使うパターン。
```mermaid
graph LR
A(Device)
B[Gateway]
D[Broker]
E[Vantiq Cloud]

A -->|PAN| B
B -->|MQTT| D
D -->|MQTT| E
```
IoT Core/ IoT Hubを使用するパターン。
```mermaid
graph LR
A(Device)
B[Gateway]
D[Broker]
E[Vantiq Cloud]
F[IoT Core/IoT Hub]

A -->|PAN| B
B -->|MQTT| F
F -->|Action| D
D -->|MQTT/AMQP| E  
```
```mermaid
graph LR
A(Device)
B[Gateway]
D[Lambda]
E[Vantiq Cloud]
F[IoT Core/IoT Hub]

A -->|PAN| B
B -->|MQTT| F
F -->|Action| D
D -->|HTTPS REST| E  
```
Vantiq Edgeを使用するパターン。
```mermaid
graph LR
A(Device)
B[Gateway]
C[Vantiq Edge]
E[Vantiq Cloud]

A -->|PAN| B
B -->|REST API| C
C -->|Invoke| E
```

### ガイドライン / Guideline
- [Edge~Vantiq構成 データ連携 ガイドライン](./docs/jp/device-to-vantiq.md)
- [Edge - Vantiq configuration Data integration Guideline](./docs/en/device-to-vantiq.md)


### コネクターのテンプレート / Connector Template
- [Python Code](./conf/vantiq-restapi-mqtt-amqp-python-sample)
  - HTTPS REST API (Python)
  - WebSocket API (Python)
  - MQTT Publish (Python)
  - AMQP Publish (Python)

- [Vantiq Project](./conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - MQTT Source
  - AMQP Source
  - Topic – Websocket subscribe
  - Topic – Websocket publish
  - Topic - REST

### デバイスの接続サンプルコード / Device Integration Sample Code
- オムロン環境センサー / Omron Ambient Sensor 2JCIE-BU01, 2JCIE-BL01
