/// Environmental knowledge base for Malaysia geographic regions.
/// Maps environmental clues to likely regions.
class EnvironmentalKnowledge {
  /// Coastal regions in Malaysia
  static const List<String> coastalRegions = [
    'Penang',
    'Selangor',
    'Johor',
    'Terengganu',
    'Kelantan',
    'Sabah',
    'Sarawak',
    'Melaka',
    'Kedah',
    'Perlis',
  ];

  /// Inland regions
  static const List<String> inlandRegions = [
    'Pahang',
    'Perak',
    'Negeri Sembilan',
    'Kuala Lumpur',
    'Putrajaya',
  ];

  /// Urban/metropolitan regions
  static const List<String> urbanRegions = [
    'Kuala Lumpur',
    'Penang',
    'Selangor',
    'Johor',
  ];

  /// Rural/less developed regions
  static const List<String> ruralRegions = [
    'Pahang',
    'Kelantan',
    'Terengganu',
    'Sarawak',
  ];

  /// Highland/tropical regions (above 300m elevation)
  static const List<String> highlandRegions = [
    'Pahang',
    'Perak',
    'Selangor',
    'Sabah',
  ];

  /// Places of worship and their regions
  static const Map<String, List<String>> placesOfWorship = {
    'mosque|masjid': [
      'Penang',
      'Selangor',
      'Johor',
      'Terengganu',
      'Kelantan',
      'Sabah',
      'Sarawak',
      'Melaka',
      'Kedah',
      'Perlis',
      'Kuala Lumpur',
      'Penang',
      'Selangor',
      'Johor',
    ],
    'temple|kuil': ['Penang', 'Selangor', 'Kuala Lumpur', 'Johor'],
    'church|gereja': ['Penang', 'Selangor', 'Sabah', 'Sarawak'],
    'synagogue': ['Kuala Lumpur', 'Selangor'],
  };

  /// Environmental features and their typical regions
  static const Map<String, List<String>> environmentalFeatures = {
    'beach': coastalRegions,
    'sea': coastalRegions,
    'ocean': coastalRegions,
    'jungle|rainforest': ['Pahang', 'Perak', 'Sabah', 'Sarawak'],
    'river': ['Perak', 'Pahang', 'Sarawak'],
    'mountain': ['Pahang', 'Perak', 'Sabah'],
    'paddy': ['Kelantan', 'Terengganu', 'Kedah', 'Perak'],
    'plantation': ['Johor', 'Perak', 'Pahang'],
  };

  /// Landmarks and their regions
  static const Map<String, List<String>> landmarks = {
    'petronas': ['Kuala Lumpur', 'Selangor'],
    'klcc': ['Kuala Lumpur'],
    'penang_bridge': ['Penang'],
    'sultan_abdul_halim': ['Perak'],
    'istana': ['Kuala Lumpur', 'Selangor'],
    'national_palace': ['Kuala Lumpur'],
    'royal_palace': ['Kuala Lumpur'],
    'cameron_highlands': ['Pahang', 'Perak'],
    'tioman': ['Pahang'],
    'langkawi': ['Kedah'],
  };

  /// Climate patterns by region
  static const Map<String, String> climatePatterns = {
    'monsoon_season': 'Tropical (all regions)',
    'dry_season': 'All',
    'hot_humid': 'Coastal regions',
    'cooler': 'Highlands',
  };

  /// Get regions matching environmental clues
  static Map<String, double> getRegionsForEnvironment(List<String> clues) {
    final confidenceMap = <String, double>{};

    for (final clue in clues) {
      final lowerClue = clue.toLowerCase();

      // Check environmental features
      for (final entry in environmentalFeatures.entries) {
        if (lowerClue.contains(entry.key)) {
          for (final region in entry.value) {
            confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.7;
          }
        }
      }

      // Check landmarks
      for (final entry in landmarks.entries) {
        if (lowerClue.contains(entry.key)) {
          for (final region in entry.value) {
            confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.9;
          }
        }
      }

      // Check places of worship
      for (final entry in placesOfWorship.entries) {
        if (lowerClue.contains(entry.key)) {
          for (final region in entry.value) {
            confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.6;
          }
        }
      }

      // Coastal indicators
      if (lowerClue.contains('beach|seaside|sea|ocean|port') &&
          !lowerClue.contains('not|no')) {
        for (final region in coastalRegions) {
          confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.5;
        }
      }

      // Urban indicators
      if (lowerClue.contains('city|urban|metropolis|shopping|mall') &&
          !lowerClue.contains('not|no')) {
        for (final region in urbanRegions) {
          confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.5;
        }
      }

      // Rural indicators
      if (lowerClue.contains('village|kampong|rural|farm|agricultural') &&
          !lowerClue.contains('not|no')) {
        for (final region in ruralRegions) {
          confidenceMap[region] = (confidenceMap[region] ?? 0.0) + 0.5;
        }
      }
    }

    // Normalize to 0.0-1.0
    if (confidenceMap.isNotEmpty) {
      final maxValue = confidenceMap.values.reduce((a, b) => a > b ? a : b);
      if (maxValue > 0) {
        confidenceMap.updateAll((key, value) => value / maxValue);
      }
    }

    return confidenceMap;
  }

  /// Check if a region is coastal
  static bool isCoastal(String region) => coastalRegions.contains(region);

  /// Check if a region is urban
  static bool isUrban(String region) => urbanRegions.contains(region);
}
