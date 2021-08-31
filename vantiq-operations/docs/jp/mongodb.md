# Vantiqのmongodb構成について

## Vantiqで構成しているMongoDBの可用性について

### TL;DR
3台のミラー構成のうち最低2台が稼働していることが必要である。

### Details
Vantiqのmongodbは3台のミラー構成になっていますが、内訳は以下の通りです。

- 3台稼働の場合: Primary + Secondary + Secondary
- 2台稼働の場合: Primary + Secondary
- 1台稼働の場合: Secondary

Primaryは書き込み専用, Secondaryは読み込み専用です。
AZ障害等で1台になると、読み込みしかできないので、書き込みしようとするとタイムアウトエラーとなります。
![timeout_error](../../imgs/mongodb/timeout_error.png)

数分後、Vantiq podが定期的な書き込みができず（ここは推測）、PodのContainer自体が`Ready`でなくなります。
その結果 `503 Service Temporary Unavailable`となります。

![503error](../../imgs/mongodb/503error.png)



## mongodb backup jobの削除のタイミング

`mongodbbackup`のcronjobの中に、`successfulJobsHistoryLimit: 3`　が設定さている。

```sh
$ kubectl get cj -n internal mongobackup -o yaml
```
```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  annotations:
...
schedule: '@daily'
successfulJobsHistoryLimit: 3
suspend: false
```

それにより、実行済みのJobは３世代以上は自動的に削除される。

```sh
$ kubectl get pods -n internal
NAME                           READY   STATUS      RESTARTS   AGE
metrics-collector-0            1/1     Running     6          81d
mongobackup-1630195200-z8ztx   0/1     Completed   0          2d11h
mongobackup-1630281600-q76jh   0/1     Completed   0          35h
mongobackup-1630368000-f6wjk   0/1     Completed   0          11h
mongodb-0                      2/2     Running     0          15d
mongodb-1                      2/2     Running     0          15d
```
