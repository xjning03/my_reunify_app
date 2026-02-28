import 'package:my_reunify_app/domain/entities/memory_clue.dart';

/// Abstract interface for semantic clue extraction.
/// Implementations can use Gemini API or rule-based parsing.
abstract class ClueExtractor {
  /// Extract structured clues from raw memory text
  Future<List<MemoryClue>> extractClues(String rawMemoryText);
}

/// Rule-based clue extractor using hard-coded patterns.
/// This implementation does NOT use LLMs - only keyword matching.
class RuleBasedClueExtractor implements ClueExtractor {
  // Pattern definitions for different clue types
  static final Map<ClueType, RegExp> _patterns = {
    ClueType.language: RegExp(
      r'(english|malay|mandarin|chinese|tamil|hindi|bengali|urdu|myanmar|thai|speak|heard|language)',
      caseSensitive: false,
    ),
    ClueType.place: RegExp(
      r'(mosque|masjid|temple|church|school|market|mall|park|beach|river|mountain|jungle|home|house|shop|station|airport|port)',
      caseSensitive: false,
    ),
    ClueType.sound: RegExp(
      r'(sound|noise|sound of|heard|music|voice|accent|calling|shouting|crying|bells)',
      caseSensitive: false,
    ),
    ClueType.visual: RegExp(
      r'(saw|seen|looked|color|dress|clothes|uniform|flag|sign|building|painted)',
      caseSensitive: false,
    ),
    ClueType.emotion: RegExp(
      r'(happy|sad|scared|frightened|confused|excited|calm|peaceful|crying|smile|laugh)',
      caseSensitive: false,
    ),
    ClueType.person: RegExp(
      r'(woman|man|girl|boy|child|kid|person|family|mother|father|uncle|auntie|teacher)',
      caseSensitive: false,
    ),
    ClueType.activity: RegExp(
      r'(playing|reading|working|cooking|farming|studying|running|walking|selling|shopping)',
      caseSensitive: false,
    ),
    ClueType.environmental: RegExp(
      r'(rain|monsoon|dry|weather|climate|hot|cold|humid|cold|windy)',
      caseSensitive: false,
    ),
  };

  @override
  Future<List<MemoryClue>> extractClues(String rawMemoryText) async {
    final clues = <MemoryClue>[];
    final processed = rawMemoryText.toLowerCase();

    // Extract language clues
    _extractLanguageClues(rawMemoryText, clues);

    // Extract place/location clues
    _extractPlaceClues(rawMemoryText, clues);

    // Extract sound clues
    _extractSoundClues(rawMemoryText, clues);

    // Extract visual clues
    _extractVisualClues(rawMemoryText, clues);

    // Extract emotion clues
    _extractEmotionClues(rawMemoryText, clues);

    // Extract person clues
    _extractPersonClues(rawMemoryText, clues);

    // Extract activity clues
    _extractActivityClues(rawMemoryText, clues);

    // Extract environmental clues
    _extractEnvironmentalClues(rawMemoryText, clues);

    return clues;
  }

