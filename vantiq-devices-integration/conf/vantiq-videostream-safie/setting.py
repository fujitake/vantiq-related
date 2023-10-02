# LiveStream
safie_api_key = "<your_safie_api_key>   # ex. "35de026644abd01bxxxxxxxxxxcafe82f800"
safie_device_id = "<your_safie_device_id>"  # ex. "6Ywr0GBVHZxxxxxxxxxx"
camera_id = "<your_camera_id>"    # ex. "One (SF-1)"
interval_sec = 2

# VANTIQ Configurations
ACCESS_TOKEN = "<your_vantiq_access_token>"
VANTIQ_TOPIC_URL = "<your_vantiq_server>/api/v1/resources/topics//jp.co.vantiq.ws/detected/object"
VANTIQ_UPLOAD_PATH = "public/detected/object/image/"
VANTIQ_DOCUMENTS_URL = "<your_vantiq_server>/api/v1/resources/documents"

# モデルの入力パラメーターを設定する
scale = 1.0 / 255.0     # スケールファクター
size = (416, 416)       # 入力サイズ
mean = (0.0, 0.0, 0.0)  # 差し引かれる平均値
swap = True             # チャンネルの順番（True: RGB、False: BGR）
crop = True            # クロップ

