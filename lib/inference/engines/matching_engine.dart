import 'package:my_reunify_app/domain/entities/case.dart';
import 'package:my_reunify_app/domain/entities/memory_clue.dart';
import 'package:my_reunify_app/domain/entities/match_result.dart';
import 'package:my_reunify_app/domain/entities/region_hypothesis.dart';
import 'package:my_reunify_app/inference/knowledge_base/demographic_rules.dart';

/// Deterministic case matching engine.
/// Converts region hypotheses and memory clues to similarity scores.
class MatchingEngine {
  /// Match memory clues to available cases
  Future<List<MatchResult>> matchMemoryToCases({
    required List<MemoryClue> memoryClues,
    required List<RegionHypothesis> regionHypotheses,
    required List<Case> availableCases,
  }) async {
    if (availableCases.isEmpty) {
      return [];
    }

    final results = <MatchResult>[];

    for (final candidateCase in availableCases) {
      final score = _calculateMatchScore(
        memoryClues: memoryClues,
        regionHypotheses: regionHypotheses,
        candidateCase: candidateCase,
      );

      results.add(score);
    }

    // Sort by total score descending
    results.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    // Assign ranks
    for (int i = 0; i < results.length; i++) {
      results[i] = results[i].copyWith(rank: i + 1);
    }

    return results;
  }

