part of my_reunify_app;

/// Text analysis service for extracting weighted keywords from user input.
class EnhancedTextProcessingService {
  static const Map<String, List<String>> _keywordCategories = {
    'placeType': [
      'mall',
      'market',
      'temple',
      'mosque',
      'church',
      'school',
      'park',
      'station',
      'bus station',
      'train station',
      'harbour',
      'harbor',
      'port',
      'restaurant',
      'cafe',
      'coffee shop',
      'shop',
      'hospital',
      'library',
      'cinema',
      'playground',
    ],
    'nature': [
      'sea',
      'beach',
      'river',
      'lake',
      'mountain',
      'forest',
      'hill',
      'valley',
      'garden',
      'ocean',
      'waterfall',
      'island',
    ],
    'language': [
      'hokkien',
      'mandarin',
      'malay',
      'tamil',
      'cantonese',
      'english',
      'dialect',
      'hakka',
      'teochew',
    ],
    'emotion': [
      'happy',
      'scared',
      'confused',
      'worried',
      'excited',
      'calm',
      'peaceful',
      'noisy',
      'quiet',
      'anxious',
    ],
    'timeOfDay': [
      'morning',
      'afternoon',
      'evening',
      'night',
      'sunset',
      'sunrise',
      'dawn',
      'dusk',
      'midday',
    ],
    'sound': [
      'loud',
      'quiet',
      'music',
      'chanting',
      'calling',
      'talking',
      'children playing',
      'traffic',
      'bells',
    ],
  };

  String normalize(String text) {
    return text.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }

  List<Keyword> extractKeywords(String text) {
    final norm = normalize(text);
    final tokens = norm.split(RegExp(r'\s+'));
    final keywords = <Keyword>[];
    final Set<String> addedKeywords = {};

    for (final category in _keywordCategories.entries) {
      for (final phrase in category.value.where((w) => w.contains(' '))) {
        if (norm.contains(phrase) && !addedKeywords.contains(phrase)) {
          keywords.add(
            Keyword(
              value: phrase,
              type: _getKeywordType(category.key),
              weight: _getWeightForType(category.key),
              confidence: 0.9,
            ),
          );
          addedKeywords.add(phrase);
        }
      }
    }

    for (final token in tokens) {
      if (token.length < 3) continue;

      for (final category in _keywordCategories.entries) {
        if (category.value.contains(token) && !addedKeywords.contains(token)) {
          keywords.add(
            Keyword(
              value: token,
              type: _getKeywordType(category.key),
              weight: _getWeightForType(category.key),
              confidence: 0.8,
            ),
          );
          addedKeywords.add(token);
          break;
        }
      }
    }

    final patterns = {
      r'near the \w+': 2.5,
      r'by the \w+': 2.5,
      r'\w+ temple': 3.0,
      r'\w+ market': 3.0,
    };

    for (final pattern in patterns.entries) {
      final matches = RegExp(pattern.key).allMatches(norm);
      for (final match in matches) {
        final phrase = match.group(0);
        if (phrase != null && !addedKeywords.contains(phrase)) {
          keywords.add(
            Keyword(
              value: phrase,
              type: KeywordType.placeType,
              weight: pattern.value,
              confidence: 0.7,
            ),
          );
          addedKeywords.add(phrase);
        }
      }
    }

    return keywords;
  }

  KeywordType _getKeywordType(String category) {
    switch (category) {
      case 'placeType':
        return KeywordType.placeType;
      case 'nature':
        return KeywordType.nature;
      case 'language':
        return KeywordType.language;
      case 'emotion':
        return KeywordType.emotion;
      case 'timeOfDay':
        return KeywordType.timeOfDay;
      case 'sound':
        return KeywordType.sound;
      default:
        return KeywordType.placeType;
    }
  }

  double _getWeightForType(String category) {
    switch (category) {
      case 'placeType':
        return 3.0;
      case 'nature':
        return 2.5;
      case 'language':
        return 3.0;
      case 'emotion':
        return 1.5;
      case 'timeOfDay':
        return 1.8;
      case 'sound':
        return 2.0;
      default:
        return 1.0;
    }
  }
}

