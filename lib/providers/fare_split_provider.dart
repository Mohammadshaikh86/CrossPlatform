import 'package:flutter/foundation.dart';
import '../models/fare_split.dart';
import '../models/ride.dart';
import '../models/user.dart';

class FareSplitProvider with ChangeNotifier {
  late FareSplitCalculation _calculation;

  FareSplitProvider() {
    _initDefaultCalculation();
  }

  FareSplitCalculation get calculation => _calculation;

  void initializeForRide(Ride ride) {
    // Generate split list for all passengers + optional driver
    final List<PassengerSplitItem> splits = [];

    final totalPassengers = ride.passengers.isNotEmpty ? ride.passengers : [
      Passenger(
        user: User.currentUser,
        seatsBooked: 1,
        pickupStop: ride.originName,
        dropoffStop: ride.destinationName,
        distanceKm: ride.distanceKm,
        hasPaid: true,
        joinedAt: DateTime.now(),
      ),
      Passenger(
        user: const User(
          id: 'usr_4',
          name: 'Maya Lin',
          avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
          email: 'maya.lin@ridesharex.com',
          phone: '+1 (555) 345-6789',
          rating: 4.92,
          totalRides: 31,
          isVerified: true,
        ),
        seatsBooked: 1,
        pickupStop: 'San Mateo',
        dropoffStop: ride.destinationName,
        distanceKm: ride.distanceKm * 0.6,
        hasPaid: true,
        joinedAt: DateTime.now(),
      ),
      Passenger(
        user: const User(
          id: 'usr_5',
          name: 'Jordan Smith',
          avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&q=80',
          email: 'jordan.s@ridesharex.com',
          phone: '+1 (555) 567-8901',
          rating: 4.85,
          totalRides: 19,
          isVerified: true,
        ),
        seatsBooked: 1,
        pickupStop: 'Redwood City',
        dropoffStop: ride.destinationName,
        distanceKm: ride.distanceKm * 0.35,
        hasPaid: false,
        joinedAt: DateTime.now(),
      ),
    ];

    final double equalShare = (ride.basePricePerSeat * totalPassengers.length) / totalPassengers.length;
    final double equalPercent = 100.0 / totalPassengers.length;

    for (var i = 0; i < totalPassengers.length; i++) {
      final p = totalPassengers[i];
      splits.add(
        PassengerSplitItem(
          user: p.user,
          baseShare: ride.basePricePerSeat,
          distanceKm: p.distanceKm,
          customPercentage: double.parse(equalPercent.toStringAsFixed(1)),
          customAmount: double.parse(equalShare.toStringAsFixed(2)),
          calculatedShare: equalShare,
          status: p.hasPaid ? PaymentStatus.paid : PaymentStatus.pending,
          paymentMethod: p.hasPaid ? PaymentMethodType.applePay : null,
          paidAt: p.hasPaid ? DateTime.now().subtract(const Duration(minutes: 45)) : null,
        ),
      );
    }

    _calculation = FareSplitCalculation(
      rideId: ride.id,
      totalRideFare: ride.basePricePerSeat * totalPassengers.length,
      tollCharges: 6.50,
      tipAmount: 3.50,
      ecoDiscount: 2.00,
      method: SplitMethod.equal,
      passengerSplits: splits,
      includeDriverInSplit: false,
    );

    _recalculateShares();
  }

  void setSplitMethod(SplitMethod method) {
    _calculation = _calculation.copyWith(method: method);
    _recalculateShares();
    notifyListeners();
  }

  void updateTollCharges(double tolls) {
    _calculation = _calculation.copyWith(tollCharges: tolls);
    _recalculateShares();
    notifyListeners();
  }

  void updateTipAmount(double tip) {
    _calculation = _calculation.copyWith(tipAmount: tip);
    _recalculateShares();
    notifyListeners();
  }

  void updateEcoDiscount(double discount) {
    _calculation = _calculation.copyWith(ecoDiscount: discount);
    _recalculateShares();
    notifyListeners();
  }

  void updatePassengerCustomPercentage(int index, double percentage) {
    if (index >= 0 && index < _calculation.passengerSplits.length) {
      final updatedSplits = List<PassengerSplitItem>.from(_calculation.passengerSplits);
      updatedSplits[index] = updatedSplits[index].copyWith(customPercentage: percentage);
      _calculation = _calculation.copyWith(passengerSplits: updatedSplits);
      _recalculateShares();
      notifyListeners();
    }
  }

