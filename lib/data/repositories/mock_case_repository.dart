import 'package:my_reunify_app/domain/entities/case.dart';
import 'package:my_reunify_app/domain/entities/memory_clue.dart';

/// Mock case repository with sample data
class MockCaseRepository {
  /// Generate mock cases for testing
  static List<Case> getMockCases() {
    return [
      // Case 1: Missing child from Kuala Lumpur
      Case(
        id: 'case_001',
        userId: 'user_001',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing 7-year-old boy from Kuala Lumpur',
        photoUrl: null,
        lastKnownLocation: 'Central Market, KL',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 30)),
        updatedAt: DateTime.now(),
        childName: 'Ahmad',
        childAge: '7',
        childRace: 'Malay',
        childLanguage: 'Malay',
        lastKnownLatitude: 3.1411,
        lastKnownLongitude: 101.6957,
        region: 'Kuala Lumpur',
        knownLanguages: ['ms', 'en'],
      ),

      // Case 2: Missing child from Penang
      Case(
        id: 'case_002',
        userId: 'user_002',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing 5-year-old girl from Penang',
        photoUrl: null,
        lastKnownLocation: 'Kek Lok Si Temple area',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 45)),
        updatedAt: DateTime.now(),
        childName: 'Wei Lin',
        childAge: '5',
        childRace: 'Chinese',
        childLanguage: 'Mandarin',
        lastKnownLatitude: 5.3667,
        lastKnownLongitude: 100.3036,
        region: 'Penang',
        knownLanguages: ['zh', 'en'],
      ),

      // Case 3: Missing child from Selangor
      Case(
        id: 'case_003',
        userId: 'user_003',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing 8-year-old boy from Selangor',
        photoUrl: null,
        lastKnownLocation: 'Subang Jaya',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        updatedAt: DateTime.now(),
        childName: 'Vinay',
        childAge: '8',
        childRace: 'Indian',
        childLanguage: 'Tamil',
        lastKnownLatitude: 3.0738,
        lastKnownLongitude: 101.5183,
        region: 'Selangor',
        knownLanguages: ['ta', 'ms', 'en'],
      ),

      // Case 4: Missing child from Johor
      Case(
        id: 'case_004',
        userId: 'user_004',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing 6-year-old girl from Johor',
        photoUrl: null,
        lastKnownLocation: 'Kuala Lumpur Johor Bahru',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 60)),
        updatedAt: DateTime.now(),
        childName: 'Nur Aini',
        childAge: '6',
        childRace: 'Malay',
        childLanguage: 'Malay',
        lastKnownLatitude: 1.4854,
        lastKnownLongitude: 103.7618,
        region: 'Johor',
        knownLanguages: ['ms', 'en'],
      ),

      // Case 5: Missing child from Pahang
      Case(
        id: 'case_005',
        userId: 'user_005',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing 9-year-old boy from Pahang',
        photoUrl: null,
        lastKnownLocation: 'Kuantan area',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        updatedAt: DateTime.now(),
        childName: 'Ravi',
        childAge: '9',
        childRace: 'Indian',
        childLanguage: 'Tamil',
        lastKnownLatitude: 3.8127,
        lastKnownLongitude: 103.3256,
        region: 'Pahang',
        knownLanguages: ['ta', 'ms'],
      ),

      // Case 6: Missing parent looking for child
      Case(
        id: 'case_006',
        userId: 'user_006',
        type: CaseType.parent,
        status: CaseStatus.open,
        description: 'Looking for missing child in Penang',
        photoUrl: null,
        lastKnownLocation: null,
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 25)),
        updatedAt: DateTime.now(),
        childName: 'Unknown',
        childAge: '4-6',
        childRace: 'Chinese',
        childLanguage: 'Mandarin',
        lastKnownLatitude: 5.3667,
        lastKnownLongitude: 100.3036,
        region: 'Penang',
        parentGuessedName: 'Mei Ling',
        knownLanguages: ['zh', 'en'],
        estimatedMissingDate: DateTime.now().subtract(Duration(days: 60)),
      ),

      // Case 7: Missing child from Kuantan (for testing coastal environment)
      Case(
        id: 'case_007',
        userId: 'user_007',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing child from Kuantan beach area',
        photoUrl: null,
        lastKnownLocation: 'Cherating Beach',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        updatedAt: DateTime.now(),
        childName: 'Amirah',
        childAge: '7',
        childRace: 'Malay',
        childLanguage: 'Malay',
        lastKnownLatitude: 4.2738,
        lastKnownLongitude: 103.3956,
        region: 'Pahang',
        knownLanguages: ['ms', 'en'],
      ),

      // Case 8: Missing child from Melaka
      Case(
        id: 'case_008',
        userId: 'user_008',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing child from Melaka',
        photoUrl: null,
        lastKnownLocation: 'Melaka Town',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 35)),
        updatedAt: DateTime.now(),
        childName: 'Siti Noor',
        childAge: '8',
        childRace: 'Malay',
        childLanguage: 'Malay',
        lastKnownLatitude: 2.1896,
        lastKnownLongitude: 102.2501,
        region: 'Melaka',
        knownLanguages: ['ms', 'en'],
      ),

      // Case 9: Missing child from Sarawak
      Case(
        id: 'case_009',
        userId: 'user_009',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing child from Sarawak jungle area',
        photoUrl: null,
        lastKnownLocation: 'Kuching area',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 50)),
        updatedAt: DateTime.now(),
        childName: 'Budi',
        childAge: '6',
        childRace: 'Indigenous',
        childLanguage: 'Dayak',
        lastKnownLatitude: 1.5533,
        lastKnownLongitude: 110.3592,
        region: 'Sarawak',
        knownLanguages: ['dy', 'ms', 'en'],
      ),

      // Case 10: Missing child from Sabah
      Case(
        id: 'case_010',
        userId: 'user_010',
        type: CaseType.child,
        status: CaseStatus.open,
        description: 'Missing child from Sabah',
        photoUrl: null,
        lastKnownLocation: 'Kota Kinabalu',
        memoryClues: [],
        createdAt: DateTime.now().subtract(Duration(days: 40)),
        updatedAt: DateTime.now(),
        childName: 'Natasha',
        childAge: '9',
        childRace: 'Eurasian',
        childLanguage: 'English',
        lastKnownLatitude: 5.3788,
        lastKnownLongitude: 118.0753,
        region: 'Sabah',
        knownLanguages: ['en', 'ms'],
      ),
    ];
  }

  /// Get a single case by ID
  static Case? getCaseById(String id) {
    try {
      return getMockCases().firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all cases for a region
  static List<Case> getCasesByRegion(String region) {
    return getMockCases().where((c) => c.region == region).toList();
  }

  /// Get all open cases
  static List<Case> getOpenCases() {
    return getMockCases().where((c) => c.status == CaseStatus.open).toList();
  }

  /// Get cases by type (parent or child)
  static List<Case> getCasesByType(CaseType type) {
    return getMockCases().where((c) => c.type == type).toList();
  }
}
