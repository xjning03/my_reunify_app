/// Demographic and matching rules for Malaysia.
/// Hard-coded rules for demographic compatibility checking.
class DemographicRules {
  /// Common Malaysian races/ethnicities
  static const List<String> races = [
    'Malay',
    'Chinese',
    'Indian',
    'Eurasian',
    'Indigenous',
    'Other',
  ];

  /// Race population distribution by region (simplified)
  static const Map<String, Map<String, double>> raceByRegion = {
    'Selangor': {'Malay': 0.4, 'Chinese': 0.35, 'Indian': 0.20, 'Other': 0.05},
    'Penang': {'Chinese': 0.45, 'Malay': 0.35, 'Indian': 0.15, 'Other': 0.05},
    'Kuala Lumpur': {
      'Chinese': 0.40,
      'Malay': 0.35,
      'Indian': 0.20,
      'Other': 0.05,
    },
    'Johor': {'Malay': 0.50, 'Chinese': 0.30, 'Indian': 0.15, 'Other': 0.05},
    'Kelantan': {'Malay': 0.85, 'Chinese': 0.10, 'Indian': 0.03, 'Other': 0.02},
    'Perak': {'Malay': 0.45, 'Chinese': 0.35, 'Indian': 0.15, 'Other': 0.05},
    'Sabah': {
      'Indigenous': 0.50,
      'Malay': 0.25,
      'Chinese': 0.20,
      'Other': 0.05,
    },
    'Sarawak': {
      'Indigenous': 0.55,
      'Malay': 0.20,
      'Chinese': 0.20,
      'Other': 0.05,
    },
  };

  /// Age categories
  static const Map<String, (int, int)> ageCategories = {
    'infant': (0, 2),
    'toddler': (2, 5),
    'child': (5, 12),
    'preteen': (8, 12),
    'teen': (13, 18),
    'young_adult': (18, 30),
  };

  /// Check demographic compatibility
  static double checkDemographicCompatibility({
    required String? caseRace,
    required String? memoryRace,
    required String? region,
  }) {
    if (memoryRace == null || memoryRace.isEmpty) {
      return 0.7; // Moderate confidence without race info
    }

    if (caseRace == null || caseRace.isEmpty) {
      return 0.7; // Moderate confidence without case race
    }

    // Exact match
    if (caseRace.toLowerCase() == memoryRace.toLowerCase()) {
      return 1.0;
    }

    // Check regional plausibility
    if (region != null && raceByRegion.containsKey(region)) {
      final regionRaces = raceByRegion[region]!;
      final memoryNotTypical = (regionRaces[memoryRace] ?? 0.0) < 0.10;
      final caseNotTypical = (regionRaces[caseRace] ?? 0.0) < 0.10;

      if (memoryNotTypical && !caseNotTypical) {
        return 0.5; // Memory describes rare race for region
      }
      if (caseNotTypical && memoryNotTypical) {
        return 0.8; // Both are rare for region - plausible match
      }
    }

    // Similar races (within same ethnic group)
    if (_areSimilarRaces(caseRace, memoryRace)) {
      return 0.7;
    }

    return 0.4; // Different races - lower score
  }

  /// Check age compatibility
  static double checkAgeCompatibility({
    required String? caseAge,
    required String? memoryAge,
  }) {
    if (memoryAge == null || memoryAge.isEmpty) {
      return 0.7; // Moderate confidence without age
    }

    if (caseAge == null || caseAge.isEmpty) {
      return 0.7;
    }

    try {
      // Try to parse as numeric ages
      final memoryAgeInt = int.tryParse(
        memoryAge.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      final caseAgeInt = int.tryParse(
        caseAge.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      if (memoryAgeInt != null && caseAgeInt != null) {
        final diff = (memoryAgeInt - caseAgeInt).abs();
        if (diff == 0) return 1.0;
        if (diff <= 2) return 0.9;
        if (diff <= 5) return 0.7;
        if (diff <= 10) return 0.5;
        return 0.2;
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return 0.6; // Default moderate confidence
  }

  /// Check language compatibility
  static double checkLanguageCompatibility({
    required List<String> caseLanguages,
    required List<String> memoryLanguages,
  }) {
    if (memoryLanguages.isEmpty) return 0.7;
    if (caseLanguages.isEmpty) return 0.7;

    int matches = 0;
    for (final memLang in memoryLanguages) {
      if (caseLanguages.any(
        (lang) => lang.toLowerCase() == memLang.toLowerCase(),
      )) {
        matches++;
      }
    }

    if (matches == memoryLanguages.length) return 1.0; // All match
    if (matches > 0) return 0.8; // Some match
    return 0.4; // No matches
  }

  /// Check name similarity (optional, basic check)
  static double checkNameSimilarity({
    required String? caseName,
    required String? memoryName,
  }) {
    if (caseName == null || memoryName == null) {
      return 0.6; // Inconclusive without both names
    }

    final caseNameLower = caseName.toLowerCase();
    final memoryNameLower = memoryName.toLowerCase();

    if (caseNameLower == memoryNameLower) return 1.0;

    // Check if one is contained in the other
    if (caseNameLower.contains(memoryNameLower) ||
        memoryNameLower.contains(caseNameLower)) {
      return 0.8;
    }

    // Calculate Levenshtein distance for partial matches
    final distance = _levenshteinDistance(caseNameLower, memoryNameLower);
    final maxLength =
        caseNameLower.length > memoryNameLower.length
            ? caseNameLower.length
            : memoryNameLower.length;

    final similarity = 1.0 - (distance / maxLength);
    return similarity.clamp(0.0, 1.0);
  }

  /// Helper: Check if two races are similar (same ethnic group)
  static bool _areSimilarRaces(String race1, String race2) {
    final races1 = _raceVariants[race1.toLowerCase()] ?? [race1.toLowerCase()];
    final races2 = _raceVariants[race2.toLowerCase()] ?? [race2.toLowerCase()];

    for (final r1 in races1) {
      if (races2.contains(r1)) return true;
    }
    return false;
  }

  /// Helper: Race variants/synonyms
  static const Map<String, List<String>> _raceVariants = {
    'malay': ['malay', 'bumiputera'],
    'chinese': ['chinese', 'han', 'sinitic'],
    'indian': ['indian', 'tamil', 'telugu'],
    'eurasian': ['eurasian', 'mixed'],
  };

  /// Helper: Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final d = List<List<int>>.generate(
      len1 + 1,
      (i) => List<int>.filled(len2 + 1, 0),
    );

    for (int i = 0; i <= len1; i++) d[i][0] = i;
    for (int j = 0; j <= len2; j++) d[0][j] = j;

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return d[len1][len2];
  }

  /// Get expected races for a region
  static List<String> getExpectedRacesForRegion(String region) {
    return (raceByRegion[region] ?? {}).keys.toList();
  }
}
