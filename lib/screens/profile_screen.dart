import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'sign_in_screen.dart';
import 'address_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9), // Light Grey Background
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          // --- GUEST STATE ---
          if (!auth.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.05),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 60,
                      color: Colors.orange.shade300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Anda belum login",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Login untuk akses fitur lengkap",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, SignInScreen.routeName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      "Login / Register",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          // --- LOGGED IN STATE ---
          final user = auth.user;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const ProfilePic(),
                const SizedBox(height: 15),

                // ✅ NAME Display
                Text(
                  user?.name ?? "Loading...", // Shows "Loading..." or Name
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // ✅ EMAIL Display
                Text(
                  user?.email ?? "",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                // Section 1: Account
                _buildSectionHeader("AKUN SAYA"),
                ProfileMenu(
                  text: "Edit Profil",
                  icon: Icons.person_outline,
                  press: () {}, // TODO: Edit Profile Screen
                ),
                ProfileMenu(
                  text: "Alamat Pengiriman",
                  icon: Icons.location_on_outlined,
                  press: () =>
                      Navigator.pushNamed(context, AddressScreen.routeName),
                ),

                const SizedBox(height: 10),

                // Section 2: General
                _buildSectionHeader("UMUM"),
                ProfileMenu(
                  text: "Notifikasi",
                  icon: Icons.notifications_none,
                  press: () {},
                ),
                ProfileMenu(
                  text: "Bantuan & Dukungan",
                  icon: Icons.help_outline,
                  press: () {},
                ),

                const SizedBox(height: 20),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      backgroundColor: const Color(0xFFFFE6E6), // Light Red
                    ),
                    onPressed: () async {
                      await auth.logout();
                      // Consumer will rebuild UI automatically
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 20),
                        const Expanded(
                          child: Text(
                            "Keluar Akun",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Versi Aplikasi 1.0.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    // Logic for Initials
    String initials = "U";
    if (user != null && user.name.isNotEmpty) {
      List<String> names = user.name.trim().split(" ");
      if (names.length >= 2) {
        initials = "${names[0][0]}${names[1][0]}".toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    }

    return SizedBox(
      height: 110,
      width: 110,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF7643),
                  Color(0xFFFFAB76),
                ], // Nice Orange Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7643).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            right: -4,
            bottom: 0,
            child: Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 18, color: Colors.black87),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
  });

  final String text;
  final IconData icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: press,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFFFF7643), size: 22),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
