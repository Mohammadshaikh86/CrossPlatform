import 'package:flutter/material.dart';
import '../../models/fare_split.dart';
import '../../models/user.dart';
import '../common/user_avatar.dart';

class FareBreakdownCard extends StatelessWidget {
  final FareSplitCalculation calculation;
  final ValueChanged<double> onTollsChanged;
  final ValueChanged<double> onTipChanged;
  final ValueChanged<double> onDiscountChanged;

  const FareBreakdownCard({
    super.key,
    required this.calculation,
    required this.onTollsChanged,
    required this.onTipChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL CARPOOL POOL',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${calculation.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Collected',
                      style: TextStyle(color: Color(0xFF15803D), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '\$${calculation.totalCollected.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF15803D),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          // Line Items
          _buildSummaryLine('Base Ride Fare', '\$${calculation.totalRideFare.toStringAsFixed(2)}'),
          _buildSummaryLine('Bridges & Highway Tolls', '+\$${calculation.tollCharges.toStringAsFixed(2)}'),
          _buildSummaryLine('Driver Appreciation Tip', '+\$${calculation.tipAmount.toStringAsFixed(2)}'),
          _buildSummaryLine('RideShareX Eco Discount', '-\$${calculation.ecoDiscount.toStringAsFixed(2)}', isGreen: true),

          const SizedBox(height: 14),

          // Quick Fee Adjusters Chips
          Row(
            children: [
              Expanded(
                child: _buildAdjustmentPill(
                  context,
                  label: 'Tolls (\$${calculation.tollCharges.toStringAsFixed(1)})',
                  icon: Icons.toll,
                  onTap: () => _showFeeModal(
                    context,
                    title: 'Toll Charges',
                    current: calculation.tollCharges,
                    onSave: onTollsChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAdjustmentPill(
                  context,
                  label: 'Tip (\$${calculation.tipAmount.toStringAsFixed(1)})',
                  icon: Icons.favorite_border,
                  onTap: () => _showFeeModal(
                    context,
                    title: 'Driver Tip',
                    current: calculation.tipAmount,
                    onSave: onTipChanged,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAdjustmentPill(
                  context,
                  label: 'Eco -\$${calculation.ecoDiscount.toStringAsFixed(1)}',
                  icon: Icons.eco,
                  onTap: () => _showFeeModal(
                    context,
                    title: 'Eco Discount',
                    current: calculation.ecoDiscount,
                    onSave: onDiscountChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String amount, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF111827),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustmentPill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFFD97706)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeeModal(
    BuildContext context, {
    required String title,
    required double current,
    required ValueChanged<double> onSave,
  }) {
    double tempVal = current;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setMState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adjust $title',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '\$${tempVal.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFFD97706)),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      thumbColor: const Color(0xFFD97706),
                    ),
                    child: Slider(
                      value: tempVal,
                      min: 0.0,
                      max: 25.0,
                      divisions: 50,
                      onChanged: (val) {
                        setMState(() => tempVal = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        onSave(tempVal);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update Charge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class PassengerShareTile extends StatelessWidget {
  final PassengerSplitItem item;
  final SplitMethod method;
  final VoidCallback onTogglePayment;
  final ValueChanged<double>? onPercentageChanged;
  final ValueChanged<double>? onAmountChanged;

  const PassengerShareTile({
    super.key,
    required this.item,
    required this.method,
    required this.onTogglePayment,
    this.onPercentageChanged,
    this.onAmountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = item.status == PaymentStatus.paid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(
                name: item.user.name,
                imageUrl: item.user.avatarUrl,
                radius: 17,
                isVerified: item.user.isVerified,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.user.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        if (item.user.id == User.currentUser.id) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YOU',
                              style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Distance: ${item.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Share Amount & Pay Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${item.calculatedShare.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: onTogglePayment,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPaid ? Icons.check_circle : Icons.pending_outlined,
                            size: 11,
                            color: isPaid ? const Color(0xFF15803D) : const Color(0xFF92400E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPaid ? 'PAID' : 'PENDING',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isPaid ? const Color(0xFF15803D) : const Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Custom percentage slider
          if (method == SplitMethod.customPercent) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '${item.customPercentage.toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.black,
                      inactiveTrackColor: const Color(0xFFE5E7EB),
                      thumbColor: const Color(0xFFD97706),
                    ),
                    child: Slider(
                      value: item.customPercentage,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: onPercentageChanged,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
