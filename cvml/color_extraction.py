import cv2
import numpy as np
from sklearn.cluster import KMeans

def dominant_color(img_path):
    img = cv2.imread(img_path)
    img = cv2.resize(img, (100,100))
    img = img.reshape((-1,3))

    kmeans = KMeans(n_clusters=1)
    kmeans.fit(img)

    return kmeans.cluster_centers_[0]

top_color = dominant_color("data/crops/top.jpg")
print(top_color)
