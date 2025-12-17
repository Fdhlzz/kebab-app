import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Screens
import 'home_screen.dart';
import 'order/order_screen.dart';
import 'profile_screen.dart';

// Constants
const Color inActiveIconColor = Color(0xFFB6B6B6);
const Color activeIconColor = Color(0xFFFF7643);

class MainNavScreen extends StatefulWidget {
  static String routeName = "/main_nav";
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final isUserLoggedIn = auth.isAuthenticated;

        final List<Widget> pages = [
          const HomeScreen(),
          if (isUserLoggedIn) const OrderScreen(),
          const ProfileScreen(),
        ];

        // Safety check
        if (_currentIndex >= pages.length) {
          _currentIndex = 0;
        }

        return Scaffold(
          body: pages[_currentIndex],

          // ✅ CUSTOM NAVBAR IMPLEMENTATION
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30), // Rounded corners for modern look
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -5),
                  blurRadius: 20,
                  color: const Color(
                    0xFFDADADA,
                  ).withOpacity(0.25), // Softer, deeper shadow
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                // ✅ KEY CHANGE: Increased padding here makes the navbar taller
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: AppIcons.homeIcon,
                      label: "Home",
                    ),
                    if (isUserLoggedIn)
                      _buildNavItem(
                        index: 1,
                        icon: AppIcons.receiptIcon,
                        label: "Pesanan",
                      ),
                    _buildNavItem(
                      index: isUserLoggedIn ? 2 : 1,
                      icon: AppIcons.userIcon,
                      label: "Akun",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
  }) {
    final bool isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque, // Ensures the whole area is clickable
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeIconColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            SvgPicture.string(
              icon,
              colorFilter: ColorFilter.mode(
                isActive ? activeIconColor : inActiveIconColor,
                BlendMode.srcIn,
              ),
              height: 24, // Slightly larger icons
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: activeIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Readable text size
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- Icons Class ---
class AppIcons {
  static const homeIcon =
      '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M9.5 3.5L3 8.5V20.5H9V14.5H15V20.5H21V8.5L14.5 3.5H9.5Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>''';

  static const receiptIcon =
      '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M4 2V22L8 19L12 22L16 19L20 22V2L16 5L12 2L8 5L4 2Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M8 10H16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M8 14H16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>''';

  static const userIcon =
      '''<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M20 21V19C20 17.9391 19.5786 16.9217 18.8284 16.1716C18.0783 15.4214 17.0609 15 16 15H8C6.93913 15 5.92172 15.4214 5.17157 16.1716C4.42143 16.9217 4 17.9391 4 19V21" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/><path d="M12 11C14.2091 11 16 9.20914 16 7C16 4.79086 14.2091 3 12 3C9.79086 3 8 4.79086 8 7C8 9.20914 9.79086 11 12 11Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>''';
}
