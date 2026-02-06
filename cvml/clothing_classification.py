import tensorflow as tf
import cv2
import numpy as np

model = tf.keras.models.load_model("models/clothing_classifier.h5")

classes = ["tshirt", "shirt", "kurta", "jeans", "trousers"]

def classify(img_path):
    img = cv2.imread(img_path)
    img = cv2.resize(img, (224,224))
    img = img / 255.0
    img = np.expand_dims(img, axis=0)

    pred = model.predict(img)
    return classes[np.argmax(pred)]

topwear = classify("data/crops/top.jpg")
bottomwear = classify("data/crops/bottom.jpg")

print(topwear, bottomwear)
