import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/analysis_provider.dart';
import '../../services/firestore_service.dart';
import 'package:shamba_eye/gen_l10n/app_localizations.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, locale),
            
            // Content
            Expanded(
              child: _buildHistoryContent(context, locale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations locale) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2EFDA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.scan_history,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locale.your_plant_analysis_records,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD2EFDA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.filter_list_rounded, 
                      color: Color(0xFF2E7D32), size: 20),
                  onPressed: () {
                    // Filter functionality can be added here
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  

  Widget _buildHistoryContent(BuildContext context, AppLocalizations locale) {
    return StreamBuilder<List<ScanHistory>>(
      stream: Provider.of<AnalysisProvider>(context, listen: false).getScanHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState(locale);
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString(), locale);
        }

        final scans = snapshot.data ?? [];

        if (scans.isEmpty) {
          return _buildEmptyState(context, locale);
        }

        return _buildHistoryList(scans, context, locale);
      },
    );
  }

  Widget _buildLoadingState(AppLocalizations locale) {
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
          Text(
            locale.loading_history,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            locale.fetching_your_scan_records,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, AppLocalizations locale) {
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
          Text(
            locale.unable_to_load_history,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations locale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFD2EFDA),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 60,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            locale.no_scans_yet,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              locale.your_plant_analysis_history_will_appear,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.photo_camera_rounded),
            label: Text(locale.start_your_first_scan),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(locale.use_the_camera_button_below),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<ScanHistory> scans, BuildContext context, AppLocalizations locale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${locale.recent_scans} (${scans.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                final scan = scans[index];
                return _buildScanCard(scan, context, locale);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanCard(ScanHistory scan, BuildContext context, AppLocalizations locale) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showScanDetails(context, scan, locale);
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE8F5E8),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with disease and confidence
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Disease icon and name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD2EFDA),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getDiseaseIcon(scan.disease),
                                  color: const Color(0xFF2E7D32),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scan.disease,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1B5E20),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat('MMM dd, yyyy • HH:mm').format(scan.timestamp),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Confidence chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(scan.confidence),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(scan.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Details row
                Row(
                  children: [
                    _buildDetailChip(
                      locale.severity,
                      scan.severity ?? locale.not_available,
                      const Color(0xFFD2EFDA),
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      locale.analysis_mode,
                      scan.isOnline ? 'Online' : 'Offline',
                      scan.isOnline ? const Color(0xFFD2EFDA) : const Color(0xFFE3F2FD),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: Text(locale.view_details),
                        onPressed: () {
                          _showScanDetails(context, scan, locale);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 44,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, 
                            color: Colors.red, size: 20),
                        onPressed: () {
                          _showDeleteDialog(context, scan, locale);
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  IconData _getDiseaseIcon(String disease) {
    if (disease.toLowerCase().contains('healthy')) {
      return Icons.health_and_safety_rounded;
    } else if (disease.toLowerCase().contains('blight')) {
      return Icons.warning_rounded;
    } else if (disease.toLowerCase().contains('mold')) {
      return Icons.water_drop_rounded;
    } else {
      return Icons.psychology_rounded;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return const Color(0xFF2E7D32); // Green
    if (confidence > 0.6) return const Color(0xFFF57C00); // Orange
    return const Color(0xFFD32F2F); // Red
  }

  void _showScanDetails(BuildContext context, ScanHistory scan, AppLocalizations locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildScanDetailsSheet(scan, context, locale),
    );
  }

  Widget _buildScanDetailsSheet(ScanHistory scan, BuildContext context, AppLocalizations locale) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2EFDA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDiseaseIcon(scan.disease),
                    color: const Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.disease,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm').format(scan.timestamp),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(scan.confidence),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(scan.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Image Comparison Section
            if (scan.isOnline && (scan.originalImageUrl != null || scan.heatmapUrl != null))
              _buildImageComparisonSection(scan, locale),
            
            // Details Section
            _buildDetailsSection(scan, locale),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                    ),
                    child: Text(locale.close),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageComparisonSection(ScanHistory scan, AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.image_analysis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    locale.original,
                    style: const TextStyle(
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
                      child: _buildHistoryImage(scan.originalImageUrl, locale.original, locale),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                children: [
                  Text(
                    locale.heatmap,
                    style: const TextStyle(
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
                      child: _buildHistoryImage(scan.heatmapUrl, locale.heatmap, locale),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDetailsSection(ScanHistory scan, AppLocalizations locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.scan_details,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B5E20),
          ),
        ),
        const SizedBox(height: 16),
        
        _buildDetailItem(locale.severity, scan.severity ?? locale.not_available),
        _buildDetailItem(locale.analysis_mode, scan.isOnline ? 'Online' : 'Offline'),
        
        if (scan.treatment.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            locale.treatment_advice,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 8),
          ...scan.treatment.entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 8, right: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ).toList(),
        ],
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B5E20),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildHistoryImage(String? imageUrl, String placeholder, AppLocalizations locale) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFFF8FDF8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_rounded, color: Colors.grey[400], size: 30),
            const SizedBox(height: 4),
            Text(
              placeholder,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF8FDF8),
          child: Center(
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF8FDF8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.grey[400], size: 30),
              const SizedBox(height: 4),
              Text(
                locale.image_unavailable,
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ScanHistory scan, AppLocalizations locale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(locale.delete_scan),
        content: Text(locale.this_will_permanently_delete(scan.disease)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(locale.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AnalysisProvider>(context, listen: false)
                  .deleteScan(scan.id)
                  .catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete scan: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              });
            },
            child: Text(locale.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}