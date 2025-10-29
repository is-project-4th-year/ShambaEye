import torch
import cv2
import numpy as np
import os
import uuid

def generate_gradcam(model, image_tensor, target_class, orig_image):
    gradients = []
    activations = []

    def save_activation(module, input, output):
        activations.append(output)
    def save_gradient(module, grad_input, grad_output):
        gradients.append(grad_output[0])

    # Pick last convolutional layer
    target_layer = list(model.children())[-2]
    handle_fwd = target_layer.register_forward_hook(save_activation)
    handle_bwd = target_layer.register_full_backward_hook(save_gradient)

    model.zero_grad()
    output = model(image_tensor)
    class_score = output[0, target_class]
    class_score.backward()

    grads = gradients[0].cpu().data.numpy()[0]
    acts = activations[0].cpu().data.numpy()[0]

    weights = np.mean(grads, axis=(1, 2))
    cam = np.zeros(acts.shape[1:], dtype=np.float32)

    for i, w in enumerate(weights):
        cam += w * acts[i, :, :]

    cam = np.maximum(cam, 0)
    cam = cv2.resize(cam, (224, 224))
    cam = cam / cam.max()

    # Clean up hooks
    handle_fwd.remove()
    handle_bwd.remove()

    # 🔥 Compute severity
    avg_intensity = cam.mean()
    if avg_intensity < 0.33:
        severity = "Mild"
    elif avg_intensity < 0.66:
        severity = "Moderate"
    else:
        severity = "Severe"

    # ✅ Convert both to same size and overlay Grad-CAM
    orig_cv = np.array(orig_image)
    orig_cv = cv2.cvtColor(orig_cv, cv2.COLOR_RGB2BGR)
    orig_cv = cv2.resize(orig_cv, (224, 224))  # <-- fix: match sizes

    cam_colored = cv2.applyColorMap(np.uint8(255 * cam), cv2.COLORMAP_JET)
    overlay = cv2.addWeighted(orig_cv, 0.5, cam_colored, 0.5, 0)

    # ✅ Save to static folder
    os.makedirs("static", exist_ok=True)
    heatmap_filename = f"heatmap_{uuid.uuid4().hex[:8]}.jpg"
    heatmap_path = os.path.join("static", heatmap_filename)
    cv2.imwrite(heatmap_path, overlay)

    return cam, severity, heatmap_path
