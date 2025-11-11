import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../providers/auth_provider.dart';
import 'dart:io';

class AnalysisView extends StatelessWidget {
  AnalysisView({super.key});

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Image Preview Section
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.imagePath != null)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(provider.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.error, size: 50),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Retake'),
                          onPressed: () => provider.pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Choose Another'),
                          onPressed: () => provider.pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Analysis Section
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: _buildAnalysisContent(context, provider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisContent(BuildContext context, AnalysisProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Analyzing your image...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Analysis Failed',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.analyzeImage(isOnline: _isUserLoggedIn(context)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (provider.lastResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Ready to Analyze',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isUserLoggedIn(context) 
                ? 'Tap the button below to analyze your image with full features'
                : 'Tap the button below for basic disease detection',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(_isUserLoggedIn(context) ? Icons.cloud : Icons.offline_bolt),
              label: Text(_isUserLoggedIn(context) ? 'Analyze Online' : 'Analyze Offline'),
              onPressed: () => provider.analyzeImage(isOnline: _isUserLoggedIn(context)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            if (!_isUserLoggedIn(context)) ...[
              const SizedBox(height: 12),
              Text(
                'Login for severity analysis and heatmaps',
                style: TextStyle(color: Colors.orange[700], fontSize: 12),
              ),
            ],
          ],
        ),
      );
    }

    // Show results
    return _buildResultsView(context, provider);
  }

  Widget _buildHeatmapSection(BuildContext context, AnalysisProvider provider, String heatmapUrl) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease Visualization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Heatmap showing affected areas (red indicates high disease concentration)',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Image Comparison
            Row(
              children: [
                // Original Image
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Original',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: provider.imagePath != null
                              ? Image.file(
                                  File(provider.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.photo, size: 40, color: Colors.grey),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Heatmap Image
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Heatmap',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildHeatmapImage(heatmapUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Full Size Heatmap
            const Text(
              'Detailed View:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildHeatmapImage(heatmapUrl),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapImage(String heatmapUrl) {
    return Image.network(
      heatmapUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text(
                'Heatmap not available',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultsView(BuildContext context, AnalysisProvider provider) {
    final result = provider.lastResult!;
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: result.isOnline ? Colors.green[50] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  result.isOnline ? Icons.cloud : Icons.offline_bolt,
                  color: result.isOnline ? Colors.green : Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  result.isOnline ? 'Online Analysis' : 'Offline Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: result.isOnline ? Colors.green[800] : Colors.blue[800],
                  ),
                ),
                if (!result.isOnline) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(Basic detection only)',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          const Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Disease Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Disease Detection',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow('Disease', result.disease),
                  _buildResultRow('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%'),
                  if (result.severity != null)
                    _buildResultRow('Severity', result.severity!),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Grad-CAM Heatmap Section - Only for online mode
          if (result.isOnline && result.heatmapUrl != null)
            _buildHeatmapSection(context, provider, result.heatmapUrl!),

          const SizedBox(height: 16),

          // Treatment Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Treatment Advice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTreatmentSection(result.treatment),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library),
                  label: const Text('New Analysis'),
                  onPressed: () => provider.clearResults(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share Results'),
                  onPressed: () {
                    // Will add share functionality later
                  },
                ),
              ),
            ],
          ),
          
          // Online features reminder for offline users
          if (!result.isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[800], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Login for full features: severity analysis, heatmaps, and cloud storage',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentSection(Map<String, dynamic> treatment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (treatment['advice'] != null)
          _buildTreatmentItem('General Advice', treatment['advice']),
        
        if (treatment['organic_treatment'] != null)
          _buildTreatmentItem('Organic Treatment', treatment['organic_treatment']),
        
        if (treatment['chemical_treatment'] != null)
          _buildTreatmentItem('Chemical Treatment', treatment['chemical_treatment']),
        
        if (treatment['prevention'] != null)
          _buildTreatmentItem('Prevention', treatment['prevention']),
          
        // Fallback for simple treatment structure
        if (treatment['advice'] == null && 
            treatment['organic_treatment'] == null && 
            treatment['chemical_treatment'] == null && 
            treatment['prevention'] == null)
          _buildTreatmentItem('Advice', treatment['advice'] ?? 'No specific treatment advice available'),
      ],
    );
  }

  Widget _buildTreatmentItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  bool _isUserLoggedIn(BuildContext context) {
  try {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    print('🔐 Checking login status in AnalysisView: ${authProvider.isLoggedIn}');
    return authProvider.isLoggedIn;
  } catch (e) {
    print('❌ Error checking login status: $e');
    return false;
  }
}
}