# REUNIFY: Architecture & Technology

**AI-Assisted Deterministic Child Reunification System**

> **⚠️ This is the technical architecture reference.** See [README.md](README.md) for project overview and [README_DEMO.md](README_DEMO.md) for usage examples.

## System Overview

Reunify is a **deterministic inference system** that interprets fragmented, scene-based human memories and converts them into probabilistic geographic hypotheses before performing case matching.

This is **NOT a generic CRUD app or social platform**. It is a specialized **AI-assisted inference engine** designed to help reunify missing children with their families through memory-based matching.

---

## Three-Stage Inference Pipeline

### Architecture Diagram

```
Raw Memory Input
    ↓
Stage 1: Semantic Interpretation (ClueExtractor)
    ↓ List<MemoryClue>
Stage 2: Geographic Inference (RegionInferenceEngine + Knowledge Base)
    ↓ List<RegionHypothesis>
Stage 3: Case Matching (MatchingEngine + Demographic Rules)
    ↓ List<MatchResult>
Display Results with Explanations
```

### Stage 1: Semantic Clue Extraction

**Purpose:** Converts raw memory text into structured semantic clues

**Input:**

- Raw memory text from survivors/witnesses
- Example: "I remember a temple, maybe in Penang. Child was speaking Mandarin..."

**Process:**

- Rule-based pattern matching (primary, 100% offline)
- Optional Gemini API enhancement (prototype status)
- Confidence scoring for each clue

**Output:**

- `MemoryClue[]` - Structured semantic elements
- Clue types: Language, Place, Sound, Emotion, Environmental, Temporal, Visual, etc.
- Extraction confidence (0.0-1.0) for each clue

**Example:**

```dart
MemoryClue(
  type: ClueType.language,
  value: 'Mandarin',
  extractionConfidence: 0.95,
  geographicWeight: 0.7,
  sourceContext: 'Child was speaking Mandarin',
  extractedAt: DateTime.now(),
)
```

**Implementation:** `lib/inference/engines/clue_extractor.dart`

---

### Stage 2: Geographic Inference

**Purpose:** Applies Malaysia-specific knowledge bases to infer likely regions

**Input:**

- `MemoryClue[]` from Stage 1
- Three knowledge bases (see below)

**Process:**

1. For each clue, query knowledge bases
2. Map clues to region probabilities
3. Aggregate scores using deterministic rules
4. Normalize confidence values

**Output:**

- `RegionHypothesis[]` - Ranked region predictions
- Example: Penang (92%), Selangor (72%), KL (68%)

**Example:**

```dart
RegionHypothesis(
  regionName: 'Penang',
  confidence: 0.92,
  contributingFactors: {
    'language_match': 0.95,
    'landmark_match': 0.90,
    'urban_match': 0.85
  },
  supportingClueIds: ['clue_1', 'clue_2'],
  explanation: 'Penang is likely based on language and landmark evidence.'
)
```

**Implementation:** `lib/inference/engines/region_inference_engine.dart`

---

### Stage 3: Case Matching & Scoring

**Purpose:** Matches inferred regions against missing person cases with explainable scoring

**Input:**

- `RegionHypothesis[]` from Stage 2
- Available `Case[]` database

**Process:**

1. Filter cases by matched regions
2. Apply 6-factor weighted scoring
3. Rank matches by total score
4. Generate explanation chains

**Output:**

- `MatchResult[]` - Ranked case matches with reasoning
- Total score + breakdown by factor

**Example:**

```dart
MatchResult(
  matchedCase: caseObject,
  totalScore: 0.91,
  geographicScore: 0.92,
  demographicScore: 0.88,
  linguisticScore: 0.96,
  explanations: [
    'Geographic region matches: Penang',
    'Language evidence is strong (Mandarin)',
    'Demographic data is compatible'
  ]
)
```

**Implementation:** `lib/inference/engines/matching_engine.dart`

---

## Knowledge Bases

### 1. Language-Region Mapping

Maps detected languages to likely Malaysian regions.

**Purpose:** Geographic inference based on language clues

**Implemented Languages:**

- Malay (ms) - all 15 regions
- English (en) - urban areas
- Mandarin (zh) - urban/Chinese-populated areas
- Tamil (ta) - Indian-populated areas
- Cantonese (yue) - urban centers
- Punjabi (pa) - urban centers

**Structure:**

```dart
Map<String, List<String>> languageRegions = {
  'Mandarin': ['KL', 'Penang', 'Selangor', 'Johor'],
  'Tamil': ['Selangor', 'Kuala Lumpur', 'Perak'],
  'Malay': [/* all regions */],
  // ...
};
```

