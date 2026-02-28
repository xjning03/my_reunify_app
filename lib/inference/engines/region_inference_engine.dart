import 'package:my_reunify_app/domain/entities/memory_clue.dart';
import 'package:my_reunify_app/domain/entities/region_hypothesis.dart';
import 'package:my_reunify_app/inference/knowledge_base/language_region_mapping.dart';
import 'package:my_reunify_app/inference/knowledge_base/environmental_knowledge.dart';
import 'package:my_reunify_app/inference/knowledge_base/demographic_rules.dart';

/// Region inference engine that converts clues to geographic hypotheses.
/// Uses deterministic rule-based inference with weighting.
class RegionInferenceEngine {
  static const String _allRegionsList =
      'Selangor,Kuala Lumpur,Putrajaya,Penang,Perak,Negeri Sembilan,Pahang,Johor,Melaka,Kedah,Perlis,Kelantan,Terengganu,Sabah,Sarawak';

  /// Infer region hypotheses from memory clues
  Future<List<RegionHypothesis>> inferRegions(List<MemoryClue> clues) async {
    if (clues.isEmpty) {
      return _generateDefaultHypotheses();
    }

    final regionScores = <String, _RegionScore>{};

    // Process each clue
    for (final clue in clues) {
      final scores = _scoreClue(clue);
      _mergeScores(regionScores, scores);
    }

    // Convert to hypotheses
    final hypotheses = _convertToHypotheses(regionScores, clues);

    // Sort by confidence
    hypotheses.sort((a, b) => b.confidence.compareTo(a.confidence));

    // Assign ranks
    for (int i = 0; i < hypotheses.length; i++) {
      hypotheses[i] = hypotheses[i]._copyWithId(
        'hyp_${DateTime.now().millisecondsSinceEpoch}_$i',
      );
    }

    return hypotheses;
  }

  /// Score a single clue against all regions
  Map<String, _RegionScore> _scoreClue(MemoryClue clue) {
    final scores = <String, _RegionScore>{};

    switch (clue.type) {
      case ClueType.language:
        final regionScores = LanguageRegionMapping.getRegionsForLanguage(
          clue.value,
        );
        _addScoresToMap(scores, regionScores, 'language_match', clue, 0.8);

      case ClueType.place:
        final placeRegions = _getPlaceRegions(clue.value);
        _addScoresToMap(scores, placeRegions, 'landmark_match', clue, 0.9);

      case ClueType.sound:
        // Sound clues have lower geographic weight
        final soundRegions = _getSoundRegions(clue.value);
        _addScoresToMap(scores, soundRegions, 'sound_match', clue, 0.6);

      case ClueType.visual:
        // Visual clues are context-dependent
        final visualRegions = _getVisualRegions(clue.value);
        _addScoresToMap(scores, visualRegions, 'visual_match', clue, 0.5);

      case ClueType.environmental:
        final envRegions = EnvironmentalKnowledge.getRegionsForEnvironment([
          clue.value,
        ]);
        _addScoresToMap(scores, envRegions, 'environment_match', clue, 0.7);

      case ClueType.person:
      case ClueType.emotion:
      case ClueType.activity:
      case ClueType.time:
      case ClueType.geographical:
        // These have minimal geographic weight
        break;
    }

    return scores;
  }

  /// Get regions associated with a place/landmark
  Map<String, double> _getPlaceRegions(String place) {
    final lowerPlace = place.toLowerCase();
    final result = <String, double>{};

    // Specific landmark mappings
    final landmarks = {
      'mosque': ['Selangor', 'Kuala Lumpur', 'Johor', 'Kelantan'],
      'masjid': ['Selangor', 'Kuala Lumpur', 'Johor', 'Kelantan'],
      'temple': ['Penang', 'Selangor', 'Kuala Lumpur', 'Johor'],
      'church': ['Penang', 'Selangor', 'Sabah'],
      'school': _allRegionsList.split(','),
      'market': ['Penang', 'Selangor', 'Kuala Lumpur', 'Johor'],
      'mall': ['Selangor', 'Kuala Lumpur', 'Penang', 'Johor'],
      'beach': ['Penang', 'Johor', 'Sabah', 'Sarawak'],
      'port': ['Penang', 'Johor', 'Sabah'],
      'mountain': ['Pahang', 'Perak', 'Sabah'],
      'jungle': ['Pahang', 'Perak', 'Sabah', 'Sarawak'],
    };

    for (final entry in landmarks.entries) {
      if (lowerPlace.contains(entry.key)) {
        for (int i = 0; i < entry.value.length; i++) {
          final confidence = 1.0 - (i * 0.15);
          result[entry.value[i]] =
              (result[entry.value[i]] ?? 0) + confidence.clamp(0.5, 1.0);
        }
      }
    }

    return result;
  }