  void _extractLanguageClues(String text, List<MemoryClue> clues) {
    final languages = {
      'english': 0.9,
      'malay': 0.9,
      'mandarin': 0.85,
      'chinese': 0.85,
      'tamil': 0.85,
      'hindi': 0.8,
      'bengali': 0.8,
      'urdu': 0.8,
      'myanmar': 0.8,
      'thai': 0.8,
    };

    languages.forEach((lang, confidence) {
      if (text.toLowerCase().contains(lang)) {
        clues.add(
          MemoryClue(
            id: 'lang_${DateTime.now().millisecondsSinceEpoch}_${lang.hashCode}',
            type: ClueType.language,
            value: lang,
            extractionConfidence: confidence,
            geographicWeight: 0.7,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _extractPlaceClues(String text, List<MemoryClue> clues) {
    final places = {
      'mosque|masjid': (0.9, 0.85),
      'temple|kuil': (0.9, 0.85),
      'church': (0.85, 0.80),
      'school': (0.8, 0.6),
      'market|bazaar': (0.85, 0.75),
      'mall': (0.85, 0.8),
      'park': (0.8, 0.6),
      'beach': (0.9, 0.9),
      'river': (0.85, 0.85),
      'mountain': (0.85, 0.85),
      'jungle|forest': (0.85, 0.85),
      'home|house': (0.7, 0.4),
      'shop': (0.8, 0.6),
      'station|railway': (0.8, 0.7),
      'airport': (0.8, 0.7),
      'port|harbor': (0.85, 0.9),
    };

    places.forEach((placePattern, scoreComp) {
      final regex = RegExp(placePattern, caseSensitive: false);
      if (regex.hasMatch(text)) {
        final match = regex.firstMatch(text);
        if (match != null) {
          clues.add(
            MemoryClue(
              id:
                  'place_${DateTime.now().millisecondsSinceEpoch}_${placePattern.hashCode}',
              type: ClueType.place,
              value: match.group(0) ?? placePattern,
              extractionConfidence: scoreComp.$1,
              geographicWeight: scoreComp.$2,
              sourceContext: _extractContext(text, match.start)!,
              extractedAt: DateTime.now(),
            ),
          );
        }
      }
    });
  }

  void _extractSoundClues(String text, List<MemoryClue> clues) {
    final soundPatterns = {
      'azan|call to prayer': 0.95,
      'temple bells': 0.95,
      'church bells': 0.9,
      'music': 0.7,
      'voice': 0.6,
      'accent': 0.7,
      'shouting': 0.5,
      'crying': 0.6,
    };

    soundPatterns.forEach((sound, confidence) {
      if (text.toLowerCase().contains(sound.toLowerCase())) {
        clues.add(
          MemoryClue(
            id:
                'sound_${DateTime.now().millisecondsSinceEpoch}_${sound.hashCode}',
            type: ClueType.sound,
            value: sound,
            extractionConfidence: confidence,
            geographicWeight: 0.6,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _extractVisualClues(String text, List<MemoryClue> clues) {
    final visualPatterns = {
      'school uniform': 0.8,
      'flag': 0.8,
      'sign': 0.6,
      'building': 0.5,
      'dress': 0.6,
      'color': 0.5,
    };

    visualPatterns.forEach((visual, confidence) {
      if (text.toLowerCase().contains(visual.toLowerCase())) {
        clues.add(
          MemoryClue(
            id:
                'visual_${DateTime.now().millisecondsSinceEpoch}_${visual.hashCode}',
            type: ClueType.visual,
            value: visual,
            extractionConfidence: confidence,
            geographicWeight: 0.5,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _extractEmotionClues(String text, List<MemoryClue> clues) {
    final emotions = [
      'happy',
      'sad',
      'scared',
      'frightened',
      'confused',
      'excited',
      'calm',
      'peaceful',
      'crying',
      'smiling',
    ];

    for (final emotion in emotions) {
      if (text.toLowerCase().contains(emotion)) {
        clues.add(
          MemoryClue(
            id:
                'emotion_${DateTime.now().millisecondsSinceEpoch}_${emotion.hashCode}',
            type: ClueType.emotion,
            value: emotion,
            extractionConfidence: 0.85,
            geographicWeight: 0.0,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  void _extractPersonClues(String text, List<MemoryClue> clues) {
    final personPatterns = {
      'woman': 0.8,
      'man': 0.8,
      'girl': 0.85,
      'boy': 0.85,
      'child': 0.8,
      'kid': 0.8,
      'mother': 0.9,
      'father': 0.9,
      'teacher': 0.9,
      'uncle': 0.85,
      'auntie': 0.85,
    };

    personPatterns.forEach((person, confidence) {
      if (text.toLowerCase().contains(person)) {
        clues.add(
          MemoryClue(
            id:
                'person_${DateTime.now().millisecondsSinceEpoch}_${person.hashCode}',
            type: ClueType.person,
            value: person,
            extractionConfidence: confidence,
            geographicWeight: 0.0,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  void _extractActivityClues(String text, List<MemoryClue> clues) {
    final activities = [
      'playing',
      'reading',
      'working',
      'cooking',
      'farming',
      'studying',
      'running',
      'walking',
      'swimming',
    ];

    for (final activity in activities) {
      if (text.toLowerCase().contains(activity)) {
        clues.add(
          MemoryClue(
            id:
                'activity_${DateTime.now().millisecondsSinceEpoch}_${activity.hashCode}',
            type: ClueType.activity,
            value: activity,
            extractionConfidence: 0.75,
            geographicWeight: 0.3,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  void _extractEnvironmentalClues(String text, List<MemoryClue> clues) {
    final environmental = {
      'monsoon': 0.8,
      'rain': 0.7,
      'dry': 0.7,
      'hot': 0.6,
      'humid': 0.6,
      'tropical': 0.8,
    };

    environmental.forEach((env, confidence) {
      if (text.toLowerCase().contains(env)) {
        clues.add(
          MemoryClue(
            id: 'env_${DateTime.now().millisecondsSinceEpoch}_${env.hashCode}',
            type: ClueType.environmental,
            value: env,
            extractionConfidence: confidence,
            geographicWeight: 0.5,
            sourceContext: text,
            extractedAt: DateTime.now(),
          ),
        );
      }
    });
  }

  String? _extractContext(String text, int position) {
    const contextLength = 100;
    final start = (position - contextLength ~/ 2).clamp(0, text.length);
    final end = (position + contextLength ~/ 2).clamp(0, text.length);
    return text.substring(start, end);
  }
}