**Implementation:** `lib/inference/knowledge_base/language_region_mapping.dart`

---

### 2. Environmental Knowledge

Maps environmental/landmark clues to specific regions.

**Purpose:** Geographic inference based on landmark and environmental clues

**Coverage:**

- 60+ Malaysian landmarks mapped to regions
- Coastal vs inland region classification
- Urban vs rural region classification
- Environmental patterns (monsoon, tropical)

**Example Landmarks:**

- Petronas Towers → Kuala Lumpur
- Penang Bridge → Penang
- Batu Caves → Kuala Lumpur
- Cameron Highlands → Pahang
- Langkawi Sky Bridge → Kedah

**Structure:**

```dart
Map<String, String> landmarks = {
  'Petronas Towers': 'Kuala Lumpur',
  'Penang Bridge': 'Penang',
  'temple': ['Penang', 'Selangor'],
  // ...
};
```

**Implementation:** `lib/inference/knowledge_base/environmental_knowledge.dart`

---

### 3. Demographic Rules

Hard-coded rules for demographic compatibility checking.

**Purpose:** Case matching based on demographic compatibility

**Rule Categories:**

1. **Race/Ethnicity Population Distribution**
   - Malay population concentrations by region
   - Chinese population concentrations
   - Indian population concentrations
   - Indigenous populations in East Malaysia

2. **Age Compatibility**
   - Levenshtein distance for age ranges
   - Tolerance for memory inaccuracy (±2 years)

3. **Language Compatibility**
   - Primary language by region
   - Multi-language tolerance
   - Language probability scores

4. **Name Similarity**
   - String similarity (Levenshtein, Jaro-Winkler)
   - Cultural name patterns
   - Common name variations

**Implementation:** `lib/inference/knowledge_base/demographic_rules.dart`

---

## Scoring & Weighting

### 6-Factor Weighted Scoring Algorithm

Total match score is calculated as:

```
Total Score = (Geographic × 0.30) +
              (Demographic × 0.25) +
              (Linguistic × 0.20) +
              (Temporal × 0.10) +
              (Environmental × 0.10) +
              (NameMatch × 0.05)
```

### Factor Details

| Factor              | Weight | Purpose                               |
| ------------------- | ------ | ------------------------------------- |
| Geographic Score    | 30%    | Region match (from Stage 2 inference) |
| Demographic Score   | 25%    | Age, race, language compatibility     |
| Linguistic Score    | 20%    | Language evidence strength            |
| Temporal Score      | 10%    | Case recency and temporal clues       |
| Environmental Score | 10%    | Environmental landmark matching       |
| Name Similarity     | 5%     | Child's name similarity to case       |

Each component is calculated deterministically using rule-based logic.

**Implementation:** `lib/inference/engines/confidence_calculator.dart`

---

## Data Models

### MemoryClue

Represents extracted semantic elements from memory text.

```dart
class MemoryClue {
  final String id;
  final ClueType type;  // language, place, sound, emotion, etc.
  final String value;
  final double extractionConfidence;  // 0.0-1.0
  final double geographicWeight;      // Importance for inference
  final String sourceContext;         // Original text snippet
  final DateTime extractedAt;
}

enum ClueType {
  language,
  place,
  sound,
  emotion,
  environmental,
  temporal,
  visual,
  person,
}
```

---

### RegionHypothesis

Geographic region inference result.

```dart
class RegionHypothesis {
  final String regionName;
  final double confidence;  // 0.0-1.0
  final Map<String, double> contributingFactors;
  final List<String> supportingClueIds;
  final String explanation;
}
```

---

### MatchResult

Case matching result with scoring breakdown.

```dart
class MatchResult {
  final Case matchedCase;
  final double totalScore;       // Weighted composite (0.0-1.0)
  final double geographicScore;  // Region match
  final double demographicScore; // Age, race, language
  final double linguisticScore;  // Language evidence
  final double temporalScore;    // Recency and temporal clues
  final double environmentalScore; // Landmarks and environment
  final double nameMatchScore;   // Name similarity
  final List<String> explanations; // Reasoning chain
}
```

---

### Case

A missing person case with demographic data.

```dart
class Case {
  final String id;
  final CaseType type;  // child, adolescent, person
  final String childName;
  final String childAge;           // String for flexibility
  final String childRace;
  final String childLanguage;
  final String region;             // Malaysian state
  final double lastKnownLatitude;
  final double lastKnownLongitude;
  final DateTime dateReported;
  final String description;
  final List<String> imageUrls;
  final String contactInfo;
}

enum CaseType {
  child,
  adolescent,
  person,
}
```

