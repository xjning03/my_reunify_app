/// IMPLEMENTATION GUIDE
/// Quick reference for using the Reunify inference system
///
/// This guide shows practical examples of how to use each component.

// =============================================================================
// EXAMPLE 1: Basic Memory Processing
// =============================================================================

import 'package:my_reunify_app/domain/entities/case.dart';
import 'package:my_reunify_app/inference/inference_service.dart';
import 'package:my_reunify_app/inference/engines/clue_extractor.dart';
import 'package:my_reunify_app/inference/engines/region_inference_engine.dart';
import 'package:my_reunify_app/inference/engines/matching_engine.dart';
import 'package:my_reunify_app/inference/engines/confidence_calculator.dart';
import 'package:my_reunify_app/data/repositories/mock_case_repository.dart';

import 'package:my_reunify_app/inference/knowledge_base/language_region_mapping.dart';
import 'package:my_reunify_app/inference/knowledge_base/environmental_knowledge.dart';
import 'package:my_reunify_app/inference/knowledge_base/demographic_rules.dart';

import 'package:my_reunify_app/data/services/google_places_service.dart';
import 'package:my_reunify_app/data/services/google_maps_service.dart';

Future<void> example1_basicProcessing() async {
  // Initialize the inference pipeline
  final inferenceService = InferenceService(
    clueExtractor: RuleBasedClueExtractor(),
    regionInferenceEngine: RegionInferenceEngine(),
    matchingEngine: MatchingEngine(),
  );

  // Get test cases
  final allCases = MockCaseRepository.getMockCases();

  // User input
  final userMemory = '''
    I remember seeing a child at Kek Lok Si Temple. 
    The child was speaking Mandarin. 
    It was very hot and humid. 
    The area was very crowded and commercial.
  ''';

  // Run full inference pipeline
  final result = await inferenceService.processMemory(
    rawMemoryText: userMemory,
    availableCases: allCases,
  );

  // Print summary
  print(result.getSummary());

  // Get best match
  final bestMatch = result.getBestMatch(minimumScore: 0.7);
  if (bestMatch != null) {
    print('Best match: ${bestMatch.matchedCase.id}');
    print('Score: ${(bestMatch.totalScore * 100).toStringAsFixed(1)}%');
    print(
      'Explanation: ${ConfidenceCalculator.generateConfidenceReport(bestMatch)}',
    );
  }

  // Get top regions
  final topRegions = result.getTopRegions(limit: 3);
  for (final region in topRegions) {
    print(
      '${region.regionName}: ${(region.confidence * 100).toStringAsFixed(1)}%',
    );
  }
}

// =============================================================================
// EXAMPLE 2: Clue Extraction Only
// =============================================================================

Future<void> example2_clueExtraction() async {
  final extractor = RuleBasedClueExtractor();

  final memoryText = '''
    I heard the azan (call to prayer) at a mosque. 
    The place was very busy with people. 
    I remember the child was crying.
  ''';

  final clues = await extractor.extractClues(memoryText);

  print('Extracted clues:');
  for (final clue in clues) {
    print(
      '  - ${clue.type}: ${clue.value} (confidence: ${clue.extractionConfidence})',
    );
  }
}

// =============================================================================
// EXAMPLE 3: Region Inference Only
// =============================================================================

Future<void> example3_regionInference() async {
  final extractor = RuleBasedClueExtractor();
  final engine = RegionInferenceEngine();

  final memoryText = '''
    I remember a temple. The child was speaking Mandarin.
    I remember eating dim sum at a restaurant.
    It was a very developed city.
  ''';

  // Step 1: Extract clues
  final clues = await extractor.extractClues(memoryText);
  print('Extracted ${clues.length} clues');

  // Step 2: Infer regions
  final hypotheses = await engine.inferRegions(clues);

  print('\nTop region hypotheses:');
  for (final hypothesis in hypotheses.take(5)) {
    print(
      '  ${hypothesis.regionName}: ${(hypothesis.confidence * 100).toStringAsFixed(1)}%',
    );
    print('    Explanation: ${hypothesis.explanation}');
  }
}

// =============================================================================
// EXAMPLE 4: Case Matching Only
// =============================================================================

