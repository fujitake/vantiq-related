## Troubleshooting

This article explains the frequently encountered problems and how to troubleshoot them.  

### 1. **Application does not work.**

In Vantiq, there are settings of active status/inactive status for some resources such as Source and Application. If it is set to inactive, it will not work. In that case, please change it to active.  

### 2. **Data cannot be delivered from the Data Generator to the MQTT broker, Data cannot be received by Source.**

If the Topic name is wrong, it means that you are publishing or subscribing to a Topic not expected. Please confirm the followings: `not include spaces before or after the Topic name`, `capitalization is correct`, `no typos`.

### 3. **During developing with App Builder, an error occurs.**

Do a "View Task Events" on the task before the task where the error occurs and confirm that the output data is as intended. Also, trace the cause of the error along with the content of the displayed error, and fix it.

### 4. **How to restart the Generator**

Confirm that the Source is set to active. Click "Launch" > "Run currentry saved Client in Client Launcher (RTC)" in "TrainingDataGeneratorClient" to open the Data Generator in a browser. Click the _Start Generator_ button. Data generation will start.  

![RestartRTC](../../imgs/troubleshootings/Restart_Data.generator.gif)
