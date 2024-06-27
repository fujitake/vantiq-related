# Vantiq Cleint について

`Cleint` は Vantiq で UI を実装するためのリソースです。  

## 目次

- [Vantiq Cleint について](#vantiq-cleint-について)
  - [目次](#目次)
  - [概要](#概要)
  - [Public Cleint](#public-cleint)

## 概要

`Client` は **MVC モデル** を採用しています。  

- **Model（モデル）**  
  モデルはアプリケーションが扱うデータやビジネスロジックを担当するコンポーネントです。  
  Vantiq サーバーからデータを読み取ったり、アプリケーションを利用するユーザーが入力したデータが格納されます。  
  また、データの変更をビューに通知する役割も担っています。  
  Vantiq ではデータオブジェクト（`Client Data Object` や `Page Data Object`）で管理しています。  

- **View（ビュー）**  
  ビューは、ユーザーインターフェース（UI）を表示するコンポーネントです。  
  モデルのデータを取り出してユーザーに情報を表示したり、ユーザーからの入力を受け付けます。  
  Vantiq では様々なウィジェットを用いて実装することができます。  

- **Controller（コントローラ）**  
  ユーザからの入力をモデルに伝えるコンポーネントです。  
  Vantiq では JavaScript を使って記述できます。  

## Public Cleint

Vantiq Client では通常、 Vantiq へのログイン認証を行ったあとに利用することが前提となっています。  

しかし、一定の制約はあるものの `Cleint` を **Public Cleint** として設定することで、 Vantiq へのログイン認証なしで利用することができます。  

- [Vantiq Public Client](./public-client/readme.md)