Future<void> example4_caseMatching() async {
  final extractor = RuleBasedClueExtractor();
  final regionEngine = RegionInferenceEngine();
  final matcher = MatchingEngine();

  final memoryText = '''
    I remember a child speaking Tamil at a temple. 
    The location was in Selangor, near Kuala Lumpur.
    The child was about 8 years old.
  ''';

  // Extract and infer
  final clues = await extractor.extractClues(memoryText);
  final regions = await regionEngine.inferRegions(clues);

  // Get cases
  final cases = MockCaseRepository.getMockCases();

  // Match
  final results = await matcher.matchMemoryToCases(
    memoryClues: clues,
    regionHypotheses: regions,
    availableCases: cases,
  );

  print('Match results:');
  for (final result in results.take(5)) {
    print(
      '${result.matchedCase.id}: ${(result.totalScore * 100).toStringAsFixed(1)}%',
    );
    print('  Explanations:');
    for (final exp in result.explanations) {
      print('    - $exp');
    }
  }
}

// =============================================================================
// EXAMPLE 5: Filtering Cases by Region
// =============================================================================

Future<void> example5_filterByRegion() async {
  final inferenceService = InferenceService(
    clueExtractor: RuleBasedClueExtractor(),
    regionInferenceEngine: RegionInferenceEngine(),
    matchingEngine: MatchingEngine(),
  );

  // Get cases for a specific region
  final penangCases = MockCaseRepository.getCasesByRegion('Penang');
  final malayCases = MockCaseRepository.getCasesByRegion('Selangor');

  print('Cases in Penang: ${penangCases.length}');
  print('Cases in Selangor: ${malayCases.length}');

  // Process memory with region-filtered cases
  final result = await inferenceService.processMemory(
    rawMemoryText: 'I remember a temple in Penang',
    availableCases: penangCases, // Only Penang cases
  );

  print('Matches in Penang: ${result.matchResults.length}');
}

// =============================================================================
// EXAMPLE 6: Confidence Analysis
// =============================================================================

