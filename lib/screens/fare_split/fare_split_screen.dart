import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/fare_split.dart';
import '../../models/ride.dart';
import '../../providers/fare_split_provider.dart';
import '../../widgets/fare/fare_breakdown_card.dart';

class FareSplitScreen extends StatefulWidget {
  final Ride ride;

  const FareSplitScreen({super.key, required this.ride});

  @override
  State<FareSplitScreen> createState() => _FareSplitScreenState();
}

class _FareSplitScreenState extends State<FareSplitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FareSplitProvider>(context, listen: false).initializeForRide(widget.ride);
    });
  }

  void _showReceiptDialog(FareSplitCalculation calc) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.receipt_long_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Carpool Fare Receipt',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF111827)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ride ID: ${calc.rideId.toUpperCase()}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _buildReceiptRow('Base Carpool Fare', '\$${calc.totalRideFare.toStringAsFixed(2)}'),
              _buildReceiptRow('Bridges & Tolls', '+\$${calc.tollCharges.toStringAsFixed(2)}'),
              _buildReceiptRow('Driver Gratuity', '+\$${calc.tipAmount.toStringAsFixed(2)}'),
              _buildReceiptRow('RideShareX Eco Discount', '-\$${calc.ecoDiscount.toStringAsFixed(2)}'),
              const Divider(height: 18, color: Color(0xFFE5E7EB)),
              _buildReceiptRow('Grand Total', '\$${calc.grandTotal.toStringAsFixed(2)}', isBold: true),
              const SizedBox(height: 14),
              const Text(
                'Rider Breakdown:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 6),
              ...calc.passengerSplits.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.user.name} (${item.status.name.toUpperCase()})',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
                      ),
                      Text(
                        '\$${item.calculatedShare.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close', style: TextStyle(color: Color(0xFF4B5563))),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📄 Receipt exported & shared with participants!')),
                );
              },
              icon: const Icon(Icons.share, size: 14, color: Colors.white),
              label: const Text('Share Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceiptRow(String title, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
              color: const Color(0xFF111827),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fareProvider = Provider.of<FareSplitProvider>(context);
    final calculation = fareProvider.calculation;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.directions_car_filled_rounded, size: 14, color: Color(0xFFF59E0B)),
                  SizedBox(width: 6),
                  Text(
                    'RideShareX',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Dynamic Fare Splitting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, color: Colors.black87),
            tooltip: 'View Digital Receipt',
            onPressed: () => _showReceiptDialog(calculation),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Card with quick toll & tip adjusters
            FareBreakdownCard(
              calculation: calculation,
              onTollsChanged: fareProvider.updateTollCharges,
              onTipChanged: fareProvider.updateTipAmount,
              onDiscountChanged: fareProvider.updateEcoDiscount,
            ),
            const SizedBox(height: 20),

            // Split Method Selector Tabs
            const Text(
              'Select Splitting Method',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildSplitMethodTab(
                  label: 'Equal',
                  icon: Icons.pie_chart_outline,
                  isSelected: calculation.method == SplitMethod.equal,
                  onTap: () => fareProvider.setSplitMethod(SplitMethod.equal),
                ),
                const SizedBox(width: 8),
                _buildSplitMethodTab(
                  label: 'By Distance',
                  icon: Icons.timeline,
                  isSelected: calculation.method == SplitMethod.byDistance,
                  onTap: () => fareProvider.setSplitMethod(SplitMethod.byDistance),
                ),
                const SizedBox(width: 8),
                _buildSplitMethodTab(
                  label: 'Custom %',
                  icon: Icons.percent,
                  isSelected: calculation.method == SplitMethod.customPercent,
                  onTap: () => fareProvider.setSplitMethod(SplitMethod.customPercent),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Passenger Shares List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Per-Passenger Settlement',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    fareProvider.markAllAsPaid();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All passenger shares marked as settled!')),
                    );
                  },
                  icon: const Icon(Icons.done_all, size: 15, color: Color(0xFFD97706)),
                  label: const Text('Mark All Paid', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Passenger share tiles
            ...calculation.passengerSplits.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return PassengerShareTile(
                item: item,
                method: calculation.method,
                onTogglePayment: () => fareProvider.togglePaymentStatus(idx),
                onPercentageChanged: (val) => fareProvider.updatePassengerCustomPercentage(idx, val),
                onAmountChanged: (val) => fareProvider.updatePassengerCustomAmount(idx, val),
              );
            }),

            const SizedBox(height: 18),

            // Settlement Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: Colors.black87, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'RideShareX Escrow Protection',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Fares are only released to the driver upon successful destination drop-off.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showReceiptDialog(calculation),
                  icon: const Icon(Icons.receipt_outlined, size: 16),
                  label: const Text('View Invoice', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment request reminders dispatched to pending riders via SMS & Chat!'),
                        backgroundColor: Colors.black,
                      ),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                  label: const Text('Request Settlement', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitMethodTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
              width: 1.2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
