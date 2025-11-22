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
  print('📄 Loaded class names: $classNames');

}


  /// Analyze an image
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

  // Print everything to console for debugging
  print('Raw logits: $logits');
  print('Probabilities: $probs');
  print('Predicted index: $bestIdx');
  print('Disease label: $label');
  print('Confidence: $bestProb');
  print('Treatment: $treatment');

  return {
    'disease': label,
    'confidence': bestProb,
    'probabilities': probs,
    'raw_logits': logits,
    'treatment': treatment,
    'predicted_index': bestIdx,
  };
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
}
