import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnalysisProvider with ChangeNotifier {
  List<AnalysisResult> _analyses = [];
  AnalysisResult? _currentAnalysis;
  bool _isLoading = false;
  String? _error;

  List<AnalysisResult> get analyses => _analyses;
  AnalysisResult? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> analyzeImage(String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call your FastAPI endpoints
      final analysisResult = await _callAnalysisAPI(imagePath);
      final severityResult = await _callSeverityAPI(imagePath);
      
      _currentAnalysis = AnalysisResult(
        imagePath: imagePath,
        disease: analysisResult['disease'],
        confidence: analysisResult['confidence'],
        severity: severityResult['severity'],
        heatmapUrl: severityResult['heatmap_url'],
        treatment: analysisResult['treatment'],
      );
      
      _analyses.insert(0, _currentAnalysis!);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _callAnalysisAPI(String imagePath) async {
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('http://10.0.2.2:8000/analyze/') // Use 10.0.2.2 for Android emulator
    );
    
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    return json.decode(responseData);
  }

  Future<Map<String, dynamic>> _callSeverityAPI(String imagePath) async {
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse('http://10.0.2.2:8000/severity/')
    );
    
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    return json.decode(responseData);
  }
}

class AnalysisResult {
  final String imagePath;
  final String disease;
  final double confidence;
  final String severity;
  final String? heatmapUrl;
  final Map<String, dynamic> treatment;

  AnalysisResult({
    required this.imagePath,
    required this.disease,
    required this.confidence,
    required this.severity,
    this.heatmapUrl,
    required this.treatment,
  });
}