class AnalysisResult {
  final String disease;
  final double confidence;
  final Map<String, dynamic> treatment;
  final String? severity;
  final String? heatmapUrl;
  final bool isOnline;
  final DateTime timestamp;

  AnalysisResult({
    required this.disease,
    required this.confidence,
    required this.treatment,
    this.severity,
    this.heatmapUrl,
    required this.isOnline,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'confidence': confidence,
      'treatment': treatment,
      'severity': severity,
      'heatmapUrl': heatmapUrl,
      'isOnline': isOnline,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  static AnalysisResult fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      disease: map['disease'],
      confidence: map['confidence'].toDouble(),
      treatment: Map<String, dynamic>.from(map['treatment']),
      severity: map['severity'],
      heatmapUrl: map['heatmapUrl'],
      isOnline: map['isOnline'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}