/// Represents an extracted semantic clue from a memory narrative.
/// These are structured interpretations of raw memory fragments.
class MemoryClue {
  /// Unique identifier for this clue
  final String id;

  /// The type of clue (place, sound, language, emotion, time, visual, person, activity)
  final ClueType type;

  /// The extracted clue value
  final String value;

  /// Confidence in the extraction (0.0 - 1.0)
  /// Higher = more confident in the extraction
  final double extractionConfidence;

  /// Geographic relevance of this clue (used during inference)
  /// Higher = more geographically informative
  final double geographicWeight;

  /// Raw context where this clue was found
  final String sourceContext;

  /// Timestamp when this clue was extracted
  final DateTime extractedAt;

  MemoryClue({
    required this.id,
    required this.type,
    required this.value,
    required this.extractionConfidence,
    required this.geographicWeight,
    required this.sourceContext,
    required this.extractedAt,
  });

  MemoryClue copyWith({
    String? id,
    ClueType? type,
    String? value,
    double? extractionConfidence,
    double? geographicWeight,
    String? sourceContext,
    DateTime? extractedAt,
  }) {
    return MemoryClue(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      extractionConfidence: extractionConfidence ?? this.extractionConfidence,
      geographicWeight: geographicWeight ?? this.geographicWeight,
      sourceContext: sourceContext ?? this.sourceContext,
      extractedAt: extractedAt ?? this.extractedAt,
    );
  }

  @override
  String toString() =>
      'MemoryClue(type: $type, value: $value, confidence: $extractionConfidence)';
}

/// Enumeration of clue types for semantic classification
enum ClueType {
  place, // landmarks, locations
  sound, // sounds, languages, accents
  language, // spoken languages detected
  emotion, // emotional context
  time, // temporal markers
  visual, // visual descriptions
  person, // personal characteristics
  activity, // activities or events
  environmental, // environmental conditions
  geographical, // direct geographic references
}
