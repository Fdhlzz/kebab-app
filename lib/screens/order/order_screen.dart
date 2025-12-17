import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';
import '../payment_upload_screen.dart';

class OrderScreen extends StatefulWidget {
  static String routeName = "/orders";
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F9),
        appBar: AppBar(
          title: const Text(
            "Pesanan Saya",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Color(0xFFFF7643),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFFFF7643),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: "Berjalan"),
              Tab(text: "Riwayat"),
            ],
          ),
        ),
        body: Consumer<OrderProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7643)),
              );
            }
            return TabBarView(
              children: [
                _buildOrderList(provider.activeOrders),
                _buildOrderList(provider.historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 60,
                color: Colors.orange.shade200,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Tidak ada pesanan",
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 15),
      itemBuilder: (context, index) => OrderCard(order: orders[index]),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items[0] : null;

    // --- ✅ UPDATED LOGIC START ---

    // 1. Has Proof?
    final bool hasProof =
        order.paymentProof != null && order.paymentProof!.isNotEmpty;

    // 2. Action Needed: QRIS + Unpaid + NO Proof
    final bool isUnpaidQRIS =
        order.paymentMethod == 'QRIS' &&
        order.paymentStatus == 'unpaid' &&
        !hasProof;

    // 3. Waiting: QRIS + Unpaid + HAS Proof + Status is STILL Pending
    // Only show "Verifying" if Admin hasn't touched it yet (status == pending)
    final bool isVerifying =
        order.paymentMethod == 'QRIS' &&
        order.paymentStatus == 'unpaid' &&
        hasProof &&
        order.status == 'pending';

    // --- LOGIC END ---

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        ).then((_) {
          // Optional: Refresh list when coming back from detail
          Provider.of<OrderProvider>(context, listen: false).fetchOrders();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF909090).withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    // Color Logic: Red (Unpaid), Orange (Verifying), or Default Status Color
                    color: isUnpaidQRIS
                        ? Colors.red.withOpacity(0.1)
                        : (isVerifying
                              ? Colors.orange.withOpacity(0.1)
                              : order.statusColor.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Text Logic: "Belum Dibayar", "Menunggu Verifikasi", or "Sedang Disiapkan/Diantar"
                    isUnpaidQRIS
                        ? "Belum Dibayar"
                        : (isVerifying
                              ? "Menunggu Verifikasi"
                              : order.statusText),
                    style: TextStyle(
                      fontSize: 12,
                      // Text Color Logic
                      color: isUnpaidQRIS
                          ? Colors.red
                          : (isVerifying ? Colors.orange : order.statusColor),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(order.date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF0F0F0)),
            ),

            // 2. Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: (firstItem != null && firstItem.image.isNotEmpty)
                        ? Image.network(
                            firstItem.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Icons.fastfood, color: Colors.orange),
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?.productName ?? "Pesanan",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.items.length > 1
                            ? "${firstItem?.quantity} item + ${order.items.length - 1} lainnya"
                            : "${firstItem?.quantity} item",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // 3. Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Belanja",
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Rp${order.grandTotal.toStringAsFixed(0)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                // Button Logic
                ElevatedButton(
                  onPressed: () {
                    // Only go to Upload screen if strictly Unpaid AND No Proof
                    if (isUnpaidQRIS) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentUploadScreen(
                            orderId: order.id,
                            total: order.grandTotal,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
                        ),
                      ).then((_) {
                        // Refresh when returning from detail to keep list synced
                        Provider.of<OrderProvider>(
                          context,
                          listen: false,
                        ).fetchOrders();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnpaidQRIS
                        ? const Color(0xFFFF7643)
                        : Colors.white,
                    foregroundColor: isUnpaidQRIS
                        ? Colors.white
                        : const Color(0xFFFF7643),
                    side: BorderSide(
                      color: isUnpaidQRIS
                          ? Colors.transparent
                          : const Color(0xFFFF7643),
                    ),
                    elevation: isUnpaidQRIS ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    isUnpaidQRIS ? "Upload Bukti" : "Lihat Detail",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
