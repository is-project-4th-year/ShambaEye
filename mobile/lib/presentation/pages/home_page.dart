import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shamba_eye_app/presentation/providers/analysis_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShambaEye'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Navigate to history page
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor!,
                  Theme.of(context).primaryColor!.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.agriculture, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Crop Disease Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload or capture an image of your crop leaf for analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture'),
                    onPressed: () => _pickImage(context, ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Recent Analyses or Empty State
          Expanded(
            child: Consumer<AnalysisProvider>(
              builder: (context, provider, child) {
                if (provider.analyses.isEmpty) {
                  return const EmptyStateWidget();
                }
                return const AnalysisHistoryList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      // Navigate to analysis page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisPage(imagePath: image.path),
        ),
      );
    }
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No analyses yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture or upload an image to get started',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder widgets - you'll create these next
class AnalysisHistoryList extends StatelessWidget {
  const AnalysisHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Analysis history will appear here'));
  }
}

class AnalysisPage extends StatelessWidget {
  final String imagePath;

  const AnalysisPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('placeholder', width: 200, height: 200), // You'll add actual image display
            const SizedBox(height: 20),
            const Text('Image selected for analysis'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AnalysisProvider>().analyzeImage(imagePath);
              },
              child: const Text('Analyze Image'),
            ),
          ],
        ),
      ),
    );
  }
}