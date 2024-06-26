import cv2
import time
import math
import numpy as np
import os
import setting
import requests
import uuid
import time, datetime
import json

# RTSP video stream URL
url = setting.rtsp_url

# process frame per seocnd. discard other frames. 
interval_sec = setting.interval_sec
camera_id = setting.camera_id

# VANTIQ Configurations
ACCESS_TOKEN = "Bearer " + setting.ACCESS_TOKEN
VANTIQ_TOPIC_URL = setting.VANTIQ_TOPIC_URL
VANTIQ_UPLOAD_PATH = setting.VANTIQ_UPLOAD_PATH
VANTIQ_DOCUMENTS_URL = setting.VANTIQ_DOCUMENTS_URL

# ファイルからクラスの名前のリストを読み込む関数
def read_classes(file):
    classes = None
    with open(file, mode='r', encoding="utf-8") as f:
        classes = f.read().splitlines()
    return classes


# クラスの数だけカラーテーブルを生成する関数
def get_colors(num):
    colors = []
    np.random.seed(0)
    for i in range(num):
        color = np.random.randint(0, 256, [3]).astype(np.uint8)
        colors.append(color.tolist())
    return colors

# モデルを読み込む
def load_model():
    directory = os.path.join(os.path.dirname(__file__), "models")
    print(f'directory:{directory}')
    # モデルを読み込む
    weights = os.path.join(directory, "yolov4-tiny.weights")
    config = os.path.join(directory, "yolov4-tiny.cfg")
    model = cv2.dnn_DetectionModel(weights, config)

    # モデルの推論に使用するエンジンとデバイスを設定する
    model.setPreferableBackend(cv2.dnn.DNN_BACKEND_OPENCV)
    model.setPreferableTarget(cv2.dnn.DNN_TARGET_CPU)

    # モデルの入力パラメーターを設定する
    scale = setting.scale     # スケールファクター
    size = setting.size       # 入力サイズ
    mean = setting.mean  # 差し引かれる平均値
    swap = setting.swap             # チャンネルの順番（True: RGB、False: BGR）
    crop = setting.crop            # クロップ
    model.setInputParams(scale, size, mean, swap, crop)

    # NMS（Non-Maximum Suppression）をクラスごとに処理する
    model.setNmsAcrossClasses(False)  # （True: 全体、False: クラスごと）

    # クラスリストとカラーテーブルを取得する
    names = os.path.join(directory, "coco.names")
    classes = read_classes(names)
    colors = get_colors(len(classes))

    print (f'model:{model}, classes:{classes}, colors:{colors}')
    return model, colors, classes

# 画像をアップロード
def post_file_to_vantiq(img, file_name):
    cv2.imwrite(file_name, img)
    headers = {
        'Authorization': ACCESS_TOKEN
    }
    with open(file_name, 'rb') as f:
        file = {
            'file': (VANTIQ_UPLOAD_PATH + os.path.basename(file_name), f)
        }
        response_file = requests.post(VANTIQ_DOCUMENTS_URL, headers=headers, files=file)
    print('----upload image to ' + VANTIQ_UPLOAD_PATH + '----')
    print(datetime.datetime.fromtimestamp(time.time()).strftime('%Y/%m/%d %H:%M:%S'))
    os.remove(file_name)

# jsonをアップロード
def post_json_to_vantiq(object_name, class_id, confidence, box, file_name):
    headers = {
        'Authorization': ACCESS_TOKEN,
        'content-type': 'application/json'
    }
    data = {}
    data['object_name'] = object_name
    data['object_id'] = str(class_id)
    data['confidence'] = float(confidence)
    data['bounding_box'] = [int(i) for i in box]
    data['file_URI'] = VANTIQ_UPLOAD_PATH + os.path.basename(file_name)
    data['camera_id'] = camera_id
    response_topic = requests.post(VANTIQ_TOPIC_URL, headers=headers, data=json.dumps(data))

def main():
    # Initialize OpenCV capture object
    cap = cv2.VideoCapture(url)
    fps = math.floor(cap.get(cv2.CAP_PROP_FPS))
    width = cap.get(cv2.CAP_PROP_FRAME_WIDTH)
    height = cap.get(cv2.CAP_PROP_FRAME_HEIGHT)
    fps = cap.get(cv2.CAP_PROP_FPS)
    print(f'fps:{fps}　width:{width}　height:{height}')

    # fps may need to be manually configured
    fps = 5
    frame_count = 0

    # load yolo4 model
    model, colors, classes = load_model()


    # Loop over video frames every x seconds
    while True:
        # Wait x seconds before capturing the next frame
        # time.sleep(1)

        # Read a frame from the video stream
        ret, frame = cap.read()

        # Check if frame was successfully read
        if not ret:
            print('Error reading frame')
            continue

        # discard frames until the target frame
        # print(f'processing: {frame_count}, ret:{ret}')
        frame_count += 1
        if frame_count < interval_sec * fps:
            continue
        else:
            frame_count = 0

        
        ## process for yolo4
        # 画像が3チャンネル以外の場合は3チャンネルに変換する
        channels = 1 if len(frame.shape) == 2 else frame.shape[2]
        if channels == 1:
            frame = cv2.cvtColor(frame, cv2.COLOR_GRAY2BGR)
        if channels == 4:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGRA2BGR)

        # オブジェクトを検出する
        confidence_threshold = 0.5
        nms_threshold = 0.4
        class_ids, confidences, boxes = model.detect(frame, confidence_threshold, nms_threshold)

        # 画像ファイル名付与
        file_name = os.path.join(os.path.dirname(__file__), 'files', '{}.jpg'.format(str(uuid.uuid4())))

        # 2次元配列(n, 1)から1次元配列(n, )に変換
        class_ids = np.array(class_ids).flatten()
        confidences = np.array(confidences).flatten()

        # 検出されたオブジェクトを描画する
        for class_id, confidence, box in zip(class_ids, confidences, boxes):
            class_name = classes[class_id]
            color = colors[class_id]
            thickness = 2
            cv2.rectangle(frame, box, color, thickness, cv2.LINE_AA)

            result = "{0} ({1:.3f})".format(class_name, confidence)
            point = (box[0], box[1] - 5)
            font = cv2.FONT_HERSHEY_SIMPLEX
            scale = 0.5
            cv2.putText(frame, result, point, font, scale, color, thickness, cv2.LINE_AA)

            # Vantiqへ画像アップロード
            post_file_to_vantiq(frame, file_name)

            # 検出されたオブジェクトの情報を連携
            post_json_to_vantiq(class_name, class_id, confidence, box, file_name)

        # Display the frame in a window
        cv2.imshow('Frame', frame)

        # Wait for a key press
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    # Release resources
    cap.release()
    cv2.destroyAllWindows()


if __name__ == '__main__':
    main()