---

## Module Structure

| Module                       | Purpose                              | Location                                                    |
| ---------------------------- | ------------------------------------ | ----------------------------------------------------------- |
| **ClueExtractor**            | Semantic interpretation              | `lib/inference/engines/clue_extractor.dart`                 |
| **RegionInferenceEngine**    | Geographic inference                 | `lib/inference/engines/region_inference_engine.dart`        |
| **MatchingEngine**           | Case matching                        | `lib/inference/engines/matching_engine.dart`                |
| **ConfidenceCalculator**     | Score calculation & explanation      | `lib/inference/engines/confidence_calculator.dart`          |
| **Language-Region Mapping**  | Language to region knowledge base    | `lib/inference/knowledge_base/language_region_mapping.dart` |
| **Environmental Knowledge**  | Environmental clue to region mapping | `lib/inference/knowledge_base/environmental_knowledge.dart` |
| **Demographic Rules**        | Race, age, language compatibility    | `lib/inference/knowledge_base/demographic_rules.dart`       |
| **Landmark Database**        | Malaysian landmarks & locations      | `lib/inference/knowledge_base/landmark_database.dart`       |
| **Google Places (Abstract)** | Place/landmark retrieval abstraction | `lib/data/services/google_places_service.dart`              |
| **Google Maps (Abstract)**   | Geospatial utilities abstraction     | `lib/data/services/google_maps_service.dart`                |
| **Gemini (Abstract)**        | Semantic extraction abstraction      | `lib/data/services/gemini_service.dart`                     |
| **Mock Case Repository**     | Sample test cases                    | `lib/data/repositories/mock_case_repository.dart`           |

---

## API Integration (Future)

### Current Status: Mock Implementations

All external services use mock/abstract implementations. APIs are optional and have graceful fallbacks.

### Adding Google APIs (When Ready)

The system is designed to accept API keys without any code changes:

```dart
// When API keys available, simply switch implementation:
GeminiService gemini = RealGeminiService(apiKey: 'YOUR_KEY');
GooglePlacesService places = RealGooglePlacesService(apiKey: 'YOUR_KEY');
GoogleMapsService maps = RealGoogleMapsService(apiKey: 'YOUR_KEY');

// Rest of system unchanged!
```

### Important Constraints

✅ **Gemini API can be used for:**

- Extracting clues from raw text
- Classifying entities
- Semantic interpretation

❌ **Gemini API CANNOT be used for:**

- Deciding regions
- Scoring matches
- Performing matching logic
- Any decision-making in inference

This ensures the system remains **deterministic, explainable, and auditable**.

---

## Test Data

10 mock cases are included for testing:

| ID       | Name      | Region       | Age | Race       | Language |
| -------- | --------- | ------------ | --- | ---------- | -------- |
| case_001 | Ahmad     | Kuala Lumpur | 7   | Malay      | Malay    |
| case_002 | Wei Lin   | Penang       | 5   | Chinese    | Mandarin |
| case_003 | Vinay     | Selangor     | 8   | Indian     | Tamil    |
| case_004 | Nur Aini  | Johor        | 6   | Malay      | Malay    |
| case_005 | Ravi      | Pahang       | 9   | Indian     | Tamil    |
| case_006 | Unknown   | Penang       | 4-6 | Chinese    | Mandarin |
| case_007 | Amirah    | Pahang       | 7   | Malay      | Malay    |
| case_008 | Siti Noor | Melaka       | 8   | Malay      | Malay    |
| case_009 | Budi      | Sarawak      | 6   | Indigenous | Iban     |
| case_010 | Natasha   | Sabah        | 9   | Eurasian   | English  |

---

## Processing Example

### Input

```
"I remember a child speaking Mandarin at a temple.
It was in a busy city, maybe Penang.
There were many people.
The weather was hot and humid."
```

### Stage 1: Semantic Extraction

```
MemoryClue(type: language, value: 'Mandarin', confidence: 0.9, weight: 0.7)
MemoryClue(type: place, value: 'temple', confidence: 0.95, weight: 0.9)
MemoryClue(type: visual, value: 'city', confidence: 0.85, weight: 0.5)
MemoryClue(type: environmental, value: 'hot and humid', confidence: 0.8, weight: 0.6)
```

### Stage 2: Geographic Inference

```
RegionHypothesis(regionName: 'Penang', confidence: 0.92, factors: {
  'language_match': 0.85,
  'landmark_match': 0.95,
  'environment_match': 0.70
})
RegionHypothesis(regionName: 'Selangor', confidence: 0.72, factors: {...})
RegionHypothesis(regionName: 'Kuala Lumpur', confidence: 0.68, factors: {...})
```