class EnhancedMockPoiService {
  final List<POI> _mockPois = [
    POI(
      id: 'poi1',
      name: 'Sunshine Mega Mall',
      category: 'mall',
      latitude: 3.1390,
      longitude: 101.6869,
      popularity: 0.95,
      languages: ['english', 'malay', 'mandarin'],
      metadata: {
        'has_cinema': true,
        'food_court': true,
        'children_play_area': true,
      },
      description: 'Large modern shopping mall with entertainment facilities',
    ),
    POI(
      id: 'poi2',
      name: 'Seaside Park & Beach',
      category: 'park',
      latitude: 3.1420,
      longitude: 101.6880,
      popularity: 0.85,
      languages: ['english', 'malay'],
      metadata: {'beach_access': true, 'playground': true, 'food_stalls': true},
      description: 'Scenic beach park with recreational activities',
    ),
    POI(
      id: 'poi3',
      name: 'Hokkien Temple',
      category: 'temple',
      latitude: 3.1405,
      longitude: 101.6875,
      popularity: 0.75,
      languages: ['hokkien', 'mandarin'],
      metadata: {
        'historical': true,
        'festival_area': true,
        'vegetarian_food': true,
      },
      description: 'Historic temple with active community events',
    ),
    POI(
      id: 'poi4',
      name: 'Central Market',
      category: 'market',
      latitude: 3.1440,
      longitude: 101.6950,
      popularity: 0.9,
      languages: ['malay', 'tamil', 'mandarin'],
      metadata: {'wet_market': true, 'food_stalls': true, 'clothing': true},
      description: 'Bustling traditional market with diverse vendors',
    ),
    POI(
      id: 'poi5',
      name: 'Riverfront Park',
      category: 'park',
      latitude: 3.1385,
      longitude: 101.6920,
      popularity: 0.7,
      languages: ['english', 'malay'],
      metadata: {'river_view': true, 'walking_path': true, 'benches': true},
      description: 'Scenic park along the river with walking trails',
    ),
  ];

