/// Language-to-region mapping knowledge base for Malaysia.
/// This hard-coded knowledge base maps detected languages to likely regions.
class LanguageRegionMapping {
  /// Maps language codes to list of regions where likely spoken
  /// Higher index = more likely region
  static const Map<String, List<String>> languagesToRegions = {
    'ms': [
      'Kedah',
      'Perlis',
      'Selangor',
      'Kuala Lumpur',
      'Putrajaya',
      'Perak',
      'Kelantan',
      'Terengganu',
      'Pahang',
      'Penang',
      'Johor',
      'Melaka',
      'Negeri Sembilan',
      'Sabah',
      'Sarawak',
    ], // Malay - everywhere
    'en': [
      'Kuala Lumpur',
      'Selangor',
      'Penang',
      'Johor',
      'Sabah',
      'Sarawak',
    ], // English - urban areas
    'zh': [
      'Penang',
      'Selangor',
      'Kuala Lumpur',
      'Johor',
      'Sarawak',
    ], // Mandarin - Chinese areas
    'ta': [
      'Selangor',
      'Kuala Lumpur',
      'Johor',
      'Penang',
    ], // Tamil - Indian areas
    'fr': ['Kuala Lumpur', 'Selangor', 'Penang'], // French - expat areas
    'ar': [
      'Kuala Lumpur',
      'Selangor',
      'Penang',
    ], // Arabic - Islamic communities
  };

  /// Maps dialect/accent patterns to regions
  static const Map<String, List<String>> dialectsToRegions = {
    'hokkien': ['Penang', 'Selangor', 'Kuala Lumpur'],
    'teochew': ['Johor', 'Selangor'],
    'cantonese': ['Kuala Lumpur', 'Selangor'],
    'hakka': ['Selangor', 'Pahang'],
    'northern_accent': ['Perlis', 'Kedah', 'Penang'],
    'southern_accent': ['Johor', 'Melaka'],
    'east_coast': ['Kelantan', 'Terengganu', 'Pahang'],
  };

  /// Get regions for a detected language with confidence
  static Map<String, double> getRegionsForLanguage(String languageCode) {
    final regions = languagesToRegions[languageCode.toLowerCase()] ?? [];
    if (regions.isEmpty) return {};

    // Assign confidence based on position in list
    final result = <String, double>{};
    for (int i = 0; i < regions.length; i++) {
      // Higher index = lower confidence
      final confidence = 1.0 - (i * 0.1);
      result[regions[i]] = confidence.clamp(0.3, 1.0);
    }
    return result;
  }

  /// Get regions for a detected dialect with confidence
  static Map<String, double> getRegionsForDialect(String dialect) {
    final regions = dialectsToRegions[dialect.toLowerCase()] ?? [];
    if (regions.isEmpty) return {};

    final result = <String, double>{};
    for (int i = 0; i < regions.length; i++) {
      final confidence = 1.0 - (i * 0.15);
      result[regions[i]] = confidence.clamp(0.4, 1.0);
    }
    return result;
  }

  /// Combine multiple language/dialect mappings
  static Map<String, double> combineLanguageEvidence(
    List<String> languages,
    List<String> dialects,
  ) {
    final combined = <String, double>{};

    for (final lang in languages) {
      final langRegions = getRegionsForLanguage(lang);
      for (final entry in langRegions.entries) {
        combined[entry.key] = (combined[entry.key] ?? 0) + (entry.value * 0.6);
      }
    }

    for (final dialect in dialects) {
      final dialectRegions = getRegionsForDialect(dialect);
      for (final entry in dialectRegions.entries) {
        combined[entry.key] = (combined[entry.key] ?? 0) + (entry.value * 0.4);
      }
    }

    // Normalize to 0.0-1.0 range
    if (combined.isNotEmpty) {
      final maxValue = combined.values.reduce((a, b) => a > b ? a : b);
      combined.updateAll((key, value) => value / maxValue);
    }

    return combined;
  }
}
