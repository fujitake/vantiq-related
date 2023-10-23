# Vision Script on Vantiq Edge 

## Vision Scriptとは
Vantiqに画像をImageリソースとして保存し、その画像に対して顔の検知やグレースケールへの変換、矩形描画などができます。  
実行可能な処理の詳細に関してはリファレンスの`Image Processing Reference Guide > Image Manipulation > Vision Script`を参照してください。   


## Vision Scriptの使い方

### 必要なもの
- Vantiq Edge(Docker)が起動できる環境  
- vantiq-edge-visionコンテナイメージリポジトリへのアクセス権
- Vantiq Edgeアクセストークン
- 顔が映っている画像

Vantiq Edgeの起動方法は[Vantiq Edge のインストール](https://github.com/wata-to/vantiq-related/tree/main/vantiq-edge-operations)を参照してください。 

※Vantiq Edgeの起動に利用するコンテナイメージは`vantiq-edge` ではなく `vantiq-edge-vision`(通常のvantiq-edgeイメージにプラスしてVision Script処理を行うための機能が有効化されたイメージ)を利用するため、Vantiq Edgeの起動に利用しているcompose.yamlのservices.vantiq_edge.imageフィールドのコンテナイメージをvantiq-edge-visionに変更してください。  
イメージタグは[Quay.ioのリポジトリ](https://quay.io/repository/vantiq/vantiq-edge-vision?tab=tags)(要権限)を参照してください。  
※2023/10時点で対応しているVantiqバージョンはr1.37以降となります。本ドキュメントは`vantiq-edge-vision:1.37.1-gpu`の動作を基にしております。    


### Imageリソースへ画像を保存
Vision Scriptの処理で利用する画像をVantiq のAPIを利用しImageリソースへ保存します。  
本ドキュメントではface.jpgという名前の顔が映っている画像を扱う場合の例を記述しております。  

```sh
curl -X POST http://<Your Vantiq Edge IP>/api/v1/resources/images \
-H 'Authorization: Bearer <Your Vantiq Edge Access Token>' \
--form 'name="face"' \
--form 'fileName="face.jpg"' \
--form 'Content-Type="image/jpeg"' \
--form 'image=@/path/to/your/image/face.jpg'
```

※`vantiq-edge-vision:1.37.1-gpu`ではformに指定しているname/fileNameは無視され、画像のファイル名としてVantiqのImageリソースに保存されます。  
そのため、上記で登録したImageは以下のようにface.jpgという名前で登録されます。  

```sh
curl http://<Your Vantiq Edge IP>/api/v1/resources/images -H 'Authorization: Bearer <Your Vantiq Edge Access Token>' 
  {
    "_id": "6535d74a4df238171cf5a694",
    "name": "face.jpg",
    "fileType": "image/jpeg",
    "contentSize": 44004,
    "ars_namespace": "va_test",
    "ars_version": 3,
    "ars_createdAt": "2023-10-23T01:15:38.203Z",
    "ars_createdBy": "test__va_test",
    "ars_modifiedAt": "2023-10-23T01:21:37.321Z",
    "ars_modifiedBy": "test__va_test",
    "content": "/pics/face.jpg"
  }
```

また、保存されたImageはcontentフィールドのパスで見ることができます。  
上記で保存したface.jpgは`http://<Your Vantiq Edge IP>/pics/face/jpg`でアクセスできます。(要アクセストークン)

### Vision Scriptの作成  
Vision Scriptの利用の際には、VisionScriptOperation.processImageに対象のImage名と以下のような構造のオブジェクトを渡すことで実行されます。  
```json
{
    scriptName: "<Name>",
    script: [
        {<Vision Script Action>},
        {<Vision Script Action>},
        ・・・
    ]
}
```

リファレンスにあるサンプルを実行してみます。  
サンプルでは以下の処理を行っています。  
- グレースケールへの変換/保存
- 顔の検出/矩形描画、画像の保存

```
PROCEDURE vsExample(imageName String)

    // Create the script
    var script = { scriptName: "FindingFaces"}
    // Build a convertToGrayscale action
    var convertAction = { name: "convertToGrayscale"}
    // Save that image to an image named gsSave.jpg
    var saveGrayScaleAction = { name: "save"}
    var saveGSParams = { saveName: "gsSave.jpg", fileType: "image/jpeg"}
    saveGrayScaleAction.parameters = saveGSParams

    // Find the faces in the image & draw boxes
    var ffAction = { name: "findFaces", tag: "locateFaces" }

    var drawBoxesAction = { name: "drawBoxes"}

    // Use results from the findFaces action to draw boxes on our image
    var dbParams = { useResultsFrom: "locateFaces"}
    drawBoxesAction.parameters = dbParams

    // Save the resulting image to boxedSave.jpg
    var saveBoxedAction = {name: "save", tag: "boxedSave"}
    var saveBoxedParams = { saveName: "boxedSave.jpg", fileType: "image/jpeg"}
    saveBoxedAction.parameters = saveBoxedParams

    script.script = [convertAction,
                    saveGrayScaleAction,
                    ffAction,
                    drawBoxesAction, 
                    saveBoxedAction]

    var result = VisionScriptOperation.processImage(imageName, script)
    return result
```

IDEから上記Procedureを実行してみます。実行時の引数のimageNameには保存したImageの名前を指定します。(本ドキュメントの場合は`face.jpg`)  

実行すると以下のような結果が返ってきます。  
- locateFaces: 検出された顔の位置
- save: グレースケールに変換したImage
- boxedSave: グレースケールに変換された画像に顔の位置へ矩形描画を追加したImage

```json
{
   "locateFaces": [
      {
         "height": 222,
         "width": 222,
         "x": 62,
         "y": 102
      }
   ],
   "save": {
      "name": "gsSave.jpg",
      "fileType": "image/jpeg",
      "contentSize": 41877,
      "ars_modifiedAt": "2023-10-23T01:56:08.419Z",
      "ars_modifiedBy": "system",
      "content": "/pics/gsSave.jpg"
   },
   "boxedSave": {
      "name": "boxedSave.jpg",
      "fileType": "image/jpeg",
      "contentSize": 43281,
      "ars_modifiedAt": "2023-10-23T01:56:08.419Z",
      "ars_modifiedBy": "system",
      "content": "/pics/boxedSave.jpg"
   }
}
```

保存されたImageを取得すると処理された画像を確認できます。  
以下はcurlコマンドで処理された画像をダウンロードする際の例です。  

```sh
curl http://<Your Vantiq Edge IP>/pics/boxedSave.jpg \
-H 'Authorization: Bearer <Your Vantiq Edge Access Token>' \
-o boxedSave.jpg
```