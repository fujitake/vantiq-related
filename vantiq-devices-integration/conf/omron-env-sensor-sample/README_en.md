[Japanese Version here](README.md)

# 【Omron Ambient Sensor】Instruction from starting the sensor to sending to Vantiq

### **Requirements for this instruction**
---
- Raspberry Pi 3B+ or 4B
- [Raspberry Pi OS with desktop (32bit)](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)
- Mouse
- Monitor
- AC adapter  
- SD card
- Omron Ambient Sensor（2JCIE-BU01 or 2JCIE-BL01）
- Sample script（[env_usb_observer.py](./) or [env_bag_observer.py](./)）
    - Sample script to send measurements to Vantiq
    - Use "env_usb_observer.py" for 2JCIE-BU01 (USB type) or " env_bag_observer.py" for 2JCIE-BL01 (Bag type).

### **Preparation in Vantiq IDE**
---
1. Create a Topic that will be the destination of the Environmental Sensor data in Vantiq development environment.  
    1. Go to "Add" -> "Advanced" -> "Topic...", and click the "+ New Topic" and set the Name to "/devices/env".
2. Issue an Access Token.
    1. Go to "Administer" -> "Advanced" -> "Access Tokens", and click the "+ New". Set an appropriate name and validity period, and issue an Access Token.  

### **Procrdure**
---
1.  Use an application such as "balenaEtcher" to write the Raspberry Pi OS to an SD card.
2.  Start Raspberry Pi and follow the UI to configure the settings.
    1. Language settings
    2. Network settings (Wifi, SSH)
4. Connect the Environment Sensor to USB port.
5. Confirm the MAC address of the ambient Sensor.
```
$ sudo hcitool lescan
LE Scan ...
C2:B7:E4:CC:FE:79 Rbt
※ "Rbt" is the MAC address of the Environment Sensor
```
6. Edit the sample script and make the following settings.
    1. Endpoint of the Topic created in the "Preparation in Vantiq IDE".  
    <br/>e.g.
    VANTIQ_ENDPOINT = 'https://dev.vantiq.co.jp/api/v1/resources/topics//devices/env'
    2. The Access Token created in the "Preparation in Vantiq IDE".  
    <br/>e.g.
    VANTIQ_ACCESS_TOKEN = 'abcdefg12345...='  
    3. The MAC address of the Environment Sensor confirmed in Step 5.  
    <br/>e.g.
    ENV_SENSOR_MAC_ADDRESS = 'C2:B7:E4:CC:FE:79'
7. Place the sample script in any directory in the Raspberry Pi.  
8. Install "bluepy" (which is a Python module to control BLE devices).  
```
sudo apt install libglib2.0-dev
pip install bluepy
```
9. In addition, if there are any other modules used in the sample script that are not on the Raspberry Pi, install them.  
```
e.g.
pip install requests
```
10. Run the sample script and confirm that the data is sent.  
```
e.g.
$ python env_usb_observer.py
Published Event: 2021/09/21 11:03:46
{'pressure': 1005, 'noise': 42, 'temperature': 29, 'env_sensor_id': 'env_sensor1', 'etvoc': 3, 'light': 44, 'eco2': 422, 'humidity': 55}
```
