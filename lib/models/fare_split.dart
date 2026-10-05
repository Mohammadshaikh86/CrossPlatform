import 'user.dart';

enum SplitMethod {
  equal,
  byDistance,
  customPercent,
  customFixed,
}

enum PaymentStatus {
  pending,
  paid,
  declined,
}

enum PaymentMethodType {
  applePay,
  googlePay,
  venmo,
  card,
  cash,
}

class PassengerSplitItem {
  final User user;
  final double baseShare;
  final double distanceKm;
  final double customPercentage;
  final double customAmount;
  final double calculatedShare;
  final PaymentStatus status;
  final PaymentMethodType? paymentMethod;
  final DateTime? paidAt;

  const PassengerSplitItem({
    required this.user,
    this.baseShare = 0.0,
    this.distanceKm = 10.0,
    this.customPercentage = 25.0,
    this.customAmount = 0.0,
    required this.calculatedShare,
    this.status = PaymentStatus.pending,
    this.paymentMethod,
    this.paidAt,
  });

  PassengerSplitItem copyWith({
    User? user,
    double? baseShare,
    double? distanceKm,
    double? customPercentage,
    double? customAmount,
    double? calculatedShare,
    PaymentStatus? status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) {
    return PassengerSplitItem(
      user: user ?? this.user,
      baseShare: baseShare ?? this.baseShare,
      distanceKm: distanceKm ?? this.distanceKm,
      customPercentage: customPercentage ?? this.customPercentage,
      customAmount: customAmount ?? this.customAmount,
      calculatedShare: calculatedShare ?? this.calculatedShare,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

class FareSplitCalculation {
  final String rideId;
  final double totalRideFare;
  final double tollCharges;
  final double tipAmount;
  final double ecoDiscount;
  final SplitMethod method;
  final List<PassengerSplitItem> passengerSplits;
  final bool includeDriverInSplit;

  const FareSplitCalculation({
    required this.rideId,
    required this.totalRideFare,
    this.tollCharges = 6.50,
    this.tipAmount = 4.00,
    this.ecoDiscount = 2.00,
    this.method = SplitMethod.equal,
    required this.passengerSplits,
    this.includeDriverInSplit = false,
  });

  double get grandTotal => totalRideFare + tollCharges + tipAmount - ecoDiscount;
  
  double get totalCollected => passengerSplits
      .where((s) => s.status == PaymentStatus.paid)
      .fold(0.0, (acc, item) => acc + item.calculatedShare);

  double get pendingAmount => grandTotal - totalCollected;

  FareSplitCalculation copyWith({
    String? rideId,
    double? totalRideFare,
    double? tollCharges,
    double? tipAmount,
    double? ecoDiscount,
    SplitMethod? method,
    List<PassengerSplitItem>? passengerSplits,
    bool? includeDriverInSplit,
  }) {
    return FareSplitCalculation(
      rideId: rideId ?? this.rideId,
      totalRideFare: totalRideFare ?? this.totalRideFare,
      tollCharges: tollCharges ?? this.tollCharges,
      tipAmount: tipAmount ?? this.tipAmount,
      ecoDiscount: ecoDiscount ?? this.ecoDiscount,
      method: method ?? this.method,
      passengerSplits: passengerSplits ?? this.passengerSplits,
      includeDriverInSplit: includeDriverInSplit ?? this.includeDriverInSplit,
    );
  }
}
