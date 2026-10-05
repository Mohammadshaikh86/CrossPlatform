import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/common/user_avatar.dart';
import '../fare_split/fare_split_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final bookedRides = rideProvider.myBookedRides;
    final hostedRides = rideProvider.myHostedRides;
    final user = User.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.directions_car_filled_rounded, size: 12, color: Color(0xFFF59E0B)),
                  SizedBox(width: 4),
                  Text(
                    'RideShareX',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'My Profile & Eco Score',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account settings & preferences')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card (Matching Dashboard Top Right Profile Style)
            Container(
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
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: const Color(0xFFE0E7FF),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.network(
                              user.avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text('A', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Color(0xFFD97706),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Verified ID',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF92400E)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 3),
                                Text(
                                  '${user.rating} (${user.totalRides} Carpools completed)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 14),

                  // 3 Eco Metrics
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileMetric('CO₂ Offset', '${user.co2SavedKg} kg', Icons.eco_outlined, const Color(0xFF16A34A)),
                      _buildProfileMetric('Trees Equiv', '6.2 🌲', Icons.nature_people_outlined, const Color(0xFFD97706)),
                      _buildProfileMetric('Money Saved', '\$348', Icons.savings_outlined, const Color(0xFF111827)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Registered Vehicle Details
            if (user.vehicle != null) ...[
              const Text(
                'Registered Vehicle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.electric_car_rounded, color: Colors.black87, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.vehicle!.displayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            'Plate: ${user.vehicle!.plateNumber} • Verified EV',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VERIFIED',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Carpool History & Invoices
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active & Past Carpools',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  '${bookedRides.length + hostedRides.length} rides',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (bookedRides.isEmpty && hostedRides.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No carpool history yet.'),
                ),
              )
            else
              ...bookedRides.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.commute, color: Colors.black87, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.originName.split('(').first.trim()} ➔ ${r.destinationName.split('(').first.trim()}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                            ),
                            Text(
                              'Driver: ${r.driver.name} • \$${r.basePricePerSeat.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.receipt_outlined, color: Colors.black87, size: 20),
                        tooltip: 'View Fare Invoice',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FareSplitScreen(ride: r)),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMetric(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF111827),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
