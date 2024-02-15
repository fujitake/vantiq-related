# はじめに
本ドキュメントはVantiq EdgeにおけるLicense更新手順について記載したものです。  
手順としては以下のような流れとなっています。  
- License ファイルの置き換え  
- Vantiq Edge の再起動  

# 前提 
Vantiq Support から Licenseファイル (それぞれ、public.pem、license.key とする) を取得していることを前提とします。

# 1. Licenseファイル更新

## 1.1 Licenseファイルバックアップ
configディレクトリに移動してください。  
古いLicenseファイルをリネームし、バックアップとします。  
```sh
$ mv license.key license.key_`date +%Y%m%d`.old
$ mv public.pem public.pem_`date +%Y%m%d`.old
```

## 1.2 Licenseファイル配置
新しいLicenseファイルをconfigディレクトリに配置します。

## 1.3 Vantiq Edgeの再起動
Vantiq Edgeコンテナを再起動します。
```sh
$ docker restart vantiq_edge_server
```

Vantiq Edgeコンテナの再起動後、Vantiq IDE画面からライセンスが更新されていることを確認してください。

# 2. Licenseファイル更新 - Rollback

## 2.1 Licenseファイルバックアップ
configディレクトリにて、新しいLicenseファイルをリネームします。
```sh
$ mv license.key license.key_`date +%Y%m%d`.new
$ mv public.pem public.pem_`date +%Y%m%d`.new
```

## 2.2 古いLicenseファイルを戻す
バックアップしておいた 古いLicenseファイルを リネームして元のファイル名に戻します。
```sh
$ mv license.key_`date +%Y%m%d`.old license.key
$ mv public.pem_`date +%Y%m%d`.old public.pem
```

## 2.3 Vantiq Edgeの再起動
Vantiq Edgeコンテナを再起動します。
```sh
$ docker restart vantiq_edge_server
```

Vantiq Edgeコンテナの再起動後、Vantiq IDE画面からライセンスがRollbackされていることを確認してください。