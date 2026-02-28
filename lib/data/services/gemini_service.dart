/// Abstraction layer for Google Gemini API
/// CRITICAL: Gemini is ONLY for semantic clue extraction from raw text.
/// Gemini MUST NOT be used for:
/// - Deciding regions
/// - Performing scoring
/// - Performing matching
/// - Replacing rule-based inference

/// Abstract interface for Gemini API client
abstract class GeminiService {
  /// Extract semantic clues from raw memory text
  /// Returns structured clues without any decision-making
  Future<String> extractSemanticClues(String memoryText);

  /// Classify perceived emotions from text
  Future<List<String>> classifyEmotions(String text);

  /// Extract named entities (places, people, organizations)
  /// USED ONLY FOR FEATURE EXTRACTION, NOT FOR MATCHING
  Future<Map<String, List<String>>> extractNamedEntities(String text);
}

/// Mock implementation of Gemini API
/// Returns structured responses without actual API call
class MockGeminiService implements GeminiService {
  @override
  Future<String> extractSemanticClues(String memoryText) async {
    // Simulate Gemini response with structured clue extraction
    // This is JSON-like output that would be parsed by ClueExtractor

    final clues = <String>[];

    // Simulate language detection
    if (memoryText.toLowerCase().contains('english')) {
      clues.add('LANGUAGE: english');
    }
    if (memoryText.toLowerCase().contains('malay') ||
        memoryText.toLowerCase().contains('melayu')) {
      clues.add('LANGUAGE: malay');
    }
    if (memoryText.toLowerCase().contains('mandarin') ||
        memoryText.toLowerCase().contains('chinese')) {
      clues.add('LANGUAGE: mandarin');
    }

    // Simulate place detection
    if (memoryText.toLowerCase().contains('mosque') ||
        memoryText.toLowerCase().contains('masjid')) {
      clues.add('PLACE: mosque');
    }
    if (memoryText.toLowerCase().contains('temple')) {
      clues.add('PLACE: temple');
    }
    if (memoryText.toLowerCase().contains('church')) {
      clues.add('PLACE: church');
    }
    if (memoryText.toLowerCase().contains('school')) {
      clues.add('PLACE: school');
    }
    if (memoryText.toLowerCase().contains('beach') ||
        memoryText.toLowerCase().contains('seaside')) {
      clues.add('PLACE: beach');
    }

    // Simulate emotion detection
    if (memoryText.toLowerCase().contains('happy') ||
        memoryText.toLowerCase().contains('smile')) {
      clues.add('EMOTION: happy');
    }
    if (memoryText.toLowerCase().contains('scared') ||
        memoryText.toLowerCase().contains('frightened')) {
      clues.add('EMOTION: scared');
    }
    if (memoryText.toLowerCase().contains('sad') ||
        memoryText.toLowerCase().contains('cry')) {
      clues.add('EMOTION: sad');
    }

    // Simulate environmental detection
    if (memoryText.toLowerCase().contains('monsoon') ||
        memoryText.toLowerCase().contains('rain')) {
      clues.add('ENVIRONMENTAL: monsoon');
    }
    if (memoryText.toLowerCase().contains('hot') ||
        memoryText.toLowerCase().contains('tropical')) {
      clues.add('ENVIRONMENTAL: tropical');
    }

    return clues.join('\n');
  }

  @override
  Future<List<String>> classifyEmotions(String text) async {
    final emotions = <String>[];
    final lowerText = text.toLowerCase();

    if (lowerText.contains('happy') ||
        lowerText.contains('smile') ||
        lowerText.contains('laugh')) {
      emotions.add('happy');
    }
    if (lowerText.contains('sad') ||
        lowerText.contains('cry') ||
        lowerText.contains('unhappy')) {
      emotions.add('sad');
    }
    if (lowerText.contains('scared') ||
        lowerText.contains('frightened') ||
        lowerText.contains('fear')) {
      emotions.add('scared');
    }
    if (lowerText.contains('excited') || lowerText.contains('enthusiastic')) {
      emotions.add('excited');
    }
    if (lowerText.contains('confused') || lowerText.contains('uncertain')) {
      emotions.add('confused');
    }
    if (lowerText.contains('calm') || lowerText.contains('peaceful')) {
      emotions.add('calm');
    }

    return emotions;
  }

  @override
  Future<Map<String, List<String>>> extractNamedEntities(String text) async {
    // Mock entity extraction - returns empty maps since we use rule-based extraction
    // This is kept for future Gemini integration if needed

    return {'persons': [], 'places': [], 'organizations': [], 'locations': []};
  }
}

/// NOTE: IMPORTANT ARCHITECTURAL DECISION
/// =====================================
/// The Gemini API is ABSTRACTED and OPTIONAL.
/// The system works perfectly fine with MockGeminiService.
/// Rule-based clue extraction (RuleBasedClueExtractor) is used instead.
///
/// When Gemini API key becomes available:
/// 1. Create a RealGeminiService that extends GeminiService
/// 2. Implement the three methods using actual Gemini API calls
/// 3. Update the dependency injection to use RealGeminiService instead
/// 4. The rest of the system remains completely unchanged
///
/// Gemini's output will ONLY be:
/// - Semantic clue extraction
/// - Entity classification
/// - Text interpretation
///
/// Gemini WILL NOT control:
/// - Region inference
/// - Case matching
/// - Confidence scoring
/// - Any decision-making in the inference pipeline
