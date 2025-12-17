import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  static String routeName = "/help_support";
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Bantuan & Dukungan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hubungi Kami",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildContactCard(
                  icon: Icons.headset_mic_rounded,
                  title: "CS 24/7",
                  color: Colors.blue,
                  onTap: () {
                    // Logic to open Live Chat
                  },
                ),
                const SizedBox(width: 15),
                _buildContactCard(
                  icon: Icons.email_rounded,
                  title: "Email",
                  color: Colors.redAccent,
                  onTap: () {
                    // Logic to open Email app
                  },
                ),
                const SizedBox(width: 15),
                _buildContactCard(
                  icon: Icons.chat_bubble_rounded,
                  title: "WhatsApp",
                  color: Colors.green,
                  onTap: () {
                    // Logic to open WhatsApp
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            const Text(
              "Pertanyaan Umum (FAQ)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            _buildFaqItem(
              "Bagaimana cara melacak pesanan?",
              "Anda dapat melacak pesanan melalui menu 'Pesanan' di navigasi bawah. Klik kartu pesanan untuk melihat detail status terkini.",
            ),
            _buildFaqItem(
              "Metode pembayaran apa saja yang tersedia?",
              "Kami mendukung pembayaran tunai (COD) dan QRIS/Transfer Bank. Bukti transfer wajib diupload untuk verifikasi.",
            ),
            _buildFaqItem(
              "Apakah bisa membatalkan pesanan?",
              "Pesanan hanya bisa dibatalkan jika statusnya masih 'Pending'. Jika sudah 'Sedang Dibuat', pesanan tidak dapat dibatalkan.",
            ),
            _buildFaqItem(
              "Berapa lama pengiriman makanan?",
              "Estimasi pengiriman tergantung jarak. Rata-rata waktu pengiriman adalah 30-45 menit setelah makanan selesai dibuat.",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          iconColor: const Color(0xFFFF7643),
          children: [
            Text(
              answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