  /// Get regions associated with sounds
  Map<String, double> _getSoundRegions(String sound) {
    final lowerSound = sound.toLowerCase();
    final result = <String, double>{};

    const soundMap = {
      'azan': ['Selangor', 'Kuala Lumpur', 'Kelantan', 'Johor'],
      'temple bells': ['Penang', 'Selangor', 'Kuala Lumpur'],
      'church bells': ['Penang', 'Selangor', 'Sabah'],
    };

    for (final entry in soundMap.entries) {
      if (lowerSound.contains(entry.key)) {
        for (int i = 0; i < entry.value.length; i++) {
          result[entry.value[i]] = 0.8;
        }
      }
    }

    return result;
  }

  /// Get regions associated with visual clues
  Map<String, double> _getVisualRegions(String visual) {
    final lowerVisual = visual.toLowerCase();
    final result = <String, double>{};

    const visualMap = {
      'school uniform': _allRegionsList,
      'flag': _allRegionsList,
    };

    for (final entry in visualMap.entries) {
      if (lowerVisual.contains(entry.key)) {
        final regions = entry.value.split(',');
        for (final region in regions) {
          result[region] = (result[region] ?? 0) + 0.3;
        }
      }
    }

    return result;
  }

  /// Add scores from a scored map to the region score map
  void _addScoresToMap(
    Map<String, _RegionScore> regionScores,
    Map<String, double> clueScores,
    String factorName,
    MemoryClue clue,
    double weight,
  ) {
    for (final entry in clueScores.entries) {
      final region = entry.key;
      final score =
          entry.value *
          clue.extractionConfidence *
          clue.geographicWeight *
          weight;

      if (!regionScores.containsKey(region)) {
        regionScores[region] = _RegionScore(
          region: region,
          totalScore: 0,
          factors: {},
          clueIds: [],
        );
      }

      final existing = regionScores[region]!;
      existing.totalScore += score;
      existing.factors[factorName] =
          (existing.factors[factorName] ?? 0) + score;
      existing.clueIds.add(clue.id);
    }
  }

  /// Merge region scores from multiple clues
  void _mergeScores(
    Map<String, _RegionScore> combined,
    Map<String, _RegionScore> newScores,
  ) {
    for (final entry in newScores.entries) {
      if (combined.containsKey(entry.key)) {
        final existing = combined[entry.key]!;
        existing.totalScore += entry.value.totalScore;
        entry.value.factors.forEach((key, value) {
          existing.factors[key] = (existing.factors[key] ?? 0) + value;
        });
        existing.clueIds.addAll(entry.value.clueIds);
      } else {
        combined[entry.key] = entry.value;
      }
    }
  }

  /// Convert region scores to hypotheses
  List<RegionHypothesis> _convertToHypotheses(
    Map<String, _RegionScore> regionScores,
    List<MemoryClue> clues,
  ) {
    final maxScore =
        regionScores.values.isEmpty
            ? 1.0
            : regionScores.values
                .map((r) => r.totalScore)
                .reduce((a, b) => a > b ? a : b);

    final hypotheses = <RegionHypothesis>[];

    for (final entry in regionScores.entries) {
      final region = entry.key;
      final score = entry.value;

      // Normalize confidence
      final confidence =
          maxScore > 0 ? (score.totalScore / maxScore).clamp(0.0, 1.0) : 0.3;

      // Get region code/coordinates (would come from database)
      final coords = _getRegionCoordinates(region);

      hypotheses.add(
        RegionHypothesis(
          id: 'hyp_${DateTime.now().millisecondsSinceEpoch}_${region.hashCode}',
          regionName: region,
          regionCode: region.substring(0, 2).toUpperCase(),
          confidence: confidence,
          contributingFactors: score.factors,
          supportingClueIds: score.clueIds.toSet().toList(),
          centerLatitude: coords['lat'] as double?,
          centerLongitude: coords['lng'] as double?,
          radiusKm: coords['radius'] as double?,
          explanation: _generateExplanation(region, score.factors, confidence),
          generatedAt: DateTime.now(),
        ),
      );
    }

    return hypotheses;
  }

