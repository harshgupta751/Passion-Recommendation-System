import cv2
import numpy as np

# -------------------------------
# Helper: resize overlay properly
# -------------------------------
def resize_overlay_keep_ratio(overlay, frame_w, frame_h, scale=0.85):
    oh, ow = overlay.shape[:2]

    # Scale overlay relative to frame height
    target_h = int(frame_h * scale)
    ratio = target_h / oh
    target_w = int(ow * ratio)

    overlay_resized = cv2.resize(
        overlay, (target_w, target_h), interpolation=cv2.INTER_AREA
    )
    return overlay_resized


# -------------------------------
# Helper: center overlay on frame
# -------------------------------
def overlay_center(frame, overlay):
    fh, fw = frame.shape[:2]
    oh, ow = overlay.shape[:2]

    # Center positions
    x_offset = (fw - ow) // 2
    y_offset = (fh - oh) // 2

    # Split channels
    overlay_rgb = overlay[:, :, :3]
    overlay_alpha = overlay[:, :, 3] / 255.0

    # Blend
    for c in range(3):
        frame[y_offset:y_offset+oh, x_offset:x_offset+ow, c] = (
            frame[y_offset:y_offset+oh, x_offset:x_offset+ow, c] * (1 - overlay_alpha)
            + overlay_rgb[:, :, c] * overlay_alpha
        )

    return frame


# -------------------------------
# Main camera loop
# -------------------------------
overlay = cv2.imread("data/overlay.png", cv2.IMREAD_UNCHANGED)
if overlay is None:
    raise FileNotFoundError("overlay.png not found")

cap = cv2.VideoCapture(0)

# Optional: force webcam resolution (prevents weird scaling)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

print("Press C to capture | Q to quit")

while True:
    ret, frame = cap.read()
    if not ret:
        break

    h, w = frame.shape[:2]

    # Resize overlay correctly
    overlay_resized = resize_overlay_keep_ratio(
        overlay, w, h, scale=0.85
    )

    # Apply centered overlay
    frame = overlay_center(frame, overlay_resized)

    cv2.imshow("Align Yourself", frame)

    key = cv2.waitKey(1) & 0xFF
    if key == ord("c"):
        cv2.imwrite("data/captures/user.jpg", frame)
        print("Image captured → data/captures/user.jpg")
        break
    elif key == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()
