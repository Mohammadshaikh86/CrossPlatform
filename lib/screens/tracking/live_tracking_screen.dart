import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../providers/live_tracking_provider.dart';
import '../../widgets/common/user_avatar.dart';
import '../../widgets/map/route_map_view.dart';
import '../chat/ride_chat_screen.dart';
import '../fare_split/fare_split_screen.dart';

class LiveTrackingScreen extends StatelessWidget {
  final Ride ride;

  const LiveTrackingScreen({super.key, required this.ride});

  void _showSosDialog(BuildContext context, LiveTrackingProvider tracking) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 26),
              SizedBox(width: 8),
              Text(
                'Emergency SOS Mode',
                style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF111827), fontSize: 17),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Activating SOS will immediately broadcast your real-time vehicle GPS coordinates to emergency dispatch services and your designated emergency contacts.',
                style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, color: Color(0xFFDC2626), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${tracking.currentStreet}\nLat: 37.5407, Long: -122.2982',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFB91C1C)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF4B5563))),
            ),
            ElevatedButton(
              onPressed: () {
                tracking.toggleSos();
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🚨 Emergency SOS dispatched! Safety monitor alerted.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Confirm SOS Alert', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showShareLinkDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.share_location_rounded, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Share Live Journey',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Anyone with this link can track your carpool progress in real-time on a live browser map:',
                style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        link,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy, size: 16, color: Colors.black87),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🔗 Live tracking link copied to clipboard!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Copy Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = Provider.of<LiveTrackingProvider>(context);
    final vehiclePos = tracking.getCurrentVehiclePosition(ride);
    final vehicleHeading = tracking.getVehicleHeadingAngle(ride);

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Live Journey Navigation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                  Text(
                    '${ride.originName.split('(').first.trim()} ➔ ${ride.destinationName.split('(').first.trim()}',
                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_location_rounded, color: Colors.black87),
            tooltip: 'Share Live Link',
            onPressed: () => _showShareLinkDialog(context, tracking.shareableLink),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.black87),
            tooltip: 'Chat with Carpool',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RideChatScreen(ride: ride)),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Turn-by-Turn Instruction Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.turn_slight_right, size: 20, color: Color(0xFF92400E)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'In 800m, keep right on ${tracking.currentStreet}',
                        style: const TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        tracking.nextStopNotice,
                        style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text('LIVE GPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Interactive Vector Map View
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                RouteMapView(
                  ride: ride,
                  vehiclePosition: vehiclePos,
                  vehicleHeadingAngle: vehicleHeading,
                  height: double.infinity,
                  isInteractive: true,
                ),

                // Floating Telemetry HUD Pill
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.96),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed_rounded, size: 15, color: Colors.black87),
                        const SizedBox(width: 5),
                        Text(
                          '${tracking.currentSpeedKmh.toStringAsFixed(0)} km/h',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 12, color: const Color(0xFFD1D5DB)),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined, size: 15, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(
                          '${tracking.remainingMinutes} min ETA',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD97706),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Red SOS Button Floating
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'sos_btn',
                    onPressed: () => _showSosDialog(context, tracking),
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.emergency, size: 16),
                    label: const Text('SOS Safety', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Telemetry & Controls
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Driver & Vehicle banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                              name: ride.driver.name,
                              imageUrl: ride.driver.avatarUrl,
                              radius: 17,
                              isVerified: ride.driver.isVerified,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.driver.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
                                ),
                                Text(
                                  '${ride.driver.vehicle?.displayName ?? "Tesla"} • ${ride.driver.vehicle?.plateNumber ?? "RSX-8902"}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Split Fare Button Shortcut
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FareSplitScreen(ride: ride)),
                            );
                          },
                          icon: const Icon(Icons.receipt_long, size: 13),
                          label: const Text('Split Fare', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Route Progress Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Route Progress: ${(tracking.progress * 100).toInt()}%',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                        ),
                        Text(
                          '${tracking.remainingKm} km remaining',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.black,
                        inactiveTrackColor: const Color(0xFFE5E7EB),
                        thumbColor: const Color(0xFFD97706),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: tracking.progress,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (val) => tracking.updateProgressManual(val),
                      ),
                    ),

                    // Simulation Controls (Play/Pause, Speed 1x, 2x, 4x, Reset)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: () => tracking.toggleSimulation(),
                              icon: Icon(tracking.isSimulating ? Icons.pause : Icons.play_arrow, size: 16),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () => tracking.resetSimulation(),
                              icon: const Icon(Icons.replay_rounded, size: 16),
                              tooltip: 'Reset simulation',
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFF3F4F6),
                              ),
                            ),
                          ],
                        ),
                        // Speed multiplier pills
                        Row(
                          children: [1, 2, 4].map((spd) {
                            final isSel = tracking.speedMultiplier == spd;
                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text('${spd}x'),
                                selected: isSel,
                                selectedColor: Colors.black,
                                backgroundColor: const Color(0xFFF3F4F6),
                                labelStyle: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : const Color(0xFF374151),
                                ),
                                onSelected: (sel) {
                                  if (sel) tracking.setSpeedMultiplier(spd);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
