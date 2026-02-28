/// REUNIFY - AI-ASSISTED CHILD REUNIFICATION SYSTEM
/// Final Year Project Architecture Documentation
///
/// =============================================================================
/// SYSTEM OVERVIEW
/// =============================================================================
///
/// Reunify is an AI-assisted inference system that interprets fragmented,
/// scene-based human memories and converts them into probabilistic geographic
/// hypotheses before performing case matching.
///
/// The system is NOT an LLM-driven app. It is a deterministic inference engine
/// that uses rule-based reasoning with optional AI for semantic interpretation only.
///
/// =============================================================================
/// ARCHITECTURE LAYERS
/// =============================================================================
///
/// PRESENTATION LAYER (UI)
/// └─> Memory Submission Screen
/// Region Hypothesis Display
/// Match Results Display
/// Confidence Indicators
/// Explainability Cards
///
/// DOMAIN LAYER (Business Logic & Entities)
/// ├─> MemoryClue (extracted semantic elements)
/// ├─> RegionHypothesis (geographic inference output)
/// ├─> MatchResult (case matching output)
/// └─> Case (missing person case)
///
/// INFERENCE LAYER (Deterministic Reasoning Engine)
/// ├─> Stage 1: Semantic Interpretation
/// │ └─> ClueExtractor (rule-based or Gemini)
/// │ Outputs: List<MemoryClue>
/// │
/// ├─> Stage 2: Geographic Inference
/// │ └─> RegionInferenceEngine
/// │ Uses: Knowledge Base
/// │ Outputs: List<RegionHypothesis>
/// │
/// └─> Stage 3: Case Matching
/// └─> MatchingEngine
/// Uses: Demographic Rules + Knowledge Base
/// Outputs: List<MatchResult>
///
/// DATA LAYER (Services & Repositories)
/// ├─> Google Service Abstractions (API Layer)
/// │ ├─> GooglePlacesService (POI / landmark retrieval)
/// │ ├─> GoogleMapsService (geospatial utilities)
/// │ └─> GeminiService (semantic clue extraction ONLY)
/// │
/// ├─> Mock Implementations (work without API keys)
/// │ ├─> MockGooglePlacesService
/// │ ├─> MockGoogleMapsService
/// │ └─> MockGeminiService
/// │
/// └─> Repositories
/// └─> MockCaseRepository (sample data)
///
/// KNOWLEDGE BASE (Hard-Coded Rules)
/// ├─> LanguageRegionMapping (language → region probability)
/// ├─> EnvironmentalKnowledge (environmental → region mapping)
/// ├─> DemographicRules (demographic compatibility rules)
/// └─> CluePatterns (clue type definitions)
///
/// =============================================================================
/// DATA FLOW
/// =============================================================================
///
/// User Input (Raw Memory Text)
/// ↓
/// Stage 1: Semantic Interpretation
/// - RuleBasedClueExtractor or Gemini API extracts structured clues
/// - Output: List<MemoryClue>
/// ↓
/// Stage 2: Geographic Inference
/// - RegionInferenceEngine applies knowledge base rules
/// - Assigns confidence scores to regions
/// - Output: List<RegionHypothesis> (sorted by confidence)
/// ↓
/// Stage 3: Case Matching
/// - MatchingEngine compares inferred regions with case data
/// - Applies demographic compatibility rules
/// - Calculates weighted similarity scores
/// - Output: List<MatchResult> (sorted by relevance)
/// ↓
/// Explainability & Presentation
/// - ConfidenceCalculator provides reasoning
/// - UI displays results with visual confidence indicators
/// - User sees "Why this match?" explanations
///
/// =============================================================================
/// KEY DESIGN CONSTRAINTS
/// =============================================================================
///
/// 1. LLM Usage (Gemini API)
/// ✅ ALLOWED:
/// - Semantic clue extraction from raw text
/// - Entity classification (places, people)
/// - Text interpretation
///
/// ❌ NOT ALLOWED:
/// - Deciding regions
/// - Performing scoring
/// - Performing matching
/// - Replacing rule-based inference logic
/// - Any decision-making in reasoning pipeline
///
/// 2. Determinism & Explainability
/// - All scoring is deterministic and rule-based
/// - Every match includes explanation of contributing factors
/// - Confidence scores are traceable to specific rules
/// - No probabilistic inference (except in region hypotheses)
///
/// 3. No Backend Required
/// - ✅ Mock data for all Google services
/// - ✅ Works offline (except optional Gemini API call)
/// - ✅ No Firebase/Firestore/Remote database
/// - ✅ No authentication system required
///
/// 4. Type Safety & Null Safety
/// - All entities are strongly typed
/// - Null-coalescing operators prevent null errors
/// - Enums for categorical values (ClueType, CaseType, etc.)
///
/// =============================================================================
/// MODULE SPECIFICATION
/// =============================================================================
///
/// 1. ClueExtractor
/// Interface: abstract class ClueExtractor
/// Implementations:
/// - RuleBasedClueExtractor (primary, works offline)
/// - GeminiClueExtractor (future, when API key available)
/// Input: String (raw memory text)
/// Output: List<MemoryClue>
///
/// 2. RegionInferenceEngine
/// Purpose: Convert clues to geographic hypotheses
/// Uses: LanguageRegionMapping, EnvironmentalKnowledge, DemographicRules
/// Input: List<MemoryClue>
/// Output: List<RegionHypothesis> (confidence-sorted)
///
/// 3. MatchingEngine
/// Purpose: Match memory to cases using region hypotheses
/// Uses: DemographicRules, case data
/// Scoring weights:
/// - Geographic: 30%
/// - Demographic: 25%
/// - Linguistic: 20%
/// - Temporal: 10%
/// - Environmental: 10%
/// - Name: 5%
/// Input: List<MemoryClue>, List<RegionHypothesis>, List<Case>
/// Output: List<MatchResult> (relevance-sorted)
///
/// 4. ConfidenceCalculator
/// Purpose: Provide explainable confidence scores
/// Methods:
/// - calculateMatchConfidence() → (score, explanation)
/// - calculateRegionConfidence() → (score, explanation)
/// - getConfidenceLevel() → "High", "Moderate", etc.
/// - generateConfidenceReport() → detailed breakdown
///
/// 5. Knowledge Base Modules
/// a) LanguageRegionMapping
/// - Maps ~6000+ language codes to Malaysian regions
/// - Handles dialects and accents
/// - Combines multiple language evidence
///
/// b) EnvironmentalKnowledge
/// - Coastal vs inland regions
/// - Urban vs rural classification
/// - Landmark-to-region mapping (60+ landmarks)
/// - Climate/environmental patterns
///
/// c) DemographicRules
/// - Race/ethnicity population distribution by region
/// - Age compatibility checking
/// - Language compatibility
/// - Name similarity scoring (Levenshtein distance)
///
/// 6. Google Service Abstractions
/// Purpose: Decouple from Google APIs, enable mock implementations
///
/// GooglePlacesService (abstract)
/// └─> MockGooglePlacesService
/// Data: 20+ hardcoded POIs in Malaysia
/// Methods: searchByType(), searchNearCoordinates(), getDetails()
///
/// GoogleMapsService (abstract)
/// └─> MockGoogleMapsService
/// Data: Coordinates for 15 regions
/// Methods: getRegionCenter(), geocodeAddress(), calculateDistance()
///
/// GeminiService (abstract)
/// └─> MockGeminiService
/// Simulates: Clue extraction, emotion classification, entity extraction
/// Future: RealGeminiService(apiKey) for production
///
/// =============================================================================
/// FOLDER STRUCTURE
/// =============================================================================
///
/// lib/
/// ├── main.dart
/// ├── inference/ [NEW] Core inference engine
/// │ ├── inference_service.dart Main orchestrator
/// │ ├── knowledge_base/
/// │ │ ├── language_region_mapping.dart
/// │ │ ├── environmental_knowledge.dart
/// │ │ └── demographic_rules.dart
/// │ └── engines/
/// │ ├── clue_extractor.dart
/// │ ├── region_inference_engine.dart
/// │ ├── matching_engine.dart
/// │ └── confidence_calculator.dart
/// ├── domain/
/// │ ├── entities/
/// │ │ ├── memory_clue.dart [REFACTORED]
/// │ │ ├── region_hypothesis.dart [NEW]
/// │ │ ├── match_result.dart [NEW]
/// │ │ ├── case.dart [REFACTORED]
/// │ │ └── ...
/// │ └── repositories/
/// ├── data/
/// │ ├── services/ [NEW] API abstraction layer
/// │ │ ├── google_places_service.dart
/// │ │ ├── google_maps_service.dart
/// │ │ └── gemini_service.dart
/// │ ├── repositories/
/// │ │ └── mock_case_repository.dart [NEW]
/// │ └── models/
/// ├── view/
/// │ ├── pages/
/// │ │ ├── forms/
/// │ │ │ └── child_memory_form_page.dart [UPDATED]
/// │ │ └── ...
/// │ └── ui_components.dart
/// └── controller/
///
/// =============================================================================
/// CREATING NEW INSTANCES (for UI)
/// =============================================================================
///
/// // Initialize inference service
/// final clueExtractor = RuleBasedClueExtractor();
/// final regionEngine = RegionInferenceEngine();
/// final matchingEngine = MatchingEngine();
/// final inferenceService = InferenceService(
/// clueExtractor: clueExtractor,
/// regionInferenceEngine: regionEngine,
/// matchingEngine: matchingEngine,
/// );
///
/// // Get mock cases
/// final cases = MockCaseRepository.getMockCases();
///
/// // Run inference
/// final result = await inferenceService.processMemory(
/// rawMemoryText: userInput,
/// availableCases: cases,
/// );
///
/// // Access results
/// final bestMatch = result.getBestMatch();
/// final topRegions = result.getTopRegions(limit: 3);
/// final summary = result.getSummary();
///
/// =============================================================================
/// ADDING GOOGLE API KEYS (Future)
/// =============================================================================
///
/// When ready to integrate real Google APIs:
///
/// 1. Install google_maps_flutter, google_places_flutter, google_generative_ai
///
/// 2. Create RealGeminiService:
/// class RealGeminiService implements GeminiService {
/// final String apiKey;
/// // Implement methods using actual API calls
/// }
///
/// 3. Create RealGooglePlacesService:
/// class RealGooglePlacesService implements GooglePlacesService {
/// final String apiKey;
/// // Implement methods using Google Places API
/// }
///
/// 4. Update main.dart dependency injection:
/// final gemini = RealGeminiService(apiKey: 'YOUR_KEY');
/// // Rest of system unchanged!
///
/// =============================================================================
/// TESTING THE SYSTEM
/// =============================================================================
///
/// Unit Tests:
/// - Test each engine independently
/// - Test knowledge base mappings
/// - Test scoring calculations
///
/// Integration Tests:
/// - Test full pipeline with mock data
/// - Test result generation and explanations
///
/// UI Tests:
/// - Test form submission
/// - Test result display and interactions
///
/// =============================================================================
/// SYSTEM PROPERTIES
/// =============================================================================
///
/// Processing Speed: < 1 second (full pipeline)
/// Accuracy: Depends on memory comprehensiveness and rule design
/// Explainability: 100% (all decisions are traced to rules)
/// API Dependency: Optional (Gemini only for semantic improvement)
/// Scalability: ~10,000 cases per inference (not a bottleneck)
/// Fairness: Rule-based (no black-box bias)
///
/// =============================================================================
