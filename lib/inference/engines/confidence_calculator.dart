import 'package:my_reunify_app/domain/entities/match_result.dart';
import 'package:my_reunify_app/domain/entities/region_hypothesis.dart';

/// Confidence score calculator with explainable reasoning.
class ConfidenceCalculator {
  /// Calculate overall confidence for a match with explanation
  static (double, String) calculateMatchConfidence(MatchResult match) {
    final score = match.totalScore;
    final quality = match.getQualityLevel();
    final explanation = _generateConfidenceExplanation(match);

    return (score, explanation);
  }

  /// Calculate confidence for a region hypothesis
  static (double, String) calculateRegionConfidence(
    RegionHypothesis hypothesis,
  ) {
    final score = hypothesis.confidence;
    final factorCount = hypothesis.contributingFactors.length;

    String explanation =
        'Region ${hypothesis.regionName} has ${(score * 100).toStringAsFixed(1)}% confidence. ';

    if (factorCount == 0) {
      explanation += 'This is based on minimal evidence.';
    } else if (factorCount == 1) {
      explanation += 'This is based on a single factor.';
    } else {
      explanation +=
          'This is based on $factorCount supporting factors: ${hypothesis.contributingFactors.keys.join(", ")}.';
    }

    return (score, explanation);
  }

  /// Calculate a combined confidence score from multiple hypotheses
  static double calculateSystemConfidence(List<RegionHypothesis> hypotheses) {
    if (hypotheses.isEmpty) return 0.0;

    // Calculate entropy/uncertainty
    final confidences = hypotheses.map((h) => h.confidence).toList();
    final maxConfidence = confidences.reduce((a, b) => a > b ? a : b);
    final minConfidence = confidences.reduce((a, b) => a < b ? a : b);

    // Higher max - lower min = more certain about top choice
    final certainty = (maxConfidence - minConfidence).clamp(0.0, 1.0);

    return certainty;
  }

  /// Get confidence level category
  static String getConfidenceLevel(double score) {
    if (score >= 0.85) return 'Very High';
    if (score >= 0.7) return 'High';
    if (score >= 0.55) return 'Moderate';
    if (score >= 0.40) return 'Low';
    return 'Very Low';
  }

  /// Get color indicator for confidence (for UI)
  static String getConfidenceColor(double score) {
    if (score >= 0.85) return '#4CAF50'; // Green
    if (score >= 0.7) return '#8BC34A'; // Light Green
    if (score >= 0.55) return '#FFC107'; // Amber
    if (score >= 0.40) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  /// Generate detailed confidence explanation
  static String _generateConfidenceExplanation(MatchResult match) {
    final factors = <String>[];

    if (match.geographicScore >= 0.7) {
      factors.add('Strong geographic alignment');
    } else if (match.geographicScore >= 0.5) {
      factors.add('Moderate geographic alignment');
    }

    if (match.demographicScore >= 0.8) {
      factors.add('matching demographics');
    } else if (match.demographicScore >= 0.6) {
      factors.add('partially matching demographics');
    }

    if (match.linguisticScore >= 0.8) {
      factors.add('strong language match');
    } else if (match.linguisticScore >= 0.6) {
      factors.add('moderate language match');
    }

    String explanation =
        'Match confidence of ${(match.totalScore * 100).toStringAsFixed(1)}% ';

    if (factors.isEmpty) {
      explanation += 'based on limited evidence.';
    } else if (factors.length == 1) {
      explanation += 'based on ${factors[0]}.';
    } else {
      explanation +=
          'based on: ${factors.sublist(0, factors.length - 1).join(', ')} and ${factors.last}.';
    }

    // Add caveats
    if (match.totalScore < 0.5) {
      explanation +=
          ' WARNING: This is a low-confidence match. Please verify manually.';
    } else if (match.totalScore < 0.7) {
      explanation += ' This match should be reviewed carefully.';
    }

    return explanation;
  }

  /// Calculate score variations for sensitivity analysis
  static Map<String, double> calculateScoreSensitivity(MatchResult match) {
    return {
      'Geographic weight': _recalculateWithWeight(
        match,
        0.0,
        0.25,
        0.20,
        0.10,
        0.10,
        0.05,
      ),
      'Demographic weight': _recalculateWithWeight(
        match,
        0.40,
        0.0,
        0.20,
        0.10,
        0.10,
        0.05,
      ),
      'Linguistic weight': _recalculateWithWeight(
        match,
        0.30,
        0.25,
        0.0,
        0.10,
        0.10,
        0.05,
      ),
    };
  }

  /// Helper: Recalculate score with different weights
  static double _recalculateWithWeight(
    MatchResult match,
    double geoW,
    double demoW,
    double lingW,
    double tempW,
    double envW,
    double nameW,
  ) {
    return (match.geographicScore * geoW) +
        (match.demographicScore * demoW) +
        (match.linguisticScore * lingW) +
        (match.temporalScore * tempW) +
        (match.environmentalScore * envW);
  }

  /// Generate a report with confidence breakdown
  static String generateConfidenceReport(MatchResult match) {
    final buffer = StringBuffer();

    buffer.writeln('=== Match Confidence Report ===');
    buffer.writeln(
      'Total Score: ${(match.totalScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln('Quality: ${match.getQualityLevel()}');
    buffer.writeln('');

    buffer.writeln('Factor Breakdown:');
    buffer.writeln(
      '  Geographic: ${(match.geographicScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '  Demographic: ${(match.demographicScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '  Linguistic: ${(match.linguisticScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '  Temporal: ${(match.temporalScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      '  Environmental: ${(match.environmentalScore * 100).toStringAsFixed(1)}%',
    );
    buffer.writeln('');

    buffer.writeln('Key Match Points:');
    for (final explanation in match.explanations) {
      buffer.writeln('  • $explanation');
    }
    buffer.writeln('');

    buffer.writeln('Confidence Assessment:');
    buffer.writeln(_generateConfidenceExplanation(match));

    return buffer.toString();
  }
}
