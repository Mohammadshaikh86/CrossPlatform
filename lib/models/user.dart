class Vehicle {
  final String make;
  final String model;
  final String color;
  final String plateNumber;
  final int year;
  final String imageUrl;

  const Vehicle({
    required this.make,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.year,
    this.imageUrl = 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?w=400&q=80',
  });

  String get displayName => '$color $make $model ($year)';
}

class User {
  final String id;
  final String name;
  final String avatarUrl;
  final String email;
  final String phone;
  final double rating;
  final int totalRides;
  final bool isVerified;
  final bool isDriver;
  final Vehicle? vehicle;
  final String bio;
  final double co2SavedKg;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.email,
    required this.phone,
    required this.rating,
    required this.totalRides,
    this.isVerified = true,
    this.isDriver = false,
    this.vehicle,
    this.bio = 'Eco-friendly commuter & daily carpooler.',
    this.co2SavedKg = 42.5,
  });

  static const User currentUser = User(
    id: 'usr_me',
    name: 'Alex Rivera',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    email: 'alex.rivera@ridesharex.com',
    phone: '+1 (555) 234-5678',
    rating: 4.94,
    totalRides: 48,
    isVerified: true,
    isDriver: true,
    vehicle: Vehicle(
      make: 'Tesla',
      model: 'Model Y',
      color: 'Pearl White',
      plateNumber: 'RSX-8902',
      year: 2024,
    ),
    bio: 'Tech lead commuting SF to Mountain View. Love quiet rides & good podcast recommendations.',
    co2SavedKg: 128.4,
  );
}

class Passenger {
  final User user;
  final int seatsBooked;
  final String pickupStop;
  final String dropoffStop;
  final double distanceKm;
  final bool hasPaid;
  final DateTime joinedAt;

  const Passenger({
    required this.user,
    this.seatsBooked = 1,
    required this.pickupStop,
    required this.dropoffStop,
    required this.distanceKm,
    this.hasPaid = false,
    required this.joinedAt,
  });

  Passenger copyWith({
    User? user,
    int? seatsBooked,
    String? pickupStop,
    String? dropoffStop,
    double? distanceKm,
    bool? hasPaid,
    DateTime? joinedAt,
  }) {
    return Passenger(
      user: user ?? this.user,
      seatsBooked: seatsBooked ?? this.seatsBooked,
      pickupStop: pickupStop ?? this.pickupStop,
      dropoffStop: dropoffStop ?? this.dropoffStop,
      distanceKm: distanceKm ?? this.distanceKm,
      hasPaid: hasPaid ?? this.hasPaid,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
