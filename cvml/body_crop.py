def crop_body(image, landmarks):
    y_shoulder = min(landmarks[11][1], landmarks[12][1])
    y_hip = max(landmarks[23][1], landmarks[24][1])
    y_ankle = max(landmarks[27][1], landmarks[28][1])

    top = image[y_shoulder:y_hip, :]
    bottom = image[y_hip:y_ankle, :]

    return top, bottom