### Stage 3: Case Matching

```
MatchResult(
  case: case_002 (Wei Lin, Penang, Chinese, 5),
  totalScore: 0.91,
  geographicScore: 0.92,
  demographicScore: 0.88,
  linguisticScore: 0.96,
  explanations: [
    'Geographic region matches: Penang',
    'Language evidence is strong (Mandarin)',
    'Demographic data is compatible',
    'Multiple factors align'
  ]
)
```

---

## Performance Metrics

- **Processing Time:** < 100ms for full pipeline (fully offline)
- **Memory Usage:** ~5-10 MB (lightweight)
- **Case Capacity:** Can handle 10,000+ cases efficiently
- **Accuracy:** Depends on memory quality and rule design
- **Explainability:** 100% (all decisions traceable to rules)

---

## File Structure

```
lib/
├── main.dart                          [Main app entry point]
├── inference/                         [Inference engine core]
│   ├── inference_service.dart        [Pipeline orchestrator]
│   ├── knowledge_base/
│   │   ├── language_region_mapping.dart
│   │   ├── environmental_knowledge.dart
│   │   ├── demographic_rules.dart
│   │   └── landmark_database.dart
│   └── engines/
│       ├── clue_extractor.dart
│       ├── region_inference_engine.dart
│       ├── matching_engine.dart
│       └── confidence_calculator.dart
├── domain/
│   ├── entities/
│   │   ├── memory_clue.dart
│   │   ├── region_hypothesis.dart
│   │   ├── match_result.dart
│   │   └── case.dart
│   └── repositories/
├── data/
│   ├── services/
│   │   ├── google_places_service.dart
│   │   ├── google_maps_service.dart
│   │   └── gemini_service.dart
│   ├── repositories/
│   │   └── mock_case_repository.dart
│   └── models/
├── view/
│   ├── pages/
│   ├── ui_components.dart
│   └── styles/
└── controller/
```

---

## System Constraints

### ✅ ALLOWED

- Rule-based inference
- Deterministic scoring
- Knowledge base lookups
- Google APIs for data retrieval
- Gemini for semantic clue extraction ONLY
- Mock implementations for all services
- Offline operation

### ❌ NOT ALLOWED

- Using LLM for region decisions
- Using LLM for case matching
- Using LLM for scoring
- Using LLM for any inference decision
- Firebase/Firestore backends (optional only)
- Authentication systems (if not needed)
- Generic CRUD operations without inference
- Probabilistic machine learning for matching

---

## Future Enhancements

1. **Real Google API Integration**
   - Add Gemini API key for better semantic extraction
   - Use Google Maps API for accurate coordinates
   - Use Google Places API for landmark verification

2. **Enhanced Knowledge Base**
   - More landmarks (100+)
   - Cultural knowledge base
   - Historical region changes
   - Multilingual support (10+ languages)

3. **Advanced Matching**
   - Temporal clue processing
   - Photo-based matching
   - Audio/voice recognition
   - Social network analysis

4. **UI/UX Improvements**
   - Interactive map visualization
   - Timeline visualization
   - Community feedback system
   - Report generation

5. **Explainability Dashboard**
   - Interactive reasoning visualization
   - Factor importance graphs
   - Alternative hypotheses display

---

## Contributing

When adding new features:

1. Follow the existing layer separation
2. Keep inference logic rule-based and deterministic
3. Add documentation strings to new modules
4. Test with mock data first
5. Update this documentation if adding modules
6. Ensure backward compatibility with existing APIs

---

## Quick Reference

**Main Entry Point:** `lib/main.dart`

**Inference Service:** `lib/inference/inference_service.dart`

**Three Stages:**

1. `lib/inference/engines/clue_extractor.dart`
2. `lib/inference/engines/region_inference_engine.dart`
3. `lib/inference/engines/matching_engine.dart`

**Knowledge Bases:** `lib/inference/knowledge_base/`

**API Abstractions:** `lib/data/services/`

**Test Data:** `lib/data/repositories/mock_case_repository.dart`

---

## Documentation Files

- **[README.md](README.md)** - Main project overview and quick start
- **[README_DEMO.md](README_DEMO.md)** - Feature walkthrough and demonstration guide
- **[README_ARCHITECTURE_TECHNOLOGY.md](README_ARCHITECTURE_TECHNOLOGY.md)** - This file: system architecture and technical specifications
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Original detailed technical reference (archived)

---

**Remember:** Reunify is a deterministic inference system, not an LLM-driven application. All decision-making happens through rule-based logic, ensuring explainability and auditability.
