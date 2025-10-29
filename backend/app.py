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
    """Performs Grad-CAM visualization and severity staging ONLY
    Uses prediction from analyze endpoint for consistency"""
    
    # First get the prediction from analyze endpoint
    analysis_result = await predict_disease(file)
    predicted_disease = analysis_result["disease"]
    confidence = analysis_result["confidence"]
    
    # Find the class index for the predicted disease
    try:
        pred_class_index = class_names.index(predicted_disease)
    except ValueError:
        return JSONResponse(
            status_code=400,
            content={"error": f"Predicted disease '{predicted_disease}' not found in class names"}
        )
    
    # Reset file pointer and read image for Grad-CAM
    await file.seek(0)
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_tensor = transform(image).unsqueeze(0)

    # Generate Grad-CAM heatmap and severity analysis
    cam, severity, heatmap_path = generate_gradcam(model_pth, image_tensor, pred_class_index, image)

    # Convert file path to public URL
    heatmap_url = f"http://127.0.0.1:8000/static/{os.path.basename(heatmap_path)}"

    return JSONResponse(content={
        "predicted_class": predicted_disease,
        "severity": severity,
        "heatmap_url": heatmap_url,
        "confidence": confidence,
        "message": "Severity analysis completed successfully"
    })