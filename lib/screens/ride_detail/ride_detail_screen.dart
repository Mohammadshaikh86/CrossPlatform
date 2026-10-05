import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../models/user.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/map/route_map_view.dart';
import '../../widgets/ride/seat_selector_widget.dart';
import '../chat/ride_chat_screen.dart';
import '../fare_split/fare_split_screen.dart';
import '../tracking/live_tracking_screen.dart';

class RideDetailScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  int _selectedSeats = 1;
  String _selectedPickup = '';
  String _selectedDropoff = '';

  @override
  void initState() {
    super.initState();
    _selectedPickup = widget.ride.originName;
    _selectedDropoff = widget.ride.destinationName;
  }

  void _bookRide() {
    final rideProvider = Provider.of<RideProvider>(context, listen: false);
    final isSuccess = rideProvider.bookRide(
      widget.ride.id,
      _selectedSeats,
      _selectedPickup,
      _selectedDropoff,
    );

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Seat booked successfully with ${widget.ride.driver.name}!'),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: 'VIEW LIVE MAP',
            textColor: const Color(0xFFF59E0B),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LiveTrackingScreen(ride: widget.ride),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final timeFormat = DateFormat('hh:mm a • EEE, MMM d');
    final formattedDeparture = timeFormat.format(ride.departureTime);
    final bool isUserPassenger = ride.passengers.any((p) => p.user.id == User.currentUser.id);

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
              'Carpool Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            tooltip: 'Share carpool',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carpool link copied to clipboard!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.black87),
            tooltip: 'Ride chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RideChatScreen(ride: ride)),
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
            // Interactive Route Vector Map Preview
            RouteMapView(
              ride: ride,
              height: 220,
              onExpandTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LiveTrackingScreen(ride: ride)),
                );
              },
            ),
            const SizedBox(height: 18),

            // Departure & Match Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedDeparture,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${ride.estimatedDurationMinutes} mins estimated (${ride.distanceKm.toStringAsFixed(1)} km)',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Text(
                    '${(ride.matchScore * 100).toInt()}% Match',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Route Stops Timeline Card
            _buildRouteTimeline(ride),
            const SizedBox(height: 18),

            // Driver Verification & Vehicle Specs Card
            _buildDriverCard(ride),
            const SizedBox(height: 18),

            // Car Cabin Seat Layout Selector
            SeatSelectorWidget(
              ride: ride,
              selectedSeatsCount: _selectedSeats,
              onSeatsChanged: (count) {
                setState(() => _selectedSeats = count.clamp(1, ride.availableSeats));
              },
            ),
            const SizedBox(height: 18),

            // Co-passengers section
            _buildPassengersSection(ride),
            const SizedBox(height: 18),

            // Amenities & Carpool Policies
            _buildAmenitiesSection(ride),
            const SizedBox(height: 110), // padding for sticky bottom bar
          ],
        ),
      ),

      // Sticky Bottom Booking Bar
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price Total
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL FARE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '\$${(ride.basePricePerSeat * _selectedSeats).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Split Fare Calculator Shortcut
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FareSplitScreen(ride: ride)),
                  );
                },
                icon: const Icon(Icons.calculate_outlined, size: 16),
                label: const Text('Split Fare', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 10),

              // Primary Action: Book or Live Map
              Expanded(
                child: ElevatedButton(
                  onPressed: isUserPassenger
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LiveTrackingScreen(ride: ride)),
                          );
                        }
                      : (ride.availableSeats > 0 ? _bookRide : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUserPassenger ? const Color(0xFFD97706) : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isUserPassenger ? 'Track Live' : 'Book $_selectedSeats ${_selectedSeats > 1 ? "Seats" : "Seat"}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(Ride ride) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Route Waypoints & Stops',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ride.detourNotice,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route Stops List
          if (ride.stops.isNotEmpty)
            ...ride.stops.asMap().entries.map((entry) {
              final idx = entry.key;
              final stop = entry.value;
              final isLast = idx == ride.stops.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: stop.isPickup
                              ? const Color(0xFF111827)
                              : (stop.isDropoff ? const Color(0xFFD97706) : const Color(0xFF9CA3AF)),
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 1.5,
                          height: 34,
                          color: const Color(0xFFE5E7EB),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Stop details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stop.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  stop.address,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              stop.expectedTime,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            })
          else
            const Text('Direct point-to-point carpool route.'),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Ride ride) {
    final driver = ride.driver;
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: driver.name,
                imageUrl: driver.avatarUrl,
                radius: 22,
                isVerified: driver.isVerified,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driver.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFFD97706)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '${driver.rating.toStringAsFixed(2)} • ${driver.totalRides} Carpools completed',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            driver.bio,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),

          // Vehicle Card
          if (driver.vehicle != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.electric_car_rounded, size: 20, color: Colors.black87),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driver.vehicle!.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Plate: ${driver.vehicle!.plateNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '-${ride.carbonSavedKg.toStringAsFixed(1)} kg CO₂',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPassengersSection(Ride ride) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Confirmed Co-passengers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                '${ride.passengers.length} riders',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (ride.passengers.isEmpty)
            const Text(
              'No other passengers yet. Be the first to join!',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            )
          else
            ...ride.passengers.map((p) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    UserAvatar(
                      name: p.user.name,
                      imageUrl: p.user.avatarUrl,
                      radius: 15,
                      isVerified: p.user.isVerified,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.user.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            'Pickup: ${p.pickupStop.split('(').first.trim()}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.hasPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.hasPaid ? 'PAID' : 'CONFIRMED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: p.hasPaid ? const Color(0xFF15803D) : const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(Ride ride) {
    final prefs = ride.preferences;
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Carpool Policies & Amenities',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAmenityChip(Icons.ac_unit, 'Air Conditioned', prefs.hasAC),
              _buildAmenityChip(Icons.pets, 'Pet Friendly', prefs.allowsPets),
              _buildAmenityChip(Icons.female, 'Women Only', prefs.isWomenOnly),
              _buildAmenityChip(Icons.flash_on, 'Instant Booking', prefs.instantBooking),
              _buildAmenityChip(Icons.luggage, 'Luggage: ${prefs.luggageCapacity.name.toUpperCase()}', true),
              _buildAmenityChip(Icons.smoke_free, 'No Smoking', !prefs.allowsSmoking),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label, bool active) {
    if (!active) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
