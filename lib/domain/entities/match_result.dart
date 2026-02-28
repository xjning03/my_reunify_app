import 'package:my_reunify_app/domain/entities/case.dart';

/// Represents the result of matching a memory to potential cases.
/// Includes the matched case, similarity score, and reasoning.
class MatchResult {
  /// The case that this result refers to
  final Case matchedCase;

  /// Overall matching score (0.0 - 1.0)
  final double totalScore;

  /// Demographic compatibility score
  final double demographicScore;

  /// Geographic/region compatibility score
  final double geographicScore;

  /// Linguistic/language compatibility score
  final double linguisticScore;

  /// Temporal/time compatibility score
  final double temporalScore;

  /// Environmental/contextual compatibility score
  final double environmentalScore;

  /// Details of what matched
  final List<String> explanations;

  /// Map of all contributing factors to their scores
  final Map<String, double> contributingFactors;

  /// Rank among all results (1 = highest match)
  final int rank;

  /// Timestamp of match generation
  final DateTime matchedAt;

  /// Unique match ID
  final String matchId;

  MatchResult({
    required this.matchedCase,
    required this.totalScore,
    required this.demographicScore,
    required this.geographicScore,
    required this.linguisticScore,
    required this.temporalScore,
    required this.environmentalScore,
    required this.explanations,
    required this.contributingFactors,
    required this.rank,
    required this.matchedAt,
    required this.matchId,
  });

  /// Calculate match quality level (Poor, Fair, Good, Excellent)
  String getQualityLevel() {
    if (totalScore >= 0.8) return 'Excellent';
    if (totalScore >= 0.6) return 'Good';
    if (totalScore >= 0.4) return 'Fair';
    return 'Poor';
  }

  MatchResult copyWith({
    Case? matchedCase,
    double? totalScore,
    double? demographicScore,
    double? geographicScore,
    double? linguisticScore,
    double? temporalScore,
    double? environmentalScore,
    List<String>? explanations,
    Map<String, double>? contributingFactors,
    int? rank,
    DateTime? matchedAt,
    String? matchId,
  }) {
    return MatchResult(
      matchedCase: matchedCase ?? this.matchedCase,
      totalScore: totalScore ?? this.totalScore,
      demographicScore: demographicScore ?? this.demographicScore,
      geographicScore: geographicScore ?? this.geographicScore,
      linguisticScore: linguisticScore ?? this.linguisticScore,
      temporalScore: temporalScore ?? this.temporalScore,
      environmentalScore: environmentalScore ?? this.environmentalScore,
      explanations: explanations ?? this.explanations,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      rank: rank ?? this.rank,
      matchedAt: matchedAt ?? this.matchedAt,
      matchId: matchId ?? this.matchId,
    );
  }

  @override
  String toString() =>
      'MatchResult(case: ${matchedCase.id}, score: ${(totalScore * 100).toStringAsFixed(1)}%, rank: $rank)';
}