  void updatePassengerCustomAmount(int index, double amount) {
    if (index >= 0 && index < _calculation.passengerSplits.length) {
      final updatedSplits = List<PassengerSplitItem>.from(_calculation.passengerSplits);
      updatedSplits[index] = updatedSplits[index].copyWith(customAmount: amount);
      _calculation = _calculation.copyWith(passengerSplits: updatedSplits);
      _recalculateShares();
      notifyListeners();
    }
  }

  void togglePaymentStatus(int index) {
    if (index >= 0 && index < _calculation.passengerSplits.length) {
      final updatedSplits = List<PassengerSplitItem>.from(_calculation.passengerSplits);
      final current = updatedSplits[index];
      final isNowPaid = current.status != PaymentStatus.paid;

      updatedSplits[index] = current.copyWith(
        status: isNowPaid ? PaymentStatus.paid : PaymentStatus.pending,
        paymentMethod: isNowPaid ? PaymentMethodType.applePay : null,
        paidAt: isNowPaid ? DateTime.now() : null,
      );

      _calculation = _calculation.copyWith(passengerSplits: updatedSplits);
      notifyListeners();
    }
  }

  void markAllAsPaid() {
    final updatedSplits = _calculation.passengerSplits.map((item) {
      return item.copyWith(
        status: PaymentStatus.paid,
        paymentMethod: PaymentMethodType.applePay,
        paidAt: DateTime.now(),
      );
    }).toList();

    _calculation = _calculation.copyWith(passengerSplits: updatedSplits);
    notifyListeners();
  }

  void _recalculateShares() {
    final totalToSplit = _calculation.grandTotal;
    final count = _calculation.passengerSplits.length;
    if (count == 0) return;

    final updatedSplits = <PassengerSplitItem>[];

    switch (_calculation.method) {
      case SplitMethod.equal:
        final perPerson = totalToSplit / count;
        for (var item in _calculation.passengerSplits) {
          updatedSplits.add(item.copyWith(calculatedShare: double.parse(perPerson.toStringAsFixed(2))));
        }
        break;

      case SplitMethod.byDistance:
        final totalDistance = _calculation.passengerSplits.fold(0.0, (acc, item) => acc + item.distanceKm);
        for (var item in _calculation.passengerSplits) {
          final ratio = totalDistance > 0 ? (item.distanceKm / totalDistance) : (1.0 / count);
          final share = totalToSplit * ratio;
          updatedSplits.add(item.copyWith(calculatedShare: double.parse(share.toStringAsFixed(2))));
        }
        break;

      case SplitMethod.customPercent:
        for (var item in _calculation.passengerSplits) {
          final share = totalToSplit * (item.customPercentage / 100.0);
          updatedSplits.add(item.copyWith(calculatedShare: double.parse(share.toStringAsFixed(2))));
        }
        break;

      case SplitMethod.customFixed:
        for (var item in _calculation.passengerSplits) {
          updatedSplits.add(item.copyWith(calculatedShare: item.customAmount));
        }
        break;
    }

    _calculation = _calculation.copyWith(passengerSplits: updatedSplits);
  }

  void _initDefaultCalculation() {
    _calculation = const FareSplitCalculation(
      rideId: 'ride_101',
      totalRideFare: 43.50,
      tollCharges: 6.50,
      tipAmount: 4.00,
      ecoDiscount: 2.00,
      method: SplitMethod.equal,
      passengerSplits: [
        PassengerSplitItem(
          user: User.currentUser,
          baseShare: 14.50,
          distanceKm: 52.4,
          customPercentage: 33.3,
          customAmount: 17.33,
          calculatedShare: 17.33,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethodType.applePay,
        ),
        PassengerSplitItem(
          user: User(
            id: 'usr_4',
            name: 'Maya Lin',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&q=80',
            email: 'maya.lin@ridesharex.com',
            phone: '+1 (555) 345-6789',
            rating: 4.92,
            totalRides: 31,
            isVerified: true,
          ),
          baseShare: 14.50,
          distanceKm: 26.2,
          customPercentage: 33.3,
          customAmount: 17.33,
          calculatedShare: 17.33,
          status: PaymentStatus.paid,
          paymentMethod: PaymentMethodType.applePay,
        ),
        PassengerSplitItem(
          user: User(
            id: 'usr_5',
            name: 'Jordan Smith',
            avatarUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=200&q=80',
            email: 'jordan.s@ridesharex.com',
            phone: '+1 (555) 567-8901',
            rating: 4.85,
            totalRides: 19,
            isVerified: true,
          ),
          baseShare: 14.50,
          distanceKm: 14.8,
          customPercentage: 33.4,
          customAmount: 17.34,
          calculatedShare: 17.34,
          status: PaymentStatus.pending,
        ),
      ],
    );
  }
}
