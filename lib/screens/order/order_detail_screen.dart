import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../payment_upload_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  static String routeName = "/order_detail";
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // --- STATE LOGIC ---
    bool hasProof =
        order.paymentProof != null && order.paymentProof!.isNotEmpty;
    bool isUnpaidQRIS =
        order.paymentMethod == 'QRIS' &&
        order.paymentStatus == 'unpaid' &&
        !hasProof;
    bool isVerifying = order.paymentStatus == 'unpaid' && hasProof;
    bool isPaid = order.paymentStatus == 'paid';
    // -------------------

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
            // 1. STATUS
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
                    DateFormat('dd MMM yyyy, HH:mm').format(order.date),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. PAYMENT INFO SECTION
            _buildSection(
              title: "Informasi Pembayaran",
              child: Column(
                children: [
                  _summaryRowText(
                    "Metode",
                    order.paymentMethod == 'COD'
                        ? "Bayar di Tempat (COD)"
                        : "QRIS / Transfer",
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Status Bayar",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // Green (Paid) / Orange (Verifying) / Red (Unpaid)
                          color: isPaid
                              ? Colors.green.shade50
                              : (isVerifying
                                    ? Colors.orange.shade50
                                    : Colors.red.shade50),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPaid
                                ? Colors.green
                                : (isVerifying ? Colors.orange : Colors.red),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          isPaid
                              ? "LUNAS"
                              : (isVerifying
                                    ? "MENUNGGU VERIFIKASI"
                                    : "BELUM LUNAS"),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPaid
                                ? Colors.green
                                : (isVerifying ? Colors.orange : Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ACTION: Upload Button if Unpaid QRIS (No proof yet)
                  if (isUnpaidQRIS) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentUploadScreen(
                                orderId: order.id,
                                total: order.grandTotal,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Upload Bukti Transfer",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7643),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],

                  // INFO: Show Proof if already uploaded
                  if (hasProof) ...[
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Bukti Transfer:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.paymentProof!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, _) => Container(
                          height: 50,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: const Text(
                            "Gagal memuat gambar",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    if (isVerifying)
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          "Menunggu verifikasi admin...",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. ADDRESS
            _buildSection(
              title: "Alamat Pengiriman",
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Color(0xFFFF7643),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      order.shippingAddress,
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. MENU ITEMS
            _buildSection(
              title: "Daftar Menu",
              child: Column(
                children: order.items.map((item) {
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
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item.image.isNotEmpty
                                ? Image.network(
                                    item.image,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.fastfood,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                  ),
                          ),
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

            // 5. SUMMARY
            _buildSection(
              title: "Rincian Biaya",
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
            color: Colors.grey.withOpacity(0.05),
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

  Widget _summaryRowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
