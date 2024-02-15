# はじめに
本ドキュメントはVantiq EdgeにおけるSSL証明書更新手順について記載したものです。  
手順としては以下のような流れとなっています。  
- SSL証明書の置き換え  
- Nginx の再起動  

# 前提 
- 証明書と秘密鍵 (それぞれ、fullchain.crt、private.key とする) を取得していることを前提とします。

- 証明書と秘密鍵が一致していることを前提とします。  
  一致しているかどうかは、次のコマンドでハッシュ値を比較し、確認できます。
```sh
$ openssl x509 -in fullchain.crt -pubkey -noout -outform pem | sha256sum
$ openssl pkey -in private.key -pubout -outform pem | sha256sum
```

# 1. SSL証明書更新

## 1.1 証明書と秘密鍵のバックアップ
certsディレクトリに移動してください。  
古い証明書と秘密鍵をリネームし、バックアップとします。  
```sh
$ mv fullchain.crt fullchain.crt_`date +%Y%m%d`.old
$ mv private.key private.key_`date +%Y%m%d`.old
```

## 1.2 証明書と秘密鍵の配置
新しい証明書と秘密鍵をcertsディレクトリに配置します。

## 1.3 Nginxの再起動
Nginxコンテナを再起動します。
```sh
$ docker restart nginx-proxy
```

Nginxコンテナの再起動後、ブラウザにてVantiqにWEBアクセスし、証明書が更新されていることを確認してください。

# 2. SSL証明書更新 - Rollback

## 2.1 証明書と秘密鍵バックアップ
certsディレクトリにて、新しい証明書と秘密鍵をリネームします。
```sh
$ mv fullchain.crt fullchain.crt_`date +%Y%m%d`.new
$ mv private.key private.key_`date +%Y%m%d`.new
```

## 2.2 古い証明書と秘密鍵を戻す
バックアップしておいた 古い証明書と秘密鍵をリネームして元のファイル名に戻します。
```sh
$ mv fullchain.crt_`date +%Y%m%d`.old fullchain.crt
$ mv private.key_`date +%Y%m%d`.old private.key
```

## 2.3 Nginxの再起動
Nginxコンテナを再起動します。
```sh
$ docker restart nginx-proxy
```

Nginxコンテナの再起動後、ブラウザにてVantiqにWEBアクセスし、証明書がRollbackされていることを確認してください。