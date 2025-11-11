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
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FDF8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.imagePath != null)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFA8D5BA),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(provider.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFFD2EFDA),
                                child: const Icon(
                                  Icons.error_outline_rounded,
                                  size: 50,
                                  color: Color(0xFF2E7D32),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildImageActionButton(
                          icon: Icons.camera_alt_rounded,
                          label: 'Retake',
                          onPressed: () => provider.pickImage(ImageSource.camera),
                        ),
                        const SizedBox(width: 12),
                        _buildImageActionButton(
                          icon: Icons.photo_library_rounded,
                          label: 'Choose Another',
                          onPressed: () => provider.pickImage(ImageSource.gallery),
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
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildAnalysisContent(context, provider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD2EFDA),
        foregroundColor: const Color(0xFF2E7D32),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFA8D5BA)),
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(BuildContext context, AnalysisProvider provider) {
    if (provider.isLoading) {
      return _buildLoadingState();
    }

    if (provider.error != null) {
      return _buildErrorState(context, provider);
    }

    if (provider.lastResult == null) {
      return _buildReadyState(context, provider);
    }

    return _buildResultsView(context, provider);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              backgroundColor: const Color(0xFFD2EFDA),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyzing Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Processing your plant image...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AnalysisProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD2EFDA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.analyzeImage(isOnline: _isUserLoggedIn(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyState(BuildContext context, AnalysisProvider provider) {
    final isOnline = _isUserLoggedIn(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFD2EFDA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isOnline ? Icons.cloud_rounded : Icons.offline_bolt_rounded,
              size: 40,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isOnline ? 'Ready for Analysis' : 'Basic Analysis Ready',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              isOnline 
                  ? 'Tap below for full AI analysis with severity assessment'
                  : 'Basic disease detection available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(isOnline ? Icons.cloud_rounded : Icons.offline_bolt_rounded),
            label: Text(isOnline ? 'Analyze Online' : 'Analyze Offline'),
            onPressed: () => provider.analyzeImage(isOnline: isOnline),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (!isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD2EFDA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFA8D5BA)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline_rounded, 
                      size: 16, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 8),
                  Text(
                    'Login for advanced features',
                    style: TextStyle(
                      color: const Color(0xFF1B5E20),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildHeatmapSection(BuildContext context, AnalysisProvider provider, String heatmapUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE8F5E8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disease Visualization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Heatmap showing affected areas (red indicates high disease concentration)',
            style: TextStyle(
              color: Colors.grey[600],
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
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8F5E8)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: provider.imagePath != null
                            ? Image.file(
                                File(provider.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color(0xFFD2EFDA),
                                child: const Icon(Icons.photo_rounded, size: 40, color: Color(0xFF2E7D32)),
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
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE8F5E8)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8F5E8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildHeatmapImage(heatmapUrl),
            ),
          ),
        ],
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
          color: const Color(0xFFD2EFDA),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFD2EFDA),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: Color(0xFF2E7D32), size: 40),
              SizedBox(height: 8),
              Text(
                'Heatmap not available',
                style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: result.isOnline ? const Color(0xFFD2EFDA) : const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: result.isOnline ? const Color(0xFFA8D5BA) : const Color(0xFFBBDEFB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  result.isOnline ? Icons.cloud_rounded : Icons.offline_bolt_rounded,
                  color: result.isOnline ? const Color(0xFF2E7D32) : const Color(0xFF1976D2),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  result.isOnline ? 'Online Analysis' : 'Offline Analysis',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: result.isOnline ? const Color(0xFF1B5E20) : const Color(0xFF0D47A1),
                  ),
                ),
                if (!result.isOnline) ...[
                  const SizedBox(width: 8),
                  Text(
                    '(Basic detection)',
                    style: TextStyle(
                      color: const Color(0xFF1B5E20).withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Analysis Results',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 20),

          // Disease Card
          _buildResultCard(
            title: 'Disease Detection',
            children: [
              _buildResultRow('Disease', result.disease),
              _buildResultRow('Confidence', '${(result.confidence * 100).toStringAsFixed(1)}%'),
              if (result.severity != null)
                _buildResultRow('Severity', result.severity!),
            ],
          ),

          const SizedBox(height: 16),

          // Grad-CAM Heatmap Section - Only for online mode
          if (result.isOnline && result.heatmapUrl != null)
            _buildHeatmapSection(context, provider, result.heatmapUrl!),

          const SizedBox(height: 16),

          // Treatment Card
          _buildResultCard(
            title: 'Treatment Advice',
            children: [
              _buildTreatmentSection(result.treatment),
            ],
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('New Analysis'),
                  onPressed: () => provider.clearResults(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Results'),
                  onPressed: () {
                    // Will add share functionality later
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Online features reminder for offline users
          if (!result.isOnline) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD2EFDA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA8D5BA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, 
                      color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Login for full features: severity analysis, heatmaps, and cloud storage',
                      style: TextStyle(
                        color: const Color(0xFF1B5E20),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
       border: Border.all(
  color: const Color(0xFFE8F5E8),
  width: 1,
),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 15,
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
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
      return authProvider.isLoggedIn;
    } catch (e) {
      return false;
    }
  }
}