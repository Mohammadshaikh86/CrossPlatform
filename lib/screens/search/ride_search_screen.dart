import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../widgets/ride/ride_card.dart';
import '../../widgets/ride/ride_filter_sheet.dart';
import '../ride_detail/ride_detail_screen.dart';

class RideSearchScreen extends StatefulWidget {
  const RideSearchScreen({super.key});

  @override
  State<RideSearchScreen> createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends State<RideSearchScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    final temp = _originController.text;
    _originController.text = _destController.text;
    _destController.text = temp;
    _applySearch();
  }

  void _applySearch() {
    final provider = Provider.of<RideProvider>(context, listen: false);
    provider.updateFilter(
      provider.currentFilter.copyWith(
        origin: _originController.text.trim(),
        destination: _destController.text.trim(),
        date: _selectedDate,
      ),
    );
  }

  void _openFiltersModal() {
    final provider = Provider.of<RideProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RideFilterSheet(
        initialCriteria: provider.currentFilter,
        onApply: (newCriteria) {
          provider.updateFilter(newCriteria);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final filteredRides = rideProvider.getFilteredRides();
    final filter = rideProvider.currentFilter;

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
              'Find a Carpool Match',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.black87),
            tooltip: 'Filter options',
            onPressed: _openFiltersModal,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              children: [
                // Origin & Destination Inputs with Swap button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: _originController,
                            onChanged: (_) => _applySearch(),
                            decoration: InputDecoration(
                              hintText: 'Pickup point (e.g. San Francisco)',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              prefixIcon: const Icon(Icons.radio_button_checked, size: 16, color: Colors.black87),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _destController,
                            onChanged: (_) => _applySearch(),
                            decoration: InputDecoration(
                              hintText: 'Drop-off point (e.g. Palo Alto)',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              prefixIcon: const Icon(Icons.location_on, size: 16, color: Color(0xFFD97706)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _swapLocations,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(Icons.swap_vert_rounded, color: Colors.black87, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quick Filter Tag Pills Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'Instant Book',
                        isSelected: filter.instantBooking,
                        onTap: () {
                          rideProvider.updateFilter(
                            filter.copyWith(instantBooking: !filter.instantBooking),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Women Only',
                        isSelected: filter.womenOnly,
                        onTap: () {
                          rideProvider.updateFilter(
                            filter.copyWith(womenOnly: !filter.womenOnly),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Pet Friendly',
                        isSelected: filter.allowsPets,
                        onTap: () {
                          rideProvider.updateFilter(
                            filter.copyWith(allowsPets: !filter.allowsPets),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Under \$15',
                        isSelected: filter.maxPrice <= 15.0,
                        onTap: () {
                          rideProvider.updateFilter(
                            filter.copyWith(maxPrice: filter.maxPrice <= 15.0 ? 80.0 : 15.0),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Results Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredRides.length} Available Carpool Matches',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  DateFormat('EEE, MMM d').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),

          // Matching Rides List View
          Expanded(
            child: filteredRides.isEmpty
                ? _buildEmptyState(rideProvider)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    itemCount: filteredRides.length,
                    itemBuilder: (context, index) {
                      final ride = filteredRides[index];
                      return RideCard(
                        ride: ride,
                        onTap: () {
                          rideProvider.selectRide(ride);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RideDetailScreen(ride: ride),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(RideProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Exact Carpool Matches Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try relaxing your detour tolerance or expanding the price range filters.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => provider.resetFilter(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Reset Search Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
