/// Abstraction layer for Google Places API.
/// Allows mock implementations when API key is not available.
import 'dart:math' as Math;

/// A point of interest (landmark, mosque, temple, etc.)
class PointOfInterest {
  final String id;
  final String name;
  final String
  placeType; // 'mosque', 'temple', 'church', 'school', 'market', etc.
  final double latitude;
  final double longitude;
  final String region;
  final double? rating; // Optional Google rating
  final List<String>? tags;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.placeType,
    required this.latitude,
    required this.longitude,
    required this.region,
    this.rating,
    this.tags,
  });

  @override
  String toString() => 'POI($name, $placeType)';
}

/// Abstract interface for Places API client
abstract class GooglePlacesService {
  /// Search for places by type and region
  Future<List<PointOfInterest>> searchPlacesByTypeAndRegion({
    required String placeType,
    required String region,
  });

  /// Search for places near coordinates
  Future<List<PointOfInterest>> searchPlacesNearCoordinates({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? placeType,
  });

  /// Get details for a specific place
  Future<PointOfInterest?> getPlaceDetails(String placeId);

  /// Search by name
  Future<List<PointOfInterest>> searchPlacesByName(String name);
}

/// Mock implementation of Google Places API
/// Returns hard-coded data for testing without API keys
class MockGooglePlacesService implements GooglePlacesService {
  // Hard-coded POI database for Malaysia
  static final Map<String, List<PointOfInterest>> _poiDatabase = {
    'mosque|Selangor': [
      PointOfInterest(
        id: 'poi_mj_sel_1',
        name: 'Masjid Putra',
        placeType: 'mosque',
        latitude: 3.1390,
        longitude: 101.5183,
        region: 'Selangor',
        tags: ['prominent', 'federal'],
      ),
      PointOfInterest(
        id: 'poi_mj_sel_2',
        name: 'Al-Zahra Mosque',
        placeType: 'mosque',
        latitude: 3.0738,
        longitude: 101.6869,
        region: 'Selangor',
        tags: ['local'],
      ),
    ],
    'mosque|Kuala Lumpur': [
      PointOfInterest(
        id: 'poi_mj_kl_1',
        name: 'National Mosque (Masjid Negara)',
        placeType: 'mosque',
        latitude: 3.1585,
        longitude: 101.6964,
        region: 'Kuala Lumpur',
        tags: ['landmark', 'prominent'],
      ),
    ],
    'temple|Penang': [
      PointOfInterest(
        id: 'poi_tp_pn_1',
        name: 'Kek Lok Si Temple',
        placeType: 'temple',
        latitude: 5.3667,
        longitude: 100.3036,
        region: 'Penang',
        tags: ['famous', 'hilltop'],
      ),
      PointOfInterest(
        id: 'poi_tp_pn_2',
        name: 'Thean Hou Temple',
        placeType: 'temple',
        latitude: 5.3521,
        longitude: 100.3213,
        region: 'Penang',
        tags: ['local'],
      ),
    ],
    'school|Selangor': [
      PointOfInterest(
        id: 'poi_sch_sel_1',
        name: 'Sekolah Kebangsaan Example',
        placeType: 'school',
        latitude: 3.0738,
        longitude: 101.5183,
        region: 'Selangor',
        tags: ['primary'],
      ),
    ],
    'market|Kuala Lumpur': [
      PointOfInterest(
        id: 'poi_mkt_kl_1',
        name: 'Central Market',
        placeType: 'market',
        latitude: 3.1411,
        longitude: 101.6957,
        region: 'Kuala Lumpur',
        tags: ['historic', 'tourist'],
      ),
    ],
    'beach|Johor': [
      PointOfInterest(
        id: 'poi_bch_jr_1',
        name: 'Desaru Beach',
        placeType: 'beach',
        latitude: 1.5547,
        longitude: 103.9252,
        region: 'Johor',
        tags: ['resort', 'popular'],
      ),
    ],
  };

  @override
  Future<List<PointOfInterest>> searchPlacesByTypeAndRegion({
    required String placeType,
    required String region,
  }) async {
    final key = '$placeType|$region';
    return _poiDatabase[key] ?? [];
  }

  @override
  Future<List<PointOfInterest>> searchPlacesNearCoordinates({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? placeType,
  }) async {
    // Return all POIs within radius (simplified implementation)
    final results = <PointOfInterest>[];

    for (final poiList in _poiDatabase.values) {
      for (final poi in poiList) {
        if (placeType != null && !poi.placeType.contains(placeType)) continue;

        final distance = _calculateDistance(
          lat1: latitude,
          lon1: longitude,
          lat2: poi.latitude,
          lon2: poi.longitude,
        );

        if (distance <= radiusKm) {
          results.add(poi);
        }
      }
    }

    return results;
  }

  @override
  Future<PointOfInterest?> getPlaceDetails(String placeId) async {
    for (final poiList in _poiDatabase.values) {
      for (final poi in poiList) {
        if (poi.id == placeId) return poi;
      }
    }
    return null;
  }

  @override
  Future<List<PointOfInterest>> searchPlacesByName(String name) async {
    final results = <PointOfInterest>[];
    final searchLower = name.toLowerCase();

    for (final poiList in _poiDatabase.values) {
      for (final poi in poiList) {
        if (poi.name.toLowerCase().contains(searchLower)) {
          results.add(poi);
        }
      }
    }

    return results;
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double _calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const R = 6371; // Earth's radius in km
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        (Math.cos(_toRad(lat1)) *
            Math.cos(_toRad(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2));
    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  double _toRad(double degree) => degree * (3.14159265359 / 180);
}

// Helper import for Math functions
