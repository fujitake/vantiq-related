# Data integration to Vantiq using Fluentd
Fluentd is useful to send the telemetry data to Vantiq if the data are generated in a flat file format like log files, etc. This article explains how to configure and integrate data, using nginx access logs as an example.  

In this article, assume the folllowing:

- Use **Windows 10, Linux (Ubuntu 20.04)** as OS
- Use Vantiq as a method to verify operation (receive Topic)
- Use regular expressions to transform a flat file (nginx log)
## Table Of Contents
- [Install Fluentd (Windows 10)](#instf)
  - [Download from the following site](#download)
  - [Install Plugin (http_ext)](#plugin)
  - [Create a configuration file](#conf)
  - [Start Fluentd](#invoke)
  - [Verify the operations](#confirm)
- [Install Fluentd (Ubuntu 20.04）](#instubnt)
  - [Download from the following site](#dlubuntu)
  - [Install Plugin (http_ext)](#plugin-ubnt)
  - [Create a configurarion file](#conf-ubnt)
  - [Start Fluentd](#invoke-ubnt)
  - [Verify the operations](#confirm-ubnt)
- [Aggregating logs using regular expressions (Vantiq)](#regexp)
  - [How to use regular expressions](#howto)
  - [Aggregate after breaking down into elements](#analize)

<h2 id="instf">1. Install Fluentd (Windows 10）</h2>

<h3 id="download">1.1 Download from the following site</h3>

- [Download Fluentd](https://www.fluentd.org/download)
<img src="../../imgs/fluentd/td-agent-win.jpg" width="70%">

- As of 2021/09/21, it is named "td-agent-4.2.0-x64.msi". "td-agent" is the stable version of Fluentd.  
- Follow the installation wizard to install Fluentd.

<h3 id="plugin">1.2 install Plugin (http_ext)</h3>

- Click the "Windows" button to display the menu as shown below.
<img src="../../imgs/fluentd/prompt.jpg" width="50%">

- Right-click on it and run it as Administrator.
<img src="../../imgs/fluentd/admin.jpg" width="50%%">

- Implement Plugin for Output (http-ext) to enable Vantiq to verify the operations.  
- Use nginx for log file output.
- Type the following command.
```
cd \opt\td-agent
td-agent-gem install fluent-plugin-out-http-ext
```
<h3 id="conf">1.3 Create a configuration file</h3>

- Make a backup just in case.
```
ren etc\td-agent\td-agent.conf etc\td-agent\td-agent.conf.org
```
- Create the **etc\td-agent\td-agent.conf** file with an appropriate editor and copy and paste the following contents into it.  
- Note that this configuration assumes the following contents.  

|Item|Details|
---|---
|①: Vantiq Topic name|The Resource URL of the Topic that receives events on Vantiq side. <br /> The following example corresponds to `jp.co.vantiq.fluentd`.|
|②: Access Token|Access Token issued in the Namespace of Vantiq target.|
|③: path|Path and file name of the log to monitor (in this case, nginx).|
|④: pos_file|Path and file name for counting the log files to monitor.|
```
####
## Output descriptions:
##
<match **>
  @type http_ext
  endpoint_url      https://internal.vantiqjp.com/api/v1/resources/topics//jp.co.vantiq/fluentd # ①
  http_method       post
  serializer        json
  use_ssl           true
  verify_ssl        false
  <headers>
    Authorization Bearer dWXRMtWjRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6EtrM= # ②
  </headers>
</match>

####
## Source descriptions:
##
<source>
  @type tail
  path     c:/dev/nginx-1.20.1/logs/access.log # ③
  pos_file c:/var/log/td-agent/access.log.pos  # ④
  tag local.syslog
  <parse>
    @type none
  </parse>
</source>
```

<h3 id="invoke">1.4 Start Fluentd</h3>

```
fluentd -c etc\td-agent\td-agent.conf
```

<h3 id="confirm">1.5 Verify the operations</h3>

- Confirm that it is possible to access the nginx site and receive its access log.

|Topic|Received data|
---|---
|<img src="../../imgs/fluentd/result.jpg">|<img src="../../imgs/fluentd/tskvent.jpg">|

<h2 id="instubnt">2. Install Fluentd (Ubuntu 20.04）</h2>

<h3 id="dlubuntu">2.1 Download from the following site</h3>

- There are amd64 version and arm64 version, so choose the appropriate one for the environment.
- [Download Fluentd](https://www.fluentd.org/download)
- Ubuntu **Focal**.  
<img src="../../imgs/fluentd/td-agent-ubuntu.jpg" width="70%">

- Move to the folder where it was downloaded and install it.  
```
cd ~/Downloads
sudo dpkg -i ./td-agent_4.2.0-1_amd64.deb
```
<h3 id="plugin-ubnt">2.2 Install Plugin (http_ext)</h3>

```
cd /opt/td-agent
sudo td-agent-gem install fluent-plugin-out-http-ext
```

<h3 id="conf-ubnt">2.3 Create a configuration file</h3>

- Create the **/opt/td-agent/td-agent.conf** file with an appropriate editor and copy and paste the following contents into it.   
- Note that this configuration assumes the following contents.  

|Item|Details|
---|---
|①: Vantiq Topic name|The Resource URL of the Topic that receives events on Vantiq side.<br /> The following example corresponds to `jp.co.vantiq.fluentd`.|
|②: Access Token|Access Token issued in the Namespace of Vantiq target.|
|③: path|Path and file name of the target log to monitor (in this case, nginx).|
|④: pos_file|Path and file name for counting the log files to monitor.|
```
####
## Output descriptions:
##
<match **>
  @type http_ext
  endpoint_url      https://internal.vantiqjp.com/api/v1/resources/topics//jp.co.vantiq/fluentd # ①
  http_method       post
  serializer        json
  use_ssl           true
  verify_ssl        false
  <headers>
    Authorization Bearer dWXRMtWjRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6EtrM= # ②
  </headers>
</match>

####
## Source descriptions:
##
<source>
  @type tail
  path     /var/log/nginx/access.log # ③
  pos_file /var/log/nginx/access.log.pos  # ④
  tag local.syslog
  <parse>
    @type none
  </parse>
</source>
```

<h3 id="invoke-ubnt">2.4 Start Fluentd</h3>

```
cd /opt/td-agent
sudo bin/fluentd -c share/td-agent.conf
```

<h3 id="confirm-ubnt">2.5 Verify the operations</h3>

- Confirm that it is possible to access the nginx site and receive its access log.  

|Topic|Received data|
---|---
|<img src="../../imgs/fluentd/result.jpg">|<img src="../../imgs/fluentd/tskevent-ubnt.jpg">|

<h2 id="regexp">3. Aggregating logs using regular expressions（Vantiq IDE）</h2>
In this section, describe how to transform the event data received in Vantiq's Topic.  

<h3 id="howto">3.1 How to use regular expressions</h3>
It is possible to extract specific elements in strings using regular expressions in VAIL code.  

|Item|Details|
---|---
|&lt;patterns&gt;|The pattern of Regular Expression (※)|
|&lt;target&gt;|Target strings|

※ As for Patterns, please refer to this [site](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html).  
```
var re = regExp("<patterns>")
var result = <target>.match(re)
```

<h3 id="analize">3.2 Aggregate after breaking down into elements</h3>

- 3.2.1 Remove the Remote Host part
```
var reRemote = regExp("^([^ ]*)")
var remoteip = event.message.match(reRemote)
```

- 3.2.2 Define the Type for Stateful Service  
<img src="../../imgs/fluentd/sstype.jpg" width="60%">

- 3.2.3 Define the initialization process
```
private PROCEDURE LogSvc.initializePartitionedState()

RemoteData = Concurrent.Map()
```

- 3.2.4 Define the Stateful Service body
Note: Before calling this process, divide it into Remote Host units using SpritByGroup.
```
PROCEDURE LogSvc.countAccess(remote String)

RemoteData.compute(remote, (key, stats) => {
    if (stats == null) {
        stats = {
            remote: remote,
            count: 0
        }
    }
    stats.count += 1    
    log.info(stringify(stats))
    return stats
})
```
- 3.2.5 Confirm the execution result
<img src="../../imgs/fluentd/ssresult.jpg" width="50%">