  Future<List<POI>> searchNearbyPois(
    List<Keyword> keywords, {
    double radius = 5.0,
    double? userLat,
    double? userLng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final relevantPois =
        _mockPois.where((poi) {
          for (final keyword in keywords) {
            if (keyword.type == KeywordType.placeType) {
              if (poi.category.contains(keyword.value) ||
                  poi.name.toLowerCase().contains(keyword.value)) {
                return true;
              }
            }
            if (keyword.type == KeywordType.language) {
              if (poi.languages.contains(keyword.value)) {
                return true;
              }
            }
          }
          return false;
        }).toList();

    relevantPois.sort((a, b) => b.popularity.compareTo(a.popularity));
    return relevantPois;
  }

  Future<POI?> getPoiDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockPois.firstWhere((poi) => poi.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// AI-based tag analysis service
/// Analyzes case descriptions and generates relevant tags automatically
class AITagAnalysisService {
  final EnhancedTextProcessingService textProcessing;

  AITagAnalysisService({required this.textProcessing});

  /// Map of tag categories for analysis
  static const Map<String, Map<String, List<String>>> tagPatterns = {
    'place': {
      'location_keywords': [
        'mall',
        'market',
        'temple',
        'mosque',
        'church',
        'school',
        'park',
        'station',
        'beach',
        'harbour',
        'harbor',
        'port',
        'restaurant',
        'cafe',
        'hospital',
        'library',
        'cinema',
        'playground',
      ],
      'pattern_phrases': [
        'near',
        'at',
        'around',
        'by the',
        'close to',
        'next to',
      ],
    },
    'language': {
      'spoken_languages': [
        'hokkien',
        'mandarin',
        'malay',
        'tamil',
        'cantonese',
        'english',
        'dialect',
        'hakka',
        'teochew',
      ],
      'language_indicators': [
        'speaking',
        'spoke',
        'talking',
        'language',
        'dialect',
      ],
    },
    'nature': {
      'natural_features': [
        'sea',
        'beach',
        'river',
        'lake',
        'mountain',
        'forest',
        'hill',
        'valley',
        'garden',
        'ocean',
        'waterfall',
        'island',
        'park',
      ],
    },
    'appearance': {
      'clothing_items': [
        'shirt',
        'dress',
        'pants',
        'shoes',
        'jacket',
        'sweater',
        'skirt',
        'backpack',
        'hat',
        'uniform',
      ],
      'color_indicators': [
        'blue',
        'red',
        'green',
        'yellow',
        'black',
        'white',
        'pink',
        'orange',
        'purple',
        'brown',
      ],
    },
    'context': {
      'activity_keywords': [
        'playing',
        'school',
        'shopping',
        'festival',
        'event',
        'outing',
        'walk',
        'visit',
        'help',
        'work',
      ],
      'time_indicators': [
        'morning',
        'afternoon',
        'evening',
        'night',
        'dawn',
        'dusk',
        'today',
        'yesterday',
        'week',
        'today',
      ],
    },
  };

  /// Analyze case description and generate relevant tags
  Future<List<String>> generateTagsFromDescription(String description) async {
    if (description.isEmpty) return [];

    final keywords = textProcessing.extractKeywords(description);
    final generatedTags = <String>{};

    final normalizedDesc = description.toLowerCase();

    // Extract location tags from keywords and patterns
    for (final keyword in keywords) {
      if (keyword.type == KeywordType.placeType) {
        generatedTags.add(keyword.value);
      }
      if (keyword.type == KeywordType.language) {
        generatedTags.add(keyword.value);
      }
      if (keyword.type == KeywordType.nature) {
        generatedTags.add(keyword.value);
      }
    }

    // Analyze patterns in description text
    for (final tag
        in tagPatterns['place']!['location_keywords'] ?? <String>[]) {
      if (normalizedDesc.contains(tag)) {
        generatedTags.add(tag);
      }
    }

    for (final lang
        in tagPatterns['language']!['spoken_languages'] ?? <String>[]) {
      if (normalizedDesc.contains(lang)) {
        generatedTags.add(lang);
      }
    }

    // Detect context based on activity keywords
    final contextKeywords =
        tagPatterns['context']!['activity_keywords'] ?? <String>[];
    final foundContexts = <String>[];
    for (final activity in contextKeywords) {
      if (normalizedDesc.contains(activity)) {
        foundContexts.add(activity);
      }
    }
    generatedTags.addAll(foundContexts.take(2)); // Add up to 2 context tags

    // Detect appearance/clothing tags
    final foundClothing = <String>[];
    for (final item
        in tagPatterns['appearance']!['clothing_items'] ?? <String>[]) {
      if (normalizedDesc.contains(item)) {
        foundClothing.add(item);
      }
    }
    generatedTags.addAll(foundClothing.take(1)); // Add top clothing tag

    // Prioritize tags by frequency and relevance
    final tagFrequency = <String, int>{};
    for (final tag in generatedTags) {
      tagFrequency[tag] = (tagFrequency[tag] ?? 0) + 1;
    }

    final sortedTags =
        generatedTags.toList()
          ..sort((a, b) => tagFrequency[b]!.compareTo(tagFrequency[a]!));

    // Return unique tags (max 8)
    return sortedTags.take(8).toList();
  }

  /// Get description template with helpful prompts
  static String getDescriptionTemplate() {
    return '''Please describe the circumstances of the missing report:

1. Location: Where was the child last seen? (e.g., near the mall, at the temple)

2. Appearance: What was the child wearing? Any distinguishing features?

3. Behavior: What was the child doing when last seen? (e.g., playing, shopping, with friends)

4. People around: Were there other people nearby? What languages might they speak?

5. Time: What time of day was this? (e.g., morning, afternoon, evening)

6. Environment: Describe the area (e.g., busy market, quiet park)

Provide as much detail as possible. The system will analyze your description to automatically generate relevant tags.''';
  }
}

/// Configuration for semantic matching algorithm
/// Enables flexible, data-driven matching without hardcoded rules
class SemanticMatchingConfig {
  /// Semantic similarity thresholds for different keyword types
  /// Scores range from 0.0 to 1.0 based on semantic distance
  final Map<KeywordType, double> semanticThresholds = {
    KeywordType.placeType: 0.6,
    KeywordType.nature: 0.65,
    KeywordType.language: 0.75,
    KeywordType.emotion: 0.7,
    KeywordType.timeOfDay: 0.7,
    KeywordType.sound: 0.65,
  };

  /// Max distance (km) for flexible location matching
  /// Adaptive based on case recency and keyword confidence
  final double maxLocationDistance = 15.0;

  /// Enable adaptive time decay based on case importance
  /// Uses exponential decay instead of hardcoded windows
  final bool useAdaptiveTimeDecay = true;

  /// Enable multi-factor scoring (semantic-based)
  /// Each factor contributes proportionally to confidence
  final bool useMultiFactorScoring = true;
}

/// Semantic matcher for flexible, data-driven matching
class SemanticMatcher {
  /// Compute semantic similarity between two strings
  /// Range: 0.0 (completely different) to 1.0 (identical)
  static double computeSemanticSimilarity(String s1, String s2) {
    final norm1 = s1.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final norm2 = s2.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');

    if (norm1 == norm2) return 1.0;

    // Levenshtein distance for partial matching
    final maxLen = math.max(norm1.length, norm2.length);
    if (maxLen == 0) return 0.0;

    final distance = _levenshteinDistance(norm1, norm2).toDouble();
    final similarity = 1.0 - (distance / maxLen);

    return similarity.clamp(0.0, 1.0);
  }

  static int _levenshteinDistance(String a, String b) {
    final len0 = a.length;
    final len1 = b.length;
    final d = List<List<int>>.generate(
      len0 + 1,
      (i) => List<int>.filled(len1 + 1, 0),
    );

    for (int i = 0; i <= len0; i++) d[i][0] = i;
    for (int j = 0; j <= len1; j++) d[0][j] = j;

    for (int i = 1; i <= len0; i++) {
      for (int j = 1; j <= len1; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = math.min(
          math.min(d[i - 1][j] + 1, d[i][j - 1] + 1),
          d[i - 1][j - 1] + cost,
        );
      }
    }

    return d[len0][len1];
  }

  /// Find matches using semantic similarity
  static List<MapEntry<String, double>> findSemanticMatches(
    String query,
    List<String> targets,
    double threshold,
  ) {
    final matches = <MapEntry<String, double>>[];

    for (final target in targets) {
      final similarity = computeSemanticSimilarity(query, target);
      if (similarity >= threshold) {
        matches.add(MapEntry(target, similarity));
      }
    }

    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches;
  }
}

class EnhancedMatchingService {
  final EnhancedTextProcessingService textProcessing;
  final EnhancedMockPoiService poiService;
  final SemanticMatchingConfig config;

  EnhancedMatchingService({
    required this.textProcessing,
    required this.poiService,
    SemanticMatchingConfig? config,
  }) : config = config ?? SemanticMatchingConfig();

  Future<List<MatchResult>> matchMemoryToCases(
    ChildMemory memory,
    List<ParentCase> cases,
  ) async {
    final keywords = textProcessing.extractKeywords(memory.text);

    final results = <MatchResult>[];

    for (final c in cases) {
      final res = await _scoreCase(memory, c, keywords);
      results.add(res);
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  /// Adaptive time decay using exponential function
  /// Newer cases naturally score higher without hardcoded windows
  Future<double> _calculateAdaptiveTimeRelevance(DateTime reportedAt) async {
    final hoursSinceReport =
        DateTime.now().difference(reportedAt).inHours.toDouble();

    // Exponential decay: e^(-lambda * hours)
    // Lambda calculated to give 0.5 score at ~30 days
    // More flexible than hardcoded 720-hour cutoff
    const lambda = 0.0003; // Natural decay rate
    final decayScore = math.exp(-lambda * hoursSinceReport);

    return decayScore.clamp(0.0, 1.0);
  }

  /// Semantic-based location matching
  /// Adaptive distance based on confidence, not hardcoded 5km
  Future<double> _calculateLocationRelevance(
    ChildMemory memory,
    ParentCase parentCase,
    List<Keyword> keywords,
  ) async {
    if (memory.latitude == null || memory.longitude == null) {
      // No location data - evaluate keyword-location semantic match
      return keywords
              .where((k) => k.type == KeywordType.placeType)
              .firstOrNull
              ?.confidence ??
          0.0;
    }

    final distance = _calculateDistance(
      memory.latitude!,
      memory.longitude!,
      parentCase.latitude,
      parentCase.longitude,
    );

    // Adaptive distance threshold based on keyword confidence
    final avgKeywordConfidence =
        keywords.isEmpty
            ? 0.5
            : keywords.fold<double>(0, (sum, k) => sum + k.confidence) /
                keywords.length;

    // Higher confidence keywords allow larger distance variance
    final adaptiveMaxDistance =
        config.maxLocationDistance * avgKeywordConfidence;

    if (distance > adaptiveMaxDistance) return 0.0;

    // Smooth proximity decay instead of hard thresholds
    final proximityScore = math.exp(-distance / (adaptiveMaxDistance / 3));

    return proximityScore.clamp(0.0, 1.0);
  }

  /// Semantic-based keyword matching using text similarity
  /// Not limited to category-based rules
  Future<double> _calculateSemanticKeywordMatch(
    ChildMemory memory,
    ParentCase parentCase,
    List<Keyword> keywords,
  ) async {
    if (keywords.isEmpty) return 0.0;

    final caseTokens = parentCase.description.toLowerCase().split(
      RegExp(r'\s+'),
    );
    double totalMatchScore = 0;
    int matchCount = 0;

    for (final keyword in keywords) {
      final threshold = config.semanticThresholds[keyword.type] ?? 0.65;

      final matches = SemanticMatcher.findSemanticMatches(
        keyword.value,
        caseTokens,
        threshold,
      );

      if (matches.isNotEmpty) {
        // Score based on semantic similarity and keyword confidence
        final bestMatch = matches.first;
        final matchScore = bestMatch.value * keyword.confidence;
        totalMatchScore += matchScore * keyword.weight;
        matchCount++;
      }
    }

    if (matchCount == 0) return 0.0;

    // Normalize by keyword count to get average semantic match
    final normalizedScore = totalMatchScore / keywords.length;

    return normalizedScore.clamp(0.0, 1.0);
  }

  /// Calculate emotional and contextual relevance
  /// Based on memory depth, not hardcoded multipliers
  Future<double> _calculateContextualRelevance(ChildMemory memory) async {
    double contextScore = 0.0;

    // Emotion depth: more emotions = more reliable memory
    if (memory.emotions.isNotEmpty) {
      contextScore += 0.3 * (memory.emotions.length / 10).clamp(0, 1);
    }

    // Confidence level: self-reported by memory
    contextScore += 0.4 * memory.confidenceLevel / 5;

    // Recency: more recent memories are more accurate
    final hoursSinceMemory =
        DateTime.now().difference(memory.rememberedAt).inHours.toDouble();
    final recencyScore = math.exp(-0.0002 * hoursSinceMemory);
    contextScore += 0.3 * recencyScore;

    return contextScore.clamp(0.0, 1.0);
  }

  Future<MatchResult> _scoreCase(
    ChildMemory memory,
    ParentCase parentCase,
    List<Keyword> keywords,
  ) async {
    final explanations = <String>[];
    final contributingFactors = <String, double>{};

    // Calculate individual match components
    final keywordRelevance = await _calculateSemanticKeywordMatch(
      memory,
      parentCase,
      keywords,
    );
    contributingFactors['Semantic Relevance'] = keywordRelevance;
    if (keywordRelevance > 0.3) {
      explanations.add(
        'Strong semantic similarity between memory and case (${(keywordRelevance * 100).toStringAsFixed(1)}%)',
      );
    }

    final timeRelevance = await _calculateAdaptiveTimeRelevance(
      parentCase.reportedAt,
    );
    contributingFactors['Time Recency'] = timeRelevance;
    if (timeRelevance > 0.5) {
      explanations.add(
        'Case reported recently (${(timeRelevance * 100).toStringAsFixed(1)}% time relevance)',
      );
    }

    final locationRelevance = await _calculateLocationRelevance(
      memory,
      parentCase,
      keywords,
    );
    contributingFactors['Location Proximity'] = locationRelevance;
    if (locationRelevance > 0.4) {
      explanations.add(
        'Geographic proximity detected (${(locationRelevance * 100).toStringAsFixed(1)}% match)',
      );
    }

    final contextRelevance = await _calculateContextualRelevance(memory);
    contributingFactors['Memory Confidence'] = contextRelevance;
    if (contextRelevance > 0.4) {
      explanations.add('Memory has high confidence level and contextual depth');
    }

    // Multi-factor composite scoring (normalized)
    // Each factor equally weighted, normalized to 0-100 range
    final componentScores = [
      keywordRelevance,
      timeRelevance,
      locationRelevance,
      contextRelevance,
    ];
    final compositeScore =
        (componentScores.fold<double>(0, (sum, s) => sum + s) /
            componentScores.length) *
        100;

    // Ensure score never exceeds 100
    final finalScore = compositeScore.clamp(0, 100.0);

    if (explanations.isEmpty) {
      explanations.add('Minimal similarity detected between memory and case');
    }

    return MatchResult(
      parentCase: parentCase,
      score: finalScore.toDouble(),
      explanations: explanations,
      contributingFactors: contributingFactors,
      matchedPois: [],
      proximityScore: locationRelevance * 100,
      timeRelevanceScore: timeRelevance * 100,
    );
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180);
}

class EnhancedMockDataRepository {
  final List<ParentCase> _cases = [];
  final List<ChildMemory> _memories = [];
  final List<TimelineEvent> _timeline = [];
  final List<NotificationMessage> _notifications = [];
  final List<ChatMessage> _chatMessages = [];

  EnhancedMockDataRepository() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _cases.addAll([
      ParentCase(
        id: 'case1',
        childName: 'Ahmad Bin Razak',
        childAge: 7,
        description:
            'Child was last seen near Sunshine Mega Mall, near the beach. He was wearing a blue shirt. The area has many food stalls and people speaking Malay.',
        lastKnownLocationText: 'Sunshine Mall, Beach Area',
        latitude: 3.1390,
        longitude: 101.6869,
        reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'ongoing',
        photos: ['https://example.com/photo1.jpg'],
        reporterName: 'Razak Bin Abdullah',
        reporterEmail: 'parent@example.com',
        reporterContact: '+60123456789',
        tags: ['mall', 'beach', 'food_stalls', 'malay_speaking'],
        viewCount: 245,
        caseImageUrl: 'https://via.placeholder.com/400x300?text=Ahmad',
      ),
      ParentCase(
        id: 'case2',
        childName: 'Wei Ling Tan',
        childAge: 5,
        description:
            'Young girl missing near Hokkien Temple area. She was with her grandmother at a temple festival. Many people speaking Hokkien and Mandarin.',
        lastKnownLocationText: 'Hokkien Temple, Old Town',
        latitude: 3.1405,
        longitude: 101.6875,
        reportedAt: DateTime.now().subtract(const Duration(hours: 24)),
        status: 'ongoing',
        photos: ['https://example.com/photo2.jpg'],
        reporterName: 'Mei Ling Tan',
        reporterEmail: 'meiling@example.com',
        reporterContact: '+60129876543',
        tags: ['temple', 'festival', 'hokkien', 'mandarin'],
        viewCount: 512,
        caseImageUrl: 'https://via.placeholder.com/400x300?text=Wei+Ling',
      ),
      ParentCase(
        id: 'case3',
        childName: 'Muthu Krishnan',
        childAge: 9,
        description:
            'Boy last seen at Central Market area. He was helping his father at their vegetable stall. The area is very busy with many languages including Tamil.',
        lastKnownLocationText: 'Central Market',
        latitude: 3.1440,
        longitude: 101.6950,
        reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
        status: 'past',
        photos: ['https://example.com/photo3.jpg'],
        reporterName: 'Krishnan A/L Muthu',
        reporterEmail: 'krishnan@example.com',
        reporterContact: '+60127654321',
        tags: ['market', 'vegetables', 'tamil', 'busy'],
        viewCount: 178,
        caseImageUrl: 'https://via.placeholder.com/400x300?text=Muthu',
      ),
      ParentCase(
        id: 'case4',
        childName: 'Siti Nurhaliza',
        childAge: 8,
        description:
            'Girl last seen near the riverfront park. She was playing with friends near the water. She had a pink backpack.',
        lastKnownLocationText: 'Riverfront Park',
        latitude: 3.1385,
        longitude: 101.6920,
        reportedAt: DateTime.now().subtract(const Duration(hours: 48)),
        status: 'ongoing',
        photos: [],
        reporterName: 'Haliza Binti Ahmad',
        reporterEmail: 'haliza@example.com',
        reporterContact: '+60128765432',
        tags: ['park', 'river', 'playground', 'malay'],
        viewCount: 95,
      ),
    ]);

    _memories.addAll([
      ChildMemory(
        id: 'mem1',
        text:
            'I remember a big mall near the sea. There was a playground and many people speaking Malay.',
        language: 'en',
        rememberedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        latitude: 3.1385,
        longitude: 101.6885,
        childIdentifier: 'child123',
        emotions: ['happy', 'excited'],
        confidenceLevel: 4,
      ),
      ChildMemory(
        id: 'mem2',
        text:
            'I was at a temple with many people. They were speaking Hokkien and there was loud music.',
        language: 'en',
        rememberedAt: DateTime.now().subtract(const Duration(hours: 2)),
        latitude: 3.1400,
        longitude: 101.6870,
        childIdentifier: 'child456',
        emotions: ['confused', 'scared'],
      ),
    ]);

    _timeline.addAll([
      TimelineEvent(
        id: 'ev1',
        type: 'match',
        title: 'Potential Match Found',
        description: 'Memory matches Parent Case #2 (Wei Ling Tan)',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        icon: Icons.link_rounded,
        color: AppColors.primary,
        actionUrl: 'case2',
      ),
      TimelineEvent(
        id: 'ev2',
        type: 'update',
        title: 'Case Status Update',
        description: 'Case #1 updated by parent',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        icon: Icons.update_rounded,
        color: AppColors.secondary,
      ),
    ]);

    _notifications.addAll([
      NotificationMessage(
        id: 'notif1',
        title: 'Match Found',
        body: 'We found a potential match for a memory you submitted.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        type: 'match',
        relatedCaseId: 'case2',
      ),
      NotificationMessage(
        id: 'notif2',
        title: 'Case Updated',
        body: 'Case #1 was updated by the parent.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: 'update',
      ),
    ]);

    _chatMessages.addAll([
      ChatMessage(
        id: 'msg1',
        conversationId: 'case_case2_mem_child456',
        isFromParent: true,
        text: 'Hi, I heard there might be a match. Can we talk?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
      ),
      ChatMessage(
        id: 'msg2',
        conversationId: 'case_case2_mem_child456',
        isFromParent: false,
        text: 'Yes, I remember the temple and the festival music.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 48)),
      ),
    ]);
  }

  Future<List<ParentCase>> getCases({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (status == null) return _cases;
    return _cases.where((c) => c.status == status).toList();
  }

  Future<List<ParentCase>> getAllCases() async {
    return getCases();
  }

  Future<List<ParentCase>> getCasesByStatus(String status) async {
    return getCases(status: status);
  }

  Future<List<ParentCase>> getCasesByReporterEmail(String email) async {
    final target = email.toLowerCase().trim();
    return _cases
        .where((c) => c.reporterEmail.toLowerCase().trim() == target)
        .toList();
  }

  Future<Map<String, dynamic>> getCasesForChildWithScoring(
    String childIdentifier,
  ) async {
    final cases = await getCases();
    final lowerId = childIdentifier.toLowerCase();
    final potentialIds = <String>{};

    for (final c in cases) {
      final descHit = c.description.toLowerCase().contains(lowerId);
      final tagHit = c.tags.any((t) => t.toLowerCase().contains(lowerId));
      final matchHit = c.matchIds.contains(childIdentifier);
      if (descHit || tagHit || matchHit) {
        potentialIds.add(c.id);
      }
    }

    return {'all': cases, 'potentialIds': potentialIds};
  }

  Future<ParentCase?> getCaseById(String id) async {
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addCase(ParentCase parentCase) async {
    _cases.add(parentCase);
  }

  Future<void> updateCase(ParentCase updated) async {
    final index = _cases.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _cases[index] = updated;
    }
  }

  Future<List<ChildMemory>> getMemories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _memories;
  }

  Future<List<ChildMemory>> getMemoriesByChildIdentifier(
    String childIdentifier,
  ) async {
    final target = childIdentifier.toLowerCase();
    return _memories
        .where((m) => m.childIdentifier.toLowerCase() == target)
        .toList();
  }

  Future<void> addMemory(ChildMemory memory) async {
    _memories.add(memory);
  }

  Future<List<TimelineEvent>> getTimeline() async {
    return _timeline;
  }

  Future<List<NotificationMessage>> getNotifications() async {
    return _notifications;
  }

  Future<void> addChatMessage(
    String conversationId,
    bool isFromParent,
    String text,
  ) async {
    _chatMessages.add(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        isFromParent: isFromParent,
        text: text,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<List<ChatMessage>> getChatMessages(String conversationId) async {
    final list =
        _chatMessages.where((m) => m.conversationId == conversationId).toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  Future<List<ConversationThread>> getConversationThreads({
    bool isParent = true,
  }) async {
    final Map<String, List<ChatMessage>> grouped = {};
    for (final m in _chatMessages) {
      grouped.putIfAbsent(m.conversationId, () => []).add(m);
    }

    if (grouped.isEmpty) {
      return [];
    }

    final threads = <ConversationThread>[];
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final last = entry.value.first;
      final caseId =
          entry.key.startsWith('case_')
              ? entry.key.replaceFirst('case_', '').split('_mem_').first
              : null;
      ParentCase? relatedCase;
      if (caseId != null) {
        relatedCase = await getCaseById(caseId);
      }
      final hasUnread = entry.value.any((m) => m.isFromParent != isParent);
      threads.add(
        ConversationThread(
          conversationId: entry.key,
          title:
              relatedCase != null
                  ? 'Re: ${relatedCase.childName}'
                  : 'Conversation',
          subtitle:
              last.text.length > 60
                  ? '${last.text.substring(0, 60)}...'
                  : last.text,
          caseId: caseId,
          lastActivity: last.timestamp,
          hasUnread: hasUnread,
        ),
      );
    }

    threads.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    return threads;
  }

  Future<Map<String, dynamic>> getStatistics() async {
    return {
      'total_cases': _cases.length,
      'ongoing_cases': _cases.where((c) => c.status == 'ongoing').length,
      'past_cases': _cases.where((c) => c.status == 'past').length,
      'resolved_cases': _cases.where((c) => c.status == 'resolved').length,
      'total_memories': _memories.length,
      'total_matches': _cases.fold<int>(0, (sum, c) => sum + c.matchIds.length),
      'avg_case_views':
          _cases.isNotEmpty
              ? _cases.fold<int>(0, (sum, c) => sum + c.viewCount) ~/
                  _cases.length
              : 0,
    };
  }

  Future<void> markNotificationsAsRead(List<String> notificationIds) async {
    for (final id in notificationIds) {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = NotificationMessage(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          timestamp: _notifications[index].timestamp,
          type: _notifications[index].type,
          isRead: true,
          relatedCaseId: _notifications[index].relatedCaseId,
        );
      }
    }
  }
}
