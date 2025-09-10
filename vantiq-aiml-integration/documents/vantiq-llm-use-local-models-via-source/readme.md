# LLM プライベートモデルの利用

プライベートで構成した LLM(Large Language Model) を Vantiq で利用する手順についての解説となります。

## 前提条件

- OpenAI API 互換の REST エンドポイントが提供されていること
- REST エンドポイントと Vantiq の間においてネットワークの疎通がとれていること

### OpenAI API 互換の REST エンドポイント

OpenAI API 互換の REST エンドポイントを用意する方法はいくつかあります。  
試験環境としては [Qiita記事:自分専用の大規模言語モデルを動作させるAPIサーバを立ててみた](https://qiita.com/vfuji/items/67b95da35704ee440f4c) の手順でも簡単に構成可能です。  
本番環境で利用する場合は、適切な VRAM を有する GPU を持ったサーバを別途用意する方が望ましいと思います。  

### 対象外のモデルについて

OpenAI、Azure OpenAI Service にて提供されるモデルを使う場合は、専用のアクティビティパターンが提供されています。  
利用方法は [こちらの記事](/vantiq-aiml-integration/documents/llm-platform-support/readme.md) をご参照下さい。  
本記事の手順でもご利用頂けますが、専用アクティビティパターンでは最適化が図られており、そちらの利用をオススメします。  

## 手順

### Source を作成

REMOTE Source を作成します。  
Properties の Server URI 設定のみとなります。  
`http://{HOSTNAME or IP}:{PORT NUMBER}` となります。  

エンドポイントが用意されている状態でないと、 Source 作成時にエラーが発生することになりますのでご注意下さい。  

### Procedure を作成

下記は例となります。  
`textgenapi` という Source 名で作成した内容となります。  
`path` は適宜指定して下さい。  
例では `chat/completions` を指定しています。  
[OpenAI API のmaking requestsのドキュメント](https://platform.openai.com/docs/api-reference/making-requests) が参考になります。  

```javascript
var path = "/v1/chat/completions"
var body = {
    "messages": [
      {
        "role": "user",
        "content": "Tell me list of heart disease."
      }
    ]
}
var response = SELECT ONE FROM SOURCE textgenapi WITH body = body, path = path
```

## リソース

上記の Source と Procedure を含む Project のサンプルは [こちらからダウンロード](./conf/sample_use_private_llms.zip) してご利用頂けます。  
