import 'dart:convert';
import 'package:http/http.dart' as http;
import '../presentation/providers/analysis_provider.dart'; // ✅ UPDATED FILE

class ApiService {
  static const String baseUrl = 'http://192.168.100.14:8000'; // Your backend URL
  
  Future<AnalysisResult> analyzeImage(
    String imagePath, {
    bool includeSeverity = false,
  }) async {
    try {
      // First get basic analysis
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze/'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode != 200) {
        throw Exception('Analysis failed: ${response.statusCode}');
      }
      
      var analysisData = json.decode(responseData);
      print('🔍 ANALYSIS RESPONSE: $analysisData');

      // If severity analysis is requested, get Grad-CAM results
      if (includeSeverity) {
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
        
        if (severityResponse.statusCode != 200) {
          throw Exception('Severity analysis failed: ${severityResponse.statusCode}');
        }
        
        var severityAnalysis = json.decode(severityData);
        print('🔍 SEVERITY RESPONSE: $severityAnalysis');

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
      throw Exception('Failed to analyze image: $e');
    }
  }

  // Additional API methods can be added here
  Future<bool> checkServerStatus() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}