Future<void> example6_confidenceAnalysis() async {
  final extractor = RuleBasedClueExtractor();
  final regionEngine = RegionInferenceEngine();
  final matcher = MatchingEngine();

  final memoryText = 'I remember a mosque. The place was hot.';

  final clues = await extractor.extractClues(memoryText);
  final regions = await regionEngine.inferRegions(clues);
  final cases = MockCaseRepository.getMockCases();
  final results = await matcher.matchMemoryToCases(
    memoryClues: clues,
    regionHypotheses: regions,
    availableCases: cases,
  );

  if (results.isNotEmpty) {
    final topMatch = results.first;

    // Analyze confidence
    final (
      confidence,
      explanation,
    ) = ConfidenceCalculator.calculateMatchConfidence(topMatch);
    print('Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
    print('Level: ${ConfidenceCalculator.getConfidenceLevel(confidence)}');
    print('Explanation: $explanation');

    // Generate full report
    print('\nDetailed Report:');
    print(ConfidenceCalculator.generateConfidenceReport(topMatch));

    // Sensitivity analysis
    final sensitivity = ConfidenceCalculator.calculateScoreSensitivity(
      topMatch,
    );
    print('\nSensitivity Analysis:');
    for (final entry in sensitivity.entries) {
      print('  ${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%');
    }
  }
}

// =============================================================================
// EXAMPLE 7: Knowledge Base Usage
// =============================================================================

Future<void> example7_knowledgeBase() async {
  // Language mapping
  final languageRegions = LanguageRegionMapping.getRegionsForLanguage('zh');
  print('Regions for Mandarin:');
  for (final entry in languageRegions.entries) {
    print('  ${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%');
  }

  // Environmental knowledge
  final envRegions = EnvironmentalKnowledge.getRegionsForEnvironment([
    'beach',
    'seaside',
  ]);
  print('\nCoastal regions:');
  for (final entry in envRegions.entries) {
    print('  ${entry.key}: ${(entry.value * 100).toStringAsFixed(1)}%');
  }

  // Demographic rules
  final raceSimilarity = DemographicRules.checkDemographicCompatibility(
    caseRace: 'Chinese',
    memoryRace: 'Chinese',
    region: 'Penang',
  );
  print('\nRace similarity (Chinese/Chinese in Penang): $raceSimilarity');

  final ageScore = DemographicRules.checkAgeCompatibility(
    caseAge: '7',
    memoryAge: '6-8',
  );
  print('Age compatibility (7 vs 6-8): $ageScore');

  final nameSimilarity = DemographicRules.checkNameSimilarity(
    caseName: 'Wei Lin',
    memoryName: 'Wei',
  );
  print('Name similarity (Wei Lin vs Wei): $nameSimilarity');
}

// =============================================================================
// EXAMPLE 8: Google Services Abstraction
// =============================================================================

Future<void> example8_googleServices() async {
  // Mock Places Service
  final placesService = MockGooglePlacesService();

  // Search for temples in Penang
  final temples = await placesService.searchPlacesByTypeAndRegion(
    placeType: 'temple',
    region: 'Penang',
  );
  print('Temples in Penang:');
  for (final temple in temples) {
    print('  - ${temple.name}');
  }

  // Search nearby
  final nearby = await placesService.searchPlacesNearCoordinates(
    latitude: 5.3667,
    longitude: 100.3036,
    radiusKm: 10,
    placeType: 'temple',
  );
  print('\nNearby temples (10km radius):');
  for (final poi in nearby) {
    print('  - ${poi.name}');
  }

  // Mock Maps Service
  final mapsService = MockGoogleMapsService();

  final centerCoords = await mapsService.getRegionCenter('Penang');
  if (centerCoords != null) {
    print('\nPenang center: ${centerCoords.$1}, ${centerCoords.$2}');
  }

  final distance = await mapsService.calculateDistance(
    lat1: 5.3667,
    lon1: 100.3036,
    lat2: 3.1390,
    lon2: 101.6869,
  );
  print('Distance Penang-KL: ${distance.toStringAsFixed(1)} km');
}

// =============================================================================
// EXAMPLE 9: Processing Multiple Memories
// =============================================================================

Future<void> example9_multiplememories() async {
  final inferenceService = InferenceService(
    clueExtractor: RuleBasedClueExtractor(),
    regionInferenceEngine: RegionInferenceEngine(),
    matchingEngine: MatchingEngine(),
  );

  final cases = MockCaseRepository.getMockCases();

  final memories = [
    'I saw a child at a mosque in Kuala Lumpur speaking Malay.',
    'I remember a girl at a temple in Penang speaking Mandarin.',
    'A boy at a beach in Johor speaking Tamil.',
  ];

  for (final memory in memories) {
    print('\nProcessing: $memory');
    final result = await inferenceService.processMemory(
      rawMemoryText: memory,
      availableCases: cases,
    );

    final best = result.getBestMatch(minimumScore: 0.6);
    if (best != null) {
      print(
        '  → Best match: ${best.matchedCase.childName} in ${best.matchedCase.region}',
      );
      print('     Score: ${(best.totalScore * 100).toStringAsFixed(1)}%');
    }
  }
}

// =============================================================================
// EXAMPLE 10: Custom Case Filtering
// =============================================================================

Future<void> example10_customFiltering() async {
  final cases = MockCaseRepository.getMockCases();

  // Filter by criteria
  final malayChildren =
      cases
          .where((c) => c.childRace == 'Malay' && c.type == CaseType.child)
          .toList();

  final coastalCases =
      cases
          .where(
            (c) =>
                c.region == 'Penang' ||
                c.region == 'Johor' ||
                c.region == 'Sabah',
          )
          .toList();

  final recent =
      cases
          .where((c) => DateTime.now().difference(c.createdAt).inDays < 30)
          .toList();

  print('Malay children: ${malayChildren.length}');
  print('Coastal region cases: ${coastalCases.length}');
  print('Recent cases (< 30 days): ${recent.length}');
}

// =============================================================================
// SUMMARY: STEP BY STEP PROCESS
// =============================================================================

/// The complete process is:
///
/// 1. User inputs memory text
/// 2. RuleBasedClueExtractor extracts MemoryClue objects
/// 3. RegionInferenceEngine generates RegionHypothesis list
/// 4. MatchingEngine compares against Case repository
/// 5. ConfidenceCalculator provides reasoning
/// 6. Results displayed to user with explanations
///
/// All steps are deterministic and rule-based.
/// No machine learning or probabilistic decisions.
/// 100% explainable system.
