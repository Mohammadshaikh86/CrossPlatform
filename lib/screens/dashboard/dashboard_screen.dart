import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../models/user.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/user_avatar.dart';
import '../chat/ride_chat_screen.dart';
import '../fare_split/fare_split_screen.dart';
import '../ride_detail/ride_detail_screen.dart';
import '../search/ride_search_screen.dart';
import '../tracking/live_tracking_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final allRides = rideProvider.allRides;
    final activeRide = rideProvider.activeRide ?? allRides.first;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Header
              _buildTopBar(context),
              const SizedBox(height: 20),

              // Hero Greeting & Top Profile Card Row
              _buildHeroAndProfileRow(context, isWide),
              const SizedBox(height: 20),

              // 3 Metric Cards Row (CO2 Saved, Carpools Completed, Eco Score)
              _buildMetricsRow(context, isWide),
              const SizedBox(height: 28),

              // Main Content Layout (Split into Active Ride + Smart Matches on wide, or stacked on mobile)
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Active & Matching Rides
                    Expanded(
                      flex: 5,
                      child: _buildActiveRideSection(context, activeRide),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Smart Matches
                    Expanded(
                      flex: 5,
                      child: _buildSmartMatchesSection(context, allRides),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActiveRideSection(context, activeRide),
                    const SizedBox(height: 24),
                    _buildSmartMatchesSection(context, allRides),
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Bar
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Action Icons (Menu, Bell with orange badge, Search)
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu_rounded, size: 22, color: Colors.black87),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu drawer opened')),
                );
              },
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 22, color: Colors.black87),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifications: Marcus Vance is 11 mins away')),
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, size: 22, color: Colors.black87),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RideSearchScreen()),
                );
              },
            ),
          ],
        ),

        // Center Logo Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.directions_car_filled_rounded, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'RideShareX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),

        // Right Gear Settings Icon
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 22, color: Colors.black87),
          onPressed: () {
            onNavigateTab?.call(4); // Profile / Settings tab
          },
        ),
      ],
    );
  }

  // 2. Hero Greeting & Top Profile Card
  Widget _buildHeroAndProfileRow(BuildContext context, bool isWide) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Welcome Greeting + Wide Search Bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, Alex!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 14),

              // Wide Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RideSearchScreen()),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Text(
                            'Where are you commuting today? e.g., Palo Alto',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Material(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RideSearchScreen()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: const Icon(Icons.search_rounded, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Subtext with 'See All'
              Row(
                children: [
                  const Text(
                    'Where, San Francisco ➔ e.g., Palo Alto  ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RideSearchScreen()),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Right Column: Profile Card (Only if wide or tablet)
        if (isWide) ...[
          const SizedBox(width: 24),
          _buildFloatingProfileCard(context),
        ],
      ],
    );
  }

  // Floating Profile Card (Top Right in image)
  Widget _buildFloatingProfileCard(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFE0E7FF),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      User.currentUser.avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('A', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD97706),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 10, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.settings_outlined, size: 16, color: Color(0xFF9CA3AF)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Alex',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
          const Text(
            'Verified Profile',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, size: 11, color: Color(0xFFD97706)),
                SizedBox(width: 4),
                Text(
                  'Verified ID',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Three Metrics Cards
  Widget _buildMetricsRow(BuildContext context, bool isWide) {
    return Row(
      children: [
        // Metric 1: 128.4 kg CO2 Saved
        Expanded(
          child: _buildMetricCard(
            icon: Icons.directions_walk_rounded,
            iconBg: const Color(0xFFF3F4F6),
            iconColor: Colors.black87,
            title: '128.4 kg',
            subtitle: 'CO₂ Saved',
          ),
        ),
        const SizedBox(width: 14),

        // Metric 2: 48 Carpools Completed
        Expanded(
          child: _buildMetricCard(
            icon: Icons.group_outlined,
            iconBg: const Color(0xFFF3F4F6),
            iconColor: Colors.black87,
            title: '48',
            subtitle: 'Carpools Completed',
          ),
        ),
        const SizedBox(width: 14),

        // Metric 3: 4.9 Eco Score
        Expanded(
          child: _buildMetricCard(
            icon: Icons.eco_outlined,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            title: '4.9★',
            subtitle: 'Eco Score',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Active & Matching Rides Section (Left Column)
  Widget _buildActiveRideSection(BuildContext context, Ride activeRide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active & Matching Rides',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Active Ride Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Tags: ACTIVE RIDE & Status LIVE en route
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Text(
                      'ACTIVE RIDE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Status  ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 7, color: Color(0xFF16A34A)),
                            SizedBox(width: 4),
                            Text(
                              'LIVE en route',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Middle: Mini Map Preview + Driver & Vehicle Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini Map Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 170,
                      height: 105,
                      color: const Color(0xFFE2EFF8),
                      child: CustomPaint(
                        painter: _MiniMapPainter(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Driver & Vehicle side info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live ind tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Live ind',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Driver',
                          style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            UserAvatar(
                              name: activeRide.driver.name,
                              imageUrl: activeRide.driver.avatarUrl,
                              radius: 14,
                              isVerified: true,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeRide.driver.name,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                                      Text(
                                        ' Rating ${activeRide.driver.rating.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 6),
                        const Text(
                          'Model 3',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                        ),
                        const Text(
                          'Details simplified',
                          style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Route Title & Arrival Estimate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'San Francisco ➔ Palo Alto',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Driver: ${activeRide.driver.name}, Tesla Model 3 Long Range',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      Text(
                        '11:16 min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        'Real-time est: 27 min',
                        style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4 Action Buttons Row: Live Map, Split Fare, Chat, Share
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.navigation_rounded,
                      label: 'Live Map',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LiveTrackingScreen(ride: activeRide)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.receipt_long_outlined,
                      label: 'Split Fare',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FareSplitScreen(ride: activeRide)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RideChatScreen(ride: activeRide)),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.share_outlined,
                      label: 'Share',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Live carpool link copied to clipboard!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 5. Smart Matches Section (Right Column)
  Widget _buildSmartMatchesSection(BuildContext context, List<Ride> allRides) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Matches',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // List of Compact Smart Match Cards
        ...allRides.map((ride) {
          final timeStr = ride.id == 'ride_101' ? '08:31' : (ride.id == 'ride_102' ? '12:28' : 'Time');
          final originShort = ride.originName.split('(').first.trim();
          final destShort = ride.destinationName.split('(').first.trim();

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                Provider.of<RideProvider>(context, listen: false).selectRide(ride);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)),
                );
              },
              child: Row(
                children: [
                  // Route Segment: Origin node -> Destination node
                  Column(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF6B7280), width: 1.5),
                        ),
                      ),
                      Container(width: 1.5, height: 16, color: const Color(0xFFD1D5DB)),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  // Origin & Destination Names
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          originShort,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          destShort,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Time Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      timeStr,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Driver Avatar with Rating
                  UserAvatar(
                    name: ride.driver.name,
                    imageUrl: ride.driver.avatarUrl,
                    radius: 15,
                    isVerified: true,
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driver.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              '${ride.driver.rating.toStringAsFixed(2)}${ride.driver.totalRides > 50 ? " (${ride.driver.totalRides})" : ""}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Match Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Text(
                      '${(ride.matchScore * 100).toInt()}% Match',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Price & Seats Left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${ride.basePricePerSeat.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${ride.availableSeats} Seat Left',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),

        // See All Match Rides Link Button
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RideSearchScreen()),
              );
            },
            child: const Text(
              'See All Match Rides',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mini Map Painter for the Active Ride card thumbnail
class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Water & Land background
    final landPaint = Paint()..color = const Color(0xFFF3EFE6);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), landPaint);

    final waterPaint = Paint()..color = const Color(0xFFD4E8F5);
    final waterPath = Path();
    waterPath.moveTo(size.width * 0.45, 0);
    waterPath.quadraticBezierTo(size.width * 0.7, size.height * 0.35, size.width, size.height * 0.55);
    waterPath.lineTo(size.width, 0);
    waterPath.close();
    canvas.drawPath(waterPath, waterPaint);

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5DDD0)
      ..strokeWidth = 0.8;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Polyline road curve
    final routePaint = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.22, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.5,
      size.width * 0.65,
      size.height * 0.75,
    );
    canvas.drawPath(path, routePaint);

    // Amber car icon on polyline
    final carOffset = Offset(size.width * 0.58, size.height * 0.68);
    final carPaint = Paint()..color = const Color(0xFFD97706);
    canvas.drawCircle(carOffset, 7, carPaint);
    canvas.drawCircle(carOffset, 4, Paint()..color = Colors.white);

    // Labels
    final tp1 = TextPainter(
      text: const TextSpan(
        text: 'San Francisco',
        style: TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, Offset(size.width * 0.08, size.height * 0.08));

    final tp2 = TextPainter(
      text: const TextSpan(
        text: 'Palo Alto',
        style: TextStyle(color: Colors.black87, fontSize: 8, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, Offset(size.width * 0.55, size.height * 0.82));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
