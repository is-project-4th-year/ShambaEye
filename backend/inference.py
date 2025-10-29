# inference.py (relevant parts)
import torch, torch.nn as nn
from torchvision import models, transforms
from PIL import Image
import io, json

PT_MODEL_PATH = "../model/tomato_disease_classifier_confidence.pt"
PTH_MODEL_PATH = "../model/tomato_disease_classifier_confidence.pth"  # checkpoint you saved earlier
CLASS_PATH = "../model/class_names.json"
TREATMENT_PATH = "../model/treatment_advice.json"

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

with open(CLASS_PATH, "r") as f:
    class_names = json.load(f)
with open(TREATMENT_PATH, "r") as f:
    treatment_advice = json.load(f)

# TorchScript model for normal predictions (used by /analyze/)
model_pt = torch.jit.load(PT_MODEL_PATH, map_location=device)
model_pt.eval()

# Eager model (same architecture) for Grad-CAM hooks
model_pth = models.resnet18(weights=None)
model_pth.fc = nn.Linear(model_pth.fc.in_features, len(class_names))

# load checkpoint properly
checkpoint = torch.load(PTH_MODEL_PATH, map_location=device)
if 'model_state_dict' in checkpoint:
    state = checkpoint['model_state_dict']
else:
    state = checkpoint  # fallback if you saved raw state_dict

model_pth.load_state_dict(state)
model_pth.to(device)
model_pth.eval()

# shared transform (use this in both endpoints)
transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize([0.485,0.456,0.406],[0.229,0.224,0.225])
])