  /// Generate explanation text for a hypothesis
  String _generateExplanation(
    String region,
    Map<String, double> factors,
    double confidence,
  ) {
    final factorDescriptions = <String>[];

    if (factors.containsKey('language_match') &&
        factors['language_match']! > 0) {
      factorDescriptions.add('language');
    }
    if (factors.containsKey('landmark_match') &&
        factors['landmark_match']! > 0) {
      factorDescriptions.add('landmark');
    }
    if (factors.containsKey('environment_match') &&
        factors['environment_match']! > 0) {
      factorDescriptions.add('environment');
    }
    if (factors.containsKey('sound_match') && factors['sound_match']! > 0) {
      factorDescriptions.add('sound');
    }

    final factorText =
        factorDescriptions.isEmpty
            ? 'Multiple factors'
            : factorDescriptions.join(', ');

    final confidenceText = _getConfidenceText(confidence);

    return '$region is a $confidenceText match based on $factorText evidence.';
  }

  /// Get confidence level text
  String _getConfidenceText(double confidence) {
    if (confidence >= 0.8) return 'strong';
    if (confidence >= 0.6) return 'moderate';
    if (confidence >= 0.4) return 'weak';
    return 'very weak';
  }

  /// Get coordinates for a region (mock data)
  Map<String, dynamic> _getRegionCoordinates(String region) {
    // Mock coordinates - would come from database in production
    const regionCoords = {
      'Selangor': {'lat': 3.0738, 'lng': 101.5183, 'radius': 80.0},
      'Kuala Lumpur': {'lat': 3.1390, 'lng': 101.6869, 'radius': 20.0},
      'Penang': {'lat': 5.3667, 'lng': 100.3036, 'radius': 60.0},
      'Johor': {'lat': 1.4854, 'lng': 103.7618, 'radius': 100.0},
      'Perak': {'lat': 4.5921, 'lng': 101.0901, 'radius': 80.0},
      'Pahang': {'lat': 3.8127, 'lng': 103.3256, 'radius': 200.0},
      'Kelantan': {'lat': 6.1184, 'lng': 102.2381, 'radius': 70.0},
      'Terengganu': {'lat': 5.3117, 'lng': 103.1324, 'radius': 80.0},
      'Kedah': {'lat': 6.1184, 'lng': 100.3688, 'radius': 70.0},
      'Perlis': {'lat': 6.4449, 'lng': 100.2048, 'radius': 40.0},
      'Melaka': {'lat': 2.1896, 'lng': 102.2501, 'radius': 40.0},
      'Negeri Sembilan': {'lat': 2.7258, 'lng': 101.9424, 'radius': 60.0},
      'Sabah': {'lat': 5.3788, 'lng': 118.0753, 'radius': 150.0},
      'Sarawak': {'lat': 1.5533, 'lng': 110.3592, 'radius': 200.0},
      'Putrajaya': {'lat': 2.7258, 'lng': 101.6964, 'radius': 20.0},
    };

    return regionCoords[region] ??
        {'lat': 3.1390, 'lng': 101.6869, 'radius': 100.0};
  }

  /// Generate default hypotheses if no clues available
  List<RegionHypothesis> _generateDefaultHypotheses() {
    final regions = _allRegionsList.split(',');
    final hypotheses = <RegionHypothesis>[];

    for (final region in regions) {
      final coords = _getRegionCoordinates(region);
      hypotheses.add(
        RegionHypothesis(
          id: 'hyp_default_${region.hashCode}',
          regionName: region,
          regionCode: region.substring(0, 2).toUpperCase(),
          confidence: 0.05, // Very low - equal for all regions
          contributingFactors: {},
          supportingClueIds: [],
          centerLatitude: coords['lat'] as double?,
          centerLongitude: coords['lng'] as double?,
          radiusKm: coords['radius'] as double?,
          explanation: 'No specific clues provided for $region.',
          generatedAt: DateTime.now(),
        ),
      );
    }

    return hypotheses;
  }
}

/// Internal class for tracking region scores during inference
class _RegionScore {
  final String region;
  double totalScore;
  final Map<String, double> factors;
  final List<String> clueIds;

  _RegionScore({
    required this.region,
    required this.totalScore,
    required this.factors,
    required this.clueIds,
  });
}

extension on RegionHypothesis {
  RegionHypothesis _copyWithId(String newId) {
    return RegionHypothesis(
      id: newId,
      regionName: regionName,
      regionCode: regionCode,
      confidence: confidence,
      contributingFactors: contributingFactors,
      supportingClueIds: supportingClueIds,
      centerLatitude: centerLatitude,
      centerLongitude: centerLongitude,
      radiusKm: radiusKm,
      explanation: explanation,
      generatedAt: generatedAt,
    );
  }
}
