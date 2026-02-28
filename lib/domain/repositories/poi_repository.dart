import 'package:my_reunify_app/domain/entities/point_of_interest.dart';

abstract class PoiRepository {
  Future<List<PointOfInterest>> searchPois(
    List<String> keywords, {
    double? latitude,
    double? longitude,
    double radiusKm,
  });

  Future<List<PointOfInterest>> getPoisByType(
    String type, {
    double? latitude,
    double? longitude,
    double radiusKm,
  });

  Future<PointOfInterest?> getPoiById(String poiId);
}
