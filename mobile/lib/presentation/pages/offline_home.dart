import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/image_selection_view.dart';
import '../widgets/analysis_view.dart';

class OfflineHome extends StatelessWidget {
  const OfflineHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShambaEye - Offline'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Offline Mode'),
                  content: Text('Basic disease detection only. Login for full features including severity analysis and heatmaps.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.imagePath == null) {
            return const ImageSelectionView();
          } else {
            return AnalysisView();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to login screen
          Navigator.pushNamed(context, '/login');
        },
        icon: Icon(Icons.cloud, color: Colors.white),
        label: Text('Go Online', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        tooltip: 'Login for full features',
      ),
    );
  }
}