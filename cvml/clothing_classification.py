import os
import cv2
import numpy as np
import tensorflow as tf

MODEL_PATH = "models/clothing_classifier.h5"
IMG_SIZE = (224, 224)

CLASSES = ['jeans', 'kurta', 'shirt', 'tshirt', 'trousers']
# Replace with your actual class order


if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model not found at {MODEL_PATH}")

model = tf.keras.models.load_model(MODEL_PATH)

def classify(img_path: str) -> str:
    """
    Takes image path → returns predicted clothing label
    """

    if not os.path.exists(img_path):
        raise FileNotFoundError(f"Image not found: {img_path}")

    img = cv2.imread(img_path)

    if img is None:
        raise ValueError(f"Failed to load image: {img_path}")

    # Resize
    img = cv2.resize(img, IMG_SIZE)

    # Normalize
    img = img / 255.0

    # Expand dims → (1, 224, 224, 3)
    img = np.expand_dims(img, axis=0)

    # Predict
    preds = model.predict(img, verbose=0)

    class_index = np.argmax(preds)
    label = CLASSES[class_index]

    return label
