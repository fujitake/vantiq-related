# timestamp_ds.yaml

Tool to check if the time is synchronized across servers.


## Related errors
The authentication process between the vantiq server and the keycloak server may fail due to some causes (server clock is not synchronized) or other circumstances.

#### Examples of errors

```
[{"code":"io.vantiq.server.error", "message":"Failed to complete authentication code flow. Please contact your Vantiq administrator and have them confirm the health/configuration of the OAuth server. Request failed due to exception: io.vertx.core.impl. NoStackTrace Throwable: Unauthorized: {\"error\":\"unauthorized_client\",\"error_description\":\"Invalid client secret\"}", "params":[]}]
```
```

[{"code":"io.vantiq.server.error", "message":"Failed to complete authentication code flow. Please contact your Vantiq administrator and have them confirm the health/configuration of the OAuth server. Request failed due to exception: io.vertx.core.impl. NoStackTrace Throwable: Bad Request: {\"error\":\"invalid grant\",\"error_description\":\"Code not valid\"}", "params":[]}]
```

## How to use

Install the [stern](https://github.com/wercker/stern/releases) (a tool which outputs the logs of multiple pods at once). As for the binaries for each environment, please refer to [here](https://github.com/wercker/stern/releases).  
```sh
$ brew install stern
```
or
```sh
$ wget https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
mv stern_linux_amd64 /usr/sbin
chmod +x /usr/sbin/stern_linux_amd64
ln /usr/sbin/stern_linux_amd64 /usr/sbin/stern
```

Deploy the DaemonSet of the tool.  
```sh
$ kubectl apply -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/timestamp_ds.yaml

$ kubectl get pods -n tools
NAME              READY   STATUS    RESTARTS   AGE
timestamp-68tlt   1/1     Running   0          7s
timestamp-97chb   1/1     Running   0          7s
timestamp-f6llc   1/1     Running   0          7s
timestamp-jjcbp   1/1     Running   0          7s
timestamp-kf8mm   1/1     Running   0          7s
timestamp-kv2q2   1/1     Running   0          7s
timestamp-ldmmv   1/1     Running   0          7s
timestamp-m6msn   1/1     Running   0          7s
timestamp-m7wfl   1/1     Running   0          7s
timestamp-sw7zw   1/1     Running   0          7s
timestamp-z8ww2   1/1     Running   0          7s
```

Printing Timestamp. The following is an example of a normal timestamp.

```
$ stern -n tools timestamp-*

...

timestamp-m7wfl timestamp Date is 2021-06-23T22:28:58.
timestamp-jjcbp timestamp Date is 2021-06-23T22:28:58.
timestamp-f6llc timestamp Date is 2021-06-23T22:28:58.
timestamp-m6msn timestamp Date is 2021-06-23T22:28:58.
timestamp-sw7zw timestamp Date is 2021-06-23T22:28:58.
timestamp-97chb timestamp Date is 2021-06-23T22:28:58.
timestamp-kf8mm timestamp Date is 2021-06-23T22:28:58.
timestamp-kv2q2 timestamp Date is 2021-06-23T22:28:58.
timestamp-z8ww2 timestamp Date is 2021-06-23T22:28:58.
timestamp-68tlt timestamp Date is 2021-06-23T22:28:58.
timestamp-ldmmv timestamp Date is 2021-06-23T22:28:58.
timestamp-m7wfl timestamp Date is 2021-06-23T22:28:59.
timestamp-jjcbp timestamp Date is 2021-06-23T22:28:59.
timestamp-f6llc timestamp Date is 2021-06-23T22:28:59.
timestamp-m6msn timestamp Date is 2021-06-23T22:28:59.
timestamp-sw7zw timestamp Date is 2021-06-23T22:28:59.
timestamp-97chb timestamp Date is 2021-06-23T22:28:59.
timestamp-kf8mm timestamp Date is 2021-06-23T22:28:59.
timestamp-kv2q2 timestamp Date is 2021-06-23T22:28:59.
timestamp-z8ww2 timestamp Date is 2021-06-23T22:28:59.
timestamp-68tlt timestamp Date is 2021-06-23T22:28:59.
timestamp-ldmmv timestamp Date is 2021-06-23T22:28:59.
timestamp-m7wfl timestamp Date is 2021-06-23T22:29:00.
timestamp-jjcbp timestamp Date is 2021-06-23T22:29:00.
timestamp-f6llc timestamp Date is 2021-06-23T22:29:00.
timestamp-m6msn timestamp Date is 2021-06-23T22:29:00.
timestamp-sw7zw timestamp Date is 2021-06-23T22:29:00.
timestamp-97chb timestamp Date is 2021-06-23T22:29:00.
timestamp-kf8mm timestamp Date is 2021-06-23T22:29:00.
timestamp-kv2q2 timestamp Date is 2021-06-23T22:29:00.
timestamp-z8ww2 timestamp Date is 2021-06-23T22:29:00.
timestamp-68tlt timestamp Date is 2021-06-23T22:29:00.
timestamp-ldmmv timestamp Date is 2021-06-23T22:29:00.
```



Undeploy the DaemonSet of the tool.  
```sh
$ kubectl delete -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/timestamp_ds.yaml
```
