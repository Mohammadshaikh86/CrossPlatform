import 'location_point.dart';
import 'user.dart';

enum RideStatus {
  scheduled,
  matching,
  enRoute,
  completed,
  cancelled,
}

enum LuggageCapacity {
  none,
  small,
  medium,
  large,
}

class RidePreferences {
  final bool allowsPets;
  final bool allowsSmoking;
  final bool hasAC;
  final bool isWomenOnly;
  final bool instantBooking;
  final LuggageCapacity luggageCapacity;
  final int maxDetourMinutes;

  const RidePreferences({
    this.allowsPets = false,
    this.allowsSmoking = false,
    this.hasAC = true,
    this.isWomenOnly = false,
    this.instantBooking = true,
    this.luggageCapacity = LuggageCapacity.medium,
    this.maxDetourMinutes = 10,
  });
}

class Ride {
  final String id;
  final User driver;
  final String originName;
  final String originAddress;
  final GeoPoint originCoords;
  final String destinationName;
  final String destinationAddress;
  final GeoPoint destinationCoords;
  final DateTime departureTime;
  final DateTime estimatedArrivalTime;
  final double distanceKm;
  final int estimatedDurationMinutes;
  final double basePricePerSeat;
  final int totalSeats;
  final int availableSeats;
  final List<Passenger> passengers;
  final List<RouteStop> stops;
  final List<GeoPoint> routePolyline;
  final RidePreferences preferences;
  final RideStatus status;
  final double matchScore; // 0.0 - 1.0 (e.g. 0.95 = 95% match)
  final String detourNotice;
  final double carbonSavedKg;

  const Ride({
    required this.id,
    required this.driver,
    required this.originName,
    required this.originAddress,
    required this.originCoords,
    required this.destinationName,
    required this.destinationAddress,
    required this.destinationCoords,
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.basePricePerSeat,
    required this.totalSeats,
    required this.availableSeats,
    this.passengers = const [],
    this.stops = const [],
    this.routePolyline = const [],
    this.preferences = const RidePreferences(),
    this.status = RideStatus.scheduled,
    this.matchScore = 0.95,
    this.detourNotice = '+4 min detour',
    this.carbonSavedKg = 8.4,
  });

  bool get isFull => availableSeats <= 0;
  int get bookedSeatsCount => totalSeats - availableSeats;
  double get totalFare => basePricePerSeat * (passengers.isEmpty ? 1 : passengers.length);

  Ride copyWith({
    String? id,
    User? driver,
    String? originName,
    String? originAddress,
    GeoPoint? originCoords,
    String? destinationName,
    String? destinationAddress,
    GeoPoint? destinationCoords,
    DateTime? departureTime,
    DateTime? estimatedArrivalTime,
    double? distanceKm,
    int? estimatedDurationMinutes,
    double? basePricePerSeat,
    int? totalSeats,
    int? availableSeats,
    List<Passenger>? passengers,
    List<RouteStop>? stops,
    List<GeoPoint>? routePolyline,
    RidePreferences? preferences,
    RideStatus? status,
    double? matchScore,
    String? detourNotice,
    double? carbonSavedKg,
  }) {
    return Ride(
      id: id ?? this.id,
      driver: driver ?? this.driver,
      originName: originName ?? this.originName,
      originAddress: originAddress ?? this.originAddress,
      originCoords: originCoords ?? this.originCoords,
      destinationName: destinationName ?? this.destinationName,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationCoords: destinationCoords ?? this.destinationCoords,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrivalTime: estimatedArrivalTime ?? this.estimatedArrivalTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      basePricePerSeat: basePricePerSeat ?? this.basePricePerSeat,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      passengers: passengers ?? this.passengers,
      stops: stops ?? this.stops,
      routePolyline: routePolyline ?? this.routePolyline,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      matchScore: matchScore ?? this.matchScore,
      detourNotice: detourNotice ?? this.detourNotice,
      carbonSavedKg: carbonSavedKg ?? this.carbonSavedKg,
    );
  }
}

class RideFilterCriteria {
  final String? origin;
  final String? destination;
  final DateTime? date;
  final int minSeats;
  final double maxPrice;
  final bool womenOnly;
  final bool instantBooking;
  final bool allowsPets;
  final bool hasAC;
  final LuggageCapacity luggageCapacity;
  final double maxDetourMinutes;
  final double minDriverRating;

  const RideFilterCriteria({
    this.origin,
    this.destination,
    this.date,
    this.minSeats = 1,
    this.maxPrice = 80.0,
    this.womenOnly = false,
    this.instantBooking = false,
    this.allowsPets = false,
    this.hasAC = false,
    this.luggageCapacity = LuggageCapacity.none,
    this.maxDetourMinutes = 20.0,
    this.minDriverRating = 4.0,
  });

  RideFilterCriteria copyWith({
    String? origin,
    String? destination,
    DateTime? date,
    int? minSeats,
    double? maxPrice,
    bool? womenOnly,
    bool? instantBooking,
    bool? allowsPets,
    bool? hasAC,
    LuggageCapacity? luggageCapacity,
    double? maxDetourMinutes,
    double? minDriverRating,
  }) {
    return RideFilterCriteria(
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      date: date ?? this.date,
      minSeats: minSeats ?? this.minSeats,
      maxPrice: maxPrice ?? this.maxPrice,
      womenOnly: womenOnly ?? this.womenOnly,
      instantBooking: instantBooking ?? this.instantBooking,
      allowsPets: allowsPets ?? this.allowsPets,
      hasAC: hasAC ?? this.hasAC,
      luggageCapacity: luggageCapacity ?? this.luggageCapacity,
      maxDetourMinutes: maxDetourMinutes ?? this.maxDetourMinutes,
      minDriverRating: minDriverRating ?? this.minDriverRating,
    );
  }
}
