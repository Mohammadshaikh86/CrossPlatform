import 'package:flutter/material.dart';
import '../../models/ride.dart';
import '../../theme/app_theme.dart';

class SeatSelectorWidget extends StatelessWidget {
  final Ride ride;
  final int selectedSeatsCount;
  final ValueChanged<int> onSeatsChanged;

  const SeatSelectorWidget({
    super.key,
    required this.ride,
    required this.selectedSeatsCount,
    required this.onSeatsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beigeLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.beigeBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vehicle Cabin & Seat Layout',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.offWhiteSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.beigeBorder),
                ),
                child: Text(
                  '${ride.availableSeats} of ${ride.totalSeats} seats open',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentAmberDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual Car Interior Graphic
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.offWhiteSurface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.beigeBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Windshield curve
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.beigeMedium,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    child: const Center(
                      child: Text(
                        'Front Windshield',
                        style: TextStyle(fontSize: 8, color: AppColors.grayText, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Front Row: Driver Seat & Front Passenger Seat
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSeatItem(
                        label: 'Driver',
                        subtext: ride.driver.name.split(' ').first,
                        isDriver: true,
                        isBooked: true,
                        isSelected: false,
                        onTap: null,
                      ),
                      _buildSeatItem(
                        label: 'Front Co-pilot',
                        subtext: ride.availableSeats >= 1 ? 'Available' : 'Booked',
                        isDriver: false,
                        isBooked: ride.availableSeats < 1,
                        isSelected: selectedSeatsCount >= 1,
                        onTap: ride.availableSeats >= 1
                            ? () => onSeatsChanged(selectedSeatsCount == 1 ? 0 : 1)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rear Row: Back Left & Back Right Seats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSeatItem(
                        label: 'Rear Left',
                        subtext: ride.availableSeats >= 2 ? 'Available' : 'Occupied',
                        isDriver: false,
                        isBooked: ride.availableSeats < 2,
                        isSelected: selectedSeatsCount >= 2,
                        onTap: ride.availableSeats >= 2
                            ? () => onSeatsChanged(selectedSeatsCount == 2 ? 1 : 2)
                            : null,
                      ),
                      _buildSeatItem(
                        label: 'Rear Right',
                        subtext: ride.availableSeats >= 3 ? 'Available' : 'Occupied',
                        isDriver: false,
                        isBooked: ride.availableSeats < 3,
                        isSelected: selectedSeatsCount >= 3,
                        onTap: ride.availableSeats >= 3
                            ? () => onSeatsChanged(selectedSeatsCount == 3 ? 2 : 3)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(AppColors.black, 'Selected'),
              const SizedBox(width: 14),
              _buildLegendDot(AppColors.accentAmber, 'Driver'),
              const SizedBox(width: 14),
              _buildLegendDot(AppColors.beigeMedium, 'Available'),
              const SizedBox(width: 14),
              _buildLegendDot(AppColors.grayLight, 'Occupied'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatItem({
    required String label,
    required String subtext,
    required bool isDriver,
    required bool isBooked,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    Color bgColor;
    Color iconColor;
    Color borderColor;

    if (isSelected) {
      bgColor = AppColors.black;
      iconColor = AppColors.offWhiteSurface;
      borderColor = AppColors.black;
    } else if (isDriver) {
      bgColor = AppColors.accentAmberSoft;
      iconColor = AppColors.accentAmberDark;
      borderColor = AppColors.accentAmber;
    } else if (isBooked) {
      bgColor = AppColors.beigeDark.withOpacity(0.5);
      iconColor = AppColors.grayText;
      borderColor = AppColors.beigeDark;
    } else {
      bgColor = AppColors.beigeLight;
      iconColor = AppColors.black;
      borderColor = AppColors.beigeBorder;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Column(
          children: [
            Icon(
              isDriver ? Icons.airline_seat_recline_extra : Icons.airline_seat_recline_normal,
              size: 24,
              color: iconColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.offWhiteSurface : AppColors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtext,
              style: TextStyle(
                fontSize: 8,
                color: isSelected ? AppColors.beigeMedium : AppColors.grayText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.grayText),
        ),
      ],
    );
  }
}
