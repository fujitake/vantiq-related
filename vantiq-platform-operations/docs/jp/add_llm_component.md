# LLM機能の追加

LLM機能を利用する場合に必要となる手順を示します。  
LLM機能を利用するにはvantiq R1.37以降である必要があります。

## AI Assistant用Nodegroup/Nodepool作成
AI Assistant podをデプロイするために、NodeGroup or Nodepoolを作成する。  
既に作成済みの場合、この作業はスキップして良い。  
作成する際のパラメータは次の通り。  
* ラベル：vantiq.com/workload-preference=orgCompute
* 台数：1台  
* スペック：2CPU,8GB Memory 以上  

## Vantiq worker Access Token作成
Vantiq IDE画面にアクセスし、system namespaceにてVantiq worker用のAccess Tokenを作成する。  
プロファイルは、`system.federatedK8sWorker`とすること。  

## LLMコンポーネント設定(secrets.yaml)
1. secrets.yamlに次の項目を追加する。  
   ```
   vantiq:
     vantiq-ai-assistant-env:
       files:
         .env: deploy/sensitive/vantiq-ai-assistant-env.txt
     vantiq-worker:
       data:
         token: <worker Access Token>
   ```
   `targetCluster/deploy/sensitive/vantiq-ai-assistant-env.txt` ファイルの中身は次のようにすること。  
  OPENAI_API_KEYの値は、実際のKeyでは無く、XXXXXXのようなダミーの値として構わない。  
  実際のKeyはvantiqアプリケーション開発者が設定可能なためである。

   ```
   OPENAI_API_KEY=XXXXXX
   ```

2. 次のコマンドにて、`generateSecrets`を実行する。
   ```
   ./gradlew -Pcluster=<クラスタ名> generateSecrets
   ```
3. `targetCluster/deploy/secrets/`ディレクトリ配下に、2つのyamlファイルが新たに作成されたことを確認する。

## LLMコンポーネント設定(deploy.yaml)
次の変更を加える。  

a) MongoDBのバージョンを5.0.18とする。既に5.0.18となっている場合は、そのままで構わない。  
もし、この変更を加える場合、次のステップにて、MongoDBの手動バージョンアップ作業が必要となる。
```
  mongodb:
    image:
      tag: 5.0.18
```

b) Vantiq workerと Qdrant vectorDBのセクションを追加する。
```
vantiq:
  vectordb:
    enabled: true
    persistence:
      size: 30Gi

  worker:
    enabled: true
```

c) `vantiq.configuration`に下記のセクションを追加する。  
   `<namespace name>` となっている箇所を書き換えること。
```
  configuration:
    io.vantiq.modelmgr.ModelManager.json:
      config:
        collectionMonitorInterval: "3 hours"
        semanticIndexService:
          vectorDB:
            host: "vantiq-<namespace name>-vectordb.<namespace name>.svc.cluster.local"
```

## LLMコンポーネントデプロイ
1. 次のコマンドにて、Vantiq pod のサービスを停止する (metrics-collector と vision-analytics は構成している場合のみ)。 
   ```
     kubectl scale sts -n <namespace name> vantiq --replicas=0
     kubectl scale sts -n <namespace name> metrics-collector --replicas=0
     kubectl scale sts -n <namespace name> vision-analytics --replicas=0
   ```

2) 次のコマンドにて、MongoDBバージョンを4.4.24へ手動アップグレードする（作業前のMongoDBバージョンが4.2.5の場合のみ）。
   ```
   kubectl edit sts -n <namespace name>  mongodb
   ```

   mongodb container セクションと bootstrap initcontainer セクションのバージョンを4.4.24に変更する。  
   変更が完了したら、MongoDBのローリングアップデートが始まるはず。  
   ローリングアップデートが完了したのち、次のコマンドにて、mongodb-0 Podにログインする。
   ```
     kubectl exec -it mongodb-0 -n <namespace name> -- bash
   ```
   次のコマンドにて、MongoDBにrootログインする。
   ```
     mongo -u root -p <ADMIN PASSWORD>
   ```
   次のコマンドにて、現在のバージョンが4.4.24であることを確認する。 
   ```
     db.version()
   ```
   次のコマンドにて、feature compatibility versionを4.4にする。
   ```
     db.adminCommand( { setFeatureCompatibilityVersion: "4.4" } )
   ```
   次のコマンドにて、feature compatibility versionが4.4となっていることを確認する。
   ```
     db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
   ```
   次のコマンドにて、mongodb-0 Podからログアウトする
   ```
   exit
   ```

3) 次のコマンドにて、MongoDBバージョンを5.0.18へ手動アップグレードする（作業前のMongoDBバージョンが4.2.5の場合のみ）。
   ```
   kubectl edit sts -n <namespace name>  mongodb
   ```

   mongodb container セクションと bootstrap initcontainer セクションのバージョンを5.0.18に変更する。  
   変更が完了したら、MongoDBのローリングアップデートが始まるはず。  
   ローリングアップデートが完了したのち、次のコマンドにて、mongodb-0 Podにログインする。
   ```
     kubectl exec -it mongodb-0 -n <namespace name> -- bash
   ```
   次のコマンドにて、MongoDBにrootログインする。
   ```
     mongo -u root -p <ADMIN PASSWORD>
   ```
   次のコマンドにて、現在のバージョンが5.0.18であることを確認する。 
   ```
     db.version()
   ```
   次のコマンドにて、feature compatibility versionを5.0にする。
   ```
     db.adminCommand( { setFeatureCompatibilityVersion: "5.0" } )
   ```
   次のコマンドにて、feature compatibility versionが5.0となっていることを確認する。
   ```
     db.adminCommand( { getParameter: 1, featureCompatibilityVersion: 1 } )
   ```
   次のコマンドにて、mongodb-0 Podからログアウトする
   ```
   exit
   ```
 
4) 次のコマンドにて、deploy.yaml の変更を適用する。
   ```
   ./gradlew -Pcluster=<クラスタ名> deployVantiq
   ```

 
5) deployVantiqが成功した後、次の3点を確認する。  
   * Qdrant VectorDB Podが起動すること
   * Vantiq worker Podが起動すること
   * AI Assistant Podが起動すること。(起動に5分～20分程度時間を要する)


6) ネットワークポリシーが機能するかを確認する。  
   AI Assistant podにログインし、次のコマンドを実行する。
   ```
     curl -v http://mongodb-0.vantiq-dev-mongodb.dev.svc.cluster.local:27017
     curl -v https://<YOUR FQDN>/
   ```
   最初のコマンドは失敗し、2番目のコマンドは成功するはず。

 
7) 動作確認として、次のページを参照し、LLM機能が利用できるかを確認する。
   https://github.com/fujitake/vantiq-related/blob/main/vantiq-aiml-integration/docs/jp/LLM_Platform_Support.md