from fastapi import FastAPI, UploadFile, File
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from inference import predict_disease, model_pth, class_names, transform
from gradcam_utils import generate_gradcam
import torch
from PIL import Image
import io
import os

app = FastAPI(title="ShambaEye Backend")

# Serve static files (for heatmaps)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/")
def root():
    return {"message": "🌿 ShambaEye Backend running successfully"}

@app.post("/analyze/")
async def analyze_image(file: UploadFile = File(...)):
    """Quick classification using TorchScript model"""
    result = await predict_disease(file)
    return JSONResponse(content=result)

@app.post("/severity/")
async def analyze_severity(file: UploadFile = File(...)):
    """Performs Grad-CAM visualization and severity staging"""
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_tensor = transform(image).unsqueeze(0)

    with torch.no_grad():
        outputs = model_pth(image_tensor)
        pred_class = torch.argmax(outputs, dim=1).item()

    cam, severity, heatmap_path = generate_gradcam(model_pth, image_tensor, pred_class, image)

    # Convert file path to public URL
    heatmap_url = f"http://127.0.0.1:8000/{heatmap_path}"

    return JSONResponse(content={
        "predicted_class": class_names[pred_class],
        "severity": severity,
        "heatmap_url": heatmap_url,
        "message": "Severity analysis completed successfully"
    })
