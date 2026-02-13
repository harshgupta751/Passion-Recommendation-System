import cv2
import os
from pose_detection import get_pose_landmarks
from body_crop import crop_body
from clothing_classification import classify
from color_extraction import dominant_color, rgb_to_color_name
from recommender import recommend


def run_pipeline(image_path):
    # Load input image
    image = cv2.imread(image_path)
    if image is None:
        raise ValueError("Image not found")

    # Detect human pose
    landmarks = get_pose_landmarks(image)
    if landmarks is None:
        return {
            "status": "fail",
            "message": "Pose not detected. Please align properly."
        }

    # Split image into top and bottom regions
    top_img, bottom_img = crop_body(image, landmarks)

    cv2.imwrite("data/crops/top.jpg", top_img)
    cv2.imwrite("data/crops/bottom.jpg", bottom_img)

    # Identify clothing type
    topwear = classify("data/crops/top.jpg")
    bottomwear = classify("data/crops/bottom.jpg")

    # Extract dominant color from topwear
    top_rgb = dominant_color("data/crops/top.jpg")
    top_color = rgb_to_color_name(top_rgb)

    # Generate outfit recommendation
    suggestions = recommend(topwear, top_color)

    # Prepare final output
    result = {
        "status": "success",
        "detected": {
            "topwear": topwear,
            "bottomwear": bottomwear,
            "top_color": top_color
        },
        "recommendation": {
            "type": "bottomwear",
            "items": suggestions
        }
    }

    return result


if __name__ == "__main__":
    output = run_pipeline("data/captures/user.jpg")
    print(output)
