# LiveStream
rtsp_url = "rtsp://192.168.3.2"
camera_id = "iPhone_1"
interval_sec = 2

# VANTIQ Configurations
ACCESS_TOKEN = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
VANTIQ_TOPIC_URL = 'https://dev.vantiq.co.jp/api/v1/resources/topics//jp.co.vantiq.ws/detected/object'
VANTIQ_UPLOAD_PATH = 'public/detected/object/image/'
VANTIQ_DOCUMENTS_URL = 'https://dev.vantiq.co.jp/api/v1/resources/documents'

# モデルの入力パラメーターを設定する
scale = 1.0 / 255.0     # スケールファクター
size = (416, 416)       # 入力サイズ
mean = (0.0, 0.0, 0.0)  # 差し引かれる平均値
swap = True             # チャンネルの順番（True: RGB、False: BGR）
crop = True            # クロップ

