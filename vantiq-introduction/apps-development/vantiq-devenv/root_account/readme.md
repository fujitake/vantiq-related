# 開発者向け環境準備手順書

## ＜はじめに＞

この記事は、初めて Vantiq Public Cloud 環境（**dev.vantiq.co.jp**）を利用する開発者向けに環境準備の手順を説明します。作業環境が利用できるためには、以下の 3つのステップが必要です。

1. ユーザーアカウントを登録する
2. 招待メールにより root namespace へのアクセス権を付与される
3. 開発用 namespace を作成する

**推奨ブラウザーは Google Chrome です。**

**資料を参照しながら開発作業を行いますのでPCと別途、ディスプレイを用意することを推奨します。**

Vantiq Workshop では VANTIQ operations (operations@vantiq.com) からのメールを受信できるメールアドレスをご利用ください。　

## Step 1 (招待メールの確認)

1. VANTIQ からの招待メール (件名: Vantiq -- Namespace Authorization) を開きます。
   > VANTIQ からのメールが迷惑メールに振り分けられる可能性がありますので届いていない場合はご確認ください。

2. メール中段にある\[here\]をクリック しブラウザーで開きます。
   > **招待メールの有効期限は *48* 時間となっています。**

   ![image1.png](./imgs/image1.png)

## Step 2 (アカウント作成)

1. 表示された画面中段にある `Register` をクリックします。

   ![image2.png](./imgs/image2.png)

2. 表示されたユーザー情報の入力欄に、ユーザー情報を入力してアカウントを登録します。

   ![image3.png](./imgs/image3.png)

    ＜注意＞ **Username にもメールアドレスを入力してください。** (Lab 運営上の都合)  

   |項目|内容|
   |:---|:---|
   |First name| 名(英語表記) 例 Taro|
   |Last name| 姓(英語表記) 例 Yamada |
   |Email| 認証をしたメールアドレス  |
   |Username| **認証をしたメールアドレス**  |
   |Password| 任意のパスワード (8文字以上)  |
   |Confirm password| パスワードの再入力|

3. 入力が終了したら `click here` をクリック、登録したメールアドレスに確認メールが届きます。

4. 次のような画面が表示されれば、VANTIQ から E メールが送られていますので、次の手順に進んでください。

   ![image4.png](./imgs/image4.png)

## Step 3 (メールアドレスの認証メールの確認をしてアカウント登録)

1. メールアドレスの認証メール (件名: Verify email) を開きます。
   > **メールアドレス認証メールの有効期限は *15* 分です。**

   ![image5.png](./imgs/image5.png)

2. `Link to e-mail address verification` のリンクをブラウザーで開きます。

3. 次の画面が表示された場合は、`Click here to proceed` をクリックし、メールアドレス認証を完了します。

   ![image6.png](./imgs/image6.png)

4. 「Edit Account」 画面が表示された場合は、アカウント情報登録の際に入力した情報が反映されているか確認し、`save` ボタンをクリックしてください。  
   緑のポップアップ `Your account has been updated` が表示されます。

5. 以上でアカウント登録は終了となります。

## Step 4 (作業用 Namespace の作成)

Namespace の作成方法は下記を参照してください。

[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/readme.md)
