import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart'; // ✅ EXISTING FILE
import '../../services/api_service.dart'; // 🆕 NEW FILE
import '../../services/local_model_service.dart'; // 🆕 NEW FILE - FIXED MISSING SEMICOLON

class AnalysisResult {
  final String disease;
  final double confidence;
  final Map<String, dynamic> treatment;
  final String? severity;
  final String? heatmapUrl;
  final bool isOnline;
  final DateTime timestamp;

  AnalysisResult({
    required this.disease,
    required this.confidence,
    required this.treatment,
    this.severity,
    this.heatmapUrl,
    required this.isOnline,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'confidence': confidence,
      'treatment': treatment,
      'severity': severity,
      'heatmapUrl': heatmapUrl,
      'isOnline': isOnline,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static AnalysisResult fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      disease: map['disease'],
      confidence: map['confidence'].toDouble(),
      treatment: Map<String, dynamic>.from(map['treatment']),
      severity: map['severity'],
      heatmapUrl: map['heatmapUrl'],
      isOnline: map['isOnline'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}

class AnalysisProvider with ChangeNotifier {
  String? _imagePath;
  bool _isLoading = false;
  AnalysisResult? _lastResult;
  List<AnalysisResult> _history = [];
  String? _error;

  // 🆕 NEW: Service instances for online and offline analysis
  final ApiService _apiService = ApiService();
  final LocalModelService _localModelService = LocalModelService();

  String? get imagePath => _imagePath;
  bool get isLoading => _isLoading;
  AnalysisResult? get lastResult => _lastResult;
  List<AnalysisResult> get history => _history;
  String? get error => _error;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      _imagePath = image.path;
      _lastResult = null;
      _error = null;
      notifyListeners();
    }
  }

 Future<void> analyzeImage({bool isOnline = false}) async {
  if (_imagePath == null) return;

  _isLoading = true;
  _error = null;
  notifyListeners();

  print('🔍 Starting analysis - Online mode: $isOnline');
  print('📁 Image path: $_imagePath');

  try {
    if (isOnline) {
      print('🌐 Using ONLINE analysis with server');
      await _analyzeOnline();
    } else {
      print('📱 Using OFFLINE analysis with local model');
      await _analyzeOffline();
    }
  } catch (e) {
    print('❌ ERROR during analysis: $e');
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> _analyzeOnline() async {
    try {
      // 🆕 UPDATED: Use ApiService instead of direct HTTP calls
      final result = await _apiService.analyzeImage(
        _imagePath!, 
        includeSeverity: true
      );
      
      _lastResult = result;
      _history.add(result);
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      throw Exception('Online analysis failed: $e');
    }
  }

  Future<void> _analyzeOffline() async {
    try {
      // 🆕 UPDATED: Use LocalModelService for offline analysis
      final result = await _localModelService.analyzeImage(_imagePath!);
      
      _lastResult = AnalysisResult(
        disease: result['disease'],
        confidence: result['confidence'].toDouble(),
        treatment: result['treatment'],
        severity: null, // Not available in offline mode
        heatmapUrl: null, // Not available in offline mode
        isOnline: false,
        timestamp: DateTime.now(),
      );

      _history.add(_lastResult!);
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      throw Exception('Offline analysis failed: $e');
    }
  }

  void clearResults() {
    _imagePath = null;
    _lastResult = null;
    _error = null;
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  // Load/Save history for persistence (optional)
  void loadHistory(List<Map<String, dynamic>> historyData) {
    _history = historyData.map((data) => AnalysisResult.fromMap(data)).toList();
    notifyListeners();
  }

  List<Map<String, dynamic>> getHistoryData() {
    return _history.map((result) => result.toMap()).toList();
  }
}