  /// Calculate match score for a single case
  MatchResult _calculateMatchScore({
    required List<MemoryClue> memoryClues,
    required List<RegionHypothesis> regionHypotheses,
    required Case candidateCase,
  }) {
    // Extract languages from memory clues
    final memoryLanguages = _extractLanguages(memoryClues);
    final memoryRace = _extractRace(memoryClues);
    final memoryAge = _extractAge(memoryClues);
    final memoryName = _extractName(memoryClues);

    // Get case details
    final caseLanguages = candidateCase.knownLanguages ?? ['ms'];
    final caseRace = candidateCase.childRace;
    final caseAge = candidateCase.childAge;
    final caseName = candidateCase.childName;
    final caseRegion = candidateCase.region;

    // Calculate individual scores
    final geographicScore = _calculateGeographicScore(
      regionHypotheses: regionHypotheses,
      caseRegion: caseRegion,
    );

    final demographicScore = _calculateDemographicScore(
      memoryRace: memoryRace,
      caseRace: caseRace,
      memoryAge: memoryAge,
      caseAge: caseAge,
      region: caseRegion,
    );

    final linguisticScore = _calculateLinguisticScore(
      memoryLanguages: memoryLanguages,
      caseLanguages: caseLanguages,
    );

    final nameScore = _calculateNameScore(
      memoryName: memoryName,
      caseName: caseName,
    );

    // Temporal score (simplified - would use temporal clues)
    const temporalScore = 0.7;

    // Environmental score (simplified)
    const environmentalScore = 0.6;

    // Calculate weighted total
    final totalScore = _calculateWeightedTotal(
      geographicScore: geographicScore,
      demographicScore: demographicScore,
      linguisticScore: linguisticScore,
      temporalScore: temporalScore,
      environmentalScore: environmentalScore,
      nameScore: nameScore,
    );

    // Generate explanations
    final explanations = _generateExplanations(
      geographicScore: geographicScore,
      demographicScore: demographicScore,
      linguisticScore: linguisticScore,
      nameScore: nameScore,
      temporalScore: temporalScore,
      environmentalScore: environmentalScore,
      caseRegion: caseRegion,
      memoryRace: memoryRace,
      caseRace: caseRace,
    );

    // Compile contributing factors
    final contributingFactors = {
      'geographic': geographicScore * 0.30,
      'demographic': demographicScore * 0.25,
      'linguistic': linguisticScore * 0.20,
      'temporal': temporalScore * 0.10,
      'environmental': environmentalScore * 0.10,
      'name': nameScore * 0.05,
    };

    return MatchResult(
      matchedCase: candidateCase,
      totalScore: totalScore,
      geographicScore: geographicScore,
      demographicScore: demographicScore,
      linguisticScore: linguisticScore,
      temporalScore: temporalScore,
      environmentalScore: environmentalScore,
      explanations: explanations,
      contributingFactors: contributingFactors,
      rank: 0, // Will be set after sorting
      matchedAt: DateTime.now(),
      matchId:
          'match_${candidateCase.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Calculate geographic score
  double _calculateGeographicScore({
    required List<RegionHypothesis> regionHypotheses,
    required String? caseRegion,
  }) {
    if (regionHypotheses.isEmpty || caseRegion == null) {
      return 0.5; // Neutral if no geographical data
    }

    // Find matching region in hypotheses
    for (final hypothesis in regionHypotheses) {
      if (hypothesis.regionName == caseRegion) {
        return hypothesis.confidence; // Return the confidence for that region
      }
    }

    // Case region is not in hypotheses - lower score
    return 0.2;
  }

  /// Calculate demographic score
  double _calculateDemographicScore({
    required String? memoryRace,
    required String? caseRace,
    required String? memoryAge,
    required String? caseAge,
    required String? region,
  }) {
    double score = 0.5; // Base score

    // Check race compatibility
    final raceScore = DemographicRules.checkDemographicCompatibility(
      caseRace: caseRace,
      memoryRace: memoryRace,
      region: region,
    );
    score += raceScore * 0.5;

    // Check age compatibility
    final ageScore = DemographicRules.checkAgeCompatibility(
      caseAge: caseAge,
      memoryAge: memoryAge,
    );
    score += ageScore * 0.5;

    return (score / 2.0).clamp(0.0, 1.0);
  }

  /// Calculate linguistic score
  double _calculateLinguisticScore({
    required List<String> memoryLanguages,
    required List<String> caseLanguages,
  }) {
    if (memoryLanguages.isEmpty) {
      return 0.6; // Inconclusive
    }

    return DemographicRules.checkLanguageCompatibility(
      caseLanguages: caseLanguages,
      memoryLanguages: memoryLanguages,
    );
  }

  /// Calculate name similarity score
  double _calculateNameScore({
    required String? memoryName,
    required String? caseName,
  }) {
    if (memoryName == null || caseName == null) {
      return 0.5; // Inconclusive
    }

    return DemographicRules.checkNameSimilarity(
      caseName: caseName,
      memoryName: memoryName,
    );
  }

  /// Calculate weighted total score
  double _calculateWeightedTotal({
    required double geographicScore,
    required double demographicScore,
    required double linguisticScore,
    required double temporalScore,
    required double environmentalScore,
    required double nameScore,
  }) {
    // Weights sum to 1.0
    const geoWeight = 0.30;
    const demoWeight = 0.25;
    const lingWeight = 0.20;
    const tempWeight = 0.10;
    const envWeight = 0.10;
    const nameWeight = 0.05;

    final total =
        (geographicScore * geoWeight) +
        (demographicScore * demoWeight) +
        (linguisticScore * lingWeight) +
        (temporalScore * tempWeight) +
        (environmentalScore * envWeight) +
        (nameScore * nameWeight);

    return total.clamp(0.0, 1.0);
  }

  /// Generate human-readable explanation for the match
  List<String> _generateExplanations({
    required double geographicScore,
    required double demographicScore,
    required double linguisticScore,
    required double nameScore,
    required double temporalScore,
    required double environmentalScore,
    required String? caseRegion,
    required String? memoryRace,
    required String? caseRace,
  }) {
    final explanations = <String>[];

    if (geographicScore >= 0.7) {
      explanations.add('Geographic region matches: $caseRegion');
    } else if (geographicScore >= 0.5) {
      explanations.add('Geographic region partially matches');
    }

    if (demographicScore >= 0.8) {
      if (memoryRace == caseRace) {
        explanations.add('Demographic data matches exactly');
      } else {
        explanations.add('Demographic data is compatible');
      }
    }

    if (linguisticScore >= 0.8) {
      explanations.add('Language evidence is strong');
    } else if (linguisticScore >= 0.6) {
      explanations.add('Language evidence is moderate');
    }

    if (nameScore >= 0.8) {
      explanations.add('Name is similar or matches');
    }

    if (temporalScore >= 0.7) {
      explanations.add('Temporal evidence aligns');
    }

    if (environmentalScore >= 0.7) {
      explanations.add('Environmental clues are consistent');
    }

    return explanations.isEmpty ? ['Limited matching evidence'] : explanations;
  }

  /// Extract languages from memory clues
  List<String> _extractLanguages(List<MemoryClue> clues) {
    return clues
        .where((c) => c.type == ClueType.language)
        .map((c) => c.value)
        .toSet()
        .toList();
  }

  /// Extract race from memory clues
  String? _extractRace(List<MemoryClue> clues) {
    // Try to find person clues that might indicate race
    for (final clue in clues) {
      if (clue.type == ClueType.person && clue.geographicWeight > 0.5) {
        return clue.value;
      }
    }
    return null;
  }

  /// Extract age from memory clues
  String? _extractAge(List<MemoryClue> clues) {
    // Look for person clues that mention age
    for (final clue in clues) {
      if (clue.type == ClueType.person && clue.value.contains('year')) {
        return clue.value;
      }
    }
    return null;
  }

  /// Extract name from memory clues
  String? _extractName(List<MemoryClue> clues) {
    for (final clue in clues) {
      if (clue.type == ClueType.person && clue.value.length > 2) {
        return clue.value;
      }
    }
    return null;
  }
}
