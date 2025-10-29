import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShambaEye',
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _imagePath;
  bool _isLoading = false;
  String _result = '';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _result = '';
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imagePath == null) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    try {
      // Call analyze endpoint
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://10.0.2.2:8000/analyze/')
      );
      request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
      
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var analysisResult = json.decode(responseData);

      // Call severity endpoint
      request = http.MultipartRequest(
        'POST', 
        Uri.parse('http://10.0.2.2:8000/severity/')
      );
      request.files.add(await http.MultipartFile.fromPath('file', _imagePath!));
      
      response = await request.send();
      responseData = await response.stream.bytesToString();
      var severityResult = json.decode(responseData);

      setState(() {
        _result = '''
Disease: ${analysisResult['disease']}
Confidence: ${(analysisResult['confidence'] * 100).toStringAsFixed(1)}%
Severity: ${severityResult['severity']}

Treatment:
${analysisResult['treatment']['organic_treatment']}
''';
      });

    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShambaEye'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
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
                    'Upload or capture an image of your crop leaf',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture'),
                    onPressed: () => _pickImage(ImageSource.camera),
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
                    onPressed: () => _pickImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Image Preview
            if (_imagePath != null) ...[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _analyzeImage,
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Analyze Image'),
              ),
              const SizedBox(height: 16),
            ],

            // Results
            if (_result.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],

            // Empty State
            if (_imagePath == null && _result.isEmpty) ...[
              const SizedBox(height: 40),
              Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No image selected',
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
          ],
        ),
      ),
    );
  }
}