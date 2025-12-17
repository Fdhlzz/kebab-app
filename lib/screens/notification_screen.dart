import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatelessWidget {
  static String routeName = "/notifications";
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for UI Demo
    final List<Map<String, dynamic>> notifications = [
      {
        "title": "Pesanan Sedang Diantar!",
        "body": "Kurir sedang menuju ke lokasimu. Siapkan uang pas ya!",
        "time": DateTime.now().subtract(const Duration(minutes: 5)),
        "type": "order", // order, promo, info
        "isRead": false,
      },
      {
        "title": "Diskon 50% Hari Ini!",
        "body": "Khusus pembelian Kebab Jumbo. Buruan sikat sebelum kehabisan.",
        "time": DateTime.now().subtract(const Duration(hours: 2)),
        "type": "promo",
        "isRead": true,
      },
      {
        "title": "Pesanan Selesai",
        "body": "Terima kasih sudah memesan. Jangan lupa beri rating ya!",
        "time": DateTime.now().subtract(const Duration(days: 1)),
        "type": "order",
        "isRead": true,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
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
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                return _buildNotificationCard(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    final bool isRead = data['isRead'];
    final String type = data['type'];

    // Icon & Color Logic based on type
    IconData icon;
    Color color;
    if (type == 'order') {
      icon = Icons.local_shipping_outlined;
      color = const Color(0xFFFF7643); // Orange
    } else if (type == 'promo') {
      icon = Icons.discount_outlined;
      color = Colors.purple;
    } else {
      icon = Icons.info_outline;
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : const Color(0xFFFFF9F5), // Highlight unread
        borderRadius: BorderRadius.circular(15),
        border: isRead
            ? Border.all(color: Colors.transparent)
            : Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isRead ? Colors.black87 : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatTime(data['time']),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  data['body'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: Color(0xFFFF7643),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Belum ada notifikasi",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Info promo dan status pesanan\nakan muncul di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes}m lalu";
    } else if (diff.inHours < 24) {
      return "${diff.inHours}j lalu";
    } else {
      return DateFormat('dd MMM').format(time);
    }
  }
}
