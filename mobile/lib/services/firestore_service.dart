import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http; // 🆕 ADD THIS IMPORT
import 'dart:io';
import 'analysis_model.dart';

class ScanHistory {
  final String id;
  final String userId;
  final String disease;
  final double confidence;
  final Map<String, dynamic> treatment;
  final String? severity;
  final String? heatmapUrl;
  final String? originalImageUrl;
  final bool isOnline;
  final DateTime timestamp;
  final String? imagePath;

  ScanHistory({
    required this.id,
    required this.userId,
    required this.disease,
    required this.confidence,
    required this.treatment,
    this.severity,
    this.heatmapUrl,
    this.originalImageUrl,
    required this.isOnline,
    required this.timestamp,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'disease': disease,
      'confidence': confidence,
      'treatment': treatment,
      'severity': severity,
      'heatmapUrl': heatmapUrl,
      'originalImageUrl': originalImageUrl,
      'isOnline': isOnline,
      'timestamp': FieldValue.serverTimestamp(),
      'imagePath': imagePath,
    };
  }

  static ScanHistory fromMap(String id, Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic timestamp) {
      if (timestamp == null) {
        return DateTime.now();
      }
      
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is String) {
        return DateTime.tryParse(timestamp) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return ScanHistory(
      id: id,
      userId: map['userId'] ?? '',
      disease: map['disease'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      treatment: Map<String, dynamic>.from(map['treatment'] ?? {}),
      severity: map['severity'],
      heatmapUrl: map['heatmapUrl'],
      originalImageUrl: map['originalImageUrl'],
      isOnline: map['isOnline'] ?? false,
      timestamp: parseTimestamp(map['timestamp']),
      imagePath: map['imagePath'],
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _scansCollection => _firestore.collection('scans');

  // 🆕 UPDATED: Save scan with both original image and heatmap upload
  Future<void> saveScan(AnalysisResult result, String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to save scans');
      }

      print('💾 Saving scan to Firestore for user: ${user.uid}');

      String? originalImageUrl;
      String? heatmapStorageUrl;
      
      if (result.isOnline) {
        try {
          // Upload original image
          originalImageUrl = await _uploadImageToStorage(imagePath, 'original');
          print('📸 Original image uploaded: $originalImageUrl');
          
          // 🆕 NEW: Upload heatmap image if available
          if (result.heatmapUrl != null && result.heatmapUrl!.isNotEmpty) {
            try {
              heatmapStorageUrl = await _uploadHeatmapToStorage(result.heatmapUrl!, user.uid);
              print('🔥 Heatmap image uploaded to Firebase Storage: $heatmapStorageUrl');
            } catch (e) {
              print('⚠️ Could not upload heatmap to storage: $e');
              // Keep the original server URL as fallback
              heatmapStorageUrl = result.heatmapUrl;
            }
          }
        } catch (e) {
          print('⚠️ Could not upload images to storage: $e');
          // Continue without image URLs - don't fail the entire scan save
        }
      }

      // Create scan data
      final scanData = {
        'userId': user.uid,
        'disease': result.disease,
        'confidence': result.confidence,
        'treatment': result.treatment,
        'severity': result.severity,
        'heatmapUrl': heatmapStorageUrl ?? result.heatmapUrl, // Use storage URL if available
        'originalImageUrl': originalImageUrl,
        'isOnline': result.isOnline,
        'timestamp': FieldValue.serverTimestamp(),
        'imagePath': imagePath,
      };

      // Save to Firestore
      await _scansCollection.add(scanData);
      print('✅ Scan saved successfully to Firestore');

    } catch (e) {
      print('❌ Error saving scan to Firestore: $e');
      throw Exception('Failed to save scan: $e');
    }
  }

  // Upload original image to Firebase Storage
  Future<String> _uploadImageToStorage(String imagePath, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$type.jpg';
      final ref = _storage.ref().child('scans/${user.uid}/$fileName');

      final file = File(imagePath);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
          'imageType': type,
        },
      );

      final uploadTask = await ref.putFile(file, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading image to storage: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // 🆕 NEW: Upload heatmap from URL to Firebase Storage
  Future<String> _uploadHeatmapToStorage(String heatmapUrl, String userId) async {
    try {
      print('🔄 Downloading heatmap from: $heatmapUrl');
      
      // Download the heatmap image from your server
      final response = await http.get(Uri.parse(heatmapUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download heatmap: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      print('📥 Heatmap downloaded, size: ${bytes.length} bytes');

      // Upload to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_heatmap.jpg';
      final ref = _storage.ref().child('scans/$userId/$fileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
          'imageType': 'heatmap',
          'sourceUrl': heatmapUrl,
        },
      );

      final uploadTask = await ref.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      print('✅ Heatmap uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;

    } catch (e) {
      print('❌ Error uploading heatmap to storage: $e');
      throw Exception('Failed to upload heatmap: $e');
    }
  }

  // Get user's scan history
  Stream<List<ScanHistory>> getScanHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _scansCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ScanHistory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Get single scan by ID
  Future<ScanHistory?> getScan(String scanId) async {
    try {
      final doc = await _scansCollection.doc(scanId).get();
      if (doc.exists) {
        return ScanHistory.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Error getting scan: $e');
      return null;
    }
  }

  // Delete scan
  Future<void> deleteScan(String scanId) async {
    try {
      await _scansCollection.doc(scanId).delete();
      print('🗑️ Scan deleted: $scanId');
    } catch (e) {
      print('❌ Error deleting scan: $e');
      throw Exception('Failed to delete scan: $e');
    }
  }

  // Get scan count
  Future<int> getScanCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final snapshot = await _scansCollection
          .where('userId', isEqualTo: user.uid)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting scan count: $e');
      return 0;
    }
  }
}