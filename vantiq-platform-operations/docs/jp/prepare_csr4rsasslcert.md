## はじめに

SSLサーバ証明書(RSA)申請のためのCSR(Certificate Signing Request)作成手順を案内します。

下記は一般的な手順であり、利用用途によって手順が違うことがございます。詳しくは認証局にお問い合わせ下さい。

## 前提条件

Windowsの場合は、OpenSSLのインストールを事前に済ませて下さい。

Macの場合は、LibreSSLが標準でインストールされているのでそのまま使用して下さい。

## 手順

`openssl`コマンドを使ってRSA暗号方式の秘密鍵を作成します。
鍵長は2048bit以上が望ましいので2048にします。

```sh:
openssl genrsa -out {wildcard.domain.key} 2048
Generating RSA private key, 2048 bit long modulus
.........+++
.......................................................................................................+++
e is 65537 (0x10001)
```

識別名(DN)を入力する準備を行って下記コマンドを実行します。

```sh:
Country Name (国名):JP
State or Province Name (都道府県名) []:Tokyo
Locality Name (市区) []:Minato-ku
Organization Name (企業名) []:{Your Company name}
Organizational Unit Name (組織名) []:{team}
Common Name (FQDN、ドメイン名) []:{*.domain.com} # ワイルドカード証明書の場合は*、特定ドメインの場合は、sub.domain.comなど
Email Address []:
```

先に作成した秘密鍵ファイルからCSRを作成します。

```sh:
openssl req -new -key {wildcard.domain.key} -out {wildcard.domain.csr}
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) []:JP
State or Province Name (full name) []:Tokyo
Locality Name (eg, city) []:Minato-ku
Organization Name (eg, company) []:{domain} Corporation
Organizational Unit Name (eg, section) []:{team}
Common Name (eg, fully qualified host name) []:{*.domain.com}
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:{password}
```

## 確認方法

下記コマンドで作成済みのCSRの内容を確認できます。

```sh:
openssl req -in wildcard.domain.csr -text
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: C=JP, ST=Tokyo, L=Minato-ku, O=My Corporation, OU=my team, CN=*.domain.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:c2:45:bb:22:76:fd:b0:b3:2f:ce:94:d2:5f:68:
                    e9:62:bd:21:71:b8:0a:7c:de:95:bb:70:53:0d:a7:
                    ca:59:51:a6:cc:91:c1:16:8b:6e:31:a2:3d:a2:8b:
以下省略
```


## 備考

RSA暗号方式ではなく、楕円曲線暗号方式(ECDSA)を使う場合は、本手順とは違う手順となります。楕円曲線暗号方式のサーバ証明書を発行可能な認証局にご確認下さい。
