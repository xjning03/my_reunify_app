library my_reunify_app;

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:my_reunify_app/domain/entities/user.dart';

// Model & Data Layer
part 'model/models.dart';
part 'data/services.dart';

// View Layer - UI Components
part 'view/ui_components.dart';

// View Layer - Pages
part 'view/pages/role_selection_page.dart';
part 'view/pages/home_page.dart';
part 'view/pages/search/parent_case_search_page.dart';
part 'view/pages/search/family_searching_page.dart';
part 'view/pages/search/user_timeline_page.dart';
part 'view/pages/reports/parent_case_report_detail_page.dart';
part 'view/pages/reports/child_memory_report_detail_page.dart';
part 'view/pages/reports/detail_compat.dart';
part 'view/pages/chat/chat_page.dart';
part 'view/pages/chat/chat_inbox_page.dart';
part 'view/pages/details/modern_case_detail_page.dart';
part 'view/pages/forms/parent_form_page.dart';
part 'view/pages/forms/child_memory_form_page.dart';
part 'view/pages/match_results_page.dart';

/// ===============================================
/// APP COLOR STANDARDIZATION
/// ===============================================

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color secondary = Color(0xFF7B1FA2);
  static const Color accent = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);
}

/// ===============================================
/// MAIN APP
/// ===============================================

void main() {
  runApp(const ModernReunifyApp());
}

class ModernReunifyApp extends StatelessWidget {
  const ModernReunifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = EnhancedMockDataRepository();
    final textProcessing = EnhancedTextProcessingService();
    final poiService = EnhancedMockPoiService();
    final matchingService = EnhancedMatchingService(
      textProcessing: textProcessing,
      poiService: poiService,
    );
    final tagAnalysisService = AITagAnalysisService(
      textProcessing: textProcessing,
    );

    return MaterialApp(
      title: 'Reunify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        fontFamily: 'Poppins',
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
      home: ModernRoleSelectionPage(
        repository: repository,
        matchingService: matchingService,
        tagAnalysisService: tagAnalysisService,
      ),
    );
  }
}
