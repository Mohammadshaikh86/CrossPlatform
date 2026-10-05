class GeoPoint {
  final double latitude;
  final double longitude;
  final String title;
  final String? subtitle;
  final DateTime? estimatedTime;

  const GeoPoint({
    required this.latitude,
    required this.longitude,
    required this.title,
    this.subtitle,
    this.estimatedTime,
  });

  GeoPoint copyWith({
    double? latitude,
    double? longitude,
    String? title,
    String? subtitle,
    DateTime? estimatedTime,
  }) {
    return GeoPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}

class RouteStop {
  final String id;
  final String name;
  final String address;
  final GeoPoint coordinates;
  final String expectedTime;
  final bool isPickup;
  final bool isDropoff;
  final bool isCompleted;

  const RouteStop({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.expectedTime,
    this.isPickup = false,
    this.isDropoff = false,
    this.isCompleted = false,
  });
}
