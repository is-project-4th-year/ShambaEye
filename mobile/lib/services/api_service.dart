import 'dart:convert';
import 'package:http/http.dart' as http;
import 'analysis_model.dart'; // 🆕 ADD THIS IMPORT

class ApiService {
  static const String baseUrl = 'http://192.168.100.14:8000'; // Your backend URL
  
  Future<AnalysisResult> analyzeImage(
    String imagePath, {
    bool includeSeverity = false,
  }) async {
    try {
      print('🔄 Sending request to server: $baseUrl/analyze/');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze/'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ));

      print('📤 Uploading image to server...');
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      print('📥 Server response status: ${response.statusCode}');
      print('📥 Server response: $responseData');
      
      if (response.statusCode != 200) {
        throw Exception('Analysis failed: ${response.statusCode} - $responseData');
      }
      
      var analysisData = json.decode(responseData);

      // If severity analysis is requested, get Grad-CAM results
      if (includeSeverity) {
        print('🔄 Getting severity analysis...');
        var severityRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/severity/'),
        );
        
        severityRequest.files.add(await http.MultipartFile.fromPath(
          'file',
          imagePath,
        ));

        var severityResponse = await severityRequest.send();
        var severityData = await severityResponse.stream.bytesToString();
        
        print('📥 Severity response status: ${severityResponse.statusCode}');
        
        if (severityResponse.statusCode != 200) {
          throw Exception('Severity analysis failed: ${severityResponse.statusCode}');
        }
        
        var severityAnalysis = json.decode(severityData);

        return AnalysisResult(
          disease: analysisData['disease'],
          confidence: analysisData['confidence'].toDouble(),
          treatment: analysisData['treatment'],
          severity: severityAnalysis['severity'],
          heatmapUrl: severityAnalysis['heatmap_url'],
          isOnline: true,
          timestamp: DateTime.now(),
        );
      }

      return AnalysisResult(
        disease: analysisData['disease'],
        confidence: analysisData['confidence'].toDouble(),
        treatment: analysisData['treatment'],
        isOnline: true,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      print('❌ API Service Error: $e');
      throw Exception('Failed to connect to analysis server: $e');
    }
  }

  // Test server connection
  Future<bool> checkServerStatus() async {
    try {
      print('🔍 Checking server status...');
      final response = await http.get(Uri.parse('$baseUrl/'));
      final isOnline = response.statusCode == 200;
      print('🌐 Server status: ${isOnline ? 'Online' : 'Offline'}');
      return isOnline;
    } catch (e) {
      print('❌ Server check failed: $e');
      return false;
    }
  }
}