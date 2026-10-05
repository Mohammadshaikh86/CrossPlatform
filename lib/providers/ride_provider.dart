import 'package:flutter/foundation.dart';
import '../models/location_point.dart';
import '../models/ride.dart';
import '../models/user.dart';

class RideProvider with ChangeNotifier {
  final List<Ride> _rides = [];
  RideFilterCriteria _currentFilter = const RideFilterCriteria();
  Ride? _selectedRide;
  String? _activeRideId;

  RideProvider() {
    _initSampleRides();
  }

  List<Ride> get allRides => List.unmodifiable(_rides);
  RideFilterCriteria get currentFilter => _currentFilter;
  Ride? get selectedRide => _selectedRide;
  Ride? get activeRide => _rides.firstWhere(
        (r) => r.id == _activeRideId || r.status == RideStatus.enRoute,
        orElse: () => _rides.first,
      );

  List<Ride> get myBookedRides => _rides.where((r) {
        return r.passengers.any((p) => p.user.id == User.currentUser.id);
      }).toList();

  List<Ride> get myHostedRides => _rides.where((r) {
        return r.driver.id == User.currentUser.id;
      }).toList();

  void selectRide(Ride ride) {
    _selectedRide = ride;
    notifyListeners();
  }

  void setActiveRide(String rideId) {
    _activeRideId = rideId;
    notifyListeners();
  }

  void updateFilter(RideFilterCriteria newFilter) {
    _currentFilter = newFilter;
    notifyListeners();
  }

  void resetFilter() {
    _currentFilter = const RideFilterCriteria();
    notifyListeners();
  }

  List<Ride> getFilteredRides() {
    return _rides.where((ride) {
      if (_currentFilter.origin != null && _currentFilter.origin!.trim().isNotEmpty) {
        final query = _currentFilter.origin!.toLowerCase().trim();
        final matchOrigin = ride.originName.toLowerCase().contains(query) ||
            ride.originAddress.toLowerCase().contains(query);
        if (!matchOrigin) return false;
      }

      if (_currentFilter.destination != null && _currentFilter.destination!.trim().isNotEmpty) {
        final query = _currentFilter.destination!.toLowerCase().trim();
        final matchDest = ride.destinationName.toLowerCase().contains(query) ||
            ride.destinationAddress.toLowerCase().contains(query);
        if (!matchDest) return false;
      }

      if (ride.availableSeats < _currentFilter.minSeats) return false;
      if (ride.basePricePerSeat > _currentFilter.maxPrice) return false;
      if (_currentFilter.womenOnly && !ride.preferences.isWomenOnly) return false;
      if (_currentFilter.instantBooking && !ride.preferences.instantBooking) return false;
      if (_currentFilter.allowsPets && !ride.preferences.allowsPets) return false;
      if (_currentFilter.hasAC && !ride.preferences.hasAC) return false;
      if (ride.driver.rating < _currentFilter.minDriverRating) return false;

      return true;
    }).toList()
      ..sort((a, b) => b.matchScore.compareTo(a.matchScore));
  }

  bool bookRide(String rideId, int seatsCount, String pickupStop, String dropoffStop) {
    final index = _rides.indexWhere((r) => r.id == rideId);
    if (index == -1) return false;

    final ride = _rides[index];
    if (ride.availableSeats < seatsCount) return false;

    final newPassenger = Passenger(
      user: User.currentUser,
      seatsBooked: seatsCount,
      pickupStop: pickupStop.isNotEmpty ? pickupStop : ride.originName,
      dropoffStop: dropoffStop.isNotEmpty ? dropoffStop : ride.destinationName,
      distanceKm: ride.distanceKm * 0.85,
      hasPaid: false,
      joinedAt: DateTime.now(),
    );

    final updatedPassengers = List<Passenger>.from(ride.passengers)..add(newPassenger);
    final updatedRide = ride.copyWith(
      availableSeats: ride.availableSeats - seatsCount,
      passengers: updatedPassengers,
      status: ride.status == RideStatus.matching ? RideStatus.scheduled : ride.status,
    );

    _rides[index] = updatedRide;
    if (_selectedRide?.id == rideId) {
      _selectedRide = updatedRide;
    }
    _activeRideId = rideId;
    notifyListeners();
    return true;
  }

  void cancelBooking(String rideId) {
    final index = _rides.indexWhere((r) => r.id == rideId);
    if (index == -1) return;

    final ride = _rides[index];
    final passenger = ride.passengers.firstWhere(
      (p) => p.user.id == User.currentUser.id,
      orElse: () => ride.passengers.first,
    );

    final updatedPassengers = ride.passengers.where((p) => p.user.id != User.currentUser.id).toList();
    final updatedRide = ride.copyWith(
      availableSeats: ride.availableSeats + passenger.seatsBooked,
      passengers: updatedPassengers,
    );

    _rides[index] = updatedRide;
    if (_selectedRide?.id == rideId) {
      _selectedRide = updatedRide;
    }
    notifyListeners();
  }

