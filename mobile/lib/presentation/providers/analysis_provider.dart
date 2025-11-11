import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart';
import '../../services/api_service.dart';
import '../../services/local_model_service.dart';
import '../../services/firestore_service.dart';
import '../../services/analysis_model.dart'; // 🆕 Use shared model

class AnalysisProvider with ChangeNotifier {
  String? _imagePath;
  bool _isLoading = false;
  AnalysisResult? _lastResult;
  List<AnalysisResult> _history = [];
  String? _error;

  // Services
  final ApiService _apiService = ApiService();
  final LocalModelService _localModelService = LocalModelService();
  final FirestoreService _firestoreService = FirestoreService();

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
      final result = await _apiService.analyzeImage(
        _imagePath!, 
        includeSeverity: true
      );
      
      _lastResult = result;
      _history.add(result);
      
      // 🆕 SAVE SCAN TO FIRESTORE
      try {
        await _firestoreService.saveScan(result, _imagePath!);
        print('✅ Scan saved to Firestore');
      } catch (e) {
        print('⚠️ Could not save scan to Firestore: $e');
        // Don't throw error - analysis still successful
      }
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      throw Exception('Online analysis failed: $e');
    }
  }

  Future<void> _analyzeOffline() async {
    try {
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
      
      // 🆕 SAVE OFFLINE SCAN TO FIRESTORE (without images)
      try {
        await _firestoreService.saveScan(_lastResult!, _imagePath!);
        print('✅ Offline scan saved to Firestore');
      } catch (e) {
        print('⚠️ Could not save offline scan to Firestore: $e');
      }
      
      _isLoading = false;
      notifyListeners();
      
    } catch (e) {
      throw Exception('Offline analysis failed: $e');
    }
  }

  // 🆕 NEW: Get scan history from Firestore
  Stream<List<ScanHistory>> getScanHistory() {
    return _firestoreService.getScanHistory();
  }

  // 🆕 NEW: Delete scan from Firestore
  Future<void> deleteScan(String scanId) async {
    try {
      await _firestoreService.deleteScan(scanId);
      notifyListeners();
    } catch (e) {
      print('❌ Error deleting scan: $e');
      rethrow;
    }
  }

  // 🆕 NEW: Get scan count
  Future<int> getScanCount() async {
    return await _firestoreService.getScanCount();
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