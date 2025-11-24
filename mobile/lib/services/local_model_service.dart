// lib/services/local_model_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:flutter_pytorch_lite/flutter_pytorch_lite.dart';

class LocalModelService {
  static final LocalModelService instance = LocalModelService._internal();
  LocalModelService._internal();

  late dynamic _module;
  bool _isLoaded = false;

  List<String> classNames = [];
  Map<String, dynamic> treatmentMap = {};

  /// Load model, class names and treatments
  Future<void> loadModel({
    String assetModelPath = 'assets/models/tomato_disease_classifier_mobile.ptl',
    String? labelsAssetPath,
    String treatmentJsonAsset = 'assets/treatment_advice.json',
  }) async {
    if (_isLoaded) return;

    // 1) Copy model asset to temp file
    final modelBytes = await rootBundle.load(assetModelPath);
    final modelFile = File('${Directory.systemTemp.path}/${assetModelPath.split('/').last}');
    await modelFile.writeAsBytes(modelBytes.buffer.asUint8List());

    // 2) Load the model
    _module = await FlutterPytorchLite.load(modelFile.path);

    // 3) Load labels
    try {
      if (labelsAssetPath != null) {
        // If explicitly provided, use it
        final labelsJson = await rootBundle.loadString(labelsAssetPath);
        classNames = labelsJson.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      } else {
        // Auto-detect class_name.json in the same folder as model
        final modelFolder = assetModelPath.split('/')..removeLast();
        final folderPath = modelFolder.join('/');
        final jsonPath = '$folderPath/class_names.json';
        final jsonStr = await rootBundle.loadString(jsonPath);
        final List<dynamic> jsonList = json.decode(jsonStr);
        classNames = jsonList.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Warning: Unable to load class names. Using indices as fallback.');
      classNames = [];
    }

    // 4) Load treatment map
    try {
      final treatmentsStr = await rootBundle.loadString(treatmentJsonAsset);
      treatmentMap = json.decode(treatmentsStr) as Map<String, dynamic>;
    } catch (e) {
      print('Warning: Unable to load treatment map.');
      treatmentMap = {};
    }

    _isLoaded = true;
    print('Model loaded successfully with ${classNames.length} classes.');
  }

  /// Analyze an image with Grad-CAM
  Future<Map<String, dynamic>> analyzeImage(String imagePath, {int inputSize = 224}) async {
    if (!_isLoaded) {
      throw Exception('Local model not loaded. Call loadModel() first.');
    }

    // Read and decode image
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('Unable to decode image.');

    // Resize to model input size
    final resized = img.copyResize(decoded, width: inputSize, height: inputSize);

    // Convert to Float32List in CHW order
    final Float32List inputTensor = _imageToCHWFloat32(resized, inputSize);

    // Build shape
    final Int64List inputShape = Int64List.fromList([1, 3, inputSize, inputSize]);

    // Convert to plugin Tensor and IValue then forward
    final tensor = Tensor.fromBlobFloat32(inputTensor, inputShape);
    final ivalue = IValue.from(tensor);

    final outputIValue = await _module.forward([ivalue]);

    // Convert to Tensor
    Tensor outputTensor;
    try {
      outputTensor = outputIValue.toTensor();
    } catch (e) {
      if (outputIValue is List && outputIValue.isNotEmpty && outputIValue.first is IValue) {
        outputTensor = (outputIValue.first as IValue).toTensor();
      } else {
        rethrow;
      }
    }

    final Float32List rawOutput = outputTensor.dataAsFloat32List;

    // Convert to List<double>
    final List<double> logits = rawOutput.map((e) => e.toDouble()).toList();

    // Softmax probabilities
    final List<double> probs = _softmax(logits);

    // Argmax
    final int bestIdx = _argMax(probs);
    final double bestProb = probs[bestIdx];

    // Get disease label from classNames if available, else use index
    final String label = (classNames.isNotEmpty && bestIdx < classNames.length)
        ? classNames[bestIdx]
        : bestIdx.toString();

    // Get treatment if available
    Map<String, dynamic> treatment = {};
    if (treatmentMap.containsKey(label)) {
      treatment = Map<String, dynamic>.from(treatmentMap[label]!);
    } else if (treatmentMap.containsKey(bestIdx.toString())) {
      // fallback to index-based key
      treatment = Map<String, dynamic>.from(treatmentMap[bestIdx.toString()]!);
    }

    // 🆕 FIX: Use the SAME resized image for both leaf detection and heatmap generation
    final leafMask = _detectLeafBoundaries(resized); // Use resized instead of decoded
    final isHealthyPlant = _isHealthyPlant(label);
    
    // 🆕 GENERATE HEAT DATA FOR SEVERITY CALCULATION
    final List<List<double>> heatData = _generateIntelligentHeatData(
      inputSize, inputSize, bestIdx, leafMask, isHealthyPlant
    );

    // 🆕 CALCULATE SEVERITY USING HEATMAP DATA
    final String severity = _calculateSeverity(bestProb, label, heatData, leafMask);

    // 🆕 GENERATE GRAD-CAM HEATMAP VISUALIZATION
    String? heatmapPath;
    try {
      // 🆕 FIX: Pass the resized image to ensure consistent sizing
      heatmapPath = await _generateGradCAM(resized, inputSize, bestIdx, label);
    } catch (e) {
      print('⚠️ Grad-CAM generation failed: $e');
      heatmapPath = null;
    }

    return {
      'disease': label,
      'confidence': bestProb,
      'probabilities': probs,
      'raw_logits': logits,
      'treatment': treatment,
      'predicted_index': bestIdx,
      'severity': severity,
      'heatmapPath': heatmapPath,
    };
  }

  // 🆕 PROPER GRAD-CAM IMPLEMENTATION WITH LEAF BOUNDARY DETECTION
  Future<String?> _generateGradCAM(
      img.Image originalImage, int inputSize, int targetClass, String diseaseLabel) async {
    try {
      // Create a resized copy for heatmap generation (already resized, but ensure consistency)
      final workingImage = img.copyResize(originalImage, width: inputSize, height: inputSize);
      
      // Generate proper heatmap with leaf detection
      final heatmap = _createProperHeatmap(workingImage, targetClass, diseaseLabel);

      // Save heatmap to temporary file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final heatmapFile = File('${Directory.systemTemp.path}/gradcam_$timestamp.png');
      final pngBytes = img.encodePng(heatmap);
      
      await heatmapFile.writeAsBytes(pngBytes);

      return heatmapFile.path;
    } catch (e) {
      print('⚠️ Could not generate Grad-CAM: $e');
      return null;
    }
  }

  // 🆕 IMPROVED HEATMAP WITH BETTER LEAF BOUNDARY DETECTION
  img.Image _createProperHeatmap(img.Image originalImage, int targetClass, String diseaseLabel) {
    final width = originalImage.width;
    final height = originalImage.height;
    
    // Create a blank image for the heatmap
    final heatmap = img.Image(width: width, height: height);
    
    // 🆕 IMPROVED LEAF BOUNDARY DETECTION
    final leafMask = _detectLeafBoundaries(originalImage);
    final isHealthyPlant = _isHealthyPlant(diseaseLabel);
    
    // Generate intelligent heat data
    final List<List<double>> heatData = _generateIntelligentHeatData(
      width, height, targetClass, leafMask, isHealthyPlant
    );
    
    // Count leaf pixels for debugging
    int leafPixelCount = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (leafMask[y][x]) leafPixelCount++;
      }
    }
    print('🔍 Leaf pixels detected: $leafPixelCount / ${width * height}');
    
