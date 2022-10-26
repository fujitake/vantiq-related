# VANTIQ CLI クイックリファレンス

Vantiq Extension Source を利用する際などに必要になる Vantiq CLI の利用方法について説明します。

## TOC
- [インストール](#install)
  - [ダウンロード](#zip-download)
  - [環境変数への追加](#add-path)
  - [動作確認](#cli-test)
- [Profile](#profile)
  - [profileファイルの作成](#create-profile)
  - [profileの編集](#edit-profile)

## インストール<a id="install"></a>
インストーラーを利用したインストールは不要で、zipファイルの展開と環境変数への追加のみで利用できます。

### ダウンロード<a id="zip-download"></a>

1. まずはじめに VANTIQ CLI をダウンロードします。  
→ [vantiq.zip](https://dev.vantiq.com/downloads/vantiq.zip)

2. ダウンロードした vantiq.zip を解凍します。

3. 解凍された `vantiq-x.x.x` フォルダを任意の場所に配置します。
    #### 例：Windows
    ```
    C:\vantiq-1.34.13
    ```
    #### 例：Mac/Linux
    ```
    ※追記予定
    ```

### 環境変数への追加<a id="add-path"></a>

1. 環境変数の `Path` に `vantiq-x.x.x\bin` フォルダを追加します。  
    #### 例：Windows
    システム → バージョン情報 → システムの詳細設定 → 環境変数(N)...  
    ```
    C:\vantiq-1.34.13\bin
    ```
    #### 例：Mac/Linux
    ```
    ※追記予定
    ```

2. PCを再起動します。

### 動作確認<a id="cli-test"></a>

1. バージョン情報の表示を表示し、Pathが通っていることを確認します。
    #### 例：Windows
    ```
    vantiq.bat -v
    ```
    #### 例：Mac/Linux
    ```
    vantiq -v
    ```

## Profile<a id="profile"></a>
profileファイルの作成を行います。

### Profileの作成<a id="create-profile"></a>
1. Profileを保存するフォルダを下記のように作成します。
    #### 例：Windows
    ```
    %UserProfile%\.vantiq\
    ```
    #### 例：Mac/Linux
    ```
    ~/.vantiq/
    ```

2. 上記で作成したフォルダに `profile` ファイルを作成します。  
※拡張子は不要です
    #### 例：Windows
    ```
    %UserProfile%\.vantiq\profile
    ```
    #### 例：Mac/Linux
    ```
    ~/.vantiq/profile
    ```

### Profileの編集<a id="edit-profile"></a>
作成した `profile` ファイルを下記を参考に作成します。

```
base {
    url = 'https://dev.vantiq.com'
    username = 'myUsername'
    password = 'myPassword'
}
user1 {
    url = 'https://dev.vantiq.com'
    token = 'rTTbtHd8Z7gFPEQPE32137HfYNDg8YA84zmOWtVbdYg='
}
```

#### 【Profile名】
##### base
-s コマンドでProfileを指定しなかった場合に利用されるデフォルト設定になります。

##### user1
- Profileの名前になります。
- 任意で命名できます。

##### url
- VANTQのアドレスになります。

#### 【オプション】
##### username
- ユーザー名は、Edgeサーバーでのみ使用できます

##### password
- パスワードは、Edgeサーバーでのみ使用できます
- パスワードとトークンの両方を指定すると、トークンの代わりにパスワードが使用されます。

##### token
- Namespaceのアクセストークンになります。
- パブリッククラウドおよびキークロークアクセスを使用するサーバーでは、tokenオプションを使用する必要があります
- トークンとパスワードの両方を指定すると、トークンの代わりにパスワードが使用されます。
- トークンの作成方法は [こちら](https://github.com/fujitake/vantiq-related/blob/main/vantiq-apps-development/1-day-workshop/docs/jp/a08-Lab05_VANTIQ_REST_API.md#user-content-step-1%E5%A4%96%E9%83%A8%E3%81%8B%E3%82%89-vantiq-%E3%81%AE-type-%E3%81%B8%E3%83%87%E3%83%BC%E3%82%BF%E3%81%AE%E7%99%BB%E9%8C%B2%E5%8F%96%E5%BE%97%E6%9B%B4%E6%96%B0%E5%89%8A%E9%99%A4%E3%82%92%E8%A1%8C%E3%81%86) を参照してください。

#### 【その他】
CLI Reference を参照してください。  
→ [CLI Reference](https://dev.vantiq.com/docs/system/cli/index.html#profile)
