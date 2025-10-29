import torch
import torch.nn as nn
from torchvision import models, transforms
import torch.serialization
from PIL import Image
import numpy as np
import io, json

# Paths
PT_MODEL_PATH = "../model/tomato_disease_classifier_confidence.pt"
PTH_MODEL_PATH = "../model/tomato_disease_classifier_confidence.pth"
CLASS_PATH = "../model/class_names.json"
TREATMENT_PATH = "../model/treatment_advice.json"

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

# Load class names and treatment advice
with open(CLASS_PATH, "r") as f:
    class_names = json.load(f)

with open(TREATMENT_PATH, "r") as f:
    treatment_advice = json.load(f)

# -------------------------------
# Load both models (TorchScript + PyTorch)
# -------------------------------

# 1️⃣ TorchScript model for normal predictions
model_pt = torch.jit.load(PT_MODEL_PATH, map_location=device)
model_pt.eval()

# 2️⃣ PyTorch model for Grad-CAM
model_pth = models.resnet18(weights=None)
model_pth.fc = nn.Linear(model_pth.fc.in_features, len(class_names))

# Allow NumPy scalar types in trusted environment
import numpy as np
torch.serialization.add_safe_globals([np.core.multiarray.scalar])

# Load full checkpoint (safe because it's your own model)
checkpoint = torch.load(PTH_MODEL_PATH, map_location=device, weights_only=False)
state_dict = checkpoint.get("model_state_dict", checkpoint)
model_pth.load_state_dict(state_dict, strict=False)
model_pth.eval()


# Common transform
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
])

# -------------------------------
# Prediction using TorchScript
# -------------------------------
async def predict_disease(file):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    input_tensor = transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = model_pt(input_tensor)
        probs = torch.nn.functional.softmax(outputs, dim=1)
        conf, pred_class = torch.max(probs, 1)
    
    disease = class_names[pred_class.item()]
    confidence = conf.item()
    advice = treatment_advice.get(disease, {"advice": "No treatment info found"})

    return {
        "disease": disease,
        "confidence": confidence,
        "treatment": advice
    }
