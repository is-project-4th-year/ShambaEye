import torch
import cv2
import numpy as np
import os
import uuid

def generate_gradcam(model, image_tensor, target_class, orig_image):
    """
    Generate Grad-CAM heatmap for the given image and target class
    """
    # Set model to eval mode and ensure requires_grad
    model.eval()
    
    gradients = []
    activations = []

    def save_activation(module, input, output):
        activations.append(output.detach())

    def save_gradient(module, grad_input, grad_output):
        gradients.append(grad_output[0].detach())

    # Get the last convolutional layer of ResNet
    target_layer = None
    if hasattr(model, 'layer4'):  # For ResNet
        target_layer = model.layer4[-1].conv2
    elif hasattr(model, 'features'):  # For other architectures
        target_layer = model.features[-1]
    else:
        # Fallback: get the last conv layer
        for module in model.modules():
            if isinstance(module, torch.nn.Conv2d):
                target_layer = module
        
    if target_layer is None:
        raise ValueError("Could not find convolutional layer for Grad-CAM")

    # Register hooks
    handle_fwd = target_layer.register_forward_hook(save_activation)
    handle_bwd = target_layer.register_full_backward_hook(save_gradient)

    try:
        # Ensure image tensor requires gradients
        image_tensor = image_tensor.clone().detach().requires_grad_(True)
        
        # Forward pass
        model.zero_grad()
        output = model(image_tensor)
        
        # Backward pass for target class
        one_hot = torch.zeros_like(output)
        one_hot[0, target_class] = 1.0
        
        # Compute gradients
        output.backward(gradient=one_hot, retain_graph=True)

        # Process gradients and activations
        if len(gradients) == 0 or len(activations) == 0:
            raise ValueError("No gradients or activations captured")

        grads = gradients[0].cpu().numpy()[0]
        acts = activations[0].cpu().numpy()[0]

        # Global average pooling of gradients
        weights = np.mean(grads, axis=(1, 2))
        
        # Create CAM
        cam = np.zeros(acts.shape[1:], dtype=np.float32)
        for i, w in enumerate(weights):
            cam += w * acts[i, :, :]

        # Apply ReLU and normalize
        cam = np.maximum(cam, 0)
        cam = cv2.resize(cam, (224, 224))
        if cam.max() > 0:
            cam = cam / cam.max()

        # 🔥 Compute severity based on CAM intensity
        if cam.max() > 0:
            avg_intensity = cam.mean()
            if avg_intensity < 0.2:
                severity = "Mild"
            elif avg_intensity < 0.5:
                severity = "Moderate"
            else:
                severity = "Severe"
        else:
            severity = "Mild"  # No activation detected

        # ✅ Prepare original image and heatmap
        orig_cv = np.array(orig_image)
        orig_cv = cv2.cvtColor(orig_cv, cv2.COLOR_RGB2BGR)
        orig_cv = cv2.resize(orig_cv, (224, 224))

        # Create heatmap
        if cam.max() > 0:
            cam_uint8 = np.uint8(255 * cam)
            heatmap = cv2.applyColorMap(cam_uint8, cv2.COLORMAP_JET)
            # Blend with original image
            overlay = cv2.addWeighted(orig_cv, 0.6, heatmap, 0.4, 0)
        else:
            overlay = orig_cv  # Fallback if no CAM

        # ✅ Save to static folder
        os.makedirs("static", exist_ok=True)
        heatmap_filename = f"heatmap_{uuid.uuid4().hex[:8]}.jpg"
        heatmap_path = os.path.join("static", heatmap_filename)
        cv2.imwrite(heatmap_path, overlay)

        return cam, severity, heatmap_path

    finally:
        # Always remove hooks
        handle_fwd.remove()
        handle_bwd.remove()