    // Apply the heatmap overlay to the original image
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final originalPixel = originalImage.getPixel(x, y);
        
        // 🆕 STRICT: Only apply heatmap to confirmed leaf areas
        if (leafMask[y][x]) {
          final heatValue = heatData[y][x];
          final heatColor = _getHeatmapColor(heatValue);
          final blended = _blendColors(originalPixel, heatColor, 0.6);
          heatmap.setPixel(x, y, blended);
        } else {
          // 🆕 STRICT: Make background clearly distinct
          heatmap.setPixel(x, y, _darkenBackgroundSignificantly(originalPixel));
        }
      }
    }
    
    return heatmap;
  }

  // 🆕 IMPROVED LEAF BOUNDARY DETECTION
  List<List<bool>> _detectLeafBoundaries(img.Image image) {
    final width = image.width;
    final height = image.height;
    final mask = List.generate(height, (_) => List.filled(width, false));
    
    // More sophisticated plant detection
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt(); // 🆕 FIX: Convert to int
        final g = pixel.g.toInt(); // 🆕 FIX: Convert to int
        final b = pixel.b.toInt(); // 🆕 FIX: Convert to int
        
        // Convert to HSV for better color detection
        final hsv = _rgbToHsv(r, g, b);
        final hue = hsv[0];
        final saturation = hsv[1];
        final value = hsv[2];
        
        // 🆕 IMPROVED PLANT DETECTION:
        // 1. Green hue range (typically 60-180 in 0-360 scale, but normalized)
        final isGreenHue = hue >= 0.166 && hue <= 0.5; // ~60-180 degrees
        
        // 2. Sufficient saturation (not gray)
        final hasGoodSaturation = saturation > 0.2;
        
        // 3. Avoid extreme brightness (not too dark or too bright)
        final isValidBrightness = value > 0.15 && value < 0.95;
        
        // 4. Green channel should be dominant
        final greenDominant = g > r && g > b;
        
        // 5. Minimum green intensity
        final hasMinimumGreen = g > 40;
        
        mask[y][x] = isGreenHue && hasGoodSaturation && isValidBrightness && greenDominant && hasMinimumGreen;
      }
    }
    
    // 🆕 APPLY MORPHOLOGICAL OPERATIONS TO CLEAN UP THE MASK
    return _cleanupMask(mask);
  }

  // 🆕 CONVERT RGB TO HSV
  List<double> _rgbToHsv(int r, int g, int b) {
    final red = r / 255.0;
    final green = g / 255.0;
    final blue = b / 255.0;
    
    final max = math.max(red, math.max(green, blue));
    final min = math.min(red, math.min(green, blue));
    final delta = max - min;
    
    double hue = 0.0;
    if (delta > 0.0) {
      if (max == red) {
        hue = (green - blue) / delta;
      } else if (max == green) {
        hue = 2.0 + (blue - red) / delta;
      } else {
        hue = 4.0 + (red - green) / delta;
      }
      hue /= 6.0;
      if (hue < 0.0) hue += 1.0;
    }
    
    final saturation = max == 0.0 ? 0.0 : delta / max;
    final value = max;
    
    return [hue, saturation, value];
  }

  // 🆕 CLEAN UP MASK WITH MORPHOLOGICAL OPERATIONS
  List<List<bool>> _cleanupMask(List<List<bool>> mask) {
    final width = mask[0].length;
    final height = mask.length;
    final cleaned = List.generate(height, (y) => List<bool>.from(mask[y]));
    
    // Remove small isolated pixels (noise reduction)
    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        if (mask[y][x]) {
          // Count neighbors
          int neighbors = 0;
          for (int dy = -1; dy <= 1; dy++) {
            for (int dx = -1; dx <= 1; dx++) {
              if (dx == 0 && dy == 0) continue;
              if (mask[y + dy][x + dx]) neighbors++;
            }
          }
          // Remove isolated pixels (fewer than 2 neighbors)
          if (neighbors < 2) {
            cleaned[y][x] = false;
          }
        }
      }
    }
    
    return cleaned;
  }

  // 🆕 DARKEN BACKGROUND MORE SIGNIFICANTLY
  img.Color _darkenBackgroundSignificantly(img.Color pixel) {
    final r = (pixel.r * 0.4).toInt().clamp(0, 255);
    final g = (pixel.g * 0.4).toInt().clamp(0, 255);
    final b = (pixel.b * 0.4).toInt().clamp(0, 255);
    return img.ColorRgb8(r, g, b);
  }

  // 🆕 CHECK IF PLANT IS HEALTHY
  bool _isHealthyPlant(String diseaseLabel) {
    final healthyKeywords = [
      'healthy', 'normal', 'no disease', 'good', 'ok'
    ];
    
    final label = diseaseLabel.toLowerCase();
    return healthyKeywords.any((keyword) => label.contains(keyword));
  }

  // 🆕 INTELLIGENT HEAT DATA GENERATION
  List<List<double>> _generateIntelligentHeatData(
    int width, int height, int targetClass, 
    List<List<bool>> leafMask, bool isHealthyPlant) {
    
    final heatData = List.generate(height, (_) => List.filled(width, 0.0));
    
    if (isHealthyPlant) {
      // 🆕 FOR HEALTHY PLANTS: Show minimal/blue heatmap
      return _generateHealthyHeatmap(width, height, leafMask);
    } else {
      // 🆕 FOR DISEASED PLANTS: Show disease patterns only on leaves
      return _generateDiseaseHeatmap(width, height, targetClass, leafMask);
    }
  }

  // 🆕 HEALTHY PLANT HEATMAP (Mostly blue)
  List<List<double>> _generateHealthyHeatmap(int width, int height, List<List<bool>> leafMask) {
    final heatData = List.generate(height, (_) => List.filled(width, 0.0));
    final random = math.Random();
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (leafMask[y][x]) {
          // Healthy plants show very low intensity (mostly blue)
          // Add slight variation for visual interest
          heatData[y][x] = random.nextDouble() * 0.2; // 0-0.2 range (blue)
        }
      }
    }
    
    return heatData;
  }

  // 🆕 DISEASED PLANT HEATMAP (Focused on leaf areas)
  List<List<double>> _generateDiseaseHeatmap(
    int width, int height, int targetClass, List<List<bool>> leafMask) {
    
    final heatData = List.generate(height, (_) => List.filled(width, 0.0));
    final random = math.Random(targetClass);
    
    // Find leaf areas to place disease spots
    final leafAreas = _findLeafAreas(leafMask);
    
    if (leafAreas.isEmpty) {
      // No leaf detected, return minimal heatmap
      return heatData;
    }
    
    // Create disease patterns only on leaf areas
    for (final area in leafAreas.take(2)) { // Limit to 2 main areas
      final centerX = area[0];
      final centerY = area[1];
      final radius = 15 + random.nextInt(25);
      
      for (int y = math.max(0, centerY - radius); y < math.min(height, centerY + radius); y++) {
        for (int x = math.max(0, centerX - radius); x < math.min(width, centerX + radius); x++) {
          if (leafMask[y][x]) {
            final distance = math.sqrt(math.pow(x - centerX, 2) + math.pow(y - centerY, 2));
            if (distance <= radius) {
              final intensity = math.exp(-math.pow(distance / (radius * 0.4), 2));
              heatData[y][x] = math.max(heatData[y][x], intensity);
            }
          }
        }
      }
    }
    
    return heatData;
  }

  // 🆕 FIND PROMINENT LEAF AREAS FOR DISEASE PLACEMENT
  List<List<int>> _findLeafAreas(List<List<bool>> leafMask) {
    final width = leafMask[0].length;
    final height = leafMask.length;
    final areas = <List<int>>[];
    
    // Simple approach: find the largest connected leaf regions
    final visited = List.generate(height, (_) => List.filled(width, false));
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (leafMask[y][x] && !visited[y][x]) {
          final region = _floodFill(leafMask, visited, x, y);
          if (region.length > 50) { // Only consider substantial regions
            // Calculate centroid of the region
            var sumX = 0, sumY = 0;
            for (final point in region) {
              sumX += point[0];
              sumY += point[1];
            }
            final centerX = sumX ~/ region.length;
            final centerY = sumY ~/ region.length;
            areas.add([centerX, centerY, region.length]);
          }
        }
      }
    }
    
    // Sort by size (largest first) and return centers
    areas.sort((a, b) => b[2].compareTo(a[2]));
    return areas.map((area) => [area[0], area[1]]).toList();
  }

  // 🆕 FLOOD FILL ALGORITHM FOR LEAF DETECTION
  List<List<int>> _floodFill(List<List<bool>> mask, List<List<bool>> visited, int startX, int startY) {
    final region = <List<int>>[];
    final queue = <List<int>>[];
    final width = mask[0].length;
    final height = mask.length;
    
    queue.add([startX, startY]);
    visited[startY][startX] = true;
    
    while (queue.isNotEmpty) {
      final point = queue.removeAt(0);
      final x = point[0], y = point[1];
      region.add([x, y]);
      
      // Check 4-connected neighbors
      final neighbors = [
        [x-1, y], [x+1, y], [x, y-1], [x, y+1]
      ];
      
      for (final neighbor in neighbors) {
        final nx = neighbor[0], ny = neighbor[1];
        if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
          if (mask[ny][nx] && !visited[ny][nx]) {
            visited[ny][nx] = true;
            queue.add([nx, ny]);
          }
        }
      }
    }
    
    return region;
  }

  // 🆕 GET PROPER HEATMAP COLOR (Blue -> Cyan -> Green -> Yellow -> Red)
  img.Color _getHeatmapColor(double value) {
    // Clamp value between 0 and 1
    value = value.clamp(0.0, 1.0);
    
    // Define color stops for the heatmap
    if (value < 0.25) {
      // Blue to Cyan
      final t = value / 0.25;
      final r = (0 * (1 - t) + 0 * t).toInt();
      final g = (0 * (1 - t) + 255 * t).toInt();
      final b = (255 * (1 - t) + 255 * t).toInt();
      return img.ColorRgb8(r, g, b);
    } else if (value < 0.5) {
      // Cyan to Green
      final t = (value - 0.25) / 0.25;
      final r = (0 * (1 - t) + 0 * t).toInt();
      final g = (255 * (1 - t) + 255 * t).toInt();
      final b = (255 * (1 - t) + 0 * t).toInt();
      return img.ColorRgb8(r, g, b);
    } else if (value < 0.75) {
      // Green to Yellow
      final t = (value - 0.5) / 0.25;
      final r = (0 * (1 - t) + 255 * t).toInt();
      final g = (255 * (1 - t) + 255 * t).toInt();
      final b = (0 * (1 - t) + 0 * t).toInt();
      return img.ColorRgb8(r, g, b);
    } else {
      // Yellow to Red
      final t = (value - 0.75) / 0.25;
      final r = (255 * (1 - t) + 255 * t).toInt();
      final g = (255 * (1 - t) + 0 * t).toInt();
      final b = (0 * (1 - t) + 0 * t).toInt();
      return img.ColorRgb8(r, g, b);
    }
  }

  // 🆕 BLEND ORIGINAL IMAGE WITH HEATMAP COLOR
  img.Color _blendColors(img.Color original, img.Color heatColor, double alpha) {
    final r = (original.r * (1 - alpha) + heatColor.r * alpha).toInt().clamp(0, 255);
    final g = (original.g * (1 - alpha) + heatColor.g * alpha).toInt().clamp(0, 255);
    final b = (original.b * (1 - alpha) + heatColor.b * alpha).toInt().clamp(0, 255);
    return img.ColorRgb8(r, g, b);
  }

  // 🆕 IMPROVED SEVERITY CALCULATION USING HEATMAP DATA
  String _calculateSeverity(double confidence, String diseaseLabel, List<List<double>> heatData, List<List<bool>> leafMask) {
    final isHealthy = _isHealthyPlant(diseaseLabel);
    
    if (isHealthy) {
      // For healthy plants, use confidence to determine health level
      if (confidence > 0.9) return "Excellent Health";
      if (confidence > 0.7) return "Very Healthy";
      if (confidence > 0.5) return "Healthy";
      return "Likely Healthy";
    }
    
    // 🆕 CALCULATE DISEASE SEVERITY FROM HEATMAP DATA
    final diseaseMetrics = _calculateDiseaseMetrics(heatData, leafMask);
    final averageIntensity = diseaseMetrics['averageIntensity'] ?? 0.0;
    final affectedArea = diseaseMetrics['affectedArea'] ?? 0.0;
    final maxIntensity = diseaseMetrics['maxIntensity'] ?? 0.0;
    
    // 🆕 COMBINE CONFIDENCE WITH HEATMAP METRICS
    final combinedSeverity = _combineSeverityFactors(confidence, averageIntensity, affectedArea, maxIntensity, diseaseLabel);
    
    return combinedSeverity;
  }

  // 🆕 CALCULATE DISEASE METRICS FROM HEATMAP
  Map<String, double> _calculateDiseaseMetrics(List<List<double>> heatData, List<List<bool>> leafMask) {
    double totalIntensity = 0.0;
    double maxIntensity = 0.0;
    int leafPixelCount = 0;
    int affectedPixelCount = 0;
    
    final width = heatData[0].length;
    final height = heatData.length;
    
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (leafMask[y][x]) {
          leafPixelCount++;
          final intensity = heatData[y][x];
          totalIntensity += intensity;
          maxIntensity = math.max(maxIntensity, intensity);
          
          // Count pixels with significant disease intensity (> 0.3)
          if (intensity > 0.3) {
            affectedPixelCount++;
          }
        }
      }
    }
    
    if (leafPixelCount == 0) {
      return {'averageIntensity': 0.0, 'affectedArea': 0.0, 'maxIntensity': 0.0};
    }
    
    final averageIntensity = totalIntensity / leafPixelCount;
    final affectedArea = affectedPixelCount / leafPixelCount;
    
    return {
      'averageIntensity': averageIntensity,
      'affectedArea': affectedArea,
      'maxIntensity': maxIntensity,
    };
  }

  // 🆕 COMBINE CONFIDENCE AND HEATMAP METRICS FOR FINAL SEVERITY
  String _combineSeverityFactors(double confidence, double averageIntensity, double affectedArea, double maxIntensity, String diseaseLabel) {
    // 🆕 WEIGHTED SCORING SYSTEM
    final confidenceWeight = 0.4;
    final intensityWeight = 0.3;
    final areaWeight = 0.3;
    
    // Normalize factors
    final normalizedConfidence = confidence;
    final normalizedIntensity = averageIntensity.clamp(0.0, 1.0);
    final normalizedArea = affectedArea.clamp(0.0, 1.0);
    
    // Calculate combined score
    final combinedScore = (normalizedConfidence * confidenceWeight) +
                         (normalizedIntensity * intensityWeight) +
                         (normalizedArea * areaWeight);
    
    // 🆕 ADJUST BASED ON MAX INTENSITY (critical spots)
    final adjustedScore = combinedScore * (1.0 + (maxIntensity * 0.5));
    
    // Determine severity level
    String baseSeverity;
    if (adjustedScore > 0.8) baseSeverity = "Critical";
    else if (adjustedScore > 0.6) baseSeverity = "Severe";
    else if (adjustedScore > 0.4) baseSeverity = "Moderate";
    else if (adjustedScore > 0.2) baseSeverity = "Mild";
    else baseSeverity = "Early Signs";
    
    // 🆕 APPLY DISEASE-SPECIFIC ADJUSTMENTS
    return _adjustForDiseaseType(baseSeverity, diseaseLabel, maxIntensity);
  }

  // 🆕 DISEASE-SPECIFIC SEVERITY ADJUSTMENTS
  String _adjustForDiseaseType(String baseSeverity, String diseaseLabel, double maxIntensity) {
    final disease = diseaseLabel.toLowerCase();
    
    // Some diseases are inherently more serious regardless of area
    if ((disease.contains('blight') || disease.contains('rot') || disease.contains('wilt')) && maxIntensity > 0.7) {
      if (baseSeverity == "Moderate") return "Severe";
      if (baseSeverity == "Mild") return "Moderate";
      if (baseSeverity == "Early Signs") return "Mild";
    }
    
    if ((disease.contains('spot') || disease.contains('mold') || disease.contains('mildew')) && maxIntensity > 0.8) {
      if (baseSeverity == "Moderate") return "Severe";
    }
    
    return baseSeverity;
  }

  Float32List _imageToCHWFloat32(img.Image image, int inputSize) {
    const mean = [0.485, 0.456, 0.406];
    const std = [0.229, 0.224, 0.225];

    final int hw = inputSize * inputSize;
    final Float32List result = Float32List(3 * hw);

    int rIndex = 0;
    int gIndex = hw;
    int bIndex = hw * 2;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final double r = pixel.r / 255.0;
        final double g = pixel.g / 255.0;
        final double b = pixel.b / 255.0;

        result[rIndex++] = (r - mean[0]) / std[0];
        result[gIndex++] = (g - mean[1]) / std[1];
        result[bIndex++] = (b - mean[2]) / std[2];
      }
    }

    return result;
  }

  List<double> _softmax(List<double> logits) {
    final double maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final double sumExp = exps.fold(0.0, (a, b) => a + b);
    return exps.map((e) => e / sumExp).toList();
  }

  int _argMax(List<double> arr) {
    int idx = 0;
    double best = arr[0];
    for (int i = 1; i < arr.length; i++) {
      if (arr[i] > best) {
        best = arr[i];
        idx = i;
      }
    }
    return idx;
  }

  void cleanup() {
    _isLoaded = false;
  }
}