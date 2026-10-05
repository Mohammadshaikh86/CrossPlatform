import 'package:flutter/material.dart';
import '../../models/ride.dart';
import '../../theme/app_theme.dart';

class RideFilterSheet extends StatefulWidget {
  final RideFilterCriteria initialCriteria;
  final ValueChanged<RideFilterCriteria> onApply;

  const RideFilterSheet({
    super.key,
    required this.initialCriteria,
    required this.onApply,
  });

  @override
  State<RideFilterSheet> createState() => _RideFilterSheetState();
}

class _RideFilterSheetState extends State<RideFilterSheet> {
  late int _seats;
  late double _maxPrice;
  late bool _womenOnly;
  late bool _instantBooking;
  late bool _allowsPets;
  late bool _hasAC;
  late LuggageCapacity _luggage;
  late double _maxDetour;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    _seats = widget.initialCriteria.minSeats;
    _maxPrice = widget.initialCriteria.maxPrice;
    _womenOnly = widget.initialCriteria.womenOnly;
    _instantBooking = widget.initialCriteria.instantBooking;
    _allowsPets = widget.initialCriteria.allowsPets;
    _hasAC = widget.initialCriteria.hasAC;
    _luggage = widget.initialCriteria.luggageCapacity;
    _maxDetour = widget.initialCriteria.maxDetourMinutes;
    _minRating = widget.initialCriteria.minDriverRating;
  }

  void _reset() {
    setState(() {
      _seats = 1;
      _maxPrice = 60.0;
      _womenOnly = false;
      _instantBooking = false;
      _allowsPets = false;
      _hasAC = false;
      _luggage = LuggageCapacity.none;
      _maxDetour = 15.0;
      _minRating = 4.0;
    });
  }

  void _apply() {
    final criteria = widget.initialCriteria.copyWith(
      minSeats: _seats,
      maxPrice: _maxPrice,
      womenOnly: _womenOnly,
      instantBooking: _instantBooking,
      allowsPets: _allowsPets,
      hasAC: _hasAC,
      luggageCapacity: _luggage,
      maxDetourMinutes: _maxDetour,
      minDriverRating: _minRating,
    );
    widget.onApply(criteria);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.offWhiteSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.beigeDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Carpool Filter Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset All',
                    style: TextStyle(
                      color: AppColors.accentAmberDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Minimum Seats Count
            _buildSectionHeader('Number of Seats Needed'),
            Row(
              children: [1, 2, 3, 4].map((num) {
                final isSelected = _seats == num;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Center(
                        child: Text(
                          '$num ${num == 1 ? "seat" : "seats"}',
                          style: TextStyle(
                            color: isSelected ? AppColors.offWhiteSurface : AppColors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.black,
                      backgroundColor: AppColors.beigeLight,
                      onSelected: (selected) {
                        if (selected) setState(() => _seats = num);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),

            // Maximum Fare Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Max Price per Seat'),
                Text(
                  '\$${_maxPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.black,
                inactiveTrackColor: AppColors.beigeMedium,
                thumbColor: AppColors.accentAmber,
                overlayColor: AppColors.accentAmber.withOpacity(0.2),
              ),
              child: Slider(
                value: _maxPrice,
                min: 5.0,
                max: 100.0,
                divisions: 19,
                onChanged: (val) => setState(() => _maxPrice = val),
              ),
            ),
            const SizedBox(height: 14),

            // Luggage Size
            _buildSectionHeader('Luggage Allowance'),
            Wrap(
              spacing: 8,
              children: [
                _buildLuggageChip('Any / Handbag', LuggageCapacity.none),
                _buildLuggageChip('Small (Cabin)', LuggageCapacity.small),
                _buildLuggageChip('Medium (Suitcase)', LuggageCapacity.medium),
                _buildLuggageChip('Large (Bulk)', LuggageCapacity.large),
              ],
            ),
            const SizedBox(height: 18),

            // Detour Tolerance Slider
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('Max Detour Tolerance'),
                Text(
                  '${_maxDetour.toStringAsFixed(0)} mins',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentAmberDark,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.black,
                inactiveTrackColor: AppColors.beigeMedium,
                thumbColor: AppColors.black,
              ),
              child: Slider(
                value: _maxDetour,
                min: 0.0,
                max: 30.0,
                divisions: 6,
                onChanged: (val) => setState(() => _maxDetour = val),
              ),
            ),
            const SizedBox(height: 14),

            // Toggles
            _buildSwitchTile('Instant Booking Only', 'Book without waiting for driver approval', _instantBooking, (v) {
              setState(() => _instantBooking = v);
            }),
            _buildSwitchTile('Women-Only Carpool', 'Show verified female drivers & riders only', _womenOnly, (v) {
              setState(() => _womenOnly = v);
            }),
            _buildSwitchTile('Pet Friendly', 'Drivers welcoming cats & dogs in carriers', _allowsPets, (v) {
              setState(() => _allowsPets = v);
            }),
            _buildSwitchTile('Air Conditioning (A/C)', 'Climate controlled cabin verified', _hasAC, (v) {
              setState(() => _hasAC = v);
            }),

            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: AppColors.offWhiteSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.black,
        ),
      ),
    );
  }

  Widget _buildLuggageChip(String label, LuggageCapacity cap) {
    final isSelected = _luggage == cap;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.black,
      backgroundColor: AppColors.beigeLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.offWhiteSurface : AppColors.black,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _luggage = cap);
      },
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.beigeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.beigeBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.grayText,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.accentAmber,
            activeTrackColor: AppColors.black,
            inactiveTrackColor: AppColors.beigeDark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
