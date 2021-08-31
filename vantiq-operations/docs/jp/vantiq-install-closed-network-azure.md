# 閉域網構成における考慮事項（Azure編）


## Internal Load Balancer
AKSの場合serviceの定義にannotationで追加する。必要があれば、annotationでsubnetやIPを指定できる。
[Azure Kubernetes Service (AKS) で内部ロード バランサーを使用する](https://docs.microsoft.com/ja-jp/azure/aks/internal-lb)
