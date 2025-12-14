import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../utils/constants.dart'; // Ensure you have this for image URLs

class OrderDetailScreen extends StatelessWidget {
  static String routeName = "/order_detail";

  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text(
          "Detail Pesanan",
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
          children: [
            // 1. HEADER STATUS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    "Order ID: ${order.orderNumber}",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    order.statusText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: order.statusColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    order.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. SHIPPING ADDRESS
            _buildSection(
              title: "Alamat Pengiriman",
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Color(0xFFFF7643),
                    size: 24,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      // Assuming your API provides a full address string
                      // If you stored it as JSON, you might need to parse it in the Model
                      "Detail Alamat tersedia di backend",
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. ORDER ITEMS
            _buildSection(
              title: "Daftar Menu",
              child: Column(
                children: order.items.map((item) {
                  String? imageUrl;
                  if (item.image != null) {
                    imageUrl = item.image!.startsWith('http')
                        ? item.image
                        : '${AppConstants.storageUrl}/${item.image}';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade100,
                            image: imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(imageUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: imageUrl == null
                              ? const Icon(
                                  Icons.fastfood,
                                  size: 20,
                                  color: Colors.orange,
                                )
                              : null,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "x${item.quantity}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Rp${(item.price * item.quantity).toStringAsFixed(0)}",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // 4. PAYMENT SUMMARY
            _buildSection(
              title: "Rincian Pembayaran",
              child: Column(
                children: [
                  _summaryRow("Subtotal", order.totalPrice),
                  const SizedBox(height: 10),
                  _summaryRow("Ongkos Kirim", order.shippingCost),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Bayar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Rp${order.grandTotal.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFFFF7643),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ACTION BUTTON (Optional based on status)
            if (order.status == 'on_delivery')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Chat Courier Logic?
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7643),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: const Text(
                    "Lacak Pesanan",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const Divider(height: 25),
          child,
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          "Rp${value.toStringAsFixed(0)}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
