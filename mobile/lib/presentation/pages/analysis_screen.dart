import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/image_selection_view.dart';
import '../widgets/analysis_view.dart';
import 'package:shamba_eye/gen_l10n/app_localizations.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          locale.analyze_plant,
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Color(0xFF1B5E20)),
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.imagePath == null) {
            return const ImageSelectionView();
          } else {
            return Stack(
              children: [
                AnalysisView(),
                // Back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFA8D5BA),
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
                    child: IconButton(
                      onPressed: () => provider.clearResults(),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}