  void updateRideStatus(String rideId, RideStatus newStatus) {
    final index = _rides.indexWhere((r) => r.id == rideId);
    if (index != -1) {
      _rides[index] = _rides[index].copyWith(status: newStatus);
      if (_selectedRide?.id == rideId) {
        _selectedRide = _rides[index];
      }
      notifyListeners();
    }
  }

  void addRide(Ride newRide) {
    _rides.insert(0, newRide);
    notifyListeners();
  }

  void _initSampleRides() {
    final now = DateTime.now();

    final userMarcus = const User(
      id: 'usr_1',
      name: 'Marcus Vance',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      email: 'marcus.v@ridesharex.com',
      phone: '+1 (555) 432-8765',
      rating: 4.96,
      totalRides: 142,
      isVerified: true,
      isDriver: true,
      vehicle: Vehicle(
        make: 'Tesla',
        model: 'Model 3 Long Range',
        color: 'Midnight Silver',
        plateNumber: '6TRX921',
        year: 2023,
      ),
      bio: 'Daily commuter from SF Financial District to Palo Alto / Stanford. Friendly, clean car, smooth jazz.',
      co2SavedKg: 340.2,
    );

    final userElena = const User(
      id: 'usr_2',
      name: 'Elena Rostova',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      email: 'elena.r@ridesharex.com',
      phone: '+1 (555) 987-1234',
      rating: 4.98,
      totalRides: 89,
      isVerified: true,
      isDriver: true,
      vehicle: Vehicle(
        make: 'Hyundai',
        model: 'Ioniq 5 EV',
        color: 'Cyber Gray',
        plateNumber: '8ION882',
        year: 2024,
      ),
      bio: 'Architect heading from Berkeley to Downtown SF every morning. Non-smoker, quiet rides welcome.',
      co2SavedKg: 215.8,
    );

    final userDavid = const User(
      id: 'usr_3',
      name: 'David Chen',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      email: 'david.c@ridesharex.com',
      phone: '+1 (555) 765-4321',
      rating: 4.88,
      totalRides: 64,
      isVerified: true,
      isDriver: true,
      vehicle: Vehicle(
        make: 'Polestar',
        model: 'Polestar 2',
        color: 'Magnesium',
        plateNumber: '4PLS391',
        year: 2023,
      ),
      bio: 'Software engineer from San Jose to Cupertino Apple Park. Carpool lane all the way!',
      co2SavedKg: 180.5,
    );

    final userMaya = const User(
      id: 'usr_4',
      name: 'Maya Lin',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
      email: 'maya.lin@ridesharex.com',
      phone: '+1 (555) 345-6789',
      rating: 4.92,
      totalRides: 31,
      isVerified: true,
      isDriver: false,
    );

    final userJordan = const User(
      id: 'usr_5',
      name: 'Jordan Smith',
      avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&q=80',
      email: 'jordan.s@ridesharex.com',
      phone: '+1 (555) 567-8901',
      rating: 4.85,
      totalRides: 19,
      isVerified: true,
      isDriver: false,
    );

    // Primary Active Featured Ride (SF Downtown -> Palo Alto / Stanford)
    final ride1 = Ride(
      id: 'ride_101',
      driver: userMarcus,
      originName: 'San Francisco (Salesforce Tower)',
      originAddress: '415 Mission St, San Francisco, CA',
      originCoords: const GeoPoint(latitude: 37.7897, longitude: -122.3972, title: 'Salesforce Tower'),
      destinationName: 'Palo Alto (Stanford Campus)',
      destinationAddress: '450 Jane Stanford Way, Stanford, CA',
      destinationCoords: const GeoPoint(latitude: 37.4275, longitude: -122.1697, title: 'Stanford University'),
      departureTime: now.add(const Duration(minutes: 18)),
      estimatedArrivalTime: now.add(const Duration(minutes: 62)),
      distanceKm: 52.4,
      estimatedDurationMinutes: 44,
      basePricePerSeat: 14.50,
      totalSeats: 4,
      availableSeats: 1,
      status: RideStatus.enRoute,
      matchScore: 0.98,
      detourNotice: '+3 min detour (Redwood City Stop)',
      carbonSavedKg: 14.2,
      preferences: const RidePreferences(
        allowsPets: false,
        allowsSmoking: false,
        hasAC: true,
        instantBooking: true,
        luggageCapacity: LuggageCapacity.medium,
        maxDetourMinutes: 8,
      ),
      passengers: [
        Passenger(
          user: User.currentUser,
          seatsBooked: 1,
          pickupStop: 'San Francisco (Salesforce Tower)',
          dropoffStop: 'Palo Alto (Stanford Campus)',
          distanceKm: 52.4,
          hasPaid: true,
          joinedAt: now.subtract(const Duration(hours: 3)),
        ),
        Passenger(
          user: userMaya,
          seatsBooked: 1,
          pickupStop: 'San Mateo (Hillsdale Mall)',
          dropoffStop: 'Palo Alto (Stanford Campus)',
          distanceKm: 26.2,
          hasPaid: true,
          joinedAt: now.subtract(const Duration(hours: 2)),
        ),
        Passenger(
          user: userJordan,
          seatsBooked: 1,
          pickupStop: 'Redwood City (Caltrain Station)',
          dropoffStop: 'Palo Alto (Stanford Campus)',
          distanceKm: 14.8,
          hasPaid: false,
          joinedAt: now.subtract(const Duration(hours: 1)),
        ),
      ],
      stops: const [
        RouteStop(
          id: 'stop_1',
          name: 'Salesforce Tower (Origin)',
          address: '415 Mission St, San Francisco',
          coordinates: GeoPoint(latitude: 37.7897, longitude: -122.3972, title: 'SF Pickup'),
          expectedTime: '08:15 AM',
          isPickup: true,
          isCompleted: true,
        ),
        RouteStop(
          id: 'stop_2',
          name: 'San Mateo Hillsdale',
          address: '60 31st Ave, San Mateo',
          coordinates: GeoPoint(latitude: 37.5407, longitude: -122.2982, title: 'San Mateo Stop'),
          expectedTime: '08:35 AM',
          isPickup: true,
          isCompleted: true,
        ),
        RouteStop(
          id: 'stop_3',
          name: 'Redwood City Caltrain',
          address: '1 James Ave, Redwood City',
          coordinates: GeoPoint(latitude: 37.4858, longitude: -122.2319, title: 'Redwood City Stop'),
          expectedTime: '08:48 AM',
          isPickup: true,
          isCompleted: false,
        ),
        RouteStop(
          id: 'stop_4',
          name: 'Stanford University (Destination)',
          address: '450 Jane Stanford Way, Stanford',
          coordinates: GeoPoint(latitude: 37.4275, longitude: -122.1697, title: 'Stanford Dropoff'),
          expectedTime: '09:02 AM',
          isDropoff: true,
          isCompleted: false,
        ),
      ],
      routePolyline: const [
        GeoPoint(latitude: 37.7897, longitude: -122.3972, title: 'SF'),
        GeoPoint(latitude: 37.7500, longitude: -122.4000, title: 'US-101 S'),
        GeoPoint(latitude: 37.6600, longitude: -122.4000, title: 'South SF'),
        GeoPoint(latitude: 37.6213, longitude: -122.3790, title: 'SFO Airport Bypass'),
        GeoPoint(latitude: 37.5407, longitude: -122.2982, title: 'San Mateo'),
        GeoPoint(latitude: 37.5000, longitude: -122.2600, title: 'Belmont/San Carlos'),
        GeoPoint(latitude: 37.4858, longitude: -122.2319, title: 'Redwood City'),
        GeoPoint(latitude: 37.4500, longitude: -122.1900, title: 'Menlo Park'),
        GeoPoint(latitude: 37.4275, longitude: -122.1697, title: 'Stanford University'),
      ],
    );

    // Ride 2 (Berkeley Downtown -> SFO Airport)
    final ride2 = Ride(
      id: 'ride_102',
      driver: userElena,
      originName: 'Berkeley Downtown (BART Station)',
      originAddress: '2161 Shattuck Ave, Berkeley, CA',
      originCoords: const GeoPoint(latitude: 37.8701, longitude: -122.2682, title: 'Berkeley'),
      destinationName: 'San Francisco Intl Airport (SFO)',
      destinationAddress: 'San Francisco, CA 94128',
      destinationCoords: const GeoPoint(latitude: 37.6213, longitude: -122.3790, title: 'SFO'),
      departureTime: now.add(const Duration(hours: 2, minutes: 15)),
      estimatedArrivalTime: now.add(const Duration(hours: 3, minutes: 05)),
      distanceKm: 38.6,
      estimatedDurationMinutes: 50,
      basePricePerSeat: 18.00,
      totalSeats: 3,
      availableSeats: 2,
      status: RideStatus.matching,
      matchScore: 0.94,
      detourNotice: '+0 min (Direct Route)',
      carbonSavedKg: 10.8,
      preferences: const RidePreferences(
        allowsPets: true,
        allowsSmoking: false,
        hasAC: true,
        isWomenOnly: true,
        instantBooking: true,
        luggageCapacity: LuggageCapacity.large,
        maxDetourMinutes: 5,
      ),
      passengers: [
        Passenger(
          user: userMaya,
          seatsBooked: 1,
          pickupStop: 'Berkeley Downtown',
          dropoffStop: 'SFO Terminal 2',
          distanceKm: 38.6,
          hasPaid: false,
          joinedAt: now.subtract(const Duration(minutes: 40)),
        ),
      ],
      stops: const [
        RouteStop(
          id: 'stop_201',
          name: 'Berkeley Downtown BART',
          address: '2161 Shattuck Ave, Berkeley',
          coordinates: GeoPoint(latitude: 37.8701, longitude: -122.2682, title: 'Berkeley'),
          expectedTime: '10:30 AM',
          isPickup: true,
        ),
        RouteStop(
          id: 'stop_202',
          name: 'Oakland Grand Lake',
          address: 'Grand Ave, Oakland',
          coordinates: GeoPoint(latitude: 37.8105, longitude: -122.2470, title: 'Oakland'),
          expectedTime: '10:45 AM',
          isPickup: true,
        ),
        RouteStop(
          id: 'stop_203',
          name: 'SFO International Terminal',
          address: 'San Francisco International Airport',
          coordinates: GeoPoint(latitude: 37.6213, longitude: -122.3790, title: 'SFO Airport'),
          expectedTime: '11:20 AM',
          isDropoff: true,
        ),
      ],
      routePolyline: const [
        GeoPoint(latitude: 37.8701, longitude: -122.2682, title: 'Berkeley'),
        GeoPoint(latitude: 37.8105, longitude: -122.2470, title: 'Oakland'),
        GeoPoint(latitude: 37.7983, longitude: -122.3778, title: 'Bay Bridge'),
        GeoPoint(latitude: 37.7500, longitude: -122.4000, title: 'US-101 S'),
        GeoPoint(latitude: 37.6213, longitude: -122.3790, title: 'SFO Airport'),
      ],
    );

    // Ride 3 (San Jose Diridon -> Cupertino Apple Park)
    final ride3 = Ride(
      id: 'ride_103',
      driver: userDavid,
      originName: 'San Jose Diridon Station',
      originAddress: '65 Cahill St, San Jose, CA',
      originCoords: const GeoPoint(latitude: 37.3299, longitude: -121.9029, title: 'San Jose'),
      destinationName: 'Cupertino (Apple Park)',
      destinationAddress: '1 Apple Park Way, Cupertino, CA',
      destinationCoords: const GeoPoint(latitude: 37.3346, longitude: -122.0090, title: 'Apple Park'),
      departureTime: now.add(const Duration(hours: 4, minutes: 30)),
      estimatedArrivalTime: now.add(const Duration(hours: 5, minutes: 00)),
      distanceKm: 18.2,
      estimatedDurationMinutes: 28,
      basePricePerSeat: 9.50,
      totalSeats: 3,
      availableSeats: 3,
      status: RideStatus.matching,
      matchScore: 0.89,
      detourNotice: '+2 min detour',
      carbonSavedKg: 5.6,
      preferences: const RidePreferences(
        allowsPets: false,
        allowsSmoking: false,
        hasAC: true,
        instantBooking: true,
        luggageCapacity: LuggageCapacity.small,
        maxDetourMinutes: 10,
      ),
      passengers: const [],
      stops: const [
        RouteStop(
          id: 'stop_301',
          name: 'San Jose Diridon',
          address: '65 Cahill St, San Jose',
          coordinates: GeoPoint(latitude: 37.3299, longitude: -121.9029, title: 'San Jose Pickup'),
          expectedTime: '12:45 PM',
          isPickup: true,
        ),
        RouteStop(
          id: 'stop_302',
          name: 'Santana Row Entrance',
          address: '377 Santana Row, San Jose',
          coordinates: GeoPoint(latitude: 37.3216, longitude: -121.9482, title: 'Santana Row'),
          expectedTime: '12:55 PM',
          isPickup: true,
        ),
        RouteStop(
          id: 'stop_303',
          name: 'Apple Park Transit Hub',
          address: '1 Apple Park Way, Cupertino',
          coordinates: GeoPoint(latitude: 37.3346, longitude: -122.0090, title: 'Apple Park Dropoff'),
          expectedTime: '01:15 PM',
          isDropoff: true,
        ),
      ],
      routePolyline: const [
        GeoPoint(latitude: 37.3299, longitude: -121.9029, title: 'San Jose'),
        GeoPoint(latitude: 37.3216, longitude: -121.9482, title: 'Santana Row'),
        GeoPoint(latitude: 37.3280, longitude: -121.9800, title: 'I-280 N'),
        GeoPoint(latitude: 37.3346, longitude: -122.0090, title: 'Apple Park'),
      ],
    );

    _rides.addAll([ride1, ride2, ride3]);
    _selectedRide = ride1;
    _activeRideId = ride1.id;
  }
}
