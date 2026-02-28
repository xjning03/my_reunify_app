/// Abstraction layer for Google Maps API
/// Provides map visualization and geospatial utilities
import 'dart:math' as Math;

/// Represents a location marker on the map
class MapMarker {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String? description;
  final String
  markerType; // 'poi', 'region_center', 'memory_location', 'case_location'
  final String? color;

  MapMarker({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.description,
    required this.markerType,
    this.color,
  });
}

/// Abstract interface for Google Maps service
abstract class GoogleMapsService {
  /// Get center coordinates for a region
  Future<(double latitude, double longitude)?> getRegionCenter(
    String regionName,
  );

  /// Get region bounds
  Future<({double northLat, double southLat, double eastLng, double westLng})?>
  getRegionBounds(String regionName);

  /// Convert address to coordinates
  Future<(double, double)?> geocodeAddress(String address);

  /// Convert coordinates to address
  Future<String?> reverseGeocodeCoordinates(double latitude, double longitude);

  /// Calculate distance between two points (km)
  Future<double> calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  });

  /// Calculate bearing between two points (degrees)
  Future<double> calculateBearing({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  });
}

/// Mock implementation of Google Maps API
class MockGoogleMapsService implements GoogleMapsService {
  // Region centers and bounds (mock data)
  static const Map<String, Map<String, double>> _regionCenters = {
    'Selangor': {'lat': 3.0738, 'lng': 101.5183},
    'Kuala Lumpur': {'lat': 3.1390, 'lng': 101.6869},
    'Penang': {'lat': 5.3667, 'lng': 100.3036},
    'Johor': {'lat': 1.4854, 'lng': 103.7618},
    'Perak': {'lat': 4.5921, 'lng': 101.0901},
    'Pahang': {'lat': 3.8127, 'lng': 103.3256},
    'Kelantan': {'lat': 6.1184, 'lng': 102.2381},
    'Terengganu': {'lat': 5.3117, 'lng': 103.1324},
    'Kedah': {'lat': 6.1184, 'lng': 100.3688},
    'Perlis': {'lat': 6.4449, 'lng': 100.2048},
    'Melaka': {'lat': 2.1896, 'lng': 102.2501},
    'Negeri Sembilan': {'lat': 2.7258, 'lng': 101.9424},
    'Sabah': {'lat': 5.3788, 'lng': 118.0753},
    'Sarawak': {'lat': 1.5533, 'lng': 110.3592},
    'Putrajaya': {'lat': 2.7258, 'lng': 101.6964},
  };

  @override
  Future<(double, double)?> getRegionCenter(String regionName) async {
    final center = _regionCenters[regionName];
    if (center == null) return null;
    return (center['lat']!, center['lng']!);
  }

  @override
  Future<({double northLat, double southLat, double eastLng, double westLng})?>
  getRegionBounds(String regionName) async {
    // Simplified bounds - in production would get from database
    final center = _regionCenters[regionName];
    if (center == null) return null;

    const offset = 1.0; // Approximate 1 degree offset
    return (
      northLat: center['lat']! + offset,
      southLat: center['lat']! - offset,
      eastLng: center['lng']! + offset,
      westLng: center['lng']! - offset,
    );
  }

  @override
  Future<(double, double)?> geocodeAddress(String address) async {
    // Mock: return a random location in Malaysia
    // In production, would call Google Geocoding API
    return (3.1390, 101.6869); // KL center as default
  }

  @override
  Future<String?> reverseGeocodeCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Mock: return generic location
    return 'Malaysia (Lat: $latitude, Lng: $longitude)';
  }

  @override
  Future<double> calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) async {
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

  @override
  Future<double> calculateBearing({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) async {
    final dLon = _toRad(lon2 - lon1);
    final lat1Rad = _toRad(lat1);
    final lat2Rad = _toRad(lat2);

    final y = Math.sin(dLon) * Math.cos(lat2Rad);
    final x =
        (Math.cos(lat1Rad) * Math.sin(lat2Rad)) -
        (Math.sin(lat1Rad) * Math.cos(lat2Rad) * Math.cos(dLon));

    final bearing = (Math.atan2(y, x) * (180 / 3.14159265359) + 360) % 360;
    return bearing;
  }

  double _toRad(double degree) => degree * (3.14159265359 / 180);
}
