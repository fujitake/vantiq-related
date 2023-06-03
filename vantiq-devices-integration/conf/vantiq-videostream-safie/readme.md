## 資材について

ディレクトリ配下の資材については以下の通りです。
<br>

| 名称 | 種別 | 概要  |
| ---- | ---- | ---- |
| opencv-safie.py | ファイル | 下記処理を行うPythonスクリプトファイル <br>・ HLSによる映像ストリームの取得<br>・ 物体検出アルゴリズムYOLOによる画像解析<br>・ Vantiqへの画像およびJSONデータの送信    |
| requirements.txt | ファイル | Pythonスクリプトファイルの実行に必要なパッケージを記載した設定ファイル  |
| setting.py     | ファイル  | 「opencv-safie.py」で参照するパラメータを記載した設定ファイル  |
| video_stream_sample.zip     | ファイル  | サンプルVantiqプロジェクトファイル<br>※[Vantiq環境準備](../../docs/jp/vantiq-videostream-safie.md#vantiq-環境)にてzipファイル形式のままインポートを行うため、zip展開は不要  |
| files          | フォルダ | Pythonスクリプトで画像を一時保存するための作業用フォルダ  |
| models         | フォルダ | YOLOの学習モデルや設定ファイルを配置  |
<br><br>