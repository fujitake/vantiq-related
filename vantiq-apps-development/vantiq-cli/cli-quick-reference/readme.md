# Vantiq CLI クイックリファレンス

Vantiq Extension Source を利用する際などに必要になる Vantiq CLI の利用方法について説明します。  
（※記事作成時の Vantiq バージョン： r1.39.3）

リファレンスはこちら  

- :globe_with_meridians: [CLI Reference Guide](https://dev.vantiq.com/docs/system/cli/)

## 目次

- [Vantiq CLI クイックリファレンス](#vantiq-cli-クイックリファレンス)
  - [目次](#目次)
  - [JDK11 のインストール](#jdk11-のインストール)
  - [インストール](#インストール)
    - [ダウンロード](#ダウンロード)
    - [環境変数への追加](#環境変数への追加)
    - [動作確認](#動作確認)
  - [Profile](#profile)
    - [Profile の作成](#profile-の作成)
    - [Profile の編集](#profile-の編集)

## JDK11 のインストール

Vantiq CLI を利用するには JDK11 が必要になります。  
Oracle社のホームページからダウンロードして、インストールしてください。  
※インストール後は再起動が必要になる場合があります。  

- :globe_with_meridians: [Java Downloads | Oracle](https://www.oracle.com/java/technologies/downloads/#java11)

## インストール

インストーラーを利用したインストールは不要で、zipファイルの展開と環境変数への追加のみで利用できます。

> **補足**  
> ※Windows 端末の操作例は PowerShell となっています。  

### ダウンロード

1. まずはじめに Vantiq CLI をダウンロードします。  
→ [vantiq.zip](https://dev.vantiq.com/downloads/vantiq.zip)

2. ダウンロードした `vantiq.zip` を解凍します。

3. 解凍された `vantiq-x.x.x` フォルダを任意の場所に配置します。

   **Windows：**

   ```PowerShell
   C:\vantiq-1.39.3
   ```

<!-- 
   **Mac/Linux：**

   ```bash
   ※Macユーザーの方、追記してください。
   ```
-->

### 環境変数への追加

1. 環境変数の `Path` に `vantiq-x.x.x\bin` フォルダを追加します。  

   **Windows：**  
   システム → バージョン情報 → システムの詳細設定 → 環境変数(N)...  

   ```PowerShell
   C:\vantiq-1.39.3\bin
   ```

<!-- 
   **Mac/Linux：**

   ```bash
   ※Macユーザーの方、追記してください。
   ```
-->

### 動作確認

1. バージョン情報の表示を表示し、Pathが通っていることを確認します。

   **Windows：**

   ```PowerShell
   vantiq.bat -v
   ```

   **Mac/Linux：**

   ```bash
   vantiq -v
   ```

## Profile

profile ファイルの作成を行います。  

> **補足**  
> ※Windows 端末の操作例は PowerShell となっています。  

### Profile の作成

1. Profile を保存するフォルダを下記のように作成します。

    **Windows：**

    ```PowerShell
    mkdir ~/.vantiq/
    ```

    **Mac/Linux：**

   ```bash
   mkdir ~/.vantiq/
   ```

2. 上記で作成したフォルダに `profile` ファイルを作成します。  
   ※拡張子は不要です。

   **Windows：**

   ```PowerShell
   New-Item ~\.vantiq\profile
   Invoke-Item ~\.vantiq\profile
   ```

   > **補足**  
   > ※ `profile` ファイルはテキストエディタ（メモ帳や VS Code など）で開いてください。

   **Mac/Linux：**

   ```bash
   nano ~/.vantiq/profile
   ```

### Profile の編集

作成した `profile` ファイルを下記を参考に作成します。

```text
base {
    url = 'https://dev.vantiq.com'
    token = 'rTTbtHd8Z7gFPEQPE32137HfYNDg8YA84zmOWtVbdYg='
}
profile_name {
    url = 'https://dev.vantiq.com'
    username = 'myUsername'
    password = 'myPassword'
}
```

#### Profile の説明

|Key|Type|Description|
|---|---|---|
|base|Object|`-s` コマンドで Profile を指定しなかった場合に利用されるデフォルト設定になります。|
|profile_name|Object|Profileの名前になります。<br>任意の名前を命名できます。|
|.url|String|Vantiq の URL になります。|
|.username|String|Vantiq ログイン時のユーザー名になります。<br>※ `username` は Vantiq Edge でのみ使用できます。|
|.password|String|Vantiq ログイン時のパスワードになります。<br>※ `password` は Vantiq Edge でのみ使用できます。|
|.token|String|Namespace のアクセストークンになります。<br>※パブリッククラウドおよび Keycloak を使用するサーバーでは `token` を使用する必要があります。|

> [!NOTE]
> - `password` と `token` の両方を指定すると `password` が使用されます。
> - トークンの作成方法はこちら
>   - [Vantiq Access Token の発行方法](/vantiq-apps-development/vantiq-resources/vantiq-access-token/create-access-token/readme.md)

#### Profile の設定例

```text
base {
    url = 'https://dev.vantiq.com'
    token = 'rTTbtHd8Z7gFPEQPE32137HfYNDg8YA84zmOWtVbdYg='
}
dev_hogehoge_namespace {
    url = 'https://dev.vantiq.com'
    token = 'QjsjjPtVTYd375R33ejSpU1fg2TZ3bRUfL1Um-zaZUQ='
}
dev_fugafuga_namespace {
    url = 'https://dev.vantiq.com'
    token = 'uthOV8BXPPKObfUX4l4t6oKK1GIycMIecW-sN1zFQeA='
}
edge_root {
    url = 'xxx.xxx.xxx.xxx'
    username = 'myUsername'
    password = 'myPassword'
}
edge_piyopiyo_namespace {
    url = 'xxx.xxx.xxx.xxx'
    username = 'myUsername'
    password = 'myPassword'
}
```
