import cv2
import numpy as np
from sklearn.cluster import KMeans


def dominant_color(image_path, k=3):

    img = cv2.imread(image_path)

    if img is None:
        raise ValueError(f"Image not found: {image_path}")

    img = cv2.resize(img, (100, 100))
    img = img.reshape((-1, 3))

    kmeans = KMeans(n_clusters=k, n_init=10)
    kmeans.fit(img)

    colors = kmeans.cluster_centers_
    counts = np.bincount(kmeans.labels_)

    dominant = colors[np.argmax(counts)]

    return dominant.astype(int)


def rgb_to_color_name(rgb):

    r, g, b = rgb

    if r > 200 and g > 200 and b > 200:
        return "white"
    elif r < 50 and g < 50 and b < 50:
        return "black"
    elif r > 150 and g < 100 and b < 100:
        return "red"
    elif r < 100 and g > 150 and b < 100:
        return "green"
    elif r < 100 and g < 100 and b > 150:
        return "blue"
    else:
        return "unknown"
