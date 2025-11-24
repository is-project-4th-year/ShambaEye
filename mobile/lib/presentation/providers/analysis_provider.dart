import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart';
import '../../services/api_service.dart';
import '../../services/local_model_service.dart';
import '../../services/firestore_service.dart';
import '../../services/analysis_model.dart';

class AnalysisProvider with ChangeNotifier {
  String? _imagePath;
  bool _isLoading = false;
  AnalysisResult? _lastResult;
  List<AnalysisResult> _history = [];
  String? _error;

  // Services
  final ApiService _apiService = ApiService();
  final LocalModelService _localModelService = LocalModelService.instance;
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
    print("📥 Loading local model...");
    await _localModelService.loadModel();

    print("🤖 Running offline inference with Grad-CAM...");
    final result = await _localModelService.analyzeImage(_imagePath!);

    // 🆕 DEBUG: Check if heatmap path exists
    print('🔍 Heatmap path from local model: ${result['heatmapPath']}');
    if (result['heatmapPath'] != null) {
      final heatmapFile = File(result['heatmapPath']!);
      print('🔍 Heatmap file exists: ${heatmapFile.existsSync()}');
      if (heatmapFile.existsSync()) {
        print('🔍 Heatmap file size: ${heatmapFile.lengthSync()} bytes');
      }
    } else {
      print('❌ HEATMAP PATH IS NULL - This is the problem!');
    }

    // 🆕 USE THE NEW GRAD-CAM AND SEVERITY FEATURES
    _lastResult = AnalysisResult(
      disease: result['disease'],
      confidence: result['confidence'].toDouble(),
      treatment: result['treatment'],
      severity: result['severity'], // 🆕 NOW INCLUDES SEVERITY
      heatmapUrl: result['heatmapPath'], // 🆕 NOW INCLUDES GRAD-CAM
      isOnline: false,
      timestamp: DateTime.now(),
    );

    _history.add(_lastResult!);
    
    print('✅ Offline scan complete with Grad-CAM visualization');
    print('📊 Severity: ${result['severity']}');
    print('🎨 Heatmap: ${result['heatmapPath']}');

    _isLoading = false;
    notifyListeners();
  } catch (e) {
    print('❌ ERROR during offline analysis: $e');
    print('❌ Stack trace: ${e.toString()}');
    throw Exception('Offline analysis failed: $e');
  }
}

  // 🆕 NEW: Get the heatmap file for display
  File? getHeatmapFile() {
    if (_lastResult?.heatmapUrl != null && _lastResult!.heatmapUrl!.startsWith('/')) {
      return File(_lastResult!.heatmapUrl!);
    }
    return null;
  }

  // 🆕 NEW: Check if current result has Grad-CAM
  bool get hasGradCAM => _lastResult?.heatmapUrl != null;

  // 🆕 NEW: Get severity color for UI
  Color getSeverityColor() {
    final severity = _lastResult?.severity?.toLowerCase();
    switch (severity) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 🆕 NEW: Get severity icon for UI
  IconData getSeverityIcon() {
    final severity = _lastResult?.severity?.toLowerCase();
    switch (severity) {
      case 'severe':
        return Icons.warning;
      case 'moderate':
        return Icons.info;
      case 'mild':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // 🆕 NEW: Clean up temporary heatmap files
  void cleanupHeatmaps() {
    try {
      for (final result in _history) {
        if (result.heatmapUrl != null && 
            result.heatmapUrl!.startsWith('${Directory.systemTemp.path}/')) {
          final file = File(result.heatmapUrl!);
          if (file.existsSync()) {
            file.deleteSync();
          }
        }
      }
      print('🧹 Cleaned up temporary heatmap files');
    } catch (e) {
      print('⚠️ Error cleaning up heatmaps: $e');
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
    // Clean up heatmap files before clearing history
    cleanupHeatmaps();
    _history.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up when provider is disposed
    cleanupHeatmaps();
    super.dispose();
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