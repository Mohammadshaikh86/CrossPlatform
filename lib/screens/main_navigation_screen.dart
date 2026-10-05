import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ride.dart';
import '../../providers/ride_provider.dart';
import '../../theme/app_theme.dart';
import 'dashboard/dashboard_screen.dart';
import 'post_ride/post_ride_screen.dart';
import 'profile/profile_screen.dart';
import 'search/ride_search_screen.dart';
import 'tracking/live_tracking_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = Provider.of<RideProvider>(context);
    final activeRide = rideProvider.activeRide;

    final List<Widget> pages = [
      DashboardScreen(onNavigateTab: _onTabChanged),
      const RideSearchScreen(),
      PostRideScreen(onRidePublished: () => _onTabChanged(0)),
      activeRide != null
          ? LiveTrackingScreen(ride: activeRide)
          : const Center(child: Text('No active carpool currently.')),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.offWhiteSurface,
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.grayText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            activeIcon: Icon(Icons.search_rounded),
            label: 'Matches',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline_rounded),
            activeIcon: Icon(Icons.add_circle_rounded),
            label: 'Host Ride',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation_outlined),
            activeIcon: Icon(Icons.navigation_rounded),
            label: 'Live GPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
