# Vantiq LLM と Mattermost のインテグレーションサンプル（機能編）

## 目次

- [Vantiq LLM と Mattermost のインテグレーションサンプル（機能編）](#vantiq-llm-と-mattermost-のインテグレーションサンプル機能編)
  - [目次](#目次)
  - [概要](#概要)
  - [スレッドへの返信](#スレッドへの返信)
    - [VAIL サンプルコード](#vail-サンプルコード)
    - [Request Body のサンプル](#request-body-のサンプル)
  - [Interactive messages](#interactive-messages)
    - [Request Body のサンプル](#request-body-のサンプル-1)
  - [Message attachments](#message-attachments)
    - [Request Body のサンプル](#request-body-のサンプル-2)

## 概要

Mattermost との連携時に活用できる機能を紹介します。  

## スレッドへの返信

スレッドに対して返信するには、別途 `root_id` が必要になります。  
下記のエンドポイントに GET リクエストを行うことで取得できます。  

```shell
/api/v4/posts/{post_id}
```

- :globe_with_meridians: [Mattermost API Reference](https://api.mattermost.com/#tag/posts/operation/GetPost)

この際、 Mattermost の Personal Access Token が必要になります。  
下記のサイトを参考にして、 Personal Access Token を取得してください。  

- :globe_with_meridians: [[Mattermost Integrations] REST API - Zenn](https://zenn.dev/kaakaa/articles/qiita-20201210-9931449346fca68940ab)

### VAIL サンプルコード

```JavaScript
/* post_idからroot_idを取得します。 */
package jp.vantiq.mattermost
import service io.vantiq.text.Template
PROCEDURE Mattermost.getRootId(
    postId String Required Description "post_id"
): String

var ENDPOINT = "/api/v4/posts/${post_id}"
var SOURCE_NAME "jp.vantiq.mattermost.Mattermost"
var TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

var params = {
    post_id: postId
}
var path = Template.format(ENDPOINT, params)
var headers = {
    "Authorization": "Bearer " + TOKEN
    , "Content-type": "application/json"
}
var response = SELECT ONE * FROM SOURCE @SOURCE_NAME WITH path=path, headers=headers

if(response.root_id){
    return response.root_id
}else{
    return postId
}
```

### Request Body のサンプル

```Json
"body": {
    "channel_id": "z4ntcgcen787ue9ho1n4aoisky"
    , "root_id": "ybu9z6dgzpripxbqg7gamwmjeh"
    , "message": "I'm fine, thank you. And you?"
}
```

## Interactive messages

Interactive messages を利用することで、メッセージにボタンやプルダウンリストを付け加える事ができます。  

- :globe_with_meridians: [Interactive messages](https://developers.mattermost.com/integrate/plugins/interactive-messages/)

### Request Body のサンプル

```Json
"body": {
    "channel_id": "z4ntcgcen787ue9ho1n4aoisky"
    , "post_id": "ybu9z6dgzpripxbqg7gamwmjeh"
    , "props": {
        "attachments": [
            {
                "pretext": "ボタンのサンプル"
                , "color": "#ffa500"
                , "title": "カードのタイトル"
                , "actions": [
                    {
                        "id": "id1"
                        , "type": "button"
                        , "name": "Button1"
                        , "integration": {
                            "url": "https://dev.vantiq.com/api/v1/resources/services/jp.vantiq.mattermost.Mattermost/InboundButtonEvent?token=xxxxxx="
                            , "context": {
                                "id": "id1"
                            }
                        }
                        , "style": "primary"
                    }
                    , {
                        "id": "id2"
                        , "type": "button"
                        , "name": "Button2"
                        , "integration": {
                            "url": "https://dev.vantiq.com/api/v1/resources/services/jp.vantiq.mattermost.Mattermost/InboundButtonEvent?token=xxxxxx"
                            , "context": {
                                "id": "id2"
                            }
                        }
                        , "style": "danger"
                    }
                ]
            }
        ]
    }
}
```

`url` には任意のエンドポイントを指定してください。  

ボタンのデザインは `good` `warning` `danger` `default` `primary` `success` から選択できます。  

> **注意**  
> `id` に `-` や `_` が含まれている場合、正しく動作しないので注意してください。  

## Message attachments

Message attachments を利用することで、メッセージの外観に変更を加えることができます。  

### Request Body のサンプル

```JSON
"body": {
    "channel_id": "z4ntcgcen787ue9ho1n4aoisky"
    , "post_id": "ybu9z6dgzpripxbqg7gamwmjeh"
    , "props": {
        "attachments": [
            {
                "pretext": "カード直前のテキスト"
                , "color": "#00fa9a"
                , "title": "カードのタイトル"
                , "text": "カード内に表示したいテキスト（※マークダウンが利用できます。またテキストの量が多い場合は自動的に畳まれます。）"
            }
        ]
    }
}
```
