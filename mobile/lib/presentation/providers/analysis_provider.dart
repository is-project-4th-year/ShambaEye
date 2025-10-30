import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../core/config.dart';

class AnalysisProvider with ChangeNotifier {
  String? _imagePath;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _severityResult;
  String? _error;

  String? get imagePath => _imagePath;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get analysisResult => _analysisResult;
  Map<String, dynamic>? get severityResult => _severityResult;
  String? get error => _error;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      _imagePath = image.path;
      _analysisResult = null;
      _severityResult = null;
      _error = null;
      notifyListeners();
    }
  }

Future<void> analyzeImage() async {
  if (_imagePath == null) return;

  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    // Call analyze endpoint
    var request = http.MultipartRequest(
      'POST', 
      Uri.parse(ApiConfig.analyzeEndpoint)
    );
    request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
    
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    _analysisResult = json.decode(responseData);
    
    print('🔍 ANALYSIS RESPONSE: $_analysisResult');

    // Call severity endpoint
    request = http.MultipartRequest(
      'POST', 
      Uri.parse(ApiConfig.severityEndpoint)
    );
    request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
    
    response = await request.send();
    responseData = await response.stream.bytesToString();
    _severityResult = json.decode(responseData);
    
    print('🔍 SEVERITY RESPONSE: $_severityResult');

  } catch (e) {
    print('❌ ERROR: $e');
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  void clearResults() {
    _imagePath = null;
    _analysisResult = null;
    _severityResult = null;
    _error = null;
    notifyListeners();
  }
}