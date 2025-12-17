import 'package:flutter/material.dart';
import 'package:kebab_app/screens/cart_screen.dart';
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
        backgroundColor: const Color(0xFFFAFAFA), // Clean background
        appBar: AppBar(
          title: const Text(
            "Pesanan Saya",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFFFF7643),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFFFF7643),
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: "Berjalan"),
                  Tab(text: "Riwayat"),
                ],
              ),
            ),
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
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF2E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 60,
                color: Color(0xFFFF7643),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Belum ada pesanan",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pesanan kamu akan muncul di sini",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
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

    // --- LOGIC START ---
    final bool hasProof =
        order.paymentProof != null && order.paymentProof!.isNotEmpty;

    final bool isUnpaidQRIS =
        order.paymentMethod == 'QRIS' &&
        order.paymentStatus == 'unpaid' &&
        !hasProof;

    final bool isVerifying =
        order.paymentMethod == 'QRIS' &&
        order.paymentStatus == 'unpaid' &&
        hasProof &&
        order.status == 'pending';
    // --- LOGIC END ---

    return GestureDetector(
      onTap: () {
        if (isUnpaidQRIS) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentUploadScreen(
                orderId: order.id,
                total: order.grandTotal,
              ),
            ),
          ).then((_) {
            Provider.of<OrderProvider>(context, listen: false).fetchOrders();
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailScreen(order: order),
            ),
          ).then((_) {
            Provider.of<OrderProvider>(context, listen: false).fetchOrders();
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // 1. Header (Date & Status)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order.id}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(order.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isUnpaidQRIS
                          ? const Color(0xFFFFE6E6) // Red background
                          : (isVerifying
                                ? const Color(0xFFFFF4E5) // Orange background
                                : order.statusColor.withOpacity(0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUnpaidQRIS
                          ? "Belum Bayar"
                          : (isVerifying ? "Verifikasi" : order.statusText),
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnpaidQRIS
                            ? Colors.red
                            : (isVerifying ? Colors.orange : order.statusColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFF0F0F0)),

            // 2. Content (Image & Info)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (firstItem != null && firstItem.image.isNotEmpty)
                          ? Image.network(
                              firstItem.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 24,
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
                  const SizedBox(width: 16),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatRupiah(order.grandTotal), // Using helper
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFFFF7643),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Footer Action (Only if action is needed)
            if (isUnpaidQRIS)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentUploadScreen(
                            orderId: order.id,
                            total: order.grandTotal,
                          ),
                        ),
                      ).then((_) {
                        Provider.of<OrderProvider>(
                          context,
                          listen: false,
                        ).fetchOrders();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      "Upload Bukti Pembayaran",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
