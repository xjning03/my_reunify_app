import 'package:my_reunify_app/domain/entities/case.dart';
import 'package:my_reunify_app/domain/entities/match_result.dart';
import 'package:my_reunify_app/domain/entities/memory_clue.dart';
import 'package:my_reunify_app/domain/entities/region_hypothesis.dart';
import 'package:my_reunify_app/inference/engines/clue_extractor.dart';
import 'package:my_reunify_app/inference/engines/region_inference_engine.dart';
import 'package:my_reunify_app/inference/engines/matching_engine.dart';
import 'package:my_reunify_app/inference/engines/confidence_calculator.dart';

/// Orchestrates the entire inference pipeline
/// This is the main service that coordinates all inference components
class InferenceService {
  final ClueExtractor _clueExtractor;
  final RegionInferenceEngine _regionInferenceEngine;
  final MatchingEngine _matchingEngine;

  InferenceService({
    required ClueExtractor clueExtractor,
    required RegionInferenceEngine regionInferenceEngine,
    required MatchingEngine matchingEngine,
  }) : _clueExtractor = clueExtractor,
       _regionInferenceEngine = regionInferenceEngine,
       _matchingEngine = matchingEngine;

  /// Main inference pipeline: Memory → Clues → Regions → Matches
  Future<InferenceResult> processMemory({
    required String rawMemoryText,
    required List<Case> availableCases,
  }) async {
    // Stage 1: Semantic interpretation
    final clues = await _clueExtractor.extractClues(rawMemoryText);

    // Stage 2: Geographic inference
    final regionHypotheses = await _regionInferenceEngine.inferRegions(clues);

    // Stage 3: Case matching
    final matches = await _matchingEngine.matchMemoryToCases(
      memoryClues: clues,
      regionHypotheses: regionHypotheses,
      availableCases: availableCases,
    );

    // Calculate system confidence
    final systemConfidence = ConfidenceCalculator.calculateSystemConfidence(
      regionHypotheses,
    );

    return InferenceResult(
      rawMemoryText: rawMemoryText,
      extractedClues: clues,
      regionHypotheses: regionHypotheses,
      matchResults: matches,
      systemConfidence: systemConfidence,
      processedAt: DateTime.now(),
    );
  }
}

/// Result of the complete inference pipeline
class InferenceResult {
  /// Original raw memory text provided by user
  final String rawMemoryText;

  /// Extracted semantic clues from Stage 1
  final List<MemoryClue> extractedClues;

  /// Geographic region hypotheses from Stage 2
  final List<RegionHypothesis> regionHypotheses;

  /// Case matching results from Stage 3
  final List<MatchResult> matchResults;

  /// Overall system confidence (0.0-1.0)
  final double systemConfidence;

  /// When was this result generated
  final DateTime processedAt;

  InferenceResult({
    required this.rawMemoryText,
    required this.extractedClues,
    required this.regionHypotheses,
    required this.matchResults,
    required this.systemConfidence,
    required this.processedAt,
  });

  /// Get top matches (can filter by minimum confidence)
  List<MatchResult> getTopMatches({int limit = 5, double minimumScore = 0.0}) {
    return matchResults
        .where((m) => m.totalScore >= minimumScore)
        .take(limit)
        .toList();
  }

  /// Get the best match if any
  MatchResult? getBestMatch({double minimumScore = 0.0}) {
    if (matchResults.isEmpty) return null;
    if (matchResults.first.totalScore < minimumScore) return null;
    return matchResults.first;
  }

  /// Get clues by type
  List<MemoryClue> getCluesByType(ClueType type) {
    return extractedClues.where((c) => c.type == type).toList();
  }

  /// Get top regions
  List<RegionHypothesis> getTopRegions({int limit = 5}) {
    return regionHypotheses.take(limit).toList();
  }

  /// Get inference summary
  String getSummary() {
    final buffer = StringBuffer();

    buffer.writeln('=== INFERENCE PIPELINE SUMMARY ===');
    buffer.writeln('');

    buffer.writeln('STAGE 1: Semantic Interpretation');
    buffer.writeln('  Clues extracted: ${extractedClues.length}');
    if (extractedClues.isNotEmpty) {
      final cluesByType = <ClueType, int>{};
      for (final clue in extractedClues) {
        cluesByType[clue.type] = (cluesByType[clue.type] ?? 0) + 1;
      }
      for (final entry in cluesByType.entries) {
        buffer.writeln(
          '    - ${entry.key.toString().split('.').last}: ${entry.value}',
        );
      }
    }
    buffer.writeln('');

    buffer.writeln('STAGE 2: Geographic Inference');
    buffer.writeln('  Region hypotheses: ${regionHypotheses.length}');
    if (regionHypotheses.isNotEmpty) {
      for (final hyp in regionHypotheses.take(3)) {
        buffer.writeln(
          '    - ${hyp.regionName}: ${(hyp.confidence * 100).toStringAsFixed(1)}%',
        );
      }
    }
    buffer.writeln('');

    buffer.writeln('STAGE 3: Case Matching');
    buffer.writeln('  Matching results: ${matchResults.length}');
    if (matchResults.isNotEmpty) {
      for (final match in matchResults.take(3)) {
        buffer.writeln(
          '    - ${match.matchedCase.id}: ${(match.totalScore * 100).toStringAsFixed(1)}%',
        );
      }
    }
    buffer.writeln('');

    buffer.writeln(
      'System Confidence: ${(systemConfidence * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln('Timestamp: $processedAt');

    return buffer.toString();
  }
}
