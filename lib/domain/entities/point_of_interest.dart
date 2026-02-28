class PointOfInterest {
  final String id;
  final String name;
  final String type; // mall, temple, beach, park, school, etc.
  final double latitude;
  final double longitude;
  final String? address;
  final Map<String, dynamic>? metadata;

  PointOfInterest({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.address,
    this.metadata,
  });

  PointOfInterest copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    Map<String, dynamic>? metadata,
  }) {
    return PointOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'POI(id: $id, name: $name, type: $type)';
}
