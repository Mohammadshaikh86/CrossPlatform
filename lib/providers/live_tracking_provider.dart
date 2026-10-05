import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../models/location_point.dart';
import '../models/ride.dart';

class LiveTrackingProvider with ChangeNotifier {
  Timer? _ticker;
  double _progress = 0.28; // 0.0 to 1.0 along the route
  bool _isSimulating = true;
  int _speedMultiplier = 1;
  bool _isSosActive = false;
  String _shareableLink = 'https://ridesharex.app/track/rsx-live-9042';

  // Live telemetry
  double _currentSpeedKmh = 64.5;
  int _remainingMinutes = 26;
  double _remainingKm = 34.2;
  String _currentStreet = 'Bayshore Fwy (US-101 S)';
  String _nextStopNotice = 'Next Stop: Redwood City Caltrain (12 min)';

  LiveTrackingProvider() {
    _startSimulationTicker();
  }

  double get progress => _progress;
  bool get isSimulating => _isSimulating;
  int get speedMultiplier => _speedMultiplier;
  bool get isSosActive => _isSosActive;
  String get shareableLink => _shareableLink;
  double get currentSpeedKmh => _currentSpeedKmh;
  int get remainingMinutes => _remainingMinutes;
  double get remainingKm => _remainingKm;
  String get currentStreet => _currentStreet;
  String get nextStopNotice => _nextStopNotice;

  void toggleSimulation() {
    _isSimulating = !_isSimulating;
    notifyListeners();
  }

  void setSpeedMultiplier(int multiplier) {
    _speedMultiplier = multiplier;
    notifyListeners();
  }

  void resetSimulation() {
    _progress = 0.05;
    _remainingMinutes = 42;
    _remainingKm = 48.0;
    _currentSpeedKmh = 58.0;
    _currentStreet = 'San Francisco (Mission St)';
    _nextStopNotice = 'Next Stop: San Mateo Hillsdale (18 min)';
    notifyListeners();
  }

  void toggleSos() {
    _isSosActive = !_isSosActive;
    notifyListeners();
  }

  void updateProgressManual(double val) {
    _progress = val.clamp(0.0, 1.0);
    _updateTelemetry();
    notifyListeners();
  }

  /// Computes interpolated vehicle coordinates along the ride's polyline
  GeoPoint getCurrentVehiclePosition(Ride ride) {
    final polyline = ride.routePolyline;
    if (polyline.isEmpty) {
      return ride.originCoords;
    }
    if (polyline.length == 1) {
      return polyline.first;
    }

    final totalSegments = polyline.length - 1;
    final scaledProgress = _progress * totalSegments;
    final segmentIndex = scaledProgress.floor().clamp(0, totalSegments - 1);
    final segmentFraction = scaledProgress - segmentIndex;

    final p1 = polyline[segmentIndex];
    final p2 = polyline[segmentIndex + 1];

    final lat = p1.latitude + (p2.latitude - p1.latitude) * segmentFraction;
    final lng = p1.longitude + (p2.longitude - p1.longitude) * segmentFraction;

    return GeoPoint(
      latitude: lat,
      longitude: lng,
      title: ride.driver.vehicle?.displayName ?? 'Carpool Vehicle',
      subtitle: 'Moving • ${_currentSpeedKmh.toStringAsFixed(0)} km/h',
    );
  }

  /// Computes vehicle heading angle (in radians) for rotating the car icon on the map
  double getVehicleHeadingAngle(Ride ride) {
    final polyline = ride.routePolyline;
    if (polyline.length < 2) return 0.0;

    final totalSegments = polyline.length - 1;
    final scaledProgress = _progress * totalSegments;
    final segmentIndex = scaledProgress.floor().clamp(0, totalSegments - 1);

    final p1 = polyline[segmentIndex];
    final p2 = polyline[segmentIndex + 1];

    final dLat = p2.latitude - p1.latitude;
    final dLng = p2.longitude - p1.longitude;

    return math.atan2(dLng, dLat);
  }

  void _startSimulationTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!_isSimulating) return;

      final step = 0.003 * _speedMultiplier;
      _progress += step;
      if (_progress >= 1.0) {
        _progress = 0.0; // Loop or reach destination
      }

      _updateTelemetry();
      notifyListeners();
    });
  }

  void _updateTelemetry() {
    // Dynamic simulated values
    final rawRemainingRatio = (1.0 - _progress);
    _remainingKm = double.parse((52.4 * rawRemainingRatio).toStringAsFixed(1));
    _remainingMinutes = (44 * rawRemainingRatio).round().clamp(1, 44);

    final randomVariance = (math.sin(_progress * 10) * 8);
    _currentSpeedKmh = (68.0 + randomVariance).clamp(20.0, 95.0);

    if (_progress < 0.25) {
      _currentStreet = 'US-101 S (Brisbane Bypass)';
      _nextStopNotice = 'Next Stop: San Mateo Hillsdale in 8 min';
    } else if (_progress < 0.60) {
      _currentStreet = 'Bayshore Fwy (San Mateo Corridor)';
      _nextStopNotice = 'Next Stop: Redwood City Caltrain in 11 min';
    } else if (_progress < 0.85) {
      _currentStreet = 'Middlefield Rd & El Camino Real';
      _nextStopNotice = 'Next Stop: Stanford University Dropoff in 6 min';
    } else {
      _currentStreet = 'Palm Dr (Approaching Stanford Oval)';
      _nextStopNotice = 'Arriving at Destination in 2 min';
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
