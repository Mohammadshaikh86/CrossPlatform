import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/location_point.dart';
import '../../models/ride.dart';
import '../../models/user.dart';
import '../../providers/ride_provider.dart';

class PostRideScreen extends StatefulWidget {
  final VoidCallback? onRidePublished;

  const PostRideScreen({super.key, this.onRidePublished});

  @override
  State<PostRideScreen> createState() => _PostRideScreenState();
}

class _PostRideScreenState extends State<PostRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _originCtrl = TextEditingController(text: 'San Francisco (Market St & 5th)');
  final TextEditingController _destCtrl = TextEditingController(text: 'San Jose Downtown (SAP Center)');
  final TextEditingController _priceCtrl = TextEditingController(text: '16.00');

  DateTime _departureDate = DateTime.now().add(const Duration(hours: 3));
  TimeOfDay _departureTime = const TimeOfDay(hour: 9, minute: 0);
  int _availableSeats = 3;
  bool _allowsPets = false;
  bool _allowsSmoking = false;
  bool _hasAC = true;
  bool _isWomenOnly = false;
  bool _instantBooking = true;
  LuggageCapacity _luggage = LuggageCapacity.medium;
  final List<String> _stops = ['San Mateo Hillsdale', 'Palo Alto Caltrain'];

  @override
  void dispose() {
    _originCtrl.dispose();
    _destCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _addStop() {
    showDialog(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Add Route Waypoint / Stop', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              hintText: 'e.g. Redwood City Caltrain',
              prefixIcon: const Icon(Icons.add_location_outlined, size: 18),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFF4B5563)))),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setState(() => _stops.add(ctrl.text.trim()));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Stop', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _publishRide() {
    if (!_formKey.currentState!.validate()) return;

    final price = double.tryParse(_priceCtrl.text) ?? 15.0;
    final departureDateTime = DateTime(
      _departureDate.year,
      _departureDate.month,
      _departureDate.day,
      _departureTime.hour,
      _departureTime.minute,
    );

    final newRide = Ride(
      id: 'ride_${DateTime.now().millisecondsSinceEpoch}',
      driver: User.currentUser,
      originName: _originCtrl.text.trim(),
      originAddress: _originCtrl.text.trim(),
      originCoords: const GeoPoint(latitude: 37.7897, longitude: -122.3972, title: 'Origin'),
      destinationName: _destCtrl.text.trim(),
      destinationAddress: _destCtrl.text.trim(),
      destinationCoords: const GeoPoint(latitude: 37.3382, longitude: -121.8863, title: 'Destination'),
      departureTime: departureDateTime,
      estimatedArrivalTime: departureDateTime.add(const Duration(minutes: 55)),
      distanceKm: 68.0,
      estimatedDurationMinutes: 55,
      basePricePerSeat: price,
      totalSeats: _availableSeats + 1,
      availableSeats: _availableSeats,
      passengers: const [],
      stops: _stops.asMap().entries.map((entry) {
        return RouteStop(
          id: 'stop_${entry.key}',
          name: entry.value,
          address: entry.value,
          coordinates: const GeoPoint(latitude: 37.5407, longitude: -122.2982, title: 'Waypoint'),
          expectedTime: '09:30 AM',
          isPickup: true,
        );
      }).toList(),
      preferences: RidePreferences(
        allowsPets: _allowsPets,
        allowsSmoking: _allowsSmoking,
        hasAC: _hasAC,
        isWomenOnly: _isWomenOnly,
        instantBooking: _instantBooking,
        luggageCapacity: _luggage,
      ),
      status: RideStatus.scheduled,
      matchScore: 0.96,
      detourNotice: '+5 min detour',
      carbonSavedKg: 16.5,
    );

    Provider.of<RideProvider>(context, listen: false).addRide(newRide);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.check_circle, color: Color(0xFF16A34A), size: 24),
              SizedBox(width: 8),
              Text('Carpool Published!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your carpool from ${_originCtrl.text.split('(').first} to ${_destCtrl.text.split('(').first} has been listed on RideShareX.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
              const SizedBox(height: 12),
              Text(
                'Seats: $_availableSeats • Fare: \$$price/seat\nDeparture: ${DateFormat('EEE, MMM d • hh:mm a').format(departureDateTime)}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onRidePublished?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Go to Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Host a Carpool Ride',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_road_rounded, color: Color(0xFFD97706), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Offer Your Empty Car Seats',
                            style: TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Offset fuel & toll expenses while reducing commuter carbon emissions.',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Route Segment
              _buildSectionTitle('Carpool Route & Stops'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _originCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Please enter origin' : null,
                decoration: InputDecoration(
                  labelText: 'Origin Pickup Location',
                  labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.trip_origin, size: 16, color: Colors.black87),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _destCtrl,
                validator: (v) => v == null || v.isEmpty ? 'Please enter destination' : null,
                decoration: InputDecoration(
                  labelText: 'Destination Drop-off Location',
                  labelStyle: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  prefixIcon: const Icon(Icons.location_on, size: 16, color: Color(0xFFD97706)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                ),
              ),
              const SizedBox(height: 12),

              // Intermediate Stops Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Intermediate Waypoints:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                  TextButton.icon(
                    onPressed: _addStop,
                    icon: const Icon(Icons.add, size: 14, color: Color(0xFFD97706)),
                    label: const Text('Add Stop', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: _stops.map((stop) {
                  return Chip(
                    label: Text(stop, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () => setState(() => _stops.remove(stop)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Schedule & Pricing
              _buildSectionTitle('Schedule & Fare per Seat'),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Date Picker
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _departureDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) setState(() => _departureDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 15, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('MMM d, yyyy').format(_departureDate),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Time Picker
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _departureTime,
                        );
                        if (picked != null) setState(() => _departureTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 15, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              _departureTime.format(context),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  // Seats selector
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Seats', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _availableSeats,
                              isExpanded: true,
                              items: [1, 2, 3, 4].map((n) {
                                return DropdownMenuItem(
                                  value: n,
                                  child: Text('$n ${n == 1 ? "seat" : "seats"}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _availableSeats = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Price per seat
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fare Per Seat (\$)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF4B5563))),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _priceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          decoration: InputDecoration(
                            prefixText: '\$ ',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Amenities & Rules
              _buildSectionTitle('Passenger Rules & Perks'),
              const SizedBox(height: 10),
              _buildSwitchRow('Instant Booking', 'Passengers book without prior approval', _instantBooking, (v) {
                setState(() => _instantBooking = v);
              }),
              _buildSwitchRow('Women Only Carpool', 'For female drivers & female passengers', _isWomenOnly, (v) {
                setState(() => _isWomenOnly = v);
              }),
              _buildSwitchRow('Air Conditioning', 'Cabin temperature controlled', _hasAC, (v) {
                setState(() => _hasAC = v);
              }),
              _buildSwitchRow('Pet Friendly', 'Carrier pets allowed in car', _allowsPets, (v) {
                setState(() => _allowsPets = v);
              }),

              const SizedBox(height: 24),

              // Publish CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _publishRide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Publish Carpool Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Color(0xFF111827),
      ),
    );
  }

  Widget _buildSwitchRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFFD97706),
            activeTrackColor: Colors.black,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
