import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AnalysisProvider(),
      child: MaterialApp(
        title: 'ShambaEye',
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF2E7D32),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

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
        Uri.parse('http://10.0.2.2:8000/analyze/')
      );
      request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      _analysisResult = json.decode(responseData);

      // Call severity endpoint
      request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://10.0.2.2:8000/severity/')
      );
      request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
      
      response = await request.send();
      responseData = await response.stream.bytesToString();
      _severityResult = json.decode(responseData);

    } catch (e) {
      _error = e.toString();
      print('Error: $e');
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShambaEye'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Will add info dialog later
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
    );
  }
}

class ImageSelectionView extends StatelessWidget {
  const ImageSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green[700]!,
                  Colors.green[500]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.agriculture, size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Crop Disease Detection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Capture or upload an image of your crop leaf for instant analysis and treatment recommendations',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'Capture',
                  onPressed: () => context.read<AnalysisProvider>().pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: () => context.read<AnalysisProvider>().pickImage(ImageSource.gallery),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Features Section
          _buildFeatureSection(),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(icon, size: 40, color: Colors.green[700]),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How it works:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.photo_camera,
          title: 'Capture Image',
          description: 'Take a clear photo of the affected crop leaf',
        ),
        _buildFeatureItem(
          icon: Icons.analytics,
          title: 'AI Analysis',
          description: 'Our model detects diseases with high accuracy',
        ),
        _buildFeatureItem(
          icon: Icons.medical_services,
          title: 'Get Treatment',
          description: 'Receive organic and chemical treatment advice',
        ),
        _buildFeatureItem(
          icon: Icons.insights,
          title: 'Severity Assessment',
          description: 'Understand the severity level of the infection',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
              onPressed: provider.analyzeImage,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (provider.analysisResult == null) {
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
            const Text(
              'Tap the button below to analyze your image',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze Image'),
              onPressed: provider.analyzeImage,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Show results
    return _buildResultsView(context, provider);
  }

  Widget _buildResultsView(BuildContext context, AnalysisProvider provider) {
    final analysis = provider.analysisResult!;
    final severity = provider.severityResult;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  _buildResultRow('Disease', analysis['disease']),
                  _buildResultRow('Confidence', 
                    '${(analysis['confidence'] * 100).toStringAsFixed(1)}%'),
                  if (severity != null)
                    _buildResultRow('Severity', severity['severity']),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Treatment Card
          if (analysis['treatment'] != null)
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
                    if (analysis['treatment']['organic_treatment'] != null)
                      _buildTreatmentSection(
                        'Organic Treatment',
                        analysis['treatment']['organic_treatment'],
                      ),
                    if (analysis['treatment']['chemical_treatment'] != null)
                      _buildTreatmentSection(
                        'Chemical Treatment',
                        analysis['treatment']['chemical_treatment'],
                      ),
                    if (analysis['treatment']['prevention'] != null)
                      _buildTreatmentSection(
                        'Prevention',
                        analysis['treatment']['prevention'],
                      ),
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
                  onPressed: () => context.read<AnalysisProvider>().clearResults(),
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

  Widget _buildTreatmentSection(String title, String content) {
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
}