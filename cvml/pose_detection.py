import cv2
import mediapipe as mp

mp_pose = mp.solutions.pose
pose = mp_pose.Pose(static_image_mode=True)

def get_pose_landmarks(image):
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = pose.process(rgb)

    if not results.pose_landmarks:
        return None

    landmarks = {}
    h, w, _ = image.shape

    for idx, lm in enumerate(results.pose_landmarks.landmark):
        landmarks[idx] = (int(lm.x * w), int(lm.y * h))

    return